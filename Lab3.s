; Archivo:	main.s
; Dispositivo:	PIC16F887
; Autor:	Julio Avila
; Compilador:	pic-as (v2.30), MPLABX V5.00
;
; Programa:	Contador y Display
; Hardware:	Display 7 segmentos, leds y pushbottons
;
; Creado: 16 feb, 2021
; Última modificación: 17 feb, 2021
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

 BANKSEL    ANSEL
 clrf	    ANSEL
 clrf	    ANSELH	    ; Unicamente puertos digitales
 
 BANKSEL    TRISA
 clrf	    TRISA
 bsf	    TRISA, 7	    ; El último bit de A (7 segmentos) no se usará
 
 clrf	    TRISB
 bsf	    TRISB, 4
 bsf	    TRISB, 5
 bsf	    TRISB, 6
 bsf	    TRISB, 7	    ; Solo los primeros 4 pines serán contadores
 
 movlw	    b'00000011'	    ; Los primeros dos pines tendrán los push
 movwf	    TRISC
 
 movlw	    b'11111110'	    ; El primer bit será el output de la alarma
 movwf	    TRISD
 
 BANKSEL    OPTION_REG
 movlw	    b'11000111'
 movwf	    OPTION_REG
 
 BANKSEL    TMR0
 movlw	    12
 movwf	    TMR0
 
 BANKSEL    OSCCON
 movlw	    b'00110111'
 movwf	    OSCCON
 
 goto loop
 
 loop:
    call inc_B
    goto loop
    

inc_B:
    btfss   T0IF
    goto $-1
    incf    PORTB
    clrf    T0IF
    return  
    
END