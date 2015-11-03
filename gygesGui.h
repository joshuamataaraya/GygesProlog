#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>

#include "gprolog.h"
#include <gtk/gtk.h>

#define BLANK 'e'

char board[36];
static GtkWidget *window;
GtkWidget *layout;
GtkWidget *image;
GtkWidget *button, *bMove, *delete; //butons
GtkEntry* entry;
char path[1024]; //img folder path
char tempPath[1024];
int gameOver = 0;
int pieceSelected = 0;

void addPiecesGui();
static void addLabels();
void createWindow();
void loadLayout();
void move();
void deletePiece();
void siguienteJugada();
static gboolean button_press_event(GtkWidget *widget, GdkEventButton *event );
