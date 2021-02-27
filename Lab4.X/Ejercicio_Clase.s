; Archivo:	Ejercicio_Clase.s
; Dispositivo:	PIC16F887
; Autor:	Julio Avila
; Compilador:	pic-as (v2.30), MPLABX V5.45
;
; Programa:	Ejercicio en Clase
; Hardware:	2 Display 7 segmentos, leds y pushbottons
;
; Creado: 22 feb, 2021
; Última modificación: 22 feb, 2021
;
; configuration word 1
    
PROCESSOR 16F887
    #include <xc.inc>
    
  CONFIG FOSC=INTRC_NOCLKOUT	//oscilador interno
  CONFIG WDTE=OFF   // WDT disabled (reinicio repetitivo de pic)
  CONFIG PWRTE=ON   // PWRT enabled (espera de 72ms al iniciar)
  CONFIG MCLRE=OFF  // El pin de MCLR se utiliza como I/O
  CONFIG CP=OFF    //Sin protección de código
  CONFIG CPD=OFF   //Sin protección de datos
  
  CONFIG BOREN=OFF  // Sin reinicio cuando el voltaje de alimentación baja de 4V
  CONFIG IESO=OFF   //Reinicio sin cambio de reloj de interno a externo
  CONFIG FCMEN=OFF  //Cambio de reloj externo a interno en caso de fallo
  CONFIG LVP=ON	    //programación en bajo voltaje permitida
  
; configuration word 2
   CONFIG WRT=OFF  //Protección de autoescritura por el programa desactivada
   CONFIG BOR4V=BOR40V	//Reinicio abajo de 4V, (BOR21V-2.1V)
    
   PSECT udata_bank0 ;common memory
	;cont: DS 1 ;1 byte
	;cont_big:   DS 1
    
PSECT resVct, class=CODE, abs, delta=2
;--------------vector reset---------------------
ORG 00h	    ;posicion 000h para el reset
;resetVec:
 ;   PAGESEL main
  ;  goto main
    
PSECT code, delta=2, abs
ORG 100h    ; posición para el código
;------------------------------------------------
 movlf	macro arg1, arg2
	movlw	arg1
	movwf	arg2
	endm
	
restartTMR0 macro
	movlf 61, TMR0
	bcf	T0IF
	endm 
 
 ;pinMode(pin, INPUT/OUTPUT)
 
 digitalWrite macro argPin, argPort, argIO
    BANKSEL	TRISA
    movlw	argIO
    IF argIO
    bsf		argPort, argPin
    ELSE
    bcf		argPort, argPin
    ENDIF
    ENDM
    
 ;digitalWrite(pin, HIHG/LOW)
 
 
