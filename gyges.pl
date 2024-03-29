/******************************
Estudiante: Seth Michael Stalley - 2014159915
Curso: Lenguajes de Programacion
Profesor: Kirstein Gatjens
Periodo: II Semestre, 2015
TAREA: IA de Gyges
*****************

Manual Usuario:
+Este archivo tiene las reglas de juego y algoritmos minMax
AI,-para las jugadas del ai. Para la realizacion de pruebas
-se recomienda correr la relacion "gyges" este tomara la tabla
-"testBoard" y lo relacionara con el jugador 1 o 2
-indicado en linea 50 y asi buscara la mejor jugada. Entonces
-para simular posiciones recomienda editar el "testBoard"

+Se define cual jugador es "cielo" o "infierno" en las relaciones
- "heaven" y "hell"


Analisis de Resultados:
+IA completo con reglas validos de juego: A
+Docu interno: A

Nota: Se implementara el "retorno" de los movimientos
realizados en C cuando se realiza la segunda parte de esta tarea.
(Kirstein nos dio permiso para hacer dicho)

*******************************/

%predicates
/*
  start a game with an board.
  @Input GameBoard
    e are empty places
    1 is a 1 lvl piece
    2 i s a 2 lvl piece
    3 i s a 3 lvl piece
  @Input PlayerNum
    1 is first player
    2 is second player
*/
boardList([_,X,Y],Y,X).

gyges(Y,Player,NextState,Board):-
    write('Before Move'),nl,
    %edit this number to change player
    write(Board),nl,
    bestMove(Player,[Player,_,Board], AfterMove),
    write('After Move'),nl,
    write(AfterMove),
    boardList(AfterMove,Y,NextState),
    write(NextState).

%a test board
testBoard([ A,B,C,D,E,F,
            e,e,e,e,e,e,
            e,e,e,e,e,e,
            e,e,e,e,e,e,
            e,e,e,e,e,e,
            A,B,C,D,E,F ]):- aiRow([A,B,C,D,E,F]).

%a game setup that our AI likes
aiRow([3,1,2,1,2,3]).

%which side of board each player is on (North/South)
heaven(2).
hell(1).

%what player are we?
nextPlayer(1,2).
nextPlayer(2,1).

%the current player is max and next min
maxMove(AI,[AI,_,_]).
minMov(AI,[P,_,_]).

%game states score respectively base on last move
score(AI,[P, won, _], -2).
score(AI,[AI, won, _], 2).
%give a small score for moving, we always have to move
score(_,[P, play, _], -10).

%indexes that signify a win
winningSLot(P,S):- hell(P), S < 0,S > -6.
winningSLot(P,S):- heaven(P),S > 35, S < 41.

%Moves, use prolog backtracking to solve for win
move([Player1, play, Board], [Player1, won, _]) :-
    nextPlayer(Player1,Player2),
    moveAux(Player1, won, _ , Board, _).

move([Player1, play, Board], [Player2, play, NextBoard]) :-
    nextPlayer(Player1,Player2),
    moveAux(Player1, play, _, Board, NextBoard).

%if Pos hasn't been instanciated start it in 0
moveAux(P,State,Pos,Board,NextBoard):-
    var(Pos),
    loopPieces(P, State,Board,NextBoard).
%victory condition
moveAux(P, won, Pos, Board, _ ):- %position that can obtain victory
    \+ var(Pos),
    selectEle(CurEle, Pos, Board),
    playOption(Pos,N1,CurEle,Board),
    winningSLot(P,N1). %if landed in south or north winning slot

moveAux(P, play , Pos, Board,AfterMove):-
    \+ var(Pos),
    selectEle(CurEle, Pos, Board),
    \+ CurEle = e,
    updateEle(e, Pos, Board, NewBoard),
    playOption(Pos,N1,CurEle,Board),
    selectEle(e, N1, Board),
    updateEle(CurEle, N1, NewBoard, AfterMove).
%if we land on another piece
moveAux(P, State , Pos, Board,AfterMove):-
    \+ var(Pos),
    selectEle(CurEle, Pos, Board),
    \+ CurEle = e,
    updateEle(e, Pos, Board, NewBoard),
    playOption(Pos,N1,CurEle,Board),
    selectEle(MovingTo, N1, Board),
    \+ MovingTo = e,
    moveOnPiece(P,State,CurEle,N1, NewBoard, AfterMove,Pos).

loopPieces(P , State, Board, AfterMove) :-
    heaven(P),%if North player
    firstNorthRow(Board, Pos),
    sixMoves(P, State , Pos, Board, AfterMove).
loopPieces(P , State, Board, AfterMove) :-
    hell(P),%if North players
    firstSouthRow(Board, Pos),
    sixMoves(P, State , Pos, Board, AfterMove).

%evaluate each of the six posible moves in a row
sixMoves(P, State , Pos, Board, AfterMove):-
    moveAux(P, State , Pos, Board, AfterMove);
    Pos1 is Pos + 1,
    moveAux(P, State , Pos1, Board, AfterMove);
    Pos2 is Pos + 2,
    moveAux(P, State , Pos2, Board, AfterMove);
    Pos3 is Pos + 3,
    moveAux(P, State , Pos3, Board, AfterMove);
    Pos4 is Pos + 4,
    moveAux(P, State , Pos4, Board, AfterMove);
    Pos5 is Pos + 5,
    moveAux(P, State , Pos5, Board, AfterMove).

%get pos of first ele in north row with a piece
firstNorthRow(Board,Pos):-
    firstNorthRowAux(Board,Pos,0).
firstNorthRowAux([H|_],Pos,Count):-
    \+H = e,
    Pos is (Count // 6) * 6.
firstNorthRowAux([H|T],Pos,Count):-
    H = e,
    Count1 is Count + 1,
    firstNorthRowAux(T, Pos,Count1).
%get pos of row with first piece for south
firstSouthRow(Board,Pos):-
    reverse(Board,ReversedB),
    firstSouthRowAux(ReversedB,Pos,35).
firstSouthRowAux([H|_],Pos,Count):-
    \+H = e,
    Pos is (Count // 6) * 6.
firstSouthRowAux([H|T],Pos,Count):-
    H = e,
    Count1 is Count - 1,
    firstSouthRowAux(T, Pos,Count1).

%when piece skipping
moveOnPieceAux(P,play,Piece, Pos, Board, AfterMove):-
    selectEle(e, Pos, Board),%if after we skip it is blank
    updateEle(Piece, Pos, Board, AfterMove).
moveOnPieceAux(P,State,Piece, Pos, Board, AfterMove):-
    selectEle(LandedPiece, Pos, Board),%if not blank
    \+ LandedPiece = e,
    playOption(Pos, Skip, LandedPiece, Board),
    movingCorrectDir(P,Skip,Pos),
    moveOnPieceAux(P,State,Piece, Skip, Board, AfterMove),!.
moveOnPieceAux(P, won ,_, Pos, _, _):-
    winningSLot(P,Pos).
%loops var so we don't get stuck in a pice skipping loop
moveOnPiece(P,State,Piece, Pos, Board, AfterMove, LastPlace):-
    \+ LastPlace = Pos,
    moveOnPieceAux(P,State,Piece,Pos, Board, AfterMove).


movingCorrectDir(P,Skip,Pos):-
  (Skip // 6) < (Pos // 6),
  hell(P).
movingCorrectDir(P,Skip,Pos):-
  (Skip // 6) > (Pos // 6),
  heaven(P).

%our posible moves in the list
%left and right moves
playOption(N, N1,1,_):-
  Mod is N mod 6, %don't want to go over the edge of the board
  Mod + 1 < 6,
  N1 is N + 1.
playOption(N, N1,1,_):-
  Mod is N mod 6, %don't want to go over the edge of the board
  Mod - 1 > 0,
  N1 is N - 1.
%left and right moves
playOption(N, N1,2,Board):-
  Mod is N mod 6, %don't want to go over the edge of the board
  Mod + 2 < 6,
  N1 is N + 2,
  Middle is N + 1,
  selectEle(e, Middle,Board). %if empty spot
playOption(N, N1,2,Board):-
  Mod is N mod 6, %don't want to go over the edge of the board
  Mod - 2 > 0,
  N1 is N - 2,
  Middle is N - 1,
  selectEle(e, Middle,Board). %if empty spot

%up and down moves
playOption(N, N1,1,_):-
  N1 is N + 6.
playOption(N, N1,1,_):-
  N1 is N - 6.
playOption(N, N1,2,Board):-
  N1 is N + 12,
  Middle is N + 6,
  selectEle(e,Middle, Board).
playOption(N, N1,2,Board):-
  N1 is N - 12,
  Middle is N - 6,
  selectEle(e,Middle, Board).
playOption(N, N1,3,Board):-
  N1 is N + 18,
  Middle is N + 6,
  Middle2 is N + 12,
  selectEle(e,Middle, Board),
  selectEle(e,Middle2, Board).


%L shaped moves
%2 lvl down
playOption(N, N1,2,Board):-
  N mod 6 < 5, %can't do right L if on last column
  N1 is N + 7,
  Middle is N + 1,
  selectEle(e,Middle,Board).
playOption(N, N1,2,Board):-
  N mod 6 < 5,
  N1 is N + 7,
  Middle is N + 6,
  selectEle(e,Middle,Board).
playOption(N, N1,2,Board):-
  N mod 6 > 0,
  N1 is N + 5,
  Middle is N - 1,
  selectEle(e,Middle,Board).
playOption(N, N1,2,Board):-
  N mod 6 > 0,
  N1 is N + 5,
  Middle is N + 6,
  selectEle(e,Middle,Board).
%2 lvl up
playOption(N, N1,2,Board):-
  N mod 6 > 0,
  N1 is N - 7,
  Middle is N - 1,
  selectEle(e,Middle,Board).
playOption(N, N1,2,Board):-
  N mod 6 > 0,
  N1 is N - 7,
  Middle is N - 6,
  selectEle(e,Middle,Board).
playOption(N, N1,2,Board):-
  N mod 6 < 5,
  N1 is N - 5,
  Middle is N + 1,
  selectEle(e,Middle,Board).
playOption(N, N1,2,Board):-
  N mod 6 < 5,
  N1 is N - 5,
  Middle is N - 6,
  selectEle(e,Middle,Board).


playOption(N, N1,3,Board):- %up right
  Mod is N mod 6,
  Mod < 4,
  N1 is N - 4,
  Middle is N + 1,
  Middle2 is N + 2,
  selectEle(e,Middle,Board),
  selectEle(e,Middle2,Board).
playOption(N, N1,3,Board):- %up right case 2
  Mod is N mod 6,
  Mod < 4,
  N1 is N - 4,
  Middle is N - 6,
  Middle2 is N - 5,
  selectEle(e,Middle,Board),
  selectEle(e,Middle2,Board).
playOption(N, N1,3,Board):- %up left
  Mod is N mod 6,
  Mod > 1,
  N1 is N - 8,
  Middle is N - 1,
  Middle2 is N - 2,
  selectEle(e,Middle,Board),
  selectEle(e,Middle2,Board).
playOption(N, N1,3,Board):- %up left case 2
  Mod is N mod 6,
  Mod > 1,
  N1 is N - 8,
  Middle is N - 7,
  Middle2 is N - 6,
  selectEle(e,Middle,Board),
  selectEle(e,Middle2,Board).
playOption(N, N1,3,Board):- %down right
  Mod is N mod 6,
  Mod < 4,
  N1 is N + 8,
  Middle is N + 1,
  Middle2 is N + 2,
  selectEle(e,Middle,Board),
  selectEle(e,Middle2,Board).
playOption(N, N1,3,Board):- %down right case 2
  Mod is N mod 6,
  Mod < 4,
  N1 is N + 8,
  Middle is N + 6,
  Middle2 is N + 7,
  selectEle(e,Middle,Board),
  selectEle(e,Middle2,Board).
playOption(N, N1,3,Board):- %down left
  Mod is N mod 6,
  Mod > 1,
  N1 is N + 4,
  Middle is N - 1,
  Middle2 is N - 2,
  selectEle(e,Middle,Board),
  selectEle(e,Middle2,Board).
playOption(N, N1,3,Board):- %down left case 2
  Mod is N mod 6,
  Mod > 1,
  N1 is N + 4,
  Middle is N + 5,
  Middle2 is N + 6,
  selectEle(e,Middle,Board),
  selectEle(e,Middle2,Board).

  playOption(N, N1,3,Board):-
    N1 is N - 18,
    Middle is N - 6,
    Middle2 is N - 12,
    selectEle(e,Middle, Board),
    selectEle(e,Middle2, Board).

/*
  Min Max
*/
depth(X):- X < 2. %change this to change tree depth

minMax(AI,Pos, BestNextPos, Val,Depth) :-
    %all posible board moves
    bagof(NextPos, move(Pos, NextPos), NextPosList),
    %pick the move that can lead to win
    best(AI,NextPosList, BestNextPos, Val,Depth), !.

%no next move
minMax(AI,Pos, _, Val, _):-
    score(AI,Pos, Val).

%pick the best scored move from the list of boards
best(AI,[Pos], Pos, Val,Depth) :-
    depth(Depth),
    N1 is Depth + 1,
    minMax(AI,Pos, _, Val, N1).
best(AI,[Pos1 | PosList], BestPos, BestVal,Depth) :-
    depth(Depth),
    N1 is Depth + 1,
    minMax(AI,Pos1, _, Val1,N1),
    best(AI,PosList, Pos2, Val2,Depth),
    betterOf(AI,Pos1, Val1, Pos2, Val2, BestPos, BestVal).

%compare move value
betterOf(AI,Pos0, Val0, _, Val1, Pos0, Val0):-
    minMov(AI,Pos0),
    Val0 > Val1, !
    ;
    maxMove(AI,Pos0),
    Val0 < Val1, !.
betterOf(_,_, _, Pos1, Val1, Pos1, Val1).

%given a game state get the best posible next state
bestMove(AI,GameState, NextState):-
  minMax(AI,GameState, NextState, _, 0). %last arg is tree depth

/*
  AUX Relations
*/
/*
  Get operations on lists
  @Input
    element
    position
    List
*/
selectEle(H, 0, [H|_]).
selectEle(H,N,[_|T]):-
  N1 is N - 1,
  selectEle(H,N1,T).

/*
  Update operations on lists
  @Input
    element
    position
    List
    New List
*/
updateEle(H, 0, [_|T], [H|T]).
updateEle(H, N, [X|T], [X|L]):-
  N1 is N - 1,
  updateEle(H,N1,T, L).

%formats the board on screen for testing
printBoard([Player,won,_]):-
  write("VICTORY! Player: "),
  write(Player),
  write(" Won!"),nl.
printBoard([_,play,[ A0,A1,A2,A3,A4,A5,
                B0,B1,B2,B3,B4,B5,
                C0,C1,C2,C3,C4,C5,
                D0,D1,D2,D3,D4,D5,
                E0,E1,E2,E3,E4,E5,
                F0,F1,F2,F3,F4,F5 ]]):-
  nl,
  write('   '), write(A0),
  write(' | '), write(A1),
  write(' | '), write(A2),
  write(' | '), write(A3),
  write(' | '), write(A4),
  write(' | '), write(A5),nl,
  write('--------------------------'),nl,
  write('   '), write(B0),
  write(' | '), write(B1),
  write(' | '), write(B2),
  write(' | '), write(B3),
  write(' | '), write(B4),
  write(' | '), write(B5),nl,
  write('--------------------------'),nl,
  write('   '), write(C0),
  write(' | '), write(C1),
  write(' | '), write(C2),
  write(' | '), write(C3),
  write(' | '), write(C4),
  write(' | '), write(C5),nl,
  write('--------------------------'),nl,
  write('   '), write(D0),
  write(' | '), write(D1),
  write(' | '), write(D2),
  write(' | '), write(D3),
  write(' | '), write(D4),
  write(' | '), write(D5),nl,
  write('--------------------------'),nl,
  write('   '), write(E0),
  write(' | '), write(E1),
  write(' | '), write(E2),
  write(' | '), write(E3),
  write(' | '), write(E4),
  write(' | '), write(E5),nl,
  write('--------------------------'),nl,
  write('   '), write(F0),
  write(' | '), write(F1),
  write(' | '), write(F2),
  write(' | '), write(F3),
  write(' | '), write(F4),
  write(' | '), write(F5),nl.
