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

    Conjunto = set of 1..21;



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
        Numeros_aleatorio: Conjunto;

	Begin


		{Precondicion: True  }

        Randomize;

        Numeros_aleatorio:=[];

            Cartas_Usadas2[1] := Senora_Blanco;
			Cartas_Usadas2[2] := Senora_Celeste;
			Cartas_Usadas2[3] := Senorita_Escarlata;
            Cartas_Usadas2[4] := Profesor_Ciruela;
	        Cartas_Usadas2[5] := Coronel_Mostaza;
	        Cartas_Usadas2[6] := Senor_Verde;
			Cartas_Usadas2[7] := Candelabro;
			Cartas_Usadas2[8] := Cuchillo;
			Cartas_Usadas2[9] := Cuerda;
			Cartas_Usadas2[10] := Llave_Inglesa;
			Cartas_Usadas2[11] := Revolver;
			Cartas_Usadas2[12] := Tubo;
			Cartas_Usadas2[13] := Biblioteca;
			Cartas_Usadas2[14] := Cocina;
			Cartas_Usadas2[15] := Comedor;
			Cartas_Usadas2[16] := Estudio;
			Cartas_Usadas2[17] := Vestibulo;
			Cartas_Usadas2[18] := Salon;
			Cartas_Usadas2[19] := Invernadero;
			Cartas_Usadas2[20] := Sala_de_Baile;
			Cartas_Usadas2[21] := Sala_de_Billar;


                For Barajeo:= 1 to 21 do
				

                Begin

					NCarta := random(21)+1;

                        if ((NCarta in Numeros_aleatorio) = true) then

                                Begin

                                    Repeat

										NCarta := random(21)+1;

									Until((NCarta in Numeros_aleatorio) = false);

                                End;


                    Numeros_aleatorio:= Numeros_aleatorio + [NCarta];
					tmp:= Cartas_Usadas2[Barajeo];
					Cartas_Usadas2[Barajeo]:= Cartas_Usadas2[NCarta];
					Cartas_Usadas2[Ncarta]:= tmp;

		    End;

                        For NCarta:= 1 to 21 do

                        Begin

                                wRITELN(Cartas_Usadas2[NCarta]);
                                Readln;

                        ENd;
End;


Var

	Njugadores2 : integer;      // Numero de jugadores
	Mano1: ArrayMano;   // Cartas de cada jugador
	Cartas_Usadas2 : ArrayCartasUsadas;


Begin

clrscr;

	Inicio(Njugadores2,Mano1,Cartas_Usadas2);

Readkey;


End.
