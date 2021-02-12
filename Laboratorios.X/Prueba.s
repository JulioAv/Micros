; Archivo:	main.s
; Dispositivo:	PIC16F887
; Autor:	Julio Avila
; Compilador:	pic-as (v2.30), MPLABX V5.00
;
; Programa:	Contadores y sumador
; Hardware:	LEDs en el puerto A
;
; Creado: 2 feb, 2021
; Última modificación: 2 feb, 2021
;
; configuration word 1
    
PROCESSOR 16F887
    #include <xc.inc>
    
  CONFIG FOSC=INTRC_NOCLKOUT	//oscilador externo
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
	cont: DS 1 ;1 byte
	;cont_big:   DS 1
    
PSECT resVct, class=CODE, abs, delta=2
;--------------vector reset---------------------
ORG 00h	    ;posicion 000h para el reset
resetVec:
    PAGESEL main
    goto main
    
PSECT code, delta=2, abs
ORG 100h    ; posición para el código
;------------------------------------------------
 
main:
    BANKSEL ANSEL
    clrf    ANSEL
    clrf    ANSELH
    
    BANKSEL TRISA
    clrf    TRISA
    ;bsf	    TRISA
    
    BANKSEL PORTA
    clrf    PORTB
;-----------loop principal---------------------
loop:
    btfsc   PORTA, 0
    call    inc_portb
    goto    loop
;-----------sub rutinas-----------------------
inc_portb:
    btfsc   PORTA, 0
    goto    $-1
    incf    PORTB, F
    btfsc   PORTB, 3
    return