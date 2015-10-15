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
gyges:-
    testBoard(X),
    write('Before Move'),nl,
    printBoard([_,_,X]),
    bestMove([1,_,X], AfterMove),
    write('After Move'),nl,
    printBoard(AfterMove).

%a test board
testBoard([ 1,2,e,e,e,e,
            e,e,e,e,e,e,
            e,e,e,e,e,e,
            e,e,e,e,e,e,
            e,e,e,e,e,e,
            1,2,e,e,e,e ]).


%what player are we?
aiPlayer(1). %this needs to bet set dinamically from C gui
nextPlayer(1,2).
nextPlayer(2,1).

%the current player is max and next min
maxMove([P,_,_]):- aiPlayer(P).
minMov([P,_,_]):- aiPlayer(X),nextPlayer(X,P).

%game states score respectively base on last move
utility([P, won, _], 2):- aiPlayer(X),nextPlayer(X,P).
utility([P, won, _], -2):- aiPlayer(P).
%give a small score for moving, we always have to move
utility([P, play, _], 1):- aiPlayer(X),nextPlayer(X,P).
utility([P, play, _], -1):- aiPlayer(P).

%Moves, use prolog backtracking to solve for win
move([X1, play, Board], [X2, won, _]) :-
    nextPlayer(X1,X2),
    moveAux(X1, won, _, Board, _), !.

move([X1, play, Board], [X2, play, NextBoard]) :-
    nextPlayer(X1,X2),
    moveAux(X1, play,_, Board, NextBoard).

%lvl 1 piece victory conditions
moveAux(P, won, 2, Board , _):- %position that can obtain victory
    selectEle(Piece, 2, Board),
    Piece = 1.
moveAux(P, won, 3, Board , _):- %position that can obtain victory
    selectEle(Piece, 3, Board),
    Piece = 1.

%if Pos hasn't been instanciated start it in 0
moveAux(P,State,Pos,Board,NextBoard):-
    var(Pos),
    moveAux(P,State,0,Board,NextBoard).

/*One lvl Pieces*/
%move one right
moveAux(P, play , Pos, Board,AfterMove):-
    \+ var(Pos),
    selectEle(CurEle, Pos, Board),
    \+ CurEle = e,
    updateEle(e, Pos, Board, NewBoard),
    playOption(Pos,N1,CurEle),
    selectEle(MovingTo, N1, Board),
    MovingTo = e,
    updateEle(CurEle, N1, NewBoard, AfterMove).
%if we land on another piece
moveAux(P, play , Pos, Board,AfterMove):-
    \+ var(Pos),
    selectEle(CurEle, Pos, Board),
    \+ CurEle = e,
    updateEle(e, Pos, Board, NewBoard),
    playOption(Pos,N1,CurEle),
    selectEle(MovingTo, N1, Board),
    \+ MovingTo = e,
    Skip is N1 + MovingTo,
    updateEle(CurEle, Skip, NewBoard, AfterMove).

moveAux(P, play , Pos, Board, AfterMove) :-
    \+ var(Pos),
    length(Board,L),
    Pos < L,
    NextPiece = Pos + 1,
    moveAux(P, _ , NextPiece, Board, AfterMove).

%our posible moves in the list
playOption(N, N1,Ele):-
  Mod is N mod 6, %don't want to go over the edge of the board
  Mod + Ele < 6,
  N1 is N + Ele.
playOption(N, N1,Ele):-
  Mod is N mod 6, %don't want to go over the edge of the board
  Mod - Ele > 0,
  N1 is N - Ele.

/*
  Min Max
*/
minMax(Pos, BestNextPos, Val,Depth) :-
    %all posible board moves
    bagof(NextPos, move(Pos, NextPos), NextPosList),
    %pick the move that can lead to win
    best(NextPosList, BestNextPos, Val,Depth), !.
%no next move
minMax(Pos, _, Val, _) :-
    utility(Pos, Val).

%pick the best scored move from the list of boards
best([Pos], Pos, Val,Depth) :-
    Depth < 1,
    N1 is Depth + 1,
    minMax(Pos, _, Val, N1).
best([Pos1 | PosList], BestPos, BestVal,Depth) :-
    Depth < 1,
    N1 is Depth + 1,
    minMax(Pos1, _, Val1,N1),
    best(PosList, Pos2, Val2,Depth),
    betterOf(Pos1, Val1, Pos2, Val2, BestPos, BestVal).

%compare move value
betterOf(Pos0, Val0, _, Val1, Pos0, Val0) :-
    minMov(Pos0),
    Val0 > Val1, !
    ;
    maxMove(Pos0),
    Val0 < Val1, !.
betterOf(_, _, Pos1, Val1, Pos1, Val1).

%given a game state get the best posible next state
bestMove(GameState, NextState):-
  minMax(GameState, NextState, _, 0). %last arg is tree depth

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
printBoard([_,_,[ A0,A1,A2,A3,A4,A5,
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
