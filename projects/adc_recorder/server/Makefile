CFLAGS = -O3 -march=armv7-a -mtune=cortex-a9 -mfpu=neon -mfloat-abi=hard

all: adc-recorder

adc-recorder: adc-recorder.c
	gcc $(CFLAGS) -o $@ $^ -lm

clean:
	rm -f adc-recorder
