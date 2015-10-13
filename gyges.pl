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
gyges(Moves):-
    game([1,e,e,e,e,e,
          e,e,e,e,e,e,
          e,e,e,e,e,e,
          e,e,e,e,e,e,
          e,e,e,e,e,e,
          e,e,e,e,e,e ]
          , 1, Moves).

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
curPlayer(1). %this needs to bet set dinamically from C gui
nextPlayer(2):- curPlayer(1).
nextPlayer(1):- curPlayer(2).

%the current player is max and next min
max_to_move([P,_,_]):- curPlayer(P).
min_to_move([P,_,_]):- nextPlayer(P).

%game states score respectively base on last move
utility([P, won, _], -1):- curPlayer(P).
utility([P, won, _], 1):- nextPlayer(P).

%Moves, use prolog backtracking to solve for win
move([X1, play, Board], [X2, win, NextBoard]) :-
    nextPlayer(X1, X2),
    move_aux(X1, Board, NextBoard),
    winPos(X1, NextBoard), !.

move([X1, play, Board], [X2, play, NextBoard]) :-
    nextPlayer(X1, X2),
    move_aux(X1, Board, NextBoard).

move_aux(P, [0|Bs], [P|Bs]).

move_aux(P, [B|Bs], [B|B2s]) :-
    move_aux(P, Bs, B2s).



/*
  MiniMax Relations
*/
minimax(Pos, BestNextPos, Val) :-                     % Pos has successors
    bagof(NextPos, move(Pos, NextPos), NextPosList),
    best(NextPosList, BestNextPos, Val), !.

minimax(Pos, _, Val) :-                     % Pos has no successors
    utility(Pos, Val).


best([Pos], Pos, Val) :-
    minimax(Pos, _, Val), !.

best([Pos1 | PosList], BestPos, BestVal) :-
    minimax(Pos1, _, Val1),
    best(PosList, Pos2, Val2),
    betterOf(Pos1, Val1, Pos2, Val2, BestPos, BestVal).


betterOf(Pos0, Val0, _, Val1, Pos0, Val0) :-   % Pos0 better than Pos1
    min_to_move(Pos0),                         % MIN to move in Pos0
    Val0 > Val1, !                             % MAX prefers the greater value
    ;
    max_to_move(Pos0),                         % MAX to move in Pos0
    Val0 < Val1, !.                            % MIN prefers the lesser value

betterOf(_, _, Pos1, Val1, Pos1, Val1).        % Otherwise Pos1
















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
% %move one right
% move(1, Board,N,AfterMove):-
%   updateEle(e, N, Board, NewBoard),
%   N1 is N + 1,
%   updateEle(1, N1, NewBoard, AfterMove).
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
% /*
%   Get operations on lists
%   @Input
%     element
%     position
%     List
% */
% selectEle(H, 0, [H|_]).
% selectEle(H,N,[_|T]):-
%   N1 is N - 1,
%   selectEle(H,N1,T).
%
% /*
%   Update operations on lists
%   @Input
%     element
%     position
%     List
%     New List
% */
% updateEle(H, 0, [_|T], [H|T]).
% updateEle(H, N, [X|T], [X|L]):-
%   N1 is N - 1,
%   updateEle(H,N1,T, L).
%
