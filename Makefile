CC = gplc
GTK_CFLAGS = $(shell pkg-config --cflags gtk+-2.0)
GTK_LIBS = $(shell pkg-config --libs gtk+-2.0)
OBJECTS = gygesGui.o gyges.o

all: gyges

gygesGui.o:
	$(CC) -c gygesGui.c -o gygesGui.o -C '$(GTK_CFLAGS)'

gyges.o:
	$(CC) -c gyges.pl -o gyges.o

gyges: $(OBJECTS)
	$(CC) $(OBJECTS) -o gyges -L '$(GTK_LIBS)'
	rm *.o
