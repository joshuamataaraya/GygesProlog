NAME = Chess

all: clean
	gcc chessGUI.c `pkg-config --cflags --libs gtk+-2.0` -o $(NAME)

clean:
	-rm -f $(NAME)
