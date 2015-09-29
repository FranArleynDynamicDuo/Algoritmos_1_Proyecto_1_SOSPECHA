(*
  SOSPECHA
  Descripcion: Programar el juego de sospecha
  Autor: Arleyn Goncalves
		 Francisco Sucre
  Fecha: 01/03/2013
*)

Program CluedoUSB;

Uses crt;

Type

	CartGlobal = (Senora_Blanco,Senora_Celeste,Senorita_Escarlata,
                  Profesor_Ciruela,Coronel_Mostaza,Senor_Verde,
                  Candelabro,Cuchillo,Cuerda,Llave_Inglesa,Revolver,Tubo,
                  Biblioteca,Cocina,Comedor,Estudio,Vestibulo,
				  Salon,Invernadero,Sala_de_Baile,Sala_de_Billar);

	// Total cartas en el juego

    Personaje  = Senora_Blanco..Senor_Verde;

	// Cartas de Personajes

	Arma       = Candelabro..Tubo;

	// Cartas de Armas

	Lugar      = Biblioteca..Sala_de_Billar;

	// Cartas de lugar.

	Direccion  = (Arriba,Abajo,Derecha,Izquierda,Parar);

	// Posibles direcciones de movimiento

	Cartas_Jugar = 3..6;

	// Numero de cartas por jugador.

	Dado       = 1..6; // Valores del dado

	Posicion   = 1..5; // Valores de Posiciones

	IdemP      = 1..6; // Identificacion de jugadores

	ArrayIdem       = Array[IdemP] of Personaje;

	// Relacion entre jugador y personaje

	Afirmacion = (Si,No); //Posibles respuestas para algunas preguntas

		ArrayMov =  Array[Personaje] of Array [Posicion] of Array[Posicion]
				of Lugar;

	ArrayMano = Array[Personaje] of array[Cartas_Jugar] of CartGlobal;

	ArrayPosicion = Array[Personaje] of Posicion;

	ArrayCartasUsadas = Array[1..21] of CartGlobal;

	ArrayComparacion = Array[1..21] of Boolean;


	Carta      = record

		Arma     : Arma; // Carta de Arma
		Lugar    : Lugar; // Carta de Lugar
		Personaje: Personaje; // Carta de Personaje

	end;
(******************************************************************************)
(*					              INICIO                    				  *)
(******************************************************************************)


	Procedure Inicio( Var Njugadores2 : integer;      // Numero de jugadores
					  Var Mano1: ArrayMano;   // Cartas de cada jugador
					  Var Cartas_Usadas2 : ArrayCartasUsadas
					);

	Const

	   Max_Cartas = 18; // Maximo de cartas a repartir

	Var

		Particion_cartas : Integer;
		NCarta : Integer;
		Barajeo : Integer;
		Iteracion : Integer;
		Iteracion2 : Integer;
		RevisionFinal : Boolean;
		Revision : integer;
		Repetidas : ArrayComparacion;
		IdemReparte : ArrayIdem;
		tmp : CartGlobal;
        Culpable1 : Carta;
        Cartas_usadas1: ArraycartasUsadas;

	Begin

		{Precondicion: True  }

                Randomize;

		Cartas_Usadas1[1]:= Senor_Verde;
		Cartas_Usadas1[2]:= Cuerda;
		Cartas_usadas1[3]:= Biblioteca;

		For Barajeo := 1 To 21 Do

			Begin

				Case Barajeo of

					1 : Cartas_Usadas2[Barajeo] := Senora_Blanco;
					2 : Cartas_Usadas2[Barajeo] := Senora_Celeste;
					3 : Cartas_Usadas2[Barajeo] := Senorita_Escarlata;
					4 : Cartas_Usadas2[Barajeo] := Profesor_Ciruela;
					5 : Cartas_Usadas2[Barajeo] := Coronel_Mostaza;
					6 : Cartas_Usadas2[Barajeo] := Senor_Verde;
					7 : Cartas_Usadas2[Barajeo] := Candelabro;
					8 : Cartas_Usadas2[Barajeo] := Cuchillo;
					9 : Cartas_Usadas2[Barajeo] := Cuerda;
					10: Cartas_Usadas2[Barajeo] := Llave_Inglesa;
					11: Cartas_Usadas2[Barajeo] := Revolver;
					12: Cartas_Usadas2[Barajeo] := Tubo;
					13: Cartas_Usadas2[Barajeo] := Biblioteca;
					14: Cartas_Usadas2[Barajeo] := Cocina;
					15: Cartas_Usadas2[Barajeo] := Comedor;
					16: Cartas_Usadas2[Barajeo] := Estudio;
					17: Cartas_Usadas2[Barajeo] := Vestibulo;
					18: Cartas_Usadas2[Barajeo] := Salon;
					19: Cartas_Usadas2[Barajeo] := Invernadero;
					20: Cartas_Usadas2[Barajeo] := Sala_de_Baile;
					21: Cartas_Usadas2[Barajeo] := Sala_de_Billar;


				End;

				If (( Barajeo <= 21) and (Cartas_Usadas2[Barajeo] <> Cartas_Usadas1[1])
                                and (Cartas_Usadas2[Barajeo] <> Cartas_Usadas1[2]) and
                                (Cartas_Usadas2[Barajeo] <> Cartas_Usadas1[3])) then

					Begin

                                                wRITELN(Cartas_Usadas2[Barajeo]);
                                                Readln;
						NCarta := random(17) + 4;
                                                Writeln(NCarta);
                                                Readln;
						tmp:= Cartas_Usadas2[Barajeo];
						Cartas_Usadas2[Barajeo]:= Cartas_Usadas2[Ncarta];
						Cartas_Usadas2[NCarta]:= tmp;
                                                Writeln(Cartas_Usadas2[NCarta]);


					End;

			End;

                        For Ncarta:= 4 to 21 do

                        Begin

                                wRITELN(Cartas_Usadas2[Ncarta]);
                                Readln;

                        ENd;
End;

Var

	Njugadores2 : integer;      // Numero de jugadores
	Mano1: ArrayMano;   // Cartas de cada jugador
	Cartas_Usadas2 : ArrayCartasUsadas;


Begin

	Inicio(Njugadores2,Mano1,Cartas_Usadas2);


End.
