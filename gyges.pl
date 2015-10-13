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
    game([1,e,e,e,e,e,
          e,e,e,e,e,e,
          e,e,e,e,e,e,
          e,e,e,e,e,e,
          e,e,e,e,e,e,
          e,e,e,e,e,e ]
          ,1).

%The id of every slot on the board
slotsId([
          "A0", "A1","A2","A3","A4","A5",
          "B0", "B1","B2","B3","B4","B5",
          "C0", "C1","C2","C3","C4","C5",
          "D0", "D1","D2","D3","D4","D5",
          "E0", "E1","E2","E3","E4","E5",
          "F0", "F1","F2","F3","F4","F5"
        ]).

%what player are we?
aiPlayer(1). %this needs to bet set dinamically from C gui
nextPlayer(1,2).
nextPlayer(2,1).

%the current player is max and next min
max_to_move([P,_,_]):- aiPlayer(P).
min_to_move([P,_,_]):- aiPlayer(X),nextPlayer(X,P).

%game states score respectively base on last move
utility([P, won, _], 1):- aiPlayer(X),nextPlayer(X,P).
utility([P, won, _], -1):- aiPlayer(P).

%Moves, use prolog backtracking to solve for win
move([X1, play, Board], [X2, won, _]) :-
    nextPlayer(X1,X2),
    move_aux(X1, won, _, Board, _), !.

move([X1, play, Board], [X2, play, NextBoard]) :-
    nextPlayer(X1,X2),
    move_aux(X1, play,_, Board, NextBoard).

%lvl 1 piece victory conditions
move_aux(P, won, 2, Board , _):- %position that can obtain victory
    selectEle(Piece, 2, Board),
    Piece = 1.
move_aux(P, won, 3, Board , _):- %position that can obtain victory
    selectEle(Piece, 3, Board),
    Piece = 1.

%if Pos hasn't been instanciated start it in 0
move_aux(P,State,Pos,Board,NextBoard):-
    var(Pos),
    move_aux(P,State,0,Board,NextBoard).
% %move one right
move_aux(P, play , Pos, Board,AfterMove):-
    \+ var(Pos),
    selectEle(1, Pos, Board),
    updateEle(e, Pos, Board, NewBoard),
    N1 is Pos + 1,
    updateEle(1, N1, NewBoard, AfterMove).
move_aux(P, play , Pos, Board, AfterMove) :-
    \+ var(Pos),
    length(Board,L),
    Pos < L,
    NextPiece = Pos + 1,
    move_aux(P, _ , NextPiece, Board, AfterMove).

/*
  MiniMax Relations
*/
minimax(Pos, BestNextPos, Val) :-
    %all posible board moves
    bagof(NextPos, move(Pos, NextPos), NextPosList),
    %pick the move that can lead to win
    best(NextPosList, BestNextPos, Val), !.

%no next move
minimax(Pos, _, Val) :-
    utility(Pos, Val).

%pick the best scored move from the list of boards
best([Pos], Pos, Val) :-
    minimax(Pos, _, Val), !.
best([Pos1 | PosList], BestPos, BestVal) :-
    minimax(Pos1, _, Val1),
    best(PosList, Pos2, Val2),
    betterOf(Pos1, Val1, Pos2, Val2, BestPos, BestVal).

%compare move value
betterOf(Pos0, Val0, _, Val1, Pos0, Val0) :-
    min_to_move(Pos0),
    Val0 > Val1, !
    ;
    max_to_move(Pos0),
    Val0 < Val1, !.

betterOf(_, _, Pos1, Val1, Pos1, Val1).        % Otherwise Pos1

bestMove(GameState, NextState):-
  minimax(GameState, NextState,_).

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












%
% /*
%   Play based on current board situation.
%   For example if someone won we find out here :)
% */
% game(Board, Player, Moves):-
%   play(Board, Player, Board, Moves,0).
%
% play(_,_,_,Moves,35).
% play(Board, Player, [Piece|PiecesL], [AfterMove|Moves], N):-
%     move(Piece, Board, N,AfterMove),
%     N1 is N+1,
%     play(Board, Player, PiecesL, Moves,N1).
%
% %Check every move posible
% move(e,_,_,nil). %if blank slot do nothing*/


% /*move one down*/
% move(1, Board,N,AfterMove):-
%   updateEle(e, N, Board, NewBoard),
%   N6 is N + 6,
%   updateEle(1, N6, NewBoard, AfterMove).
%
% /*
%   A piece that is related to position X on the Board
%   where X is the id of the slot as in "slotsId"
%   Piece is the variable to "solve" for
% */
% getPiece(Pos,Piece,Board):-
%     slotsId(PosL),
%     getPieceAux(Pos, Piece, PosL, Board).
%
% /*this is the piece*/
% getPieceAux(Pos,Piece,[Pos|_],[Piece|_]).
% getPieceAux(X, Piece, [Pos|PosL], [_|PieceL]):-
%     getPieceAux(X,Piece, PosL, PieceL).
%
%
