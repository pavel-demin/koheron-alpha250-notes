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
  uint8_t *buffer;
  uint32_t *coordinates, code, data;
  uint64_t command;
  volatile void *cfg, *sts;
  volatile uint8_t *cfg8;
  volatile uint16_t *cfg16, *rd_cntr, *wr_cntr;
  volatile uint32_t *cfg32, *fifo;

  size = 0;
  coordinates = malloc(4194304);
  buffer = malloc(33554432);

  if((fd = open("/dev/mem", O_RDWR)) < 0)
  {
    perror("open");
    return EXIT_FAILURE;
  }

  cfg = mmap(NULL, sysconf(_SC_PAGESIZE), PROT_READ|PROT_WRITE, MAP_SHARED, fd, 0x40000000);
  sts = mmap(NULL, sysconf(_SC_PAGESIZE), PROT_READ|PROT_WRITE, MAP_SHARED, fd, 0x41000000);
  fifo = mmap(NULL, 32*sysconf(_SC_PAGESIZE), PROT_READ|PROT_WRITE, MAP_SHARED, fd, 0x42000000);

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
  cfg32[3] = 0;
  cfg32[4] = (uint32_t)floor(10000000 / 250.0e6 * (1<<30) + 0.5);
  cfg32[5] = 0;
  cfg32[6] = (uint32_t)floor(10000000 / 250.0e6 * (1<<30) + 0.5);
  cfg32[7] = 0;
  cfg32[8] = (uint32_t)floor(10000000 / 250.0e6 * (1<<30) + 0.5);
  cfg32[9] = 0;

  /* set initial posisition */
  cfg8[0] |= 3;
  *fifo = 0x7fff7fff;
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
          cfg32[3] = data > 0 ? 0 : 1;
          break;
        case 3:
          /* set frequency */
          cfg32[4] = (uint32_t)floor(data / 250.0e6 * (1<<30) + 0.5);
          cfg32[5] = data > 0 ? 0 : 1;
          break;
        case 4:
          /* set frequency */
          cfg32[6] = (uint32_t)floor(data / 250.0e6 * (1<<30) + 0.5);
          cfg32[7] = data > 0 ? 0 : 1;
          break;
        case 5:
          /* set frequency */
          cfg32[8] = (uint32_t)floor(data / 250.0e6 * (1<<30) + 0.5);
          cfg32[9] = data > 0 ? 0 : 1;
          break;
        case 6:
          /* clear coordinates */
          size = 0;
          break;
        case 7:
          /* add coordinates */
          if(size >= 1048576) continue;
          coordinates[size] = data;
          ++size;
          break;
        case 8:
          /* set position */
          cfg8[0] |= 3;
          *fifo = data;
          usleep(500);
          cfg8[0] &= ~3;
          break;
        case 9:
          /* scan */
          counter = 0;
          position = 0;
          n = 2048;
          m = 2048;

          /* enable FIFO buffers */
          cfg8[0] |= 9;

          while(counter < data || position < size)
          {
            /* read ADC samples */
            if(n > data - counter) n = data - counter;
            if(*rd_cntr < n * 8) usleep(500);
            if(*rd_cntr >= n * 8 && counter < data)
            {
              memcpy(buffer + counter * 32, fifo, n * 32);
              counter += n;
            }

            /* write coordinates to DAC FIFO */
            if(m > size - position) m = size - position;
            if(*wr_cntr < m && position < size)
            {
              memcpy(fifo, coordinates + position, m * 4);
              position += m;
            }

            /* start scan */
            cfg8[0] |= 6;
          }

          /* stop scan */
          cfg8[0] &= ~15;

          send(sock_client, buffer, data * 32, MSG_NOSIGNAL);

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
