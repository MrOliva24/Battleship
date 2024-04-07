section .data               

section .text            





;Subrutines d'assemblador que es criden des de C.
global posCurScreen, showDigits, updateBoard,
global moveCursor, openCard, checkPairs, moveCursorcnt,
global play

;Variables definides en C.
extern mboard, mOpen, tecla,RowScreenIni,ColScreenIni 
extern row, col, status, boats, moves, pos, value, rowScreen, colScreen
 
;Funcions de C que es criden des d'assemblador.
extern clearScreen_C, printBoard_C, gotoxy_C, getch_C, printch_C
extern printMessage_C


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; ;;;;;;;;;;;;;;;;;;;;;;
;; ATENCIÓ: Recordeu que en assemblador les variables i els paràmetres
;; de tipus 'char' s'han d'assignar a registres de tipus
;; BYTE (1 byte): al, ah, bl, bh, cl, ch, dl, dh, sil, dil, ..., r15b
;; les de tipus 'short' s'han d'assignar a registres de tipus
;; WORD (2 bytes): ax, bx, cx, dx, si, digues, ...., r15w
;; les de tipus 'int' s'han d'assignar a registres de tipus
;; DWORD (4 bytes): eax, ebx, ecx, edx, esi, edi, ...., r15d
;; les de tipus 'long' s'han d'assignar a registres de tipus
;; QWORD (8 bytes): rax, rbx, rcx, rdx, rsi, rdi, ...., r15
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; ;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Les subrutines en assemblador que cal modificar són:
;; postCurScreen, showDigits, updateBoard,
;; moveCursor, openCard.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; ;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; ;;;;;;;;;;;;;;;;;;;;;;;
; AQUESTA SUBRUTINA US LA DONEM FETA: NO LA PODEU MODIFICAR.
; Situar el cursor en la posició corresponent de la pantalla
; en funció dels valors de les variables rowScreen i colScreen
; cridant a la funció gotoxy_C.
;
; Variables globals utilitzades:
; rowScreen
; colScreen
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; ;;;;;;;;;;;;;;;;;;;;;;
gotoxy:
   push rbp
   mov  rbp, rsp
   ;guardem l'estat dels registres del processador perquè
   ;les funcions de C no mantenen l'estat dels registres.
   push rax
   push rbx
   push rcx
   push rdx
   push rsi
   push rdi
   push r8
   push r9
   push r10
   push r11
   push r12
   push r13
   push r14
   push r15

   ; Quan cridem la funció gotoxy_C(int rowScreen, int colScreen)
   ; des d'assemblador el primer paràmetre (rowScreen) s'ha de
   ; passar pel registre edi, i el segon paràmetre (colScreen)
   ; s'ha de passar pel registre esi.
   mov esi, DWORD[colScreen]
   mov edi, DWORD[rowScreen]
   call gotoxy_C
 
   pop r15
   pop r14
   pop r13
   pop r12
   pop r11
   pop r10
   pop r9
   pop r8
   pop rdi
   pop rsi
   pop rdx
   pop rcx
   pop rbx
   pop rax

   mov rsp, rbp
   pop rbp
   ret


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; ;;;;;;;;;;;;;;;;;;;;;;
; AQUESTA SUBRUTINA US LA DONEM FETA: NO LA PODEU MODIFICAR.
; Mostrar un caràcter a la pantalla, rebut com a paràmetre (dil),
; a la posició de la pantalla on està situat el cursor cridant 
; a la funció printch_C.
;
; Variables globals utilitzades:
; Cap
;
; Paràmetres d'entrada:
; (c): dil: caràcter que volem mostrar
;
; Paràmetres de sortida:
; Cap
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
printch:
   push rbp
   mov  rbp, rsp
   ;guardem l'estat dels registres del processador perquè
   ;les funcions de C no mantenen l'estat dels registres
   push rax
   push rbx
   push rcx
   push rdx
   push rsi
   push rdi
   push r8
   push r9
   push r10
   push r11
   push r12
   push r13
   push r14
   push r15

   ; Quan cridem a la funció printch_C(char c) des d'assemblador,
   ; el paràmetre (c) s'ha de passar pel registre dil.
   call printch_C
 
   pop r15
   pop r14
   pop r13
   pop r12
   pop r11
   pop r10
   pop r9
   pop r8
   pop rdi
   pop rsi
   pop rdx
   pop rcx
   pop rbx
   pop rax

   mov rsp, rbp
   pop rbp
   ret
   

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; ;;;;;;;;;;;;;;;;;;;;;;
; AQUESTA SUBRUTINA US LA DONEM FETA: NO LA PODEU MODIFICAR.
; Llegir una tecla i retornar el caràcter associat a la variable global 
; tecla sense mostrar-ho en pantalla per a fer això
; crida a la funció getch_C
;
; Variables globals utilitzades:
; tecla
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; ;;;;;;;;;;;;;;;;;;;;;;
getch:
   push rbp
   mov  rbp, rsp
   ;guardem l'estat dels registres del processador perquè
   ;les funcions de C no mantenen l'estat dels registres.
   push rbx
   push rcx
   push rdx
   push rsi
   push rdi
   push r8
   push r9
   push r10
   push r11
   push r12
   push r13
   push r14
   push r15
   push rbp

   mov rax, 0
   ; cridem a la funció getch_C(char c) des d'assemblador,
   ; retorna sobre el registre al el caràcter llegit.
   call getch_C
   ; Guardem el caracter a la variable tecla
   mov BYTE[tecla], al
   
  
   pop rbp
   pop r15
   pop r14
   pop r13
   pop r12
   pop r11
   pop r10
   pop r9
   pop r8
   pop rdi
   pop rsi
   pop rdx
   pop rcx
   pop rbx
   
   mov rsp, rbp
   pop rbp
   ret 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; ;;;;;;;;;;;;;;;;;;;;;;
; Posicionar el cursor a la pantalla, dins del tauler, en funció del
; valors de les variables globals row i col, 
; de tipus  row int(DWORD) 4bytes i col char(BYTE) 1 byte, a partir
; de la posició inicial del taulell a la pantalla, indicada per les
; variables globals RowScreenIni i ColScreenIni.
; Per ca alcular la posició del cursor a la pantalla (rowScreen) i
; (colScreen) utilitzar aquestes fórmules:
; rowScreen=RowScreenIni+row*2)
; colScreen=ColScrennIni+col*4)
; Per posicionar el cursor en pantalla cal cridar a la
; subrutina gotoxy després d'haver calculat els valors de rowScreen i
; colScreen.
;
; Variables globals utilitzades:
; row: fila dintre de la matriu (int: 4 bytes)
; col: columna dintre de la matriu (char: 1 byte)
; RowScreenIni: Fila inicial del taulell
; ColScrennIni: Columna inicial del taulell
; rowScreen: Fila de pantalla en la que volem posicionar el cursor
; colScreenIni: Columna de la pantalla on volem posicionar el cursor
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; ;;;;;;;;;;;;;;;;;;;;;;
posCurScreen:
   push rbp
   mov  rbp, rsp
   push rax
   push rbx
   mov rax,0
   mov rbx,0
   mov eax, Dword[row]
   shl eax,1
   add eax, Dword[RowScreenIni]
   mov Dword[rowScreen], eax
   mov eax,0
   mov al, byte[col]
   sub al, 'A'
   shl al,2
   add eax, Dword[ColScreenIni]
   mov Dword[colScreen], eax
   call gotoxy
   pop rbx
   pop rax
   mov rsp, rbp
   pop rbp
   ret


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Convertir un valor (value) de tipus short(WORD)2bytes (entre 0 i 99)
; en 2 caràcters ASCII que representin aquest valor. (27 -> '2' '7').
; Cal dividir el valor entre 10, el quocient representarà les
; desenes i el residu les unitats, i després cal convertir a ASCII
; sumant '0' o 48(codi ASCII de '0') a les desenes i a les unitats.
; Mostrar els dígits (caràcter ASCII) a partir de la fila indicada
; per la variable (rowScreen) i a la columna indicada per la variable
; (colscreen).
; Per posicionar el cursor cal cridar a la subrutina gotoxy que 
; posicona el cursor a la posicio de la pantalla indicada per colScreen
; i rowScreen i per mostrar els caràcters cridar a la subrutina printch
; que treu per pantalla el codi caràcter corresponent al codi ASCII
; emmagatzemat al registre dil.
;
; Variables globals utilitzades:
; rowScreen: posició de la fila
; colScreen: posició de la columna
; value: valor a imprimir per pantalla
;
;;;;;
showDigits:
push rbp
   mov  rbp, rsp
   
   push rax
   push rdx
   push rcx
   
   mov rdx, 0
   mov ecx, 10
   
   mov ax, WORD[value]
   div ecx
   add ax, '0'
   add dx, '0'
   
   call gotoxy
   mov dil, al
   call printch
   mov dil,dl
   call printch
   
   pop rcx
   pop rdx
   pop rax
   
 
   mov rsp, rbp
   pop rbp
   ret



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Mostrar els valors de la matriu (mOpenCards) dins del tauler,
; a les posicions corresponents, els intents que queden (moves)
; i els vaixells no enfonsats (boats).
; S'ha de recórrer tota la matriu (mOpenCards), d'esquerra a
; dreta i de dalt a baix, cada posició és de tipus char(BYTE)1byte,
; i per a cada element de la matriu fer:
; Posicionar el cursor al tauler en funció de les variables
; (rowScreen) fila i (colScreen) columna cridant a la subrutina gotoxy.
; Les variables (rowScreen) i (colScreen) s'inicialitzen a 10 i 12
; respectivament, que és la posició en pantalla de la casella [0][0].
; Mostra els caràcters de cada posició de la matriu (mOpen)
; cridant a la subrutina printch.
; Després, mostrar els intents que queden (moves) de tipus int(DWORD)4bytes,
; a partir de la posició [25,15] de la pantalla i 
;mostrar els vaixells no enfonsats (boats) de tipus int(DWORD)4bytes a partir de la
; posició [25,24] de la pantalla cridant a la subrutina showDigits.
;
; Variables globals utilitzades:
; mOpen: Matriu on guardem les targetes del joc.
; moves: Valor que indica el nombre d'intents que queden
; boats: Vaixells no enfonsats
; rowScreen: posició de la fila
; colScreen: posició de la columna
; 
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
updateBoard:
	push rbp
	mov  rbp, rsp
	
	push rax
	push rbx
	push rcx
	push rdx
	push rsi
	
	
	mov ecx,DWORD[row]
	mov dl,Byte[col]
	mov esi,0
	mov DWORD[row],0
	mov Byte[col],'A'

segrow:
	cmp DWORD[row],6
	jg fiupdate

segcol:	
	cmp Byte[col],'F'
	jg canvifila
	
		call posCurScreen
		mov dil,Byte mOpen[esi] 
		call printch
        inc esi
        inc Byte[col]
        jmp segcol	
	
canvifila:
		inc DWORD[row]
		mov Byte[col],'A'
		jmp segrow
	
fiupdate:

		mov eax,DWORD[moves]
		mov WORD[value],ax
		
		mov DWORD[rowScreen], 25
		mov DWORD[colScreen],15
		
		call showDigits
 
 		mov eax,DWORD[boats]
		mov WORD[value],ax
		
		mov DWORD[rowScreen], 25
		mov DWORD[colScreen],24
		
		call showDigits
		
		mov Byte[col],dl
		mov DWORD[row],ecx
 
	pop rsi
	pop rdx
	pop rcx
	pop rbx
	pop rax
	
	mov rsp, rbp
	
	pop rbp
	ret


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Actualitzar la posició del cursor dins la matriu indicada per la
; variable (row,col), de tipus int(DWORD)4bytes, rebuda com a variable global.
; S'ha de cridar la funció posCurScreen per posicionar el cursor i updateBoard.
; En funció de la tecla premuda (tecla), que s'obte a la crida de la funcio
; getch, de tipus char(BYTE)1byte,
; i: a dalt, j:esquerra, k:a baix l:dreta).
; Comprovar que no sortim de la matriu, (row,col) només pot prendre valors
; de posicions dins de la matriu row [0,6] i col[A,F].
; Per canviar de fila sumem o restem 1 (row) i per canviar de
; columna sumem o restem 1 a (col) perquè cada posició de la matriu
; és de tipus char(BYTE)1byte.
; Si el moviment surt de la matriu, no fer el moviment.
; Tornar la posició del cursor (row,col) actualitzada.
;
; I posicionar el cursor amb la funcio posCurScreen.
;
; Variables globals utilitzades:
; tecla : Caràcter llegit de teclat.
; row: la fila dintre de la matriu (4bytes)
; col: la columa dintre de la matriu(1bytes)
;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
moveCursor:   
   push rbp
   mov  rbp, rsp
   
   call updateBoard
   call posCurScreen
   call getch
   cmp BYTE[tecla],'i'
   jne j
   cmp Dword[row],0
   je fi
   dec Dword[row]
   jmp fi
   
   j: cmp BYTE[tecla],'j'
   jne k
   cmp Dword[col],'A'
   je fi
   dec Dword[col]
   jmp fi
   
   k: cmp BYTE[tecla],'k'
   jne l
   cmp Dword[row],6
   je fi
   inc Dword[row]
   jmp fi
   
   l: cmp BYTE[tecla],'l'
   jne fi
   cmp Dword[col],'F'
   je fi
   inc Dword[col]
   
   fi: call gotoxy
   mov rsp, rbp
   pop rbp
   ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; ;;;;;;;;;;;;;;;;;;;;;;
; Segons la tecla llegida cridarem a les subrutines que corresponguin.
; - ['i','j','k' o 'l'] desplaçar el cursor segons l'adreça
; escollida, cridant a la subrutina (moveCursor).
; - '<SPACE>'(codi ASCII 32) i <ESC>' (codi ASCII 27) per sortir.

;
; Variables globals utilitzades:
; tecla: tecla llegida per teclat
;
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
moveCursorcnt:

push rbp
mov  rbp, rsp

bucle: 
call moveCursor
cmp BYTE[tecla], 32
je fin
cmp BYTE[tecla], 27
je fin
jmp bucle

fin: 



mov rsp, rbp
pop rbp
ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; ;;;;;;;;;;;;;;;;;;;;;;
; calcular l'índex per accedir a les matrius en assemblador
; mboard[row][col] en C, és [mboard + pos] en assemblador
; on pos = row*6 + col(col convertir a número)
; 
; 
; Variables globales utilizadas:
; row    : fila per accedir a la matriu.
; col    : fila per accedir a la matriu.
; pos    : Posició dintre la matriu.
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
calIndex:

push rbp
mov  rbp, rsp
push rax
push rdx

mov eax, '0'
mov eax, Dword[row]
mov ebx, 6
mul ebx

mov edx, '0'
mov edx, Dword[col]
sub edx, 'A'
add eax, edx
mov Dword[pos], eax
pop rax
pop rdx

	 
mov rsp, rbp
pop rbp
ret

;;;;;
; Obrir una casella de la matriu mboard a partir
; del index pos, que s'obté al cridar a la funcio calIndex.
; 
;
; NO cal mostrar la matriu amb els canvis, es fa a updateBoard().
;
; Si la posició de la matriu no esta oberta (='X'), a l'obrir-la
; en el cas que sigui aigua restali una move
;
; En el cas que no sigui aigua crida a la funcio hitandhunk
;
; Variables globals utilitzades:
; mboard : Matriu on guardem els vaixells.
; mOpen: Matriu on tenim les caselles obertes
; pos : Posició dins de la matriu.
; move: Valor que indica el nombre d'intents que queden
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
openCard:  
push rbp
mov rbp, rsp

push rdx
push rbx
push rcx
push rax


call moveCursorcnt
mov bl, BYTE[tecla]
cmp bl,32
jne final1
call calIndex

mov ecx, DWORD[pos]
mov dl, BYTE mboard [ecx]
mov BYTE mOpen [ecx],dl

call updateBoard

final1

pop rax
pop rcx
pop rbx
pop rdx

mov rsp, rbp
pop rbp
ret

; En el cas que estiguin obertes totes les caselles que formen un vaixell 
; restar un al boats
; 
;
; Variables globals utilitzades:
; mboard : Matriu on guardem els vaixells.
; mOpen: Matriu on tenim les caselles obertes
; pos : Posició dins de la matriu.
; boats: Vaixells no enfonsats
;
;
;;;;;
hitandhunk: 

push rbp
mov  rbp, rsp
push rax
push rbx
push rcx
push rdx
push r8
push r9
push r10
push r11
push r12
push r13
push r14
push r15

mov r8d,Dword[pos]
mov r9d,Dword[pos]
mov r10d,Dword[pos]
mov r11d,Dword[pos]

mov eax, r8d

sub r8d,6
add r9d,6
sub r10d,1
add r11d, 1

;Comprobamos arriba del barco
pabajoparriba:
cmp Byte mboard [r8d], "B"
jne abajo
mov ebx, r8d
cmp Byte mboard [r9d], "B"
jne b3up 
mov ecx, r9d
jmp marcpolitoxicomano
b3up: mov r12d, r8d
sub r12d,6
cmp Byte mboard [r12d], "B"
jne samuelcharnego
mov ecx, r12d
jmp marcpolitoxicomano

abajo: cmp Byte mboard [r9d], "B"
jne paunlaopalotro
mov ebx, r9d
mov r13d, r9d
add r13d, 6
cmp Byte mboard [r13d], "B"
jne samuelcharnego
mov ecx, r13d
jmp marcpolitoxicomano


paunlaopalotro:cmp Byte mboard [r10d], "B"
jne derecha
mov ebx, r10d
cmp Byte mboard [r11d], "B"
jne b3iz 
mov ecx, r11d
jmp marcpolitoxicomano
b3iz: mov r14d, r10d
sub r14d,1
cmp Byte mboard [r14d], "B"
jne samuelcharnego
mov ecx, r14d
jmp marcpolitoxicomano

derecha: cmp Byte mboard [r11d], "B"
jne davidmachista
mov ebx, r11d
mov r15d, r11d
add r15d, 1
cmp Byte mboard [r15d], "B"
jne samuelcharnego
mov ecx, r15d
jmp marcpolitoxicomano

davidmachista:mov dl, Byte mOpen [eax]
cmp dl, "B"
jne final2
dec Dword[boats]
jmp final2 
samuelcharnego:mov dl, Byte mOpen [eax]
cmp dl, "B"
jne final2
mov dl, Byte mOpen [ebx]
cmp dl, "B"
jne final2
dec Dword[boats]
jmp final2
marcpolitoxicomano:mov dl, Byte mOpen [eax]
cmp dl, "B"
jne final2
mov dl, Byte mOpen [ebx]
cmp dl, "B"
jne final2
mov dl, Byte mOpen [ecx]
cmp dl, "B"
jne final2
dec Dword[boats] 
final2:
pop r15
pop r14
pop r13
pop r12
pop r11
pop r10
pop r9
pop r8
pop rdx
pop rcx
pop rax
mov rsp, rbp
pop rbp
ret
;;;;;
; Obrir de forma continuada una posició de la matriu (mboard) a partir
; de la funció openCard
; 
; Utiliza el ; '<SPACE>'(codi ASCII 32) per obrir les caselles
; i <ESC>' per sortir.
; En el cas que el moves sigui 0 sortir del joc
;
;
; Variables globals utilitzades:
; move: Valor que indica el nombre d'intents que queden
; tecla: tecla llegida per teclat 
;
;
;;;;;
play: 

 push rbp
 mov  rbp, rsp 
 
 push rdx
 push rbx
 push rcx
 push rax

 bucle1:
  call moveCursorcnt
  mov bl, BYTE[tecla]
  cmp bl,32
  jne fi
  call calIndex

  mov ecx, DWORD[pos]
  mov bl, BYTE mOpen [ecx]
  cmp bl, "O"
  je updateMove
  mov dl, BYTE mboard [ecx]
  mov BYTE mOpen [ecx],dl
  cmp dl, "O"
  jne updateMove
  mov Dword[rowScreen],25
  mov Dword[colScreen],15
  dec Dword[moves]
  call updateBoard
  mov edx, Dword[moves]
  cmp edx,0
  je fi2
  jmp bucle1
  updateMove:
  call hitandhunk
  mov ebx,Dword[boats]
  cmp ebx,0
  je fi2
  mov ebx,0
  call updateBoard
  jmp bucle1

fi2: call updateBoard
 pop rax
 pop rcx
 pop rbx
 pop rdx
	 
 mov rsp, rbp
 pop rbp
 ret
