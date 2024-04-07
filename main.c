
#include <stdlib.h>
#include <stdio.h>
#include <termios.h>     //termios, TCSANOW, ECHO, ICANON
#include <unistd.h>      //STDIN_FILENO

/**
 * Constants
 */
#define ROWDIM  7        //files de la matriu
#define COLDIM  6        //columnes de la matriu


/**
 * Definición de variables globales
 */

int PosCursor;
char tecla;
int RowScreenIni = 10; //Fila inicial del taulell
int ColScreenIni = 12; //Columna inicial del taulell
int row;
char col;
int pos;
int moves = 23;
int boats= 7; 
int value;
int rowScreen;
int colScreen;

//Matriu 7x6 amb els vaixells
char mboard[ROWDIM][COLDIM] = { 
	               {'B','B','B','O','O','O'},
                   {'O','O','O','O','O','O'},
                   {'B','O','O','O','B','B'},
                   {'O','O','B','O','O','O'}, 
                   {'B','O','B','O','B','O'}, 
                   {'B','O','B','O','O','O'}, 
                   {'O','O','O','O','B','O'} 
                   };  
                   
//Matriu 7x6 on es mostre les caselles obertes  
char mOpen[ROWDIM][COLDIM] = { 
	               {'X','X','X','X','X','X'},
                   {'X','X','X','X','X','X'},
                   {'X','X','X','X','X','X'},
                   {'X','X','X','X','X','X'},
                   {'X','X','X','X','X','X'},
                   {'X','X','X','X','X','X'},
                   {'X','X','X','X','X','X'} };

/**
 * Definició de les funcions de C
 */
void clearscreen_C();
void clearTaulell_C();
void gotoxy_C(int, int);
void printch_C(char);
char getch_C();

char printMenu_C();
void printBoard_C();


void printMessage_C(int);
void play_C();


/**
 * Definició de les subrutines d'assemblador que s'anomenen des de C.
 */
void posCurScreen();
void showDigits();
void updateBoard();
void moveCursor();
void openCard();
void checkPairs();
void play();
void moveCursorcnt();


/**
 * Reiniciar joc
 *
 * Variables globals utilitzades:
 * Cap
 *
 *
 * Aquesta funció no es crida des d'assemblador
 * i no hi ha definida una subrutina d'assemblador equivalent.
 */
void clearTaulell_C(){
   
    for (int i = 0; i < ROWDIM; i++)
    {
        for (int j = 0; j < COLDIM; j++)
        {
            mOpen[i][j] = 'X';
        }
    }
}


/**
 * Esborrar la pantalla
 *
 * Variables globals utilitzades:
 * Cap
 *
 *
 * Aquesta funció no es crida des d'assemblador
 * i no hi ha definida una subrutina d'assemblador equivalent.
 */
void clearScreen_C(){
   
    printf("\x1B[2J");
    
}


/**
 * Situar el cursor en una fila i una columna de la pantalla
 * en funció de la fila (rowScreen) i de la columna (colScreen)
 * rebuts com a paràmetres.
 *
 * Variables globals utilitzades:
 * Cap
 *
 * Paràmetres d'entrada:
 * (rowScreen): edi: Fila
 * (colScreen): esi: Columna
 *
 * Paràmetres de sortida :
 * Cap
 *
 * S'ha definit una subrutina en assemblador equivalent 'gotoxyP'
 * per poder cridar a aquesta funció guardant l'estat dels registres
 * del processador. Això es fa perquè les funcions de C no mantenen
 * l'estat dels registres.
 * El pas de paràmetres és equivalent.
 **/
void gotoxy_C(int rowScreen, int colScreen){
   
   printf("\x1B[%d;%dH",rowScreen,colScreen);
   
}


/**
 * Mostrar un caràcter (c) en pantalla, rebut com a paràmetre,
 * a la posició on hi ha el cursor.
 *
 * Variables globals utilitzades:
 * Cap
 *
 * Paràmetres d'entrada:
 * (c): dil: Caràcter que volem mostrar.
 *
 * Paràmetres de sortida :
 * Cap
 *
 * S'ha definit un subrutina en assemblador equivalent 'printchP'
 * per cridar a aquesta funció guardant l'estat dels registres del
 * processador. Això es fa perquè les funcions de C no mantenen
 * l'estat dels registres.
 * El pas de paràmetres és equivalent.
 */
void printch_C(char c){
   
   printf("%c",c);
   
}


/**
 * Llegir una tecla i retornar el caràcter associat
 * sense mostrar-ho en pantalla.
 *
 * Variables globals utilitzades:
 * Cap
 *
 * Paràmetres d'entrada:
 * Cap
 *
 * Paràmetres de sortida :
 * (c): al: Caràcter que llegim de teclat
 *
 * S'ha definit un subrutina en assemblador equivalent 'getchP' per a
 * cridar a aquesta funció guardant l'estat dels registres del processador.
 * Això es fa perquè les funcions de C no mantenen l'estat dels
 * registres.
 * El pas de paràmetres és equivalent.
 */
char getch_C(){

   int c;   

   static struct termios oldt, newt;

   /*tcgetattr obtenir els paràmetres del terminal
   STDIN_FILENO indica que s'escriguin els paràmetres de l'entrada estàndard (STDIN) sobre oldt*/
   tcgetattr( STDIN_FILENO, &oldt);
   /*se copian los parámetros*/
   newt = oldt;

    /* ~ICANON per tractar l'entrada de teclat caràcter a caràcter no com a línia sencera acabada a /n
    ~ECHOperquè no es mostri el caràcter llegit.*/
   newt.c_lflag &= ~(ICANON | ECHO);          

   /*Fixeu els nous paràmetres del terminal per a l'entrada estàndard (STDIN)
   TCSANOW indica a tcsetattr que canviï els paràmetres immediatament. */
   tcsetattr( STDIN_FILENO, TCSANOW, &newt);

   /*Llegir un caràcter*/
   c=getchar();                 
    
   /*restaurar els paràmetres originals*/
   tcsetattr( STDIN_FILENO, TCSANOW, &oldt);

   /*Tornar el caràcter llegit*/
   return (char)c;
   
}


/**
 * Mostrar a la pantalla el menú del joc i demanar una opció.
 * Només accepta una de les opcions correctes del menú ('0'-'9')
 *
 * Variables globals utilitzades:
 * Cap
 *
 * Paràmetres d'entrada:
 * Cap
 *
 * Paràmetres de sortida :
 * (charac): al: Opció escollida del menú, llegida de teclat.
 *
 * Aquesta funció no es crida des d'assemblador
 * i no hi ha definida una subrutina d'assemblador equivalent.
 */
char printMenu_C(){
	
   clearScreen_C();
   gotoxy_C(1,1);
   printf("                                 \n");
   printf("                                 \n");
   printf("                                 \n");
   printf(" _______________________________ \n");
   printf("|                               |\n");
   printf("|           MAIN MENU           |\n");
   printf("|_______________________________|\n");
   printf("|                               |\n");
   printf("|        1. PosCurScreen        |\n");
   printf("|        2. ShowDigits          |\n");
   printf("|        3. UpdateBoard         |\n");
   printf("|        4. moveCursor          |\n");
   printf("|        5. MoveContinus        |\n");   
   printf("|        6. OpenCard            |\n");
   printf("|        7. Play                |\n");
   printf("|                               |\n");
   printf("|        0. Exit                |\n");
   printf("|_______________________________|\n");
   printf("|                               |\n");
   printf("|           OPTION:             |\n");
   printf("|_______________________________|\n"); 

   char charac =' ';
   while (charac < '0' || charac > '9') {
     gotoxy_C(20,21);          //Posicionar el cursor
     charac = getch_C();       //Llegir una opció
   }
   return charac;
}


/**
* Mostrar el tauler de joc a la pantalla. Les línies del tauler.
 *
 * Variables globals utilitzades:
 * Cap
 *
 *
 * Aquesta funció es crida des de C i des d'assemblador,
 * i no hi ha definida una subrutina d'assemblador equivalent.
 * No hi ha pas de paràmetres.
 */
void printBoard_C(){

   gotoxy_C(1,1);                                     //Files
                                                        //Taulell                                 
   printf(" _____________________________________ \n"); //01
   printf("|                                     |\n"); //02
   printf("|            B  O  A  T  S            |\n"); //03
   printf("|                                     |\n"); //04
   printf("|            Find all boats           |\n"); //05
   printf("|                                     |\n"); //06
   printf("|                                     |\n"); //07
 //Columnes Taulell   12  16  20  24   28         
   printf("|          A   B   C   D   E   F      |\n"); //08
   printf("|        +---+---+---+---+---+---+    |\n"); //09
   printf("|      0 |   |   |   |   |   |   |    |\n"); //10
   printf("|        +---+---+---+---+---+---+    |\n"); //11
   printf("|      1 |   |   |   |   |   |   |    |\n"); //12
   printf("|        +---+---+---+---+---+---+    |\n"); //13
   printf("|      2 |   |   |   |   |   |   |    |\n"); //14
   printf("|        +---+---+---+---+---+---+    |\n"); //15
   printf("|      3 |   |   |   |   |   |   |    |\n"); //16
   printf("|        +---+---+---+---+---+---+    |\n"); //17
   printf("|      4 |   |   |   |   |   |   |    |\n"); //18
   printf("|        +---+---+---+---+---+---+    |\n"); //19
   printf("|      5 |   |   |   |   |   |   |    |\n"); //20
   printf("|        +---+---+---+---+---+---+    |\n"); //21
   printf("|      6 |   |   |   |   |   |   |    |\n"); //22
   printf("|        +---+---+---+---+---+---+    |\n"); //23  
  
  //Columnes dígits      15       24                 
   printf("|           +----+   +----+           |\n"); //24
   printf("|     Moves |    |   |    | Boats     |\n"); //25
   printf("|           +----+   +----+           |\n"); //26 
   printf("| (ESC) Exit        Open Card (Space) |\n"); //27
   printf("| (i)Up    (j)Left  (k)Down  (l)Right |\n"); //28
   printf("|                                     |\n"); //29
   printf("| [                                 ] |\n"); //30
   printf("|_____________________________________|\n"); //31
                          
}











//Programa Principal
int main(void){
   
   int   op=0;  
   char  charac;

   
   while (op!='0') {
      clearScreen_C();
      op = printMenu_C();    //Mostra menú i demana opció
      switch(op){
          case '1': //Posicionar el cursor en pantalla, dins del taulell, en funció de les variables row i col
            printf(" %c",op);
            clearScreen_C();    
            printBoard_C();   
            gotoxy_C(30,12);
            printf(" Press any key ");
            row = 5;
            col = 'C';
            posCurScreen();
            getch_C();
         break; 
         
         case '2': // Convertir un valor (entre 0 i 99) en 2 dos caracters ASCII i mostrar els dígits en pantalla. 
            printf(" %c",op);
            clearScreen_C();    
            printBoard_C();
            rowScreen = 25;
            colScreen = 15;
            value     = 99;
              showDigits();
            gotoxy_C(30,12);
            printf(" Press any key ");
            getch_C();
         break;
         
          case '3': //Actualizar el contingut del taulell i mostrar-lo per pantalla
            clearScreen_C();       
            printBoard_C();
            moves = 23;
            boats = 7;      
            updateBoard();
            gotoxy_C(30,12);
            printf(" Press any key ");
            getch_C();
         break;
        case '4': //Moure del cursor en el taulell 
            clearScreen_C();
            printBoard_C();
            moves = 23;
            boats = 7;  


            //moveCursor();
            gotoxy_C(30,12);
            printf(" Press i,j,k,l ");
			row = 4;
            col = 'D';
            moveCursor();
            gotoxy_C(30,12);
            printf(" Press any key ");
            posCurScreen();
            getch_C();
         break;
         case '5': //Moviment continuo del cursor pel taulell
		    clearScreen_C();
            printBoard_C();
            gotoxy_C(30,12);
            printf(" Press i,j,k,l ");
            moves = 23;
            boats = 7;  
            row = 5;
            col = 'C';
			moveCursorcnt();
            gotoxy_C(30,12);
            printf(" Press any key ");
			getch_C();


         break;
         case '6': ////Obrir una casella 
            clearScreen_C();
            printBoard_C();
            gotoxy_C(30,12);
            printf("Press <space> ");
            row = 4;
            col = 'C';
            openCard();
         
            gotoxy_C(30,5);
            printf("Card Opened       Press any key");
			getch_C();

         break;
         case '7': ////Obrir una casella de forma continuada 
            
            clearScreen_C();
            printBoard_C();
            row = 1;
            col = 'B';
            moves = 23;
            boats = 7; 
            clearTaulell_C(); 
            play();
         
            gotoxy_C(30,5);
            printf("                                ");
            gotoxy_C(30,16);
            printf("GAME OVER");
			getch_C();

         break;
     }
   }
   printf("\n\n");
   
   return 0;
   
}
