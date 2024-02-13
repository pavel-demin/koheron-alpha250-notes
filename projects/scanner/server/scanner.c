#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>
#include <unistd.h>
#include <fcntl.h>
#include <math.h>
#include <sys/mman.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>

int main()
{
  int fd, sock_server, sock_client;
  struct sockaddr_in addr;
  int n, m, counter, position, size, yes = 1;
  uint8_t *buffer0, *buffer1;
  uint32_t *coordinates, code, data;
  uint64_t command;
  volatile void *cfg, *sts;
  volatile uint8_t *cfg8;
  volatile uint16_t *cfg16, *rd_cntr, *wr_cntr;
  volatile uint32_t *cfg32, *fifo0, *fifo1;

  size = 0;
  coordinates = malloc(4194304);
  buffer0 = malloc(58720256);
  buffer1 = malloc(58720256);

  if((fd = open("/dev/mem", O_RDWR)) < 0)
  {
    perror("open");
    return EXIT_FAILURE;
  }

  cfg = mmap(NULL, sysconf(_SC_PAGESIZE), PROT_READ|PROT_WRITE, MAP_SHARED, fd, 0x40000000);
  sts = mmap(NULL, sysconf(_SC_PAGESIZE), PROT_READ|PROT_WRITE, MAP_SHARED, fd, 0x41000000);
  fifo0 = mmap(NULL, 28*sysconf(_SC_PAGESIZE), PROT_READ|PROT_WRITE, MAP_SHARED, fd, 0x42000000);
  fifo1 = mmap(NULL, 28*sysconf(_SC_PAGESIZE), PROT_READ|PROT_WRITE, MAP_SHARED, fd, 0x43000000);

  wr_cntr = (uint16_t *)(sts + 0);
  rd_cntr = (uint16_t *)(sts + 2);

  cfg8 = (uint8_t *)(cfg + 0);
  cfg16 = (uint16_t *)(cfg + 0);
  cfg32 = (uint32_t *)(cfg + 0);

  /* stop scan */
  cfg8[0] &= ~15;

  /* set scan rate */
  cfg32[1] = 25000 - 1;

  /* set sample rate */
  cfg16[1] = 100;

  /* set frequency */
  cfg32[2] = (uint32_t)floor(10000000 / 250.0e6 * (1<<30) + 0.5);
  cfg32[3] = (uint32_t)floor(10000000 / 250.0e6 * (1<<30) + 0.5);
  cfg32[4] = (uint32_t)floor(10000000 / 250.0e6 * (1<<30) + 0.5);
  cfg32[5] = (uint32_t)floor(10000000 / 250.0e6 * (1<<30) + 0.5);
  cfg32[6] = (uint32_t)floor(10000000 / 250.0e6 * (1<<30) + 0.5);
  cfg32[7] = (uint32_t)floor(10000000 / 250.0e6 * (1<<30) + 0.5);
  cfg32[8] = (uint32_t)floor(10000000 / 250.0e6 * (1<<30) + 0.5);

  /* set initial posisition */
  cfg8[0] |= 3;
  *fifo0 = 0x7fff7fff;
  usleep(500);
  cfg8[0] &= ~3;

  if((sock_server = socket(AF_INET, SOCK_STREAM, 0)) < 0)
  {
    perror("socket");
    return EXIT_FAILURE;
  }

  setsockopt(sock_server, SOL_SOCKET, SO_REUSEADDR, (void *)&yes , sizeof(yes));

  /* setup listening address */
  memset(&addr, 0, sizeof(addr));
  addr.sin_family = AF_INET;
  addr.sin_addr.s_addr = htonl(INADDR_ANY);
  addr.sin_port = htons(1001);

  if(bind(sock_server, (struct sockaddr *)&addr, sizeof(addr)) < 0)
  {
    perror("bind");
    return EXIT_FAILURE;
  }

  listen(sock_server, 1024);

  while(1)
  {
    if((sock_client = accept(sock_server, NULL, NULL)) < 0)
    {
      perror("accept");
      return EXIT_FAILURE;
    }

    while(1)
    {
      if(recv(sock_client, &command, 8, MSG_WAITALL) <= 0) break;
      code = command >> 32;
      data = command & 0xffffffff;
      switch(code)
      {
        case 0:
          /* set scan rate */
          cfg32[1] = data - 1;
          break;
        case 1:
          /* set sample rate */
          cfg16[1] = data;
          break;
        case 2:
          /* set frequency */
          cfg32[2] = (uint32_t)floor(data / 250.0e6 * (1<<30) + 0.5);
          break;
        case 3:
          /* set frequency */
          cfg32[3] = (uint32_t)floor(data / 250.0e6 * (1<<30) + 0.5);
          break;
        case 4:
          /* set frequency */
          cfg32[4] = (uint32_t)floor(data / 250.0e6 * (1<<30) + 0.5);
          break;
        case 5:
          /* set frequency */
          cfg32[5] = (uint32_t)floor(data / 250.0e6 * (1<<30) + 0.5);
          break;
        case 6:
          /* set frequency */
          cfg32[6] = (uint32_t)floor(data / 250.0e6 * (1<<30) + 0.5);
          break;
        case 7:
          /* set frequency */
          cfg32[7] = (uint32_t)floor(data / 250.0e6 * (1<<30) + 0.5);
          break;
        case 8:
          /* set frequency */
          cfg32[8] = (uint32_t)floor(data / 250.0e6 * (1<<30) + 0.5);
          break;
        case 9:
          /* clear coordinates */
          size = 0;
          break;
        case 10:
          /* add coordinates */
          if(size >= 1048576) continue;
          coordinates[size] = data;
          ++size;
          break;
        case 11:
          /* set position */
          cfg8[0] |= 3;
          *fifo0 = data;
          usleep(500);
          cfg8[0] &= ~3;
          break;
        case 12:
          /* scan */
          if(data > 1048576) continue;
          counter = 0;
          position = 0;
          n = 1024;
          m = 1024;

          /* enable FIFO buffers */
          cfg8[0] |= 9;

          while(counter < data || position < size)
          {
            /* read ADC samples */
            if(n > data - counter) n = data - counter;
            if(*rd_cntr < n) usleep(500);
            if(*rd_cntr >= n && counter < data)
            {
              memcpy(buffer0 + counter * 56, fifo0, n * 56);
              memcpy(buffer1 + counter * 56, fifo1, n * 56);
              counter += n;
            }

            /* write coordinates to DAC FIFO */
            if(m > size - position) m = size - position;
            if(*wr_cntr < m && position < size)
            {
              memcpy(fifo0, coordinates + position, m * 4);
              position += m;
            }

            /* start scan */
            cfg8[0] |= 6;
          }

          /* stop scan */
          cfg8[0] &= ~15;

          send(sock_client, buffer0, data * 56, MSG_NOSIGNAL);
          send(sock_client, buffer1, data * 56, MSG_NOSIGNAL);

          break;
      }
    }

    /* stop scan */
    cfg8[0] &= ~15;

    close(sock_client);
  }

  close(sock_server);

  return EXIT_SUCCESS;
}
