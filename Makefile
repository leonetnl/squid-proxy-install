src = $(wildcard *.c)
obj = $(src:.c=.o)

LDFLAGS = -lpng -lz -lm

myprog: $(obj)
	$(CC) -o $@ $^ 

.PHONY: clean
clean:
	rm -f $(obj) myprog