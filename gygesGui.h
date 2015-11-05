#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>

#include "gprolog.h"
#include <gtk/gtk.h>

#define BLANK 'e'

struct myPiece{
  char p;
  int pos;
};

char board[36];
static GtkWidget *window;
GtkWidget *layout;
GtkWidget *image;
GtkWidget *image2;
GtkWidget *button, *bMove, *delete; //butons
GtkEntry* entry;
char path[1024]; //img folder path
char tempPath[1024];
int gameOver = 0;
int nextPlayer=1; //could be 1 or 2
int pieceSelected = -1;
void addPiecesGui();
static void addLabels();
void createWindow();
void loadLayout();
void movePiece(int position);
void deletePiece();
void siguienteJugada();
static gboolean button_press_event(GtkWidget *widget, GdkEventButton *event );
void initboard();
void posibleMovements(struct myPiece res[]);
int isAvailable(int piece);
