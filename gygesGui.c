#include "gygesGui.h"
#include "gprolog.h"



//int initGui( int   argc, char *argv[] )
int main(int argc, char *argv[])
{

	initboard();

	//get running dir put in swd
   	getcwd(path, sizeof(path));
	strcat(path, "/img/");

  //LOAD GUI
	gtk_init(&argc, &argv);
   	createWindow();

	loadLayout();

  //close on exit
  g_signal_connect_swapped(G_OBJECT(window), "destroy",
      G_CALLBACK(gtk_main_quit), NULL);

	 gtk_signal_connect (GTK_OBJECT (window), "button_press_event",
             (GtkSignalFunc) button_press_event, NULL);

    gtk_main ();

    return 0;
}
void initboard(){
	WamWord arg[10];
	int nbSol, i; i = nbSol = 0;
	WamWord *sol;

	int argc;
	char *argv[0];
	Start_Prolog(argc, argv);
	Pl_Query_Begin(TRUE);

	arg[0]=Mk_Variable();
	Pl_Query_Call(Find_Atom("testBoard"), 1, arg); //this is to initialize the board

	PlTerm list = arg[0];
	char piece;
	for(i = 0; i< List_Length(arg[0]);i++){
		sol = Rd_List(list);
		piece = Rd_Char(*sol);
		if(piece != BLANK){
			piece += '0';
		}
		printf("%c\t%d\n",piece,i);
		board[i]=piece;
		list = sol[1];
	}
	Pl_Query_End(PL_RECOVER);
	Stop_Prolog();

}
void siguienteJugada(){

	//The player could be 1 or 2
	WamWord arg[10];
	int nbSol, i; i = nbSol = 0;
	WamWord *sol;


	PlTerm list = arg[0];
	char piece;
	int argc;
	char *argv[0];
	Start_Prolog(argc, argv);

	Pl_Query_Begin(TRUE);
	PlTerm list2[36];
	for(i=0; i<36;i++){
		list2[i] = board[i] == BLANK ?
			Mk_Char(board[i]) : Mk_Integer(board[i] - '0');
	}

	arg[0] = Mk_Variable();
	arg[1] = Mk_Number(nextPlayer);
	arg[2] = Mk_Variable();
	arg[3] = Mk_Proper_List(36,list2);
	Pl_Query_Call(Find_Atom("gyges"), 4, arg);

	list = arg[0];
	int length = List_Length(arg[0]);
	char res[length];
	printf("%d\n",length);
	for(i = 0; i< List_Length(arg[0]);i++){
		sol = Rd_List(list);
		piece = Rd_Char(*sol);
		if(piece != BLANK){
			piece += '0';
		}
		board[i]=piece;
		list = sol[1];
	}
	gameOver= Rd_Char(arg[2])=='w'?1:0;
	nextPlayer=nextPlayer==1?2:1;
	Pl_Query_End(PL_RECOVER);
	Stop_Prolog();
}





void createWindow(){
    //create new window
    window = gtk_window_new (GTK_WINDOW_TOPLEVEL);

    // Set the window title
    gtk_window_set_title (GTK_WINDOW (window), "Gyges");

    //set window size
    gtk_window_set_default_size(
        GTK_WINDOW(window), 1050, 750);

    layout = gtk_layout_new(NULL, NULL);
    gtk_container_add(GTK_CONTAINER (window), layout);
}

void loadLayout(){
	//refresh the layout widget
	gtk_container_remove(GTK_CONTAINER(window), layout);

    layout = gtk_layout_new(NULL, NULL);
    gtk_container_add(GTK_CONTAINER (window), layout);
	strcpy(tempPath, path);
    image = gtk_image_new_from_file(
        strcat(tempPath, "GygesBoard.png"));
    gtk_layout_put(GTK_LAYOUT(layout), image, 0, 0);

		strcpy(tempPath, path);
		image = gtk_image_new_from_file(
        strcat(tempPath, "play_button.png"));
    gtk_layout_put(GTK_LAYOUT(layout), image, 800, 100);

		strcpy(tempPath, path);
		if(nextPlayer==1){
			image = gtk_image_new_from_file(
					strcat(tempPath, "infierno.jpg"));
		}else{
			image = gtk_image_new_from_file(
					strcat(tempPath, "cielo.jpeg"));
		}
		gtk_layout_put(GTK_LAYOUT(layout), image, 900, 100);
		if(gameOver){
			strcpy(tempPath, path);
			if(nextPlayer==1){
				image = gtk_image_new_from_file(
						strcat(tempPath, "cieloWon.jpg"));
			}else{
				image = gtk_image_new_from_file(
						strcat(tempPath,"infiernoWon.jpg"));
			}
			gtk_layout_put(GTK_LAYOUT(layout), image, 0, 0);
			//mouse listener
	    gtk_widget_set_events (window,GDK_BUTTON_PRESS_MASK);
	    gtk_widget_show(layout);
	    gtk_widget_show_all(window);
		}else{
    	//mouse listener
	    gtk_widget_set_events (window,GDK_BUTTON_PRESS_MASK);
	    gtk_widget_show(layout);
	    gtk_widget_show_all(window);
	    addPiecesGui();
		}
}

void callback( GtkWidget *widget,
               gpointer   data )
{
    GtkEntry* entry = (GtkEntry*)data;

    printf("on_button_clicked - entry = '%s'\n", gtk_entry_get_text(entry));
    fflush(stdout);
}

//add pieces to board in gui from global bitmaps
void addPiecesGui(){
    int i, j;

  //add images for each piece on board
  for(i = 0; i<36; i++){
  	int position = i;
  	int x = ((i%6) * 100) + 75;
  	int y = (i/6 * 100) + 75;
  	strcpy(tempPath, path);
        switch(board[i]){
          case '1':
              image = gtk_image_new_from_file(strcat(tempPath, "1lvlpiece.png"));
              gtk_layout_put(GTK_LAYOUT(layout), image, x, y);
              break;
          case '2':
              image = gtk_image_new_from_file(strcat(tempPath, "2lvlpiece.png"));
              gtk_layout_put(GTK_LAYOUT(layout), image, x, y);
 	         break;
        	case '3':
                image = gtk_image_new_from_file(strcat(tempPath, "3lvlpiece.png"));
                gtk_layout_put(GTK_LAYOUT(layout), image, x, y);
        	    break;
        }
    }
    gtk_widget_show_all(layout);
}
static gboolean
button_press_event(GtkWidget *widget, GdkEventButton *event )
{
	printf("%f %f\n",event->x,event->y );
  int x = event->x;
  int y = event->y;

	int position=(x-75)/100+((y-75)/100)*6;
	printf("%d\n",position);

	if(x>75 && y>75 && x<675 && y<675){ //piece selected
		movePiece(position);
	}else{
		pieceSelected = -1;
		if(x>800 && x<900 && y>100 && y<200){ //play_button selected
			siguienteJugada();
			loadLayout();
		}else if(x>350 && x<400 && y>25 && y<75 &&
			nextPlayer==1){ //gano el infierno
				//its needed to check if the player is available to do this movement
			gameOver=1;
			nextPlayer=2;
			loadLayout();
		}else if(x>350	 && x<400 && y>675 && y<725 &&
			nextPlayer==2){ //gano el infierno
				//its needed to check if the player is available to do this movement
			gameOver=1;
			nextPlayer=1;
			loadLayout();
		}
	}
  return TRUE;
}
void movePiece(int position){
	if(pieceSelected<0){
		if(board[position]!=BLANK){
			pieceSelected=position;
			int imgx = ((position%6) * 100) + 75;
			int imgy = (position/6 * 100) + 75;
			loadLayout();
			strcpy(tempPath, path);
			image = gtk_image_new_from_file(strcat(tempPath, "highlight.png"));
			gtk_layout_put(GTK_LAYOUT(layout), image, imgx, imgy);
			gtk_widget_show_all(window);
		}
  }else{
      if(position == pieceSelected){
        loadLayout();
      }else{
				board[position]=board[pieceSelected];
				printf("Piece: %d\n", pieceSelected );
				board[pieceSelected]=BLANK; //to delete the piece
				nextPlayer=nextPlayer==1?2:1;
				loadLayout();
			}
      pieceSelected = -1;
  }
}
