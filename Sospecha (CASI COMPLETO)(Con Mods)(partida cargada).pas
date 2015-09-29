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

	CartGlobal = (SenioraBlanco,SenioraCeleste,SenioritaaEscarlata,
                  ProfesorCiruela,CoronelMostaza,SeniorVerde,
                  Candelabro,Cuchillo,Cuerda,LlaveInglesa,Revolver,Tubo,
                  Biblioteca,Cocina,Comedor,Estudio,Vestibulo,
				  Salon,Invernadero,SalaDeBaile,SalaDeBillar,Pasillo,Vacio);

	// Total cartas en el juego

    Personaje  = SenioraBlanco..SeniorVerde;

	// Cartas de Personajes

	Arma       = Candelabro..Tubo;

	// Cartas de Armas

	Lugar      = Biblioteca..Pasillo;

	// Cartas de lugar.

	Direccion  = (Arriba,Abajo,Derecha,Izquierda,Parar);

	// Posibles direcciones de movimiento

	Cartas_Jugar = 1..6;

	// Numero de cartas por jugador.

	Dado       = 0..6; // Valores del dado

	Posicion   = 1..5; // Valores de Posiciones

	IdemP      = 1..8; // Identificacion de jugadores

	ArrayIdem       = Array[IdemP] of Personaje;

	// Relacion entre jugador y personaje

	Afirmacion = (Si,No); //Posibles respuestas para algunas preguntas

	ArrayMov =  Array[Personaje] of Array [Posicion] of Array[Posicion]
				of Lugar;
				
	// Define la posicion de un jugador en el tablero

	ArrayMano = Array[Personaje] of array[1..21] of CartGlobal;
	
	// La mano de cada jugador, teniendo el personaje a la cual pertenece y
	// el numero de la carta que se quiere usar

	ArrayPosicion = Array[Personaje] of Posicion;
	
	// Usado para memorizar las posiciones verticales y horizontales de
	// cada jugador de manera independiente

	ArrayCartasUsadas = Array[1..21] of CartGlobal;
	
	// Usado para barajear y repartir las cartas, ayudando a que no se
	// repitan

	Array_Nrefutadas = Array[Personaje] of Integer;

	// Usado para memorizar el numero de cartas refutadas para cada jugador
	
	Conjunto = set of 1..21;
	
	// Es el rango del conjunto de cartas.

	Carta      = record

		Arma     : Arma; // Carta de Arma
		Lugar    : Lugar; // Carta de Lugar
		Personaje: Personaje; // Carta de Personaje

	end;

	Estado = (Activo, Eliminado);
	
	// Posibles estado de juego de los jugadores
	
	ArrayEstado = Array[Personaje] of Estado;
	
	// Usado para memorizar o comprar el estado de juego de cada jugador
	
	ArrayLugarGuardado = Array[Personaje] of CartGlobal;
	
	// Usado para memorizar el lugar de cada personaje al cargar una partida
	
(******************************************************************************)
(*					                Logo                     				  *)
(******************************************************************************)

	Procedure Logo; // Procedimiento que imprime el logo del juego
	
	Begin
	
		Textcolor(9);
		Writeln('                   ****  *    *   *  ****  ***     *****');
		Writeln('                   *     *    *   *  *     *   *   *   *');
		Writeln('                   *     *    *   *  ***   *   *   *   *');
		Writeln('                   *     *    *   *  *     *   *   *   *');
		Writeln('                   ****  ***  *****  ****  ****    *****');
	
	End;

(******************************************************************************)
(*					            INTRODUCCION                				  *)
(******************************************************************************)

	Procedure Introduccion(Var Opcion_Cargar : Afirmacion); // Mensaje de bienvenida

	Var

	   Instruccion   : Afirmacion;
	
	   // Variable Pregunta para decidir si jugar o no
	
	   Iniciar_Juego : Afirmacion;
	
	   // Variable Pregunta para decidir si leer las instrucciones o nombradas
	
	   codigo        : word;
	
	   // Variable para la correcion del "runtime error"
	
	   mensajeError  : string;
	
	   // Variable que indica el error

		Begin

			{Precondicion: true}

			Case codigo of

				106 : mensajeError:='Invalid number.';

			end;

				{$IOCHECKS OFF}

                Repeat


					Writeln;
					Textcolor(11);
					Writeln('Quiere cargar una partida?');
					Textcolor(7);
					Writeln;
					Readln(Opcion_Cargar);

					codigo:= ioResult;
					if codigo = 106 then

					Begin
							Writeln('Solo se puede ingresar la opcion si o no');

					End;

   				Until (codigo = 0);

				{$IOCHECKS ON}

			If (Opcion_Cargar = No) Then
			
				Begin
				
					{$IOCHECKS OFF}

					Repeat


						Writeln;
						Textcolor(11);
						Writeln('Quiere iniciar una partida ?');
						Textcolor(7);
						Writeln;
						Readln(Instruccion);

						codigo:= ioResult;
						if codigo = 106 then

						Begin
								Writeln('Solo se puede ingresar la opcion si o no');

						End;

					Until (codigo = 0);

					{$IOCHECKS ON}


					if (Instruccion = No) then

						Begin

							Writeln('Se ha salido del juego, hasta la proxima');
							halt; // Se finaliza el juego.

						End;	

					{$IOCHECKS OFF}

					Repeat

						Writeln;
						Textcolor(11);
						Writeln('Quiere leer las instrucciones ?');
						Textcolor(7);
						Writeln;
						Readln(Iniciar_Juego);
						codigo:= ioResult;
						if codigo = 106 then

						Begin

								Writeln('Solo se puede ingresar la opcion si o no');

						End;

					Until (codigo = 0);

					{$IOCHECKS ON}



					If (Iniciar_Juego = Si) then

						Begin

							Writeln;
							Textcolor(9);
							Writeln('OBJETIVO');
							Writeln;
							Textcolor(7);
							Writeln('Bienvenido a Villa Tudor. El anfitrión, Dr. John');
							Writeln('Black, ha muerto asesinado. Para resolver este');
							Writeln('caso, debes descubrir las respuestas a estas');
							Writeln('tres preguntas: ¿Quién lo hizo?, ¿con qué arma?');
							Writeln('y ¿donde?.');
							Writeln;
							Writeln('Presione enter para continuar');
							Readln;
							Writeln;
							Textcolor(9);
							Writeln('CARTAS CLUEDO');
							Writeln;
							Textcolor(7);
							Writeln('Son 21 cartas: 9 de salas, 6 de armas y 6 de');
							Writeln('personajes. Se eligen al azar tres cartas de cada');
							Writeln('grupo y esta contiene la respuestas: ¿Quién?,');
							Writeln('¿Cómo? y ¿Dónde? estas se colocan en el sobre del');
							writeln('ASESINATO. El resto de las cartas se mezclan se');
							Writeln(' barajan y se reparte entre los jugadores.');
							Writeln;
							Writeln('Presione enter para continuar');
							Readln;
							Textcolor(9);
							Writeln('MOVER TU FICHA');
							Writeln;
							Textcolor(7);
							Writeln('Empieza el turno el jugador, se lanza el dado y');
							Writeln('se intenta llegar a una sala de la mansion,');
							Writeln('nunca el jugador puede quedar en los pasillos.');
							Writeln;
							Writeln('Presione enter para continuar');
							Readln;
							Textcolor(9);
							Writeln('HACER SUPOSICIONES');
							Writeln;
							Textcolor(7);
							Writeln('Cada ves que entres en una sala, haz una');
							Writeln('suposicion. Haciendo suposiciones en el juego');
							Writeln('podras determinar las tres cartas hay en el sobre');
							Writeln('del ASESINATO. La sala en la que estás se incluye');
							Writeln('automaticamente para completar la suposicion,');
							Writeln('después selecciona un arma y un sospechoso.');
							Writeln;
							Writeln('Presione enter para continuar');
							Readln;
							Textcolor(9);
							Writeln('DEMOSTRAR UNA SUPOSICION');
							Writeln;
							Textcolor(7);
							Writeln('Cuando hagas una suposicion, los rivales trataran');
							Writeln('de demostrar que es falsa tu suposicion. Si algún');
							Writeln('oponente tiene alguna de las cartas nombradas, ');
							Writeln('debe mostrarla solo una al jugador que hizo la');
							Writeln('suposición.');
							Writeln;
							Writeln('Presione enter para continuar');
							Readln;
							Textcolor(9);
							Writeln('HACER LA ACUSACION');
							Writeln;
							Textcolor(7);
							Writeln('Al jugador estar seguro de las tres cartas que');
							Writeln('estan en el sobre del ASESINATO, entonces el');
							Writeln('jugador al final de su turno puede hacer su');
							Writeln('acusacion.');
							Writeln;
							Writeln('Presione enter para continuar');
							Readln;
							Textcolor(9);
							Writeln('FIN DEL JUEGO');
							Writeln;
							Textcolor(7);
							Writeln('Si la acusacion es incorrecta, se finaliza el');
							Writeln('juego. Si la acusacion es correcta se resuelve el');
							Writeln('caso y ganas la partida');
							Writeln;
							Writeln('Presione enter para continuar');
							Readln;
					
					End;
			
			End;
			
			{Postcondicion: true}

		End;

		
(******************************************************************************)
(*					           Cargar Partida              				      *)
(******************************************************************************)		

	Procedure Cargar_Partida(Var Njugadores : Integer;
							 // Numero de jugadores en la partida a cargar
							 Var Lugar_guardado : ArrayLugarGuardado;
							 // Lugar de los jugadores en la partida a cargar
							 Var Mano : ArrayMano;
							 // Mano de los jugadores en la partida a cargar
							 Var Idem : ArrayIdem;
							 // Relacion personaje con el numero de jugador
							 Var Refutadas : ArrayMano;
							 // Cartas refutadas para cada jugador
							 Var Mem_Refutadas : Array_Nrefutadas;
							 // Numero de cartas refutadas por jugador
							 Var Cartas_Usadas : ArrayCartasUsadas;
							 // Se usa para guardar las cartas culpables
							 Var Estado_Jugador : ArrayEstado
							 // Identifica si el jugador esta activo o
							 // eliminado de la partida
							); // Procedimiento para cargar una partida

	Var

	archivo :text;
	NCartaMAX : integer;
	NCarta : Integer;
	Jugador : integer;

	begin

		assign(archivo,'C:\Users\Francisco\Dropbox\Arleyn y Yo\clue01.txt');
		reset(archivo);

		while not eof(archivo) do begin

			Readln(archivo,Njugadores);
			Readln(archivo,Cartas_Usadas[1],Cartas_Usadas[2],Cartas_Usadas[3]);

				For Jugador := 1 to Njugadores Do

					Begin

						Readln(archivo,Idem[Jugador],
							   Estado_Jugador[Idem[Jugador]],
							   Lugar_guardado[Idem[Jugador]],
							   NCartaMAX,Mem_Refutadas[Idem[Jugador]]);
						
						For NCarta := 1 To NCartaMAX Do
							
							Begin
							
									Readln(archivo,Mano[Idem[Jugador]][NCarta]);
							
							End;
					
						For NCarta := 1 To Mem_Refutadas[Idem[Jugador]] Do
							
							Begin
							
									Readln(archivo,
										   Refutadas[Idem[Jugador]][NCarta]);

							End;

					End;

		end;

	close(archivo);		
	
	End;
	
(******************************************************************************)
(*					              PRE JUEGO                 				  *)
(******************************************************************************)

	Procedure Prejuego( Var Njugadores1: integer;
	                    // Numero de jugadores
                          Var Culpable1  : Carta;
						// Carta culpable
						Var Idem1 : ArrayIdem;
						// Personaje del jugador
						Var Cartas_Usadas1 : ArrayCartasUsadas
						// Las Cartas ya usadas/barajeadas
					   );
					
	// Procedimiento en el que se define el numero de jugadores, los personajes,
	// y las cartas culpable

	Var

	   ID : IdemP; // Identificacion del jugador
	   Culpable_roll : Integer;
	   // Variable para la eleccion del culpable al azar
	   Roll_Personajes : Integer;
	   // Variable para la eleccion de personajes al azar
	   i : Integer; // Variable auxiliar de iteraciones
	   codigo: word; // Variable para la correcion del "runtime error"
	   mensajeError: string; // Variable que indica el error


	Begin

		Randomize;

		{Precondicion:  3 <= Njugadores /\ Njugadores <= 6}


		Case codigo of

			106 : mensajeError:='Invalid number.';

		end;

		{$IOCHECKS OFF}

		Repeat

		Textcolor(11);
		Writeln;
		Writeln('De cuantos jugadores es la partida?');
		Textcolor(7);
		Writeln;
		Readln(Njugadores1);

			codigo:= ioResult;

				if codigo = 106 then

					Begin

						Writeln;
						Writeln('Solo se puede ingresar numeros');

					End;


				if ((( 3 > Njugadores1 ) or ( Njugadores1 > 6))
						and (codigo = 0)) then

					Begin

						Writeln;
						Writeln('ERROR: El numero de jugadores debe estar entre');
						Writeln('       3 y 6 jugadores');

					end;


		Until  (( 3 <= Njugadores1 ) and ( Njugadores1 <= 6) and(codigo = 0));


		{$IOCHECKS ON}



		{$IOCHECKS OFF}

		Repeat

		Writeln;
		Textcolor(11);
		Writeln('¿Cual personaje quiere ser (SenioraBlanco,SenioraCeleste,');
		Writeln('SenioritaaEscarlata,ProfesorCiruela,CoronelMostaza,');
		Writeln('SeniorVerde):?');
		Textcolor(7);
		Writeln;
		Readln(Idem1[1]);

		codigo:= ioResult;
			if codigo = 106 then

				Begin

						Writeln;
						Writeln('Solo se puede ingresar las opciones');
						Writeln('mencionadas anteriormente');

				End;

		Until (codigo = 0);

		Repeat

			Roll_Personajes := Random(6) + 1;

			Case Roll_Personajes of


				1 : Idem1[2] := SenioraBlanco;
				2 : Idem1[2] := SenioraCeleste;
				3 :	Idem1[2] := SenioritaaEscarlata;
				4 : Idem1[2] := ProfesorCiruela;
				5 : Idem1[2] := CoronelMostaza;
				6 : Idem1[2] := SeniorVerde;

			End;

		Until (Idem1[2] <> Idem1[1]);


		Repeat

			Roll_Personajes := Random(6) + 1;

			Case Roll_Personajes of

				1 : Idem1[3] := SenioraBlanco;
				2 : Idem1[3] := SenioraCeleste;
				3 : Idem1[3] := SenioritaaEscarlata;
				4 : Idem1[3] := ProfesorCiruela;
				5 : Idem1[3] := CoronelMostaza;
				6 : Idem1[3] := SeniorVerde;

			End;


		Until ((Idem1[3] <> Idem1[2]) And (Idem1[3] <> Idem1[1]));


		Repeat

			Roll_Personajes := Random(6) + 1;

			Case Roll_Personajes of

				1 : Idem1[4] := SenioraBlanco;
				2 : Idem1[4] := SenioraCeleste;
				3 : Idem1[4] := SenioritaaEscarlata;
				4 : Idem1[4] := ProfesorCiruela;
				5 : Idem1[4] := CoronelMostaza;
				6 : Idem1[4] := SeniorVerde;

			End;


		Until ((Idem1[4] <> Idem1[3]) And (Idem1[4] <> Idem1[2]) And
			  (Idem1[4] <> Idem1[1]));


		Repeat

			Roll_Personajes := Random(6) + 1;

			Case Roll_Personajes of

				1 : Idem1[5] := SenioraBlanco;
				2 : Idem1[5] := SenioraCeleste;
				3 : Idem1[5] := SenioritaaEscarlata;
				4 : Idem1[5] := ProfesorCiruela;
				5 : Idem1[5] := CoronelMostaza;
				6 : Idem1[5] := SeniorVerde;

			End;


		Until ((Idem1[5] <> Idem1[4]) And (Idem1[5] <> Idem1[3]) And
			  (Idem1[5] <> Idem1[2]) And (Idem1[5] <> Idem1[1]));

		Repeat

			Roll_Personajes := Random(6) + 1;

			Case Roll_Personajes of

				1 : Idem1[6] := SenioraBlanco;
				2 : Idem1[6] := SenioraCeleste;
				3 : Idem1[6] := SenioritaaEscarlata;
				4 : Idem1[6] := ProfesorCiruela;
				5 : Idem1[6] := CoronelMostaza;
				6 : Idem1[6] := SeniorVerde;

			End;


		Until ((Idem1[6] <> Idem1[5]) And (Idem1[6] <> Idem1[4])	And
			  (Idem1[6] <> Idem1[3]) And (Idem1[6] <> Idem1[2]) And
			  (Idem1[6] <> Idem1[1]));

            Writeln;
			Writeln('Los jugadores de la partida son: ');
            Writeln;

                For i:= 1 to Njugadores1 do

			Begin


				Writeln('       El jugador numero ',i, ' es ',Idem1[i]);

			End;

            Writeln;
			Writeln('Ahora elegimos aleatoriamente tres cartas');
			Writeln('culpables, un arma, un sospechoso y una escena de crimen');
			Writeln('Y las colocamos en el sobre del asesinato');


		Culpable_roll := random(6) + 1;

			Case Culpable_roll of

				1 : Culpable1.Personaje := SenioraBlanco;
				2 : Culpable1.Personaje := SenioraCeleste;
				3 : Culpable1.Personaje := SenioritaaEscarlata;
				4 : Culpable1.Personaje := ProfesorCiruela;
				5 : Culpable1.Personaje := CoronelMostaza;
				6 : Culpable1.Personaje := SeniorVerde;

			End;

		Culpable_roll := random(6) + 7;

			Case Culpable_roll of

				7 : Culpable1.Arma := Candelabro;
				8 : Culpable1.Arma := Cuchillo;
				9 : Culpable1.Arma := Cuerda;
				10: Culpable1.Arma := LlaveInglesa;
				11: Culpable1.Arma := Revolver;
				12: Culpable1.Arma := Tubo;

			End;

		Culpable_roll := random(9) + 13;

			Case Culpable_roll of

				13 : Culpable1.Lugar := Biblioteca;
				14 : Culpable1.Lugar := Cocina;
				15 : Culpable1.Lugar := Comedor;
				16 : Culpable1.Lugar := Estudio;
				17 : Culpable1.Lugar := Vestibulo;
				18 : Culpable1.Lugar := Salon;
				19 : Culpable1.Lugar := Invernadero;
				20 : Culpable1.Lugar := SalaDeBaile;
				21 : Culpable1.Lugar := SalaDeBillar;

			End;

		Cartas_Usadas1[1] := Culpable1.Personaje;
		Cartas_Usadas1[2] := Culpable1.Arma;
		Cartas_Usadas1[3] := Culpable1.Lugar;
		
		// Anadimos las cartas culpables a las cartas usadas para que no esten
		// en el barajeo ni en la reparticion
		
		Readln;

		{Postcondicion: (%Exist x,y,z : True :  x = Culpable1.Arma /\
                                        y = Culpable1.Personaje /\
                                        z = Culpable1.Lugar
        }


        End;

(******************************************************************************)
(*					              INICIO                    				  *)
(******************************************************************************)

	Procedure Inicio( Njugadores : integer;      // Numero de jugadores
					 Var Mano1: ArrayMano;   // Cartas de cada jugador
					  Cartas_Usadas : ArrayCartasUsadas;
					  // Array para guardar cuales cartas ya fueron usadas
					 Var Cartas_Usadas2 : ArrayCartasUsadas;
					  Idem: ArrayIdem;
					 Var Particion_Cartas1 : Cartas_Jugar
					);
	
	// Procedimiento en el que barajean las cartas y se reparten a los jugadores

	Const

	   Max_Cartas = 18; // Maximo de cartas a repartir

	Var

		NCarta : Integer; // Variable de iteracion para repartir las cartas
		tmp : CartGlobal; // Variable auxiliar para el barajeo
        Cartas_usadas3 :ArrayCartasUsadas;
		Iteracion : Integer; // Variable de iteracion para la reparticion
		Iteracion2 : Integer;// Variable de iteracion para la reparticion
		Numeros_aleatorio : conjunto;
		Barajeo: integer; // Variable que saca cartas al azar para reordenarlas
		

	Begin
	
		{Precondicion: True  }

		Randomize;
		NCarta:= 1;
		Numeros_aleatorio:= [];

		While (NCarta <= 18) do

			Begin

				Barajeo := random(21)+1;

					if ((Barajeo in Numeros_aleatorio) = true) then

						Begin

							Repeat

								Barajeo := random(21)+1;

							Until((Barajeo in Numeros_aleatorio) = false);

						End;

				Case Barajeo of

					1 : Cartas_Usadas2[1] := SenioraBlanco;
					2 : Cartas_Usadas2[2] := SenioraCeleste;
					3 : Cartas_Usadas2[3] := SenioritaaEscarlata;
					4 : Cartas_Usadas2[4] := ProfesorCiruela;
					5 : Cartas_Usadas2[5] := CoronelMostaza;
					6 : Cartas_Usadas2[6] := SeniorVerde;
					7 : Cartas_Usadas2[7] := Candelabro;
					8 : Cartas_Usadas2[8] := Cuchillo;
					9 : Cartas_Usadas2[9] := Cuerda;
					10 : Cartas_Usadas2[10] := LlaveInglesa;
					11 : Cartas_Usadas2[11] := Revolver;
					12 : Cartas_Usadas2[12] := Tubo;
					13 : Cartas_Usadas2[13] := Biblioteca;
					14 : Cartas_Usadas2[14] := Cocina;
					15 : Cartas_Usadas2[15] := Comedor;
					16 : Cartas_Usadas2[16] := Estudio;
					17 : Cartas_Usadas2[17] := Vestibulo;
					18 : Cartas_Usadas2[18] := Salon;
					19 : Cartas_Usadas2[19] := Invernadero;
					20 : Cartas_Usadas2[20] := SalaDeBaile;
					21 : Cartas_Usadas2[21] := SalaDeBillar;

				End;


				if ((Cartas_Usadas2[Barajeo] <> Cartas_Usadas[1]) and
					(Cartas_Usadas2[Barajeo] <> Cartas_Usadas[2]) and
					(Cartas_Usadas2[Barajeo] <> Cartas_Usadas[3])) then

					Begin

						Numeros_aleatorio:= Numeros_aleatorio + [Barajeo];

						tmp:= Cartas_Usadas2[Barajeo];
						Cartas_Usadas2[Barajeo]:= Cartas_Usadas2[NCarta];
						Cartas_usadas3[NCarta] := tmp;
						NCarta:= NCarta + 1;

					End;	

			End;
			
			
			Particion_Cartas1 := Max_Cartas div NJugadores;
			
			NCarta := 1;
			
			if ((Njugadores = 3) or (Njugadores = 6)) then
			
				Begin

					For Iteracion := 1 to Njugadores Do

						Begin

							For Iteracion2 := 1 to Particion_Cartas1 Do

								Begin

									Mano1[Idem[Iteracion],Iteracion2]:=
									Cartas_Usadas3[NCarta];
									NCarta := NCarta + 1;

								End;
						End;
					
					Writeln;
					Writeln('Estas son tus cartas: ');
					
					For NCarta := 1 to (Particion) do
					
						Begin
						
							Write(Mano1[Idem[1]][NCarta],',');
							Readln;
						
						End;
					
				End;
				
			Cartas_Usadas3[19]:= Vacio;
			Cartas_Usadas3[20]:= Vacio;

			If ((Njugadores = 4) or (Njugadores = 5)) then

				Begin

					For Iteracion := 1 To (Njugadores - 2) Do

						Begin

							For Iteracion2 := 1 to (Particion_Cartas1 + 1) do

								Begin

									Mano1[Idem[Iteracion],Iteracion2] :=
									Cartas_Usadas3[NCarta];
									NCarta := NCarta + 1;

								End;
						End;
					
					For Iteracion := (NJugadores -1) to (NJugadores) Do
					
						Begin
						
							For Iteracion2 := 1 to (Particion_Cartas1) Do
							
								Begin
								
									Mano1[Idem[Iteracion],Iteracion2] :=
									Cartas_Usadas3[NCarta];
									NCarta := NCarta + 1;
									
								End;
								
						End;	
					
					Writeln;
					Writeln('Estas son tus cartas: ');
					
					For NCarta := 1 to (Particion + 1) do
					
						Begin
						
							Write(Mano1[Idem[1]][NCarta],',');
							Readln;
						
						End;
						
				End;
			
		
					
		{Postcondicion: MAX_CARTA = (Particion_CartasC * NJugadores) +
				(Max_Cartas mod NJugadores)
		}
		
	End;
(******************************************************************************)
(*					               TABLERO                   				  *)
(******************************************************************************)

	Procedure Tablero;	// Procedimiento que imprime el tablero del juego

	Begin
	
		Textcolor(7);
		Writeln('   ______________________________________________________',
				'______________ ');
		Writeln('  |              |           |              |           |',
				'              |');
		Writeln('  |  Biblioteca  |           |    Cocina    |           |',
				'    Comedor   |');
		Writeln('  |1.5___________|2.5________|3.5___________|4.5________|',
				'5.5___________|');
		Writeln('  |              |           |              |           |',
				'              |');
		Writeln('  |              |           |              |           |',
				'              |');
		Writeln('  |1.4___________|2.4________|3.4___________|4.4________|',
		        '5.4___________|');
		Writeln('  |              |           |              |           |',
				'              |');
		Writeln('  |   Estudio    |           |  Vestibulo   |           |',
				'     Salon    |');
		Writeln('  |1.3___________|2.3________|3.3___________|4.3________|',
				'5.3___________|');
		Writeln('  |              |           |              |           |',
				'              |');
		Writeln('  |              |           |              |           |',
				'              |');
		Writeln('  |1.2___________|2.2________|3.2___________|4.2________|',
				'4.5___________|');
		Writeln('  |              |           |              |           |',
				'              |');
		Writeln('  | Invernadero  |           |SALA DE BAILE |           |',
				'SALA DE BILLA |');
		Writeln('  |1.1___________|2.1________|3.1___________|4.1________|',
				'5.1___________|');

	end;
		

	
(******************************************************************************)
(*					      MOVIMIENTO EN EL TABLERO             				  *)
(******************************************************************************)



	Procedure Movimiento ( Var Horizontal_mem1 : ArrayPosicion;
						   // Variable que almacena la posicion vertical
						   Var Vertical_mem1 : ArrayPosicion;
						   // Variable que almacena la posicion vertical
						   Turno1   : Idemp;
						   // Variable que indica de quien es el turno
						   Idem : ArrayIdem;
						   // Variable que relaciona el turno con un personaje
						   Var Mov1 : ArrayMov
						   // Variable que guarda las posiciones
						);
	
	// Procedimiento que ejecuta el movimiento de los jugadores en el tablero y
	// guarda esas posiciones
	
		Procedure Dadoroll( Var Memoria_Dado1 : dado // Memoriza el valor del dado
		                   );

			Begin

				{Precondicion: true}

					Memoria_Dado1 := Random (6) + 1;

				{Postcondicion: true}

			End;
	Var

		Memoria_Dado : Dado;

		// Guarda el favor que resulte del dado

		Pasos : Dado;

		// Contador de pasos en el turno

		Horizontal     : Posicion;

		// Posicion horizontal del jugador

		Vertical       : Posicion;

		// Posicion vertical del jugador
		
		Roll_Mov : Dado;
		
		// Decide al azar el movimiento de la maquina
		
		Direccion_Opcion : Direccion;
		
		// La usa el usario para decidir en que direccion moverse
		
		codigo: word;
		
		// Variable para la correcion del "runtime error"
		
		mensajeError: string;
		
		// Variable que indica el error
		
		Begin

			{Precondicion:  (Horizontal <> 2) /\ (Horizontal <> 4) /\
							(Vertical <> 2) /\ (Vertical <> 4) ) }
							
			
		Case codigo of

			106 : mensajeError:='Invalid number.';

		end;
		

			If (Turno1 = 1) Then

			(*                          *)
			(*	MOVIMIENTO DEL JUGADOR  *)
			(*							*)

			Begin
				
				Textcolor(11);
				Writeln('Es el turno de ', Idem[Turno1]);
				Writeln;
				Textcolor(7);
				Writeln('     ','Se procedera a lanzar el dado');

				Dadoroll(Memoria_Dado);

				Pasos := 0;
					

					Repeat
						
					Horizontal := Horizontal_mem1[Idem[Turno1]];
					Vertical   := Vertical_mem1[Idem[Turno1]];

							
						While (Memoria_Dado <> Pasos) Do

							Begin

								Write('     ','Usted ha sacado ',Memoria_Dado);
								Writeln('     ','Lleva ',Pasos,' pasos');
								Writeln;
								Write('     ','Su posicion actual es ');
								Writeln('(',Horizontal,',',Vertical,')');
								Tablero;
								Writeln;
									
								{$IOCHECKS Off}
									
								Repeat
								
									Textcolor(11);
									Write('     ','¿Hacia que direccion desea ');
									Writeln('moverse? Arriba,Abajo,');
									Write('     ','Izquierda, Derecha o ');
									Writeln('desea Parar?');
									Writeln;
									Textcolor(7);
									Write('     ');
									Readln(Direccion_Opcion);
									Writeln;
									codigo:= ioResult;
									
									if codigo = 106 then

										Begin

											Writeln;
											Write('     ','ERROR: Solo se ');
											Writeln('puede ingresar las opciones');
											Writeln;
											Write('     ','mencionadas ');
											Writeln('anteriormente');
											Writeln;
											Writeln;

										End;

								Until (codigo = 0);
									
								{$IOCHECKS ON}

									If ((Direccion_Opcion = Arriba) and
									(Vertical < 5) and (Vertical >= 1)) then

										Begin

											Vertical := Vertical + 1;
											Pasos := Pasos + 1;

										End

                                    Else If ((Direccion_Opcion = Abajo) and
									(Vertical <= 5) and (Vertical > 1)) then

										Begin

											Vertical := Vertical - 1;
											Pasos := Pasos + 1;

										End

									Else If ((Direccion_Opcion = Derecha) and
									(Horizontal < 5) and (Horizontal >= 1)) then

										Begin

											Horizontal := Horizontal + 1;
											Pasos := Pasos + 1;

										End

									Else If ((Direccion_Opcion = Izquierda) and
									(Vertical <= 5) and (Vertical > 1)) then

										Begin

											Horizontal := Horizontal - 1;
											Pasos := Pasos + 1;

										End
									
									Else if (Direccion_Opcion = Parar) then

										Begin
										
											Pasos := Memoria_Dado;
										
										End

									Else

										Begin

											Writeln('Usted se esta saliendo del');
											Write('  tablero, vuelva a mover');
											Writeln;

										End;

							End;
							

						Pasos:= 0;

						If ( Mov1[idem[Turno1]][Horizontal][Vertical] = Pasillo)
						then

							Begin

								Write('Ha caido en un pasillo y ningun personaje');
								Writeln('puede quedar en un pasillo. ');
								Writeln('Por favor vuelva a efectuar su movimiento');	
								Writeln('Presiona enter para continuar');
								Readln;
								
							End;



					Until ( Mov1[idem[Turno1]][Horizontal][Vertical] <> Pasillo);

					Textcolor(11);
					Write(Idem[Turno1],' Se dirige a: ');
					Textcolor(7);
					Writeln(Mov1[idem[Turno1]][Horizontal][Vertical]);
					Writeln;
					Horizontal_mem1[Idem[Turno1]] := Horizontal;
					Vertical_mem1[Idem[Turno1]]   := Vertical;

			End

			Else If ((Turno1 = 2) or (Turno1 = 3) or (Turno1 = 4) or (Turno1 = 5)
			or (Turno1 = 6)) Then


						(****************************)
						(* MOVIMIENTO DE LA MAQUINA *)
						(****************************)

				Begin

					Textcolor(7);
					Write('Es el turno de: ');
					Textcolor(11);
					Writeln(Idem[Turno1]);
					Writeln;

					Dadoroll(Memoria_Dado);

					Textcolor(7);
					Writeln('	Se procedera a lanzar el dado: ', Memoria_Dado);
					Writeln;
					Write('     ','Su posicion actual es: ');
					Textcolor(11);
					Writeln(Mov1[Idem[Turno1]][Horizontal_mem1[Idem[Turno1]]]
								[Vertical_mem1[Idem[Turno1]]]);
					Writeln;
					Textcolor(7);
					Writeln('   ',Idem[Turno1],' se dirige a :');

					Pasos := 0;

						Repeat
						
							Horizontal := Horizontal_mem1[Idem[Turno1]];

							Vertical   := Vertical_mem1[Idem[Turno1]];

							While (Memoria_Dado <> Pasos) Do

								Begin

									Roll_Mov := Random(5) + 1;

									If (Roll_Mov = 1) and (Vertical < 5)
										and (Vertical >= 1) then

										Begin

											Vertical := Vertical + 1;
											Pasos := Pasos + 1;

										End

									Else If (Roll_Mov = 2) and (Vertical <= 5)
											and (Vertical > 1) then

										Begin

											Vertical := Vertical - 1;
											Pasos := Pasos + 1;

										End

									Else If (Roll_Mov = 3) and (Horizontal < 5)
											and (Horizontal >= 1) then

										Begin

											Horizontal := Horizontal + 1;
											Pasos := Pasos + 1;

										End

									Else If (Roll_Mov = 4) and (Vertical <= 5)
											and (Vertical > 1) then

										Begin

											Horizontal := Horizontal - 1;
											Pasos := Pasos + 1;

										End
									
									Else if (Roll_Mov = 5) then
									
										Begin
									
											Pasos:= Memoria_Dado;
											
										End


								end;

							Pasos := 0;

						If ( Mov1[idem[Turno1]][Horizontal][Vertical] = Pasillo)
						then

							Begin

								Pasos:= 0;
								
							End;
							

						
						Until ( Mov1[idem[Turno1]][Horizontal][Vertical] <>
								Pasillo);
								
					Textcolor(11);
					Writeln('   ',Mov1[idem[Turno1]][Horizontal][Vertical]);
					Readln;
						
					Horizontal_mem1[Idem[Turno1]] := Horizontal;
					Vertical_mem1[Idem[Turno1]]   := Vertical;
				
				End;
		
			(* Donde horizontal(0) es la posicion horizontal inicial del
			   jugador y Vertical(0) es la posicion vertical inicial del
			   jugador
			 *)

			{Postcondicion: Dadoroll >= Abs(Horizontal - Horizontal(0))
							+ Abs(Vertical - Vertical(0)) }

		End;

(******************************************************************************)
(*					           SOSPECHA USUARIO             				  *)
(******************************************************************************)

	Procedure Sospecha ( Mov : ArrayMov;
						// Posicion actual del jugador
						Escena : Lugar;
						// Indica el lugar donde se hace la sospecha
	                    Mano : ArrayMano ;
						// Mano de los jugadores
                     	Var Preguntas : Carta;
						// Almacena la sospecha jugador
						Particion_Cartas : Cartas_Jugar;
						// Cuantas cartas por jugador de manera equivalente
                        Njugadores   : integer;
						// Numero de jugadores en la partida
                        Idem         : ArrayIdem;
						// Relaciona personajes con numeros
						Var Sospechoso : Personaje;
						// Indica el sospechoso
						Mem_Refutadas : Array_Nrefutadas;
						// Guarda cuantas cartas han sido refutadas
						Refutadas : ArrayMano
						// Guarda las cartas refutadas
                         );
	// Procedimiento en el que el usuario hace una sospecha

		Procedure Pregunta (Var Pregunta2 : Carta;
							// Sospecha del jugador
							Escena : Lugar
							//Lugar donde se hace la sospecha
                            );
			Var
			
				codigo        : word;
				// Variable para evitar un "runtime" error
				mensajeError  : string;
				// Variable que indica el error

			Begin
			
				Case codigo of

					106 : mensajeError:='Invalid number.';

				end;

				{Precondicion: true}

					Writeln;
					Writeln;
					
					
					{$IOCHECKS OFF}
					
					Repeat
					
						Textcolor(11);
						Writeln('     ','¿De Quien Sospechas?');
						Writeln;
						Write('       ');
						Textcolor(7);
						Readln(Pregunta2.Personaje);
						Writeln;
						
						codigo:= ioResult;
						if codigo = 106 then

							Begin
							
								Write('     ','Solo se puede ingresar la opcion');
								Writeln('de tipo Personaje');
								Writeln;

							End;

					Until (codigo = 0);

					{$IOCHECKS ON}

					{$IOCHECKS OFF}

					Repeat

						Textcolor(11);
						Writeln('     ','¿Con Que Arma?');
						Writeln;
						Write('       ');
						Textcolor(7);
						Readln(Pregunta2.Arma);
						Writeln;

						codigo:= ioResult;
						if codigo = 106 then

						Begin

							Write('     ','Solo se puede ingresar la opcion');
							Writeln(' tipo Arma ');
							Writeln;

						End;

					Until (codigo = 0);

					{$IOCHECKS ON}

					Pregunta2.Lugar := Escena;
					Textcolor(11);
					Write('     ','Como usted se encuentra en ');
					Textcolor(7);
					Writeln(Pregunta2.Lugar);
					Textcolor(11);
					Writeln('     ','Entonces la sospecha sera ahi');
					Writeln;
					Readln;
					Textcolor(7);

				{Postcondicion: true}

			End;


		Procedure Imprimir_Mazo(Mano : ArrayMano;
								// La mano del jugador
								Idem : ArrayIdem;
								// Relacion personajes con numeros
								Particion_Cartas : Cartas_Jugar
								// Numero de cartas por persona equitativamente
								);
		
		// Imprime la mano del jugador
		
		Var

			NCarta : integer; // Variable iteracion
            Turno : IdemP; // Indica el turno del jugador

		Begin

            Turno:= 1;
			If ((Njugadores = 3) or (Njugadores = 6)) then

				Begin

					Write('[');

						For NCarta:= 1 to Particion_Cartas do

							Begin

								Write(Mano[Idem[Turno]][NCarta], ',');
					
							End;
				
					Write(']');
						
				End
					
			Else if ((Njugadores = 4) or (Njugadores = 5)) then
				
				Begin
			
					Write('[');

						For NCarta:= 1 to (Particion_Cartas + 1) do
				
							Begin
				
								Write(Mano[Idem[Turno]][NCarta],',');
					
							End;
				
					Write(']');
						
				End;

		End;

		Procedure Imprimir_Todas_Las_Cartas;
		//Imprime todas las cartas del juego para que el jugador sepa como
		//escribir sus sospecha

		Begin
		Textcolor(11);
		Writeln('   Personajes            Armas               Habitaciones*');
		Writeln;
		Textcolor(7);
		Writeln('   SenioraBlanco       Candelabro        Cocina       Comedor');
		Writeln('   SenioraCeleste        Cuerda        Biblioteca     Estudio');
		Writeln(' SenioritaaEscarlata      Tubo         Vestibulo       Salon');
		Writeln('   SeniorVerde          Revolver             Invernadero    ');
		Writeln(' CoronelMostaza         Cuchillo            SalaDeBaile');
		Writeln(' ProfesorCiruela      LlaveInglesa         SalaDeBillar');


		End;

		Procedure Refutadas_Mostrar(Refutadas: ArrayMano;
									// Lista de cartas refutadas
		                            Carta_Refutada : integer;
									// Numero de cartas refutadas
                                    Turno : idemP
									// Indica el turno del jugador
                                                        );
		// Imprime las cartas refutadas al jugador
														
		Var

			Carta_Mostrar : integer;
			// Variable de iteracion

        Begin

			Write('[');

				For Carta_Mostrar:= 1 to (Carta_Refutada - 1) do

					Begin

						Write(Refutadas[Idem[Turno]][Carta_Mostrar],',');

					End;

				Write(']');
		End;

	Var

		Usuario : integer;
		// Identificacion de los jugadores
		Horizontal : Posicion;
		// Posicion Horizontal en el tablero
		Vertical: Posicion;
		// Posicion Vertical en el tablero
		NCarta     : Integer;
		// Variable de iteracion
		Turno : IdemP;
		// Turno de comparacion al momento de sospechar
		Verificar : boolean;
		// Verifica si hay coincidencia
		Turno_usuario : integer;
		// Indica el turno de quien preguntas
		Carta_Refutada : Integer;
		// Numero de cartas refutadas para el jugador que preguntas

	Begin

		{Precondicion: true }
		
		
		WRITELn('SUBPROGRAMA SOSPECHA');
		
		Carta_Refutada := Mem_Refutadas[Idem[Turno]];
		
		For Turno:= 1 To Njugadores do
		
			Begin
			
				For NCarta:= 1 to Particion_Cartas do
				
				begin
				
					Writeln(Idem[Turno]);
					Writeln(Mano[idem[Turno]][NCarta]);
					Readln;
				
				end;
				
			end;

		Textcolor(11);
		Writeln;
		Writeln('La Lista de cartas es: ');
		Writeln;
		Textcolor(7);
		Imprimir_Todas_Las_Cartas;
		Writeln;
		Textcolor(11);
		Writeln('Tus Cartas son :');
		Writeln;
		Textcolor(7);
		Imprimir_Mazo(Mano,Idem,Particion_Cartas);
		Textcolor(11);
		Writeln;
		Writeln('Estas cartas ya te han sido refutadas: ');
		Writeln;
		Textcolor(7);
		Refutadas_Mostrar(Refutadas,Carta_Refutada,Turno);
		Writeln(Carta_Refutada);
		readln;


	


		Writeln;
		Pregunta(Preguntas,Escena);
		Verificar := false;

		Turno:= 2;

			If ((Njugadores = 3) or (Njugadores = 6)) then

				Begin

					While (Turno <= Njugadores) do

						Begin
						
							NCarta := 1;
							
							While (NCarta <= Particion_Cartas) do

								Begin

									If (Mano[Idem[Turno]][NCarta] =
													Preguntas.Personaje) then
									
										Begin
									
											Write(Idem[Turno],' Te muestra una');
											Writeln('carta ');
											Writeln(Mano[Idem[Turno]][NCarta]);
											Writeln;
											Verificar:= true;
										
										End

									else if (Mano[Idem[Turno]][NCarta] =
															Preguntas.Arma) then

										Begin

											Write(Idem[Turno],' Te muestra una');
											Writeln('carta ');
											Writeln(Mano[Idem[Turno]][NCarta]);
											Writeln;
											Verificar:= true;

										End

									else if (Mano[Idem[Turno]][NCarta] =
														  Preguntas.Lugar) then

										Begin
										
											Write(Idem[Turno],' Te muestra una');
											Writeln('carta ');
											Writeln(Mano[Idem[Turno]][NCarta]);
											Writeln;
											Verificar:= true;

										End;

									if (Verificar = true ) then

										Begin
										
											Turno_usuario:= 1;
											Refutadas[Idem[Turno_usuario]]
											[Carta_Refutada]
											:= Mano[Idem[Turno]][NCarta];
											NCarta:= (Particion_Cartas + 1);
										
										End
									
									Else if (Verificar = false) then
									
										Begin
										
											NCarta:= NCarta + 1;
											
										End;
								End;
									
							if (Verificar =  true) then
									
								Begin
										
									Turno:= (Njugadores + 1);
									Carta_Refutada := Carta_Refutada + 1;
										
								End
									
							Else if (Verificar = false) then
									
								Begin

									Turno:= Turno + 1;

								End;

						End;

				End


			else If ((Njugadores = 4) or (Njugadores = 5)) then

				Begin

					While (Turno <= Njugadores) do

						Begin

							NCarta := 1;

							While (NCarta <= (Particion_Cartas + 1)) do

								Begin

									If (Mano[Idem[Turno]][NCarta] =
													Preguntas.Personaje) then

										Begin

											Write(Idem[Turno],' Te muestra una');
											Writeln('carta ');
											Writeln(Mano[Idem[Turno]][NCarta]);
											Writeln;
											Verificar:= true;

										End

									else if (Mano[Idem[Turno]][NCarta] =
															Preguntas.Arma) then

										Begin

											Write(Idem[Turno],' Te muestra una');
											Writeln('carta ');
											Writeln(Mano[Idem[Turno]][NCarta]);
											Writeln;
											Verificar:= true;

										End

									else if (Mano[Idem[Turno]][NCarta] =
														Preguntas.Lugar) then

										Begin

											Write(Idem[Turno],' Te muestra una');
											Writeln('carta ');
											Writeln(Mano[Idem[Turno]][NCarta]);
											Writeln;
											Verificar:= true;

										End;
			
									if (Verificar = true ) then
				
										Begin
										
											Turno_usuario:= 1;
											Refutadas[Idem[Turno_usuario]]
											[Carta_Refutada]:=
											Mano[Idem[Turno]][NCarta];
											NCarta:= (Particion_Cartas + 2);

										End

									Else if (Verificar = false) then

										Begin

											NCarta:= NCarta + 1;

										End;
								End;

							if (Verificar =  true) then

								Begin

									Turno:= (Njugadores + 1);
									Carta_Refutada := Carta_Refutada + 1;

								End

							Else if (Verificar = false) then

								Begin

									Turno:= Turno + 1;

								End;

						End;

				End;
			
			If (Verificar = false) then
			
				Begin
				
					Writeln('No se encontro ninguna carta que refutar');
				
				End;
			
			Mem_Refutadas[Idem[Turno_usuario]] := Carta_Refutada;


			{Postcondicion: true }
			

			Turno := 1;
			Sospechoso:= Preguntas.Personaje;

		End;

(******************************************************************************)
(*					           ACUSACION USUARIO            				  *)
(******************************************************************************)


	Procedure Acusar (Cartas_Usadas : ArrayCartasUsadas; // Cartas culpables a
														 // comparar
					  Var Pregunta_Culpable1 : Carta;
                      Escena                 : Lugar
	                  );
	// Procedimiento en el que el jugador hace una acusacion y se verifica si es
	// correcta y dependiendo del resultado se dara un mensaje de victoria o de
	// derrota
	
	    Procedure Hipotesis(Var Asesino1 : Personaje;
							// El personaje que acusa del asesinato
							Var Arma_culpable1 : Arma;
							// El arma con la que dice que se hizo
							Escena : Lugar
							// La escena del crimen
							);
		
		// Procedimiento en el que el usario formula su acusacion
			
			Var
			
				Pregunta_Culpable1 : Carta;
				// La acusacion del jugador
				codigo: word;
				// La Variable para evitar el "runtime error"
				mensajeError: string;
				// Variable que indica el error
				
			Begin
			
			Case codigo of

				106 : mensajeError:='Invalid number.';

			end;

				{Precondicion: True}

				{$IOCHECKS OFF}

				Repeat

					Textcolor(11);
					Writeln;
					Writeln('     ','¿Quien es el asesino?');
					Writeln;
					Write('        ');
					Textcolor(7);
					Readln(Pregunta_Culpable1.Personaje);
					
					codigo:= ioResult;

					if codigo = 106 then

						Begin
						
						Writeln;
						Write('       ','Solo se puede ingresar opciones de');
						Writeln(' tipo personaje');

						End;
					
				Until (Codigo = 0);
				
				Asesino1:= Pregunta_Culpable1.Personaje;
				
				{$IOCHECKS ON}
				
				{$IOCHECKS OFF}
					
				Repeat
				
					Textcolor(11);
					Writeln;
					Writeln('     ','¿Cual es el Arma?');
					Writeln;
					Write('        ');
					Textcolor(7);
					Readln(Pregunta_Culpable1.Arma);
					
					codigo:= ioResult;

					if codigo = 106 then

						Begin

							Writeln;
							Write('       ','Solo se puede ingresar opciones');
							Writeln(' de tipo arma');

						End;
			
				Until (Codigo = 0);

				{$IOCHECKS ON}
					
					Arma_culpable1:= Pregunta_Culpable1.Arma;
					
					Textcolor(11);
					Writeln;
					Write('     ','La acusacion de la Escena es en donde te ');
					Write('encuentra: ');
					Textcolor(7);
					Writeln(Escena);
					
					Writeln;
					Writeln;

				{Postcondicion: True}

			End;

		Procedure SalidaVictoria;  // Mensaje si la acusacion es correcta

			Begin

				{Precondicion: True}
				
					Textcolor(12);
					Writeln('¡FELICITACIONES!':40);
					Writeln;
					Textcolor(15);
					Writeln('HA DESCUBIERTO EL ASESINATO EN LA CASA DEL DR. BLACK');
					Writeln('ERES UN GRAN DETECTIVE.');
					Writeln;
					Textcolor(7);
					Writeln('Presiona enter para salir del juego');
					Readln;
					Halt;

				{Postcondicion: true}

			End;

		Procedure SalidaDerrota(Cartas_Usadas : ArrayCartasUsadas
								// se usa para comparar con las cartas culpable
								);
		// Mensaje si la acusacion e sincorrecta

			Begin

				{Precondicion: true}

				Textcolor(12);
				Writeln('TU ACUSACION ES INCORRECTA, LA VERDADERA RESPUESTA ES: ');
				Writeln;
                Textcolor(15);
				Writeln(Cartas_Usadas[1]);
				Writeln(Cartas_Usadas[2]);
				Writeln(Cartas_Usadas[3]);
				Writeln;
				Textcolor(7);
				Writeln('Presiona enter para salir del juego');
				Readln;
				halt//


				{Postcondicion: true}

			End;
    Var

            Asesino            : Personaje;
			// El personaje culpable del asesinato
            Arma_culpable      : Arma;
			// El Arma con el que lo hizo
			
	Begin

		{Precondicion: true }

		Hipotesis(Asesino,Arma_culpable,Escena);
		
		if ((Asesino = Cartas_Usadas[1]) and (Arma_culpable = Cartas_Usadas[2])
		and	(Escena = Cartas_Usadas[3])) then

			Begin

				SalidaVictoria;

			End

		else

			Begin

				SalidaDerrota(Cartas_Usadas);

			End;

		{Postcondicion: true}
			
	End;
	
(******************************************************************************)
(*					          SOSPECHA DE MAQUINA            				  *)
(******************************************************************************)
	
		Procedure Sospecha_bot (
								Mano : ArrayMano;
								// Mano de los jugadores
								Idem : ArrayIdem;
								// Relacion personajes con numeros
								Turno : Idemp;
								// Turno de comparacion
								Escena : lugar;
								// Lugar donde se hace la sospecha
								Njugadores : IdemP;
								// Numero de jugadores en la partida
								Particion_Cartas : Cartas_Jugar;
								// Numero de cartas por jugador distribuidas
								// equitativamente
								Var Sospecha_Maquina_Persona1: CartGlobal;
								// Variable para comparar con las manos
								Var Sospecha_Maquina_Arma1  : CartGlobal;
								// Variable para comparar con las manos
								Var Sospecha_Maquina_Lugar1 : CartGlobal;
								// Variable para comparar con las manos
								Var Mem_Refutadas : Array_Nrefutadas;
								// Memoriza el numero de cartas refutadas
								Var Refutadas : ArrayMano
								// Lista de refutadas
								);
		// Procediminto en el que la maquina hace su sospecha y se compara con
		// las cartas de los demas jugadores

			Procedure Pregunta_bot (Var Sospecha_Valida_Personaje1 : CartGlobal;
									// Guarda una sospecha no repetida
									Var sospecha_Valida_Arma1     : CartGlobal;
									// Guarda una sospecha no repetida
									Var sospecha_Valida_lugar1    : CartGlobal;
									// Guarda una sospecha no repetida
									Var Refutadas2 : ArrayMano;
									// Lista de cartas refutadas
                                    Njugadores : IdemP;
									// Numero de jugadores en la partida
									Particion_Cartas : Cartas_jugar;
									// Numero de cartas por jugador distribuidas
									// equitativamente									
									Mano : ArrayMano;
									// Mano de los jugaores
									escena : lugar
									// Lugar donde se hace la sospecha
									);
			// Procedimiento en el que la maquina formula su sospecha
			
				Var

					Sospecha_roll : Integer;
					// Se usa para que la maquina formule una sospecha al azar
					Mazo : boolean;
					// verifica si hay coincidencias entre las manos de los
					// demas jugadores y la sospecha
					NCarta : integer;
					// Variable de iteracion


				Begin

					{Precondicion: true}

					Repeat

						Repeat
					
							Sospecha_Roll := Random(6) + 1;

							Case Sospecha_Roll of

								1 : Sospecha_Valida_Personaje1 :=
									SenioraBlanco;
								2 : Sospecha_Valida_Personaje1 :=
									SenioraCeleste;
								3 : Sospecha_Valida_Personaje1 :=
									SenioritaaEscarlata;
								4 : Sospecha_Valida_Personaje1 :=
									ProfesorCiruela;
								5 : Sospecha_Valida_Personaje1 :=
									CoronelMostaza;
								6 : Sospecha_Valida_Personaje1 :=
									SeniorVerde;

							end;

						Until
						((Sospecha_Valida_Personaje1 <>
						  Refutadas[Idem[Turno]][1])
						And
						(Sospecha_Valida_Personaje1 <>
						 Refutadas[Idem[Turno]][2])
						And
						(Sospecha_Valida_Personaje1 <>
						 Refutadas[Idem[Turno]][3])
						And
						(Sospecha_Valida_Personaje1 <>
						 Refutadas[Idem[Turno]][4])
						And
						(Sospecha_Valida_Personaje1 <>
						 Refutadas[Idem[Turno]][5])
						And
						(Sospecha_Valida_Personaje1 <>
						 Refutadas[Idem[Turno]][6])
						And
						(Sospecha_Valida_Personaje1 <>
						 Refutadas[Idem[Turno]][7])
						And
						(Sospecha_Valida_Personaje1 <>
						 Refutadas[Idem[Turno]][8])
						And
						(Sospecha_Valida_Personaje1 <>
						 Refutadas[Idem[Turno]][9])
						And
						(Sospecha_Valida_Personaje1 <>
						 Refutadas[Idem[Turno]][10])
						And
						(Sospecha_Valida_Personaje1 <>
						 Refutadas[Idem[Turno]][11])
						And
						(Sospecha_Valida_Personaje1 <>
						 Refutadas[Idem[Turno]][12])
						And
						(Sospecha_Valida_Personaje1 <>
						 Refutadas[Idem[Turno]][13])
						And
						(Sospecha_Valida_Personaje1 <>
						 Refutadas[Idem[Turno]][14])
						And
						(Sospecha_Valida_Personaje1 <>
						 Refutadas[Idem[Turno]][15])
						And
						(Sospecha_Valida_Personaje1 <>
						 Refutadas[Idem[Turno]][16])
						And
						(Sospecha_Valida_Personaje1 <>
						 Refutadas[Idem[Turno]][17])
						And
						(Sospecha_Valida_Personaje1 <>
						 Refutadas[Idem[Turno]][18])
						And
						(Sospecha_Valida_Personaje1 <>
						 Refutadas[Idem[Turno]][19])
						And
						(Sospecha_Valida_Personaje1 <>
						 Refutadas[Idem[Turno]][20])
						And
						(Sospecha_Valida_Personaje1 <>
						 Refutadas[Idem[Turno]][21]));

					Mazo:= True;
					NCarta:= 1;

					if ((Njugadores = 3) or  (Njugadores = 6)) then

						Begin

							While (NCarta <= Particion_Cartas) do

								Begin

									if (Mano[Idem[Turno]][NCarta] <>
											Sospecha_Valida_Personaje1) then

										Begin

											Mazo:= false;
											NCarta := NCarta + 1;

										End

									else

										Begin

											Mazo:= true;
											NCarta:= Particion_Cartas + 1;

										end;

								End;
						End

					else if ((Njugadores = 4) or  (Njugadores = 5)) then

						Begin

							While (NCarta <= (Particion_Cartas + 1)) do

								Begin

									if (Mano[Idem[Turno]][NCarta] <>
										Sospecha_Valida_Personaje1) then

										Begin

											Mazo:= false;
											NCarta := NCarta + 1;

										End

									else

										Begin

											Mazo:= true;
											NCarta:= Particion_Cartas + 2;

										end;

								End;
						End;

					Until (Mazo = false);

					Repeat

						Repeat
						
							Sospecha_Roll := Random(6) + 7;

							Case Sospecha_Roll of

								7 : sospecha_Valida_Arma1 := Candelabro;
								8 : Sospecha_Valida_Arma1 := Cuchillo;
								9 : Sospecha_Valida_Arma1 := Cuerda;
								10: Sospecha_Valida_Arma1 := LlaveInglesa;
								11: Sospecha_Valida_Arma1 := Revolver;
								12: Sospecha_Valida_Arma1 := Tubo;

							End;
						
												Until
						((Sospecha_Valida_Arma1 <> Refutadas[Idem[Turno]][1])
						And
						(Sospecha_Valida_Arma1 <> Refutadas[Idem[Turno]][2])
						And
						(Sospecha_Valida_Arma1 <> Refutadas[Idem[Turno]][3])
						And
						(Sospecha_Valida_Arma1 <> Refutadas[Idem[Turno]][4])
						And
						(Sospecha_Valida_Arma1 <> Refutadas[Idem[Turno]][5])
						And
						(Sospecha_Valida_Arma1 <> Refutadas[Idem[Turno]][6])
						And
						(Sospecha_Valida_Arma1 <> Refutadas[Idem[Turno]][7])
						And
						(Sospecha_Valida_Arma1 <> Refutadas[Idem[Turno]][8])
						And
						(Sospecha_Valida_Arma1 <> Refutadas[Idem[Turno]][9])
						And
						(Sospecha_Valida_Arma1 <> Refutadas[Idem[Turno]][10])
						And
						(Sospecha_Valida_Arma1 <> Refutadas[Idem[Turno]][11])
						And
						(Sospecha_Valida_Arma1 <> Refutadas[Idem[Turno]][12])
						And
						(Sospecha_Valida_Arma1 <> Refutadas[Idem[Turno]][13])
						And
						(Sospecha_Valida_Arma1 <> Refutadas[Idem[Turno]][14])
						And
						(Sospecha_Valida_Arma1 <> Refutadas[Idem[Turno]][15])
						And
						(Sospecha_Valida_Arma1 <> Refutadas[Idem[Turno]][16])
						And
						(Sospecha_Valida_Arma1 <> Refutadas[Idem[Turno]][17])
						And
						(Sospecha_Valida_Arma1 <> Refutadas[Idem[Turno]][18])
						And
						(Sospecha_Valida_Arma1 <> Refutadas[Idem[Turno]][19])
						And
						(Sospecha_Valida_Arma1 <> Refutadas[Idem[Turno]][20])
						And
						(Sospecha_Valida_Arma1 <> Refutadas[Idem[Turno]][21]));
						
					Mazo:= True;
					NCarta:= 1;

					if ((Njugadores = 3) or  (Njugadores = 6)) then

						Begin

							While (NCarta <= Particion_Cartas) do

								Begin

									if (Mano[Idem[Turno]][NCarta] <>
													Sospecha_Valida_Arma1) then

										Begin

											Mazo:= false;
											NCarta := NCarta + 1;

										End

									else

										Begin

											Mazo:= true;
											NCarta:= Particion_Cartas + 1;

										end;

								End;
						End

					else if ((Njugadores = 4) or  (Njugadores = 5)) then

						Begin

							While (NCarta <= (Particion_Cartas + 1)) do

								Begin

									if (Mano[Idem[Turno]][NCarta] <>
												Sospecha_Valida_Personaje1) then

										Begin

											Mazo:= false;
											NCarta := NCarta + 1;

										End

									else

										Begin

											Mazo:= true;
											NCarta:= Particion_Cartas + 2;

										end;

								End;
						End;

					Until (Mazo = false);

					Sospecha_Valida_Lugar1 := Escena;


				End;

		Var

			ID : IdemP;
			// Guarda el turno actual
			Sospecha_Valida_Personaje : CartGlobal;
			// Sospecha de la maquina que no es repetida
			Sospecha_Valida_Arma      : CartGlobal;
			// Sospecha de la maquina que no es repetida
			Sospecha_Valida_Lugar     : CartGlobal;
			// Sospecha de la maquina que no es repetida
			NCarta                    : integer;
			// Variable de iteracion
            Verificar                 : boolean;
			// Verifica si hay coincidencias
			Carta_Refutada            : Integer;
			// Numero de carta refutada

		Begin
			
			Carta_Refutada := Mem_Refutadas[Idem[Turno]];
			Pregunta_bot(Sospecha_Valida_Personaje,sospecha_Valida_Arma,
						sospecha_Valida_lugar,Refutadas,Njugadores,
						Particion_Cartas,Mano,Escena);
							
			ID := Turno;
			Verificar:= false;
			Writeln('ID :=', ID);
			
			For Turno:= 1 to Njugadores do
			
				Begin
				
					For NCarta:= 1 to Particion_Cartas do
					
						Begin
						
							Writeln(Turno);
							Writeln(Mano[Idem[Turno]][NCarta]);
							Readln;
						
						End;
				
				End;


			Textcolor(11);
			Write('La sospecha de: ');
			Textcolor(7);
			Writeln(Idem[ID]);
			Writeln;
			Textcolor(11);
			Writeln('¿Quien es el culpable?');
			Textcolor(7);
			Writeln(Sospecha_Valida_Personaje);
			Writeln;
			Textcolor(11);
			Writeln('¿Cual es el Arma?');
			Textcolor(7);
			Writeln(sospecha_Valida_Arma);
			Write('     ','Como usted se encuentra en ');
			Textcolor(11);
			Writeln(Sospecha_Valida_Lugar);
			Textcolor(7);
			Writeln('     ','Entonces la sospecha sera ahi');
			Writeln;
			Readln;
			
			Turno:= ID;

			
			If (Turno < Njugadores) then
			
				begin
				
					Turno := Turno + 1;
				
				end
			
			else if (Turno = NJugadores) then
			
				Begin
				
					Turno:= 1;
				
				end;
				

			If ((Njugadores = 3) or (Njugadores = 6)) then

				Begin

					While ((Turno <= Njugadores) and (ID <> Turno)) do

						Begin

							NCarta := 1;

							While (NCarta <= Particion_Cartas) do

							Begin
							
								Writeln('REVISANDO LA CARTA ', Idem[Turno]);
								Writeln(Mano[Idem[Turno]][NCarta]);
								Readln;
							
							
								If (Mano[Idem[Turno]][NCarta] =
												Sospecha_Valida_Personaje) then

									Begin

										Writeln(Idem[Turno],' Le muestra la carta ');
										Writeln(Idem[ID]);
										Writeln;
										Verificar:= true;
										
									End

								else if (Mano[Idem[Turno]][NCarta] =
													Sospecha_Valida_Arma) then
	
									Begin

										Writeln(Idem[Turno],' Le muestra la carta ');
										Writeln(Idem[ID]);
										Writeln;
										Verificar:= true;

									End

								else if (Mano[Idem[Turno]][NCarta] =
													Sospecha_Valida_Lugar) then

									Begin

										Writeln(Idem[Turno],' Le muestra la carta ');
										Writeln(Idem[ID]);
										Writeln;
										Verificar:= true;

									End;
									
								if (Verificar =  true) then
									
									Begin
										
										NCarta:= (Particion_Cartas + 2);
										
									End

								Else if (Verificar = false) then
									
									Begin
										
										NCarta:= NCarta + 1;
											
									End;
							End;
									
							if (Verificar =  true) then
									
								Begin
										
									Turno:= (Njugadores + 2);
									Refutadas[Idem[ID]][Carta_Refutada] :=
									Mano[Idem[Turno]][NCarta];
									Carta_Refutada := Carta_Refutada + 1;
										
								End
									
							Else if (Verificar = false) then
									
								Begin

									Turno:= Turno + 1;
									
									if (Turno = (Njugadores + 1)) then
							
										Begin
								
											Turno:= 1;
									
										End;
								End;
								
						End;

				End

			else If ((Njugadores = 4) or (Njugadores = 5)) then

				Begin

					While ((Turno <= Njugadores) and (ID <> Turno)) do

						Begin

							NCarta := 1;
							Writeln('ESTOY REVISANDO LAS CARTAS DE := ',Idem[Turno]);
							Readln;

							While (NCarta <= (Particion_Cartas + 1))  do

								Begin

									If (Mano[Idem[Turno]][NCarta] =
												Sospecha_Valida_Personaje) then

										Begin

											Writeln(Idem[Turno],' Le muestra la carta ');
											Writeln(Idem[ID]);
											Verificar:= true;

										End

									else if (Mano[Idem[Turno]][NCarta] =
													Sospecha_Valida_Arma) then

										Begin

											Writeln(Idem[Turno],' Le muestra la carta ');
											Writeln(Idem[ID]);
											Writeln;
											Verificar:= true;

										End

									else if (Mano[Idem[Turno]][NCarta] =
													Sospecha_Valida_Lugar) then

										Begin

											Writeln(Idem[Turno],' Le muestra la carta ');
											Writeln(Idem[ID]);
											Writeln;
											Verificar:= true;

										End;

									if (Verificar =  true) then

										Begin

											NCarta:= (Particion_Cartas + 2);

										End

									Else if (Verificar = false) then

										Begin

											NCarta:= NCarta + 1;

										End;
								End;

							if (Verificar =  true) then

								Begin

									Turno:= (Njugadores + 2);
									Refutadas[Idem[ID]][Carta_Refutada] :=
									Mano[Idem[Turno]][NCarta];
									Carta_Refutada := Carta_Refutada + 1;

								End

							Else if (Verificar = false) then

								Begin

									Turno:= Turno + 1;

								End;
								
							if (Turno = (Njugadores + 1)) then
							
								Begin
								
									Turno:= 1;
								
								End;

						End;

				End;
			
			If (Verificar = false) then
			
				Begin
				
					Writeln('No se encontro ninguna carta que refutar');
				
				End;
				
			Mem_Refutadas[Idem[ID]] := Carta_Refutada;
			Sospecha_Maquina_Persona1:= Sospecha_Valida_Personaje;
			Sospecha_Maquina_Arma1   := Sospecha_Valida_Arma;
			Sospecha_Maquina_Lugar1  := Sospecha_Valida_Lugar;
			
			Turno:= ID;
			
		End;
(******************************************************************************)
(*					          ACUSAR MAQUINA                   				  *)
(******************************************************************************)
		
	Procedure Acusar_bot(Idem : ArrayIdem;
						 // Relaciona personajes con numeros
						 Turno: IdemP;
						 // Turno de quien acusa
						 Sospecha_Maquina_Persona : CartGlobal;
						 // Persona de la que sospecha antes de acusar
						 Sospecha_Maquina_Arma    : CartGlobal;
						 // El arma que utilizo
						 Sospecha_Maquina_Lugar   : CartGlobal
						 // El lugar donde se cometio
						  );
			// Procedimiento en el que la maquina hace una acusacion y se
			// verifica si es correcta o incorrecta


		Procedure SalidaVictoria_bot; // Mensaje si la acusacion es correcta

			Begin

				{Precondicion: True}

					Textcolor(12);
					Writeln('¡FELICITACIONES!':40);
					Writeln;
					Textcolor(15);
					Writeln('HA DESCUBIERTO EL ASESINATO EN LA CASA DEL DR. BLACK');
					Writeln('ERES UN GRAN DETECTIVE.');
					Writeln;
					Textcolor(7);
					Writeln('Presiona enter para salir del juego');
					Readln;
					Halt;

				{Postcondicion: true}

			End;


		Begin

			{Precondicion: True}

			Writeln(Idem[Turno],' Acusa a ',Sospecha_Maquina_Persona, ' de ');
			Writeln('matar al Sr. Black con ', Sospecha_Maquina_Arma,' en');
			Writeln(Sospecha_Maquina_Lugar);

			SalidaVictoria_bot;

			{Postcondicion: True}

		end;

(******************************************************************************)
(*					              PROGRAMA                    				  *)
(******************************************************************************)


	Var


		Culpable   	   : Carta;

		// Conjunto de las tres cartas culpables

		Mov        	   : ArrayMov;

		// Posicion del jugador en el tablero

		Mano    	   : ArrayMano;

		// Conjunto de cartas por jugador

		Horizontal_mem : ArrayPosicion;

		// Memoria de la posicion horizontal para los turnos

		Vertical_mem   : ArrayPosicion;

		// Memoria de la posicion vertical para los turnos

		ID : IdemP;

		// Contador para identificar de cual jugador es el turno

		Cartas_Usadas : ArrayCartasUsadas;
		
		// Lista de cartas usadas para que no se repitan en el barajeo o la
		// reparticion

        Cartas_Usadas2: ArrayCartasUsadas;

		// contiene el mazo de cartas, barajeadas
		
		Njugadores : integer;
		
		// Numero de jugadores de la partida

        Idem : ArrayIdem;
		
		// Relaciona personajes con numeros
		
		Turno : IdemP;
		
		// Variable que indica de quien es el turno actual	

		Hor : Posicion;
		
		// Variable de iteracion para asignar las habitaciones

		Ver : Posicion;
		
		// Variable de iteracion para asignar las habitaciones		
		
		Pregunta : Carta;
		
		// Guarda una sospecha

		Escena : Lugar;
		
		// Guarda el lugar de una sospecha para mover al jugador del que se
		// sospecha

		Particion_Cartas: Cartas_Jugar;
		
		// Numero de cartas por jugador repartidas equitativamente

		Opcion_sospecha : Afirmacion;
		
		// Opción que se le da al jugador de si quiere sospechar o no.

		Opcion_Acusa : Afirmacion;
		
		// Opción que se le da al jugador de si quiere acusar o no.

		Pregunta_Culpable : Carta;
		
		// Respuesta de la maquina respecto a su sospecha.

		Sospechoso : Personaje;
		
		// Almacena al sospechoso elegido por el jugador
		
		Iteracion : Integer;
		
		// Variable de iteracion

		codigo: word;
		
		// Identifica si la información que ingresa el jugador tiene un error
		// para asi evitar un "runtime error"
		
		mensajeError: string;
		
		// Indica cual es el error

        Refutadas : ArrayMano;
		
		// Contiene las cartas refutadas de los jugadores
		
		Error_bot_mano : Boolean;
		
		// Verifica si las cartas con las que sospecha la maquina no estan encontro
		// su mano
		
		Sospecha_Maquina_Arma: CartGlobal;
		
		// Guarda la sospecha maquina del personaje hecha por el jugador-maquina.
		
		Sospecha_Maquina_Persona : CartGlobal;
		
		// Guarda la sospecha maquina del arma hecha por el jugador-maquina.
		
		Sospecha_Maquina_Lugar : CartGlobal;
		
		// Guarda la sospecha maquina del lugar hecha por el jugador-maquina.
		
		Mem_Refutadas : Array_Nrefutadas;
		
		// Guarda el numero de cartas refutadas
		
		Estado_Jugador : ArrayEstado;
		
		// Indica si el jugador anda activo o eliminado de la partida
		
		Opcion_Cargar : Afirmacion;
		
		// Da la opcion de cargar una partida previamente guardada
		
		Lugar_guardado : ArrayLugarGuardado;
		
		// Guarda el lugar de cada jugador en la partida cargada para asi poder
		// asignar las coordenadas

		

	Begin

	    {Precondicion: true}

        clrscr;

		(*Asignacion De Coordenadas Habitaciones*)


		
		Turno:= 1;
		
		Mem_Refutadas[SeniorVerde] := 1;
		Mem_Refutadas[SenioraBlanco] := 1;
		Mem_Refutadas[SenioraCeleste] := 1;
		Mem_Refutadas[SenioritaaEscarlata] := 1;
		Mem_Refutadas[ProfesorCiruela] := 1;
		Mem_Refutadas[CoronelMostaza] := 1;	
		
		Horizontal_mem[SeniorVerde] := 3;
		Vertical_mem  [SeniorVerde] := 3;
		Horizontal_mem[SenioraBlanco] := 3;
		Vertical_mem  [SenioraBlanco] := 3;
		Horizontal_mem[SenioraCeleste] := 3;
		Vertical_mem  [SenioraCeleste] := 3;
		Horizontal_mem[SenioritaaEscarlata] := 3;
		Vertical_mem  [SenioritaaEscarlata] := 3;
		Horizontal_mem[CoronelMostaza] := 3;
		Vertical_mem  [CoronelMostaza] := 3;
		Horizontal_mem[ProfesorCiruela] := 3;
		Vertical_mem  [ProfesorCiruela] := 3;		

		For Iteracion := 1 To 21 Do
			
			Begin
					
						Refutadas[SeniorVerde][Iteracion] := Vacio;
						Refutadas[SenioraBlanco][Iteracion] := Vacio;
						Refutadas[SenioraCeleste][Iteracion] := Vacio;
						Refutadas[SenioritaaEscarlata][Iteracion] := Vacio;
						Refutadas[ProfesorCiruela][Iteracion] := Vacio;
						Refutadas[CoronelMostaza][Iteracion] := Vacio;
		
			End;
		
		
		Case codigo of

			106 : mensajeError:='Invalid number.';

		end;

		Logo;
		Tablero;
		introduccion(Opcion_Cargar);
		
		If (Opcion_Cargar = No) Then

			Begin
		
				Prejuego(Njugadores,Culpable,Idem,Cartas_Usadas);
				Inicio(Njugadores,Mano,Cartas_Usadas,Cartas_Usadas2,Idem,
				Particion_Cartas);
				
				Estado_Jugador[Idem[1]] := Activo;
				Estado_Jugador[Idem[2]] := Activo;
				Estado_Jugador[Idem[3]] := Activo;
				Estado_Jugador[Idem[4]] := Activo;
				Estado_Jugador[Idem[5]] := Activo;
				Estado_Jugador[Idem[6]] := Activo;
			
			End
			
		Else If (Opcion_Cargar = Si) Then
		
			Begin
			
				Cargar_Partida(Njugadores,Lugar_guardado,Mano,Idem,
							   Refutadas, Mem_Refutadas,Cartas_Usadas,
							   Estado_Jugador);
				
				Culpable.Personaje := Cartas_Usadas[1];
				Culpable.Arma := Cartas_Usadas[2];
				Culpable.Lugar := Cartas_Usadas[3];
				

				For ID := 1 To 6 Do

					Begin
					
						If (Lugar_guardado[Idem[ID]] = Invernadero) Then
						
							Begin
							
								Horizontal_mem[Idem[ID]] := 1;
								Vertical_mem[Idem[ID]] := 1;
							
							End
						
						Else If (Lugar_guardado[Idem[ID]] = SalaDeBaile) Then
						
							Begin
							
								Horizontal_mem[Idem[ID]] := 3;
								Vertical_mem[Idem[ID]] := 1;
							
							End

						Else If (Lugar_guardado[Idem[ID]] = SalaDeBillar) Then
						
							Begin
							
								Horizontal_mem[Idem[ID]] := 5;
								Vertical_mem[Idem[ID]] := 1;
							
							End

						Else If (Lugar_guardado[Idem[ID]] = Estudio) Then
						
							Begin
							
								Horizontal_mem[Idem[ID]] := 1;
								Vertical_mem[Idem[ID]] := 3;
							
							End						

						Else If (Lugar_guardado[Idem[ID]] = Vestibulo) Then
						
							Begin
							
								Horizontal_mem[Idem[ID]] := 3;
								Vertical_mem[Idem[ID]] := 3;
							
							End

						Else If (Lugar_guardado[Idem[ID]] = Salon) Then
						
							Begin
							
								Horizontal_mem[Idem[ID]] := 5;
								Vertical_mem[Idem[ID]] := 3;
							
							End

						Else If (Lugar_guardado[Idem[ID]] = Biblioteca) Then
						
							Begin
							
								Horizontal_mem[Idem[ID]] := 1;
								Vertical_mem[Idem[ID]] := 5;
							
							End
							
						Else If (Lugar_guardado[Idem[ID]] = Cocina) Then
						
							Begin
							
								Horizontal_mem[Idem[ID]] := 3;
								Vertical_mem[Idem[ID]] := 5;
							
							End

						Else If (Lugar_guardado[Idem[ID]] = Comedor) Then
						
							Begin
							
								Horizontal_mem[Idem[ID]] := 5;
								Vertical_mem[Idem[ID]] := 5;
							
							End;
					
					End;
					
			End;
		
		For ID := 1 To 6 Do

			Begin

				For Hor := 1 To 5 Do

					Begin

						For Ver := 1 to 5 Do

							Begin

								If (Ver = 1) And (Hor = 1) Then

									Begin

										Mov[Idem[ID]][Hor][Ver]
										:= Invernadero;

									End

								Else If (Ver = 1) And (Hor = 3)
								Then

									Begin

										Mov[Idem[ID]][Hor][Ver]
										:= SalaDeBaile;

									End

								Else If (Ver = 1) And (Hor = 5)
								Then

									Begin

										Mov[Idem[ID]][Hor][Ver]
										:= SalaDeBillar;

									End

								Else If (Ver = 3) And (Hor = 1)
								Then

									Begin

										Mov[Idem[ID]][Hor][Ver]
										:= Estudio;

									End

								Else If (Ver = 3) And (Hor = 3)
								Then

									Begin

										Mov[Idem[ID]][Hor][Ver]
										:= Vestibulo;

									End

								Else If (Ver = 3) And (Hor = 5)
								Then

									Begin

										Mov[Idem[ID]][Hor][Ver]
										:= Salon;

									End

								Else If (Ver = 5) And (Hor = 1)
								Then

									Begin

										Mov[Idem[ID]][Hor][Ver]
										:= Biblioteca;

									End

								Else If (Ver = 5) And (Hor = 3)
								Then

									Begin

										Mov[Idem[ID]][Hor][Ver]
      									:= Cocina;

									End

								Else If (Ver = 5) And (Hor = 5)
								Then

									Begin

										Mov[Idem[ID]][Hor][Ver]
										:= Comedor;

									End
			
								Else

									Begin

										Mov[Idem[ID]][Hor][Ver]
										:= Pasillo;

									End;
							End;
					End;
			End;

		While (Turno <= Njugadores) do


			Begin

					Movimiento(Horizontal_mem,Vertical_mem,Turno,Idem,Mov);
					Escena:= Mov[idem[Turno]][Horizontal_mem[Idem[Turno]]]
												[Vertical_mem[Idem[Turno]]];

					If (Turno = 1) then

						Begin
						
							{$IOCHECKS OFF}

							Repeat

								Textcolor(11);
								Writeln('¿Desea hacer una sospecha?');
								Writeln;
								Textcolor(7);
								Write('     ');
								Readln(Opcion_sospecha);

								codigo:= ioResult;

								if codigo = 106 then

								Begin

									Writeln;
									Writeln('Solo se tiene la opcion si o no');
					
								End;

							Until (Codigo = 0);

							if (Opcion_sospecha = si) then

								Begin

									Sospecha(Mov,Escena,Mano,Pregunta,
											Particion_Cartas,Njugadores,Idem,
											Sospechoso,Mem_Refutadas,Refutadas);


								If (Sospechoso = Idem[2]) then

									Begin

										Horizontal_mem[Idem[2]]:=
										Horizontal_mem[idem[Turno]];

										Vertical_mem[Idem[2]]:=
										Vertical_mem[Idem[Turno]];

									End

								else If (Sospechoso = Idem[3]) then

									Begin

										Horizontal_mem[Idem[3]]:=
										Horizontal_mem[idem[Turno]];

										Vertical_mem[Idem[3]]:=
										Vertical_mem[idem[Turno]];

									end

								else If (Sospechoso = Idem[3]) then

									Begin

										Horizontal_mem[Idem[3]]:=
										Horizontal_mem[idem[Turno]];

										Vertical_mem[Idem[3]]:=
										Vertical_mem[idem[Turno]];

									End

								else If (Sospechoso = Idem[4]) then

									Begin

										Horizontal_mem[Idem[4]]:=
										Horizontal_mem[idem[Turno]];

										Vertical_mem[Idem[4]]:=
										Vertical_mem[idem[Turno]];

									End

								else If (Sospechoso = Idem[5]) then

									begin

										Horizontal_mem[Idem[5]]:=
										Horizontal_mem[idem[Turno]];

										Vertical_mem[Idem[5]]:=
										Vertical_mem[idem[Turno]];

									End

								else If (Sospechoso = Idem[6]) then

									Begin

										Horizontal_mem[Idem[6]]:=
										Horizontal_mem[idem[Turno]];

										Vertical_mem[Idem[6]]:=
										Vertical_mem[idem[Turno]];

									End;

								End;

							Repeat

								Textcolor(11);
								Writeln('¿Desea hacer una acusacion?');
								Writeln;
								Textcolor(7);
								Write('     ');
								Readln(Opcion_Acusa);
								Writeln;

								codigo:= ioResult;

									if codigo = 106 then

										Begin

											Writeln;
											Write('Solo se tiene la opcion');
											Writeln(' si o no');

										End;

							Until (Codigo = 0);

							if (Opcion_Acusa = si) then

								Begin

								   Acusar(Cartas_Usadas,Pregunta_Culpable,Escena);

								End;

						End

					Else if (((Turno = 2) And (Estado_Jugador[Idem[2]] = Activo)) or
					((Turno = 3) And (Estado_Jugador[Idem[3]] = Activo)) or
					((Turno = 4) And (Estado_Jugador[Idem[4]] = Activo)) or
					((Turno = 5) And (Estado_Jugador[Idem[5]] = Activo)) or
					((Turno = 6) And (Estado_Jugador[Idem[6]] = Activo))) then

						Begin

							Sospecha_bot(Mano,Idem,Turno,Escena,
										Njugadores,Particion_Cartas,
										Sospecha_Maquina_Persona,
										Sospecha_Maquina_Arma,
										Sospecha_Maquina_Lugar,
										Mem_Refutadas,Refutadas);
							
							Error_bot_mano := True;
							
							Error_bot_mano := ((Sospecha_Maquina_Lugar
							= Mano[Idem[Turno]][1]) or (Sospecha_Maquina_Lugar =
							Mano[Idem[Turno]][2]) or (Sospecha_Maquina_Lugar =
							Mano[Idem[Turno]][3]) or (Sospecha_Maquina_Lugar =
							Mano[Idem[Turno]][4]) or (Sospecha_Maquina_Lugar =
							Mano[Idem[Turno]][5]) or (Sospecha_Maquina_Lugar =
							Mano[Idem[Turno]][6]));

							if ((Sospecha_Maquina_Persona = Cartas_Usadas[1]) and
							   (Sospecha_Maquina_Arma    = Cartas_Usadas[2]) and
							   (Sospecha_Maquina_Lugar   = Cartas_Usadas[3])
								And (Error_bot_mano = False)) then

									Begin
									
										Acusar_bot(Idem,Turno,
													Sospecha_Maquina_Persona,
													Sospecha_Maquina_Arma,
													Sospecha_Maquina_Lugar
													);

									End;

								If (Sospecha_Maquina_Persona = Idem[2]) then

									Begin

										Horizontal_mem[Idem[2]]:=
										Horizontal_mem[idem[Turno]];

										Vertical_mem[Idem[2]]:=
										Vertical_mem[Idem[Turno]];

									End

								else If (Sospecha_Maquina_Persona = Idem[3]) then

									Begin

										Horizontal_mem[Idem[3]]:=
										Horizontal_mem[idem[Turno]];

										Vertical_mem[Idem[3]]:=
										Vertical_mem[idem[Turno]];

									end

								else If (Sospecha_Maquina_Persona = Idem[3]) then

									Begin

										Horizontal_mem[Idem[3]]:=
										Horizontal_mem[idem[Turno]];

										Vertical_mem[Idem[3]]:=
										Vertical_mem[idem[Turno]];

									End

								else If (Sospecha_Maquina_Persona = Idem[4]) then

									Begin

										Horizontal_mem[Idem[4]]:=
										Horizontal_mem[idem[Turno]];

										Vertical_mem[Idem[4]]:=
										Vertical_mem[idem[Turno]];

									End

								else If (Sospecha_Maquina_Persona = Idem[5]) then

									begin

										Horizontal_mem[Idem[5]]:=
										Horizontal_mem[idem[Turno]];

										Vertical_mem[Idem[5]]:=
										Vertical_mem[idem[Turno]];

									End

								else If (Sospecha_Maquina_Persona = Idem[6]) then

									Begin

										Horizontal_mem[Idem[6]]:=
										Horizontal_mem[idem[Turno]];

										Vertical_mem[Idem[6]]:=
										Vertical_mem[idem[Turno]];
				
									End;							

						End;
						
				Turno:= Turno + 1;

				if (Njugadores < Turno) then

					Begin

						Turno:= 1;

					End;

			End;

        readkey;

	    {Postcondicion:

		((Culpable1.Arma = Hipotesis.Arma) /\ (Culpable1.Personaje = Hipotesis.Personaje) /\ (Culpable1.Lugar = Hipotesis.Lugar) ==> SalidaVictoria)

		/\((Culpable1.Arma <> Hipotesis.Arma) \/ (Culpable1.Personaje <> Hipotesis.Personaje) \/ (Culpable1.Lugar <> Hipotesis.Lugar) ==> SalidaDerrota)}
		
	End.
