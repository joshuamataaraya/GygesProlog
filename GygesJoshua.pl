/*
INSTITUTO TECNOLOGICO DE COSTA RICA
JOSHUA MATA ARAYA
2014079095


MANUAL DE USUARIO
INGRESAR   mejorJugada(Tabla,TablaFinal,PosicionIncial,PosicionFinal,Jugador) PARA VER EL SIGUIENTE MOVIMIENTO

TABLA DE ERRORES
EL SISTEMA BUSCA SOLUCION, SI NO LA ENCUENTRA, devuelve CUALQUIER SOLUCION.
*/

tablaMia([0,0,2,0,1,0,
          0,0,0,0,0,0,
          0,0,0,0,0,0,
          0,0,3,0,0,0,
          0,0,0,0,0,0,
          0,0,0,0,0,0]).


/*
Relacion queda un formato a la tabla de entrada
*/
tabla(X,Format):-
  X = [E11,E12,E13,E14,E15,E16,
        E21,E22,E23,E24,E25,E26,
        E31,E32,E33,E34,E35,E36,
        E41,E42,E43,E44,E45,E46,
        E51,E52,E53,E54,E55,E56,
        E61,E62,E63,E64,E65,E66],
  Format = [[E11,11],[E12,12],[E13,13],[E14,14],[E15,15],[E16,16],
  [E21,21],[E22,22],[E23,23],[E24,24],[E25,25],[E26,26],
  [E31,31],[E32,32],[E33,33],[E34,34],[E35,35],[E36,36],
  [E41,41],[E42,42],[E43,43],[E44,44],[E45,45],[E46,46],
  [E51,51],[E52,52],[E53,53],[E54,54],[E55,55],[E56,56],
  [E61,61],[E62,62],[E63,63],[E64,64],[E65,65],[E66,66]].

  /*
  Relacion que devuelve el elemento de arriba
  */
  elemArriba(_, [Elem,Pos],[Elem2,Pos2],Jugador):-
    Jugador = i,
    between(11,16,Pos),
    Elem2 =Elem,
    Pos2 = -1.

  elemArriba([[Head,Second]|ColaTabl], [Elem,Pos],[Elem2,Pos2],Jugador):-
    Pos2 is Pos-10,
    Second = Pos2,
    Elem2=Head;
    elemArriba(ColaTabl,[Elem,Pos],[Elem2,Pos2],Jugador).

  /*
  Relacion que devuelve el elemento de abajo
  */
  elemAbajo(_, [Elem,Pos],[Elem2,Pos2],Jugador):-
    Jugador = c,
    between(61,66,Pos),
    Elem2 =Elem,
    Pos2 = -1.

  elemAbajo([[Head,Second]|ColaTabl], [Elem,Pos],[Elem2,Pos2],Jugador):-
    Pos2 is Pos+10,
    Second = Pos2,
    Elem2=Head;
    elemAbajo(ColaTabl,[Elem,Pos],[Elem2,Pos2],Jugador).

  /*
  Relacion que devuelve el elemento de derecha
  */
  elemDer([[Head,Second]|ColaTabl], [Elem,Pos],[Elem2,Pos2]):-
    Pos2 is Pos+1,
    Second = Pos2,
    Elem2=Head;
    elemDer(ColaTabl,[Elem,Pos],[Elem2,Pos2]).

  /*
  Relacion que devuelve el elemento de izquierda
  */
  elemIzq([[Head,Second]|ColaTabl], [Elem,Pos],[Elem2,Pos2]):-
    Pos2 is Pos-1,
    Second = Pos2,
    Elem2=Head;
    elemIzq(ColaTabl,[Elem,Pos],[Elem2,Pos2]).

  elemsAlLado(Tabla,Elem,Elem2,_):-elemIzq(Tabla,Elem,Elem2).
  elemsAlLado(Tabla,Elem,Elem2,_):-elemDer(Tabla,Elem,Elem2).
  elemsAlLado(Tabla,Elem,Elem2,Jugador):-elemArriba(Tabla,Elem,Elem2,Jugador).
  elemsAlLado(Tabla,Elem,Elem2,Jugador):-elemAbajo(Tabla,Elem,Elem2,Jugador).

  analizaPosibles(_,[],ListaVieja,Inserted,_,_,_):-Inserted=ListaVieja.
  analizaPosibles(Tabla,[[Elem,Pos]|Cola],ListaVieja,Inserted,Restantes,Recorrido,Jugador):-
    not(Elem=0), %ultimo movimiento y ya hay una ficha
    Restantes = 1,
    not(member([Elem,Pos],Recorrido)), %se controla el recorrido para evitar ciclos infinitos
    append(Recorrido,[[Elem,Pos]],RecorridoNuevo),
    bagof([Elem3,PosFinal],elemsAlLado(Tabla,[Elem,Pos],[Elem3,PosFinal],Jugador),AlLado),
    analizaPosibles(Tabla,AlLado,ListaVieja,Posibles,Elem,RecorridoNuevo,Jugador),
    analizaPosibles(Tabla,Cola,Posibles,Inserted,Restantes,RecorridoNuevo,Jugador);
    Elem=0, %ultimo movimiento y no hay ficha
    Restantes = 1,
    not(member([Elem,Pos],ListaVieja)),
    append(ListaVieja,[[Elem,Pos]],ListaNueva),
    not(member([Elem,Pos],Recorrido)),
    analizaPosibles(Tabla,Cola,ListaNueva,Inserted,Restantes,Recorrido,Jugador);
    Elem=0, % no es el ultimo movimiento
    Restantes >1,
    RestantesAux is Restantes-1,
    not(member([Elem,Pos],Recorrido)),
    append(Recorrido,[[Elem,Pos]],RecorridoNuevo),
    bagof([Elem3,PosFinal],elemsAlLado(Tabla,[Elem,Pos],[Elem3,PosFinal],Jugador),AlLado),
    analizaPosibles(Tabla,AlLado,ListaVieja,Posibles,RestantesAux,RecorridoNuevo,Jugador),
    analizaPosibles(Tabla,Cola,Posibles,Inserted,Restantes,Recorrido,Jugador);
    analizaPosibles(Tabla,Cola,ListaVieja,Inserted,Restantes,Recorrido,Jugador). %hay una ficha en el lugar

  /*
    RELACION QUE PERMITE VER TODOS LOS MOVIMIENTOS DE UNA FICHA EN ESPECIFICO
  */
  posibleMovimiento(Tabla,[Elem,PosInicial],Posibles,Jugador):-
    bagof([Elem3,PosFinal],elemsAlLado(Tabla,[Elem,PosInicial],[Elem3,PosFinal],Jugador),AlLado),
    analizaPosibles(Tabla,AlLado,[],Posibles,Elem,[],Jugador).

  % c hace referencia al que juega arriba del tablero
  operacionJugador(Jugador,Fila,FilaNueva):-
    Jugador = c,
    FilaNueva is Fila+1.

  % i hace referencia al que juega abajo del tablero
  operacionJugador(Jugador,Fila,FilaNueva):-
    Jugador = i,
    FilaNueva is Fila-1.

  posiblesFichasAux(_,_,FichasAux,_,0,Fichas):-
    not(FichasAux = []),
    Fichas = FichasAux.
  posiblesFichasAux([[Elem|Pos]|Cola],Jugador,FichasAux,Fila,0,Fichas):-
    FichasAux = [],
    operacionJugador(Jugador,Fila,FilaAux),
    posiblesFichasAux([[Elem|Pos]|Cola],Jugador,FichasAux,FilaAux,6,Fichas).

  posiblesFichasAux([[Elem|Pos]|Cola],Jugador,FichasAux,Fila,Cont,Fichas):-
    Elem>0,
    PosAux is Pos//10,
    Fila=PosAux,
    append(FichasAux,[[Elem|Pos]],FichasAux2),
    ContAux is Cont-1,
    posiblesFichasAux(Cola,Jugador,FichasAux2,Fila,ContAux,Fichas);
    ContAux is Cont-1,
    posiblesFichasAux(Cola,Jugador,FichasAux,Fila,ContAux,Fichas).

  /*
    RELACION QUE PERMITE VER TODAS LAS FICHAS DE UN JUGADOR
  */
  posiblesFichas(Tabla,Jugador,Fichas):-
    Jugador = c,
    posiblesFichasAux(Tabla,Jugador,[],1,6,Fichas).
  posiblesFichas(Tabla,Jugador,Fichas):-
    Jugador = i,
    reverse(Tabla,TablaAux),
    posiblesFichasAux(TablaAux,Jugador,[],6,6,Fichas).

  jugadasDeUnJugadorAux(_,_,Jugadas,[],JugadasAux):-Jugadas=JugadasAux.
  jugadasDeUnJugadorAux(Tabla,Jugador,Jugadas,[[Elem,Pos]|Cola],JugadasAux):-
    posibleMovimiento(Tabla,[Elem,Pos],Posibles,Jugador),
    append(JugadasAux,[[[Elem,Pos],Posibles]],JugadasNuevas),
    jugadasDeUnJugadorAux(Tabla,Jugador,Jugadas,Cola,JugadasNuevas).

  jugadasDeUnJugador(Tabla,Jugador,Jugadas):-
    posiblesFichas(Tabla,Jugador,Fichas),
    jugadasDeUnJugadorAux(Tabla,Jugador,Jugadas,Fichas,[]).

  moverFichaAux([],_,_,TablaNueva,TablaAux):-
    TablaNueva=TablaAux.

  moverFichaAux([[_,PosTabla]|Cola],[Elem1,Pos1],[_,Pos2],TablaNueva,TablaAux):-
    PosTabla = Pos1,
    append(TablaAux,[[0,PosTabla]],TablaAux2),
    moverFichaAux(Cola,[Elem1,Pos1],[_,Pos2],TablaNueva,TablaAux2).

  moverFichaAux([[_,PosTabla]|Cola],[Elem1,Pos1],[_,Pos2],TablaNueva,TablaAux):-
    PosTabla = Pos2,
    append(TablaAux,[[Elem1,PosTabla]],TablaAux2),
    moverFichaAux(Cola,[Elem1,Pos1],[_,Pos2],TablaNueva,TablaAux2).

  moverFichaAux([[ElemTabla,PosTabla]|Cola],[Elem1,Pos1],[_,Pos2],TablaNueva,TablaAux):-
    append(TablaAux,[[ElemTabla,PosTabla]],TablaAux2),
    moverFichaAux(Cola,[Elem1,Pos1],[_,Pos2],TablaNueva,TablaAux2).

  moverFicha(Tabla,Elem,[_,Pos2],TablaNueva):-
    moverFichaAux(Tabla,Elem,[_,Pos2],TablaNueva,[]).

  asignarPuntajes(_,_,_,3,_,_).

  asignarPuntajes(Tabla,Jugador,[[Elem,[[JugadaElem,JugadaPos]|RestoJugadas]]|RestoFichas],_,ElemPos1,ElemPos2):-
    JugadaPos = -1,
    ElemPos1=Elem,
    ElemPos2=[JugadaElem,JugadaPos],
    asignarPuntajes(Tabla,Jugador,[[Elem|RestoJugadas]|RestoFichas],3,ElemPos1,ElemPos2).

  asignarPuntajes(Tabla,Jugador,[[Elem,[[_,_]|RestoJugadas]]|RestoFichas],_,ElemPos1,ElemPos2):-
    asignarPuntajes(Tabla,Jugador,[[Elem,RestoJugadas]|RestoFichas],0,ElemPos1,ElemPos2).
  asignarPuntajes(Tabla,Jugador,[[_,[[_,_]|_]]|RestoFichas],_,ElemPos1,ElemPos2):-
    asignarPuntajes(Tabla,Jugador,[RestoFichas],0,ElemPos1,ElemPos2).


/*
  Si el algoritmo puede ganar, lo hace, si no puede, da una solucion aleatoria.
*/
  mejorJugada(Tabla,TablaFinal,PosicionIncial,PosicionFinal,Jugador):-
    jugadasDeUnJugador(Tabla,Jugador,Jugadas),
    asignarPuntajes(Tabla,Jugador,Jugadas,0,ElemPos1,ElemPos2),
    moverFicha(Tabla,ElemPos1,ElemPos2,TablaFinal),
    PosicionIncial=ElemPos1,
    PosicionFinal=ElemPos2;
    jugadasDeUnJugador(Tabla,Jugador,[[Elem,[[JugadaElem,JugadaPos]|_]]|_]),
    ElemPos1=Elem,
    ElemPos2=[JugadaElem,JugadaPos],
    moverFicha(Tabla,ElemPos1,ElemPos2,TablaFinal),
    PosicionIncial=ElemPos1,
    PosicionFinal=ElemPos2.
/*
siguienteMov(TableroInicial,TableroFinal,PosicionIncial,PosicionFinal,Jugador):-
*/
