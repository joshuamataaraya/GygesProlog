/*
  start a game with an empty board
*/
gyges:- game([e,e,e,e,e,e,
              e,e,e,e,e,e,
              e,e,e,e,e,e,
              e,e,e,e,e,e,
              e,e,e,e,e,e,
              e,e,e,e,e,e ]
              , 1).

/*
  Play based on current board situation.
  For example if someone won we find out here :)
*/
game(Board, Player):-
    starting(Board,Player).

/*
  The id of every slot on the board
*/
slotsId([
          "A0", "A1","A2","A3","A4","A5",
          "B0", "B1","B2","B3","B4","B5",
          "C0", "C1","C2","C3","C4","C5",
          "D0", "D1","D2","D3","D4","D5",
          "E0", "E1","E2","E3","E4","E5",
          "F0", "F1","F2","F3","F4","F5"
        ]).

/*
  A piece that is related to position X on the Board
  where X is the id of the slot as in "slotsId"
  Piece is the variable to "solve" for
*/
getPiece(Pos,Piece,Board):-
    slotsId(PosL),
    getPieceAux(Pos, Piece, PosL, Board).

/*this is the piece*/
getPieceAux(Pos,Piece,[Pos|_],[Piece|_]).
getPieceAux(X, Piece, [Pos|PosL], [_|PieceL]):-
    getPieceAux(X,Piece, PosL, PieceL).
