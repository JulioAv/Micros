; Archivo:	main.s
; Dispositivo:	PIC16F887
; Autor:	Julio Avila
; Compilador:	pic-as (v2.30), MPLABX V5.00
;
; Programa:	Contador y Display
; Hardware:	Display 7 segmentos, leds y pushbottons
;
; Creado: 16 feb, 2021
; Última modificación: 19 feb, 2021
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
resetVec:
    PAGESEL main
    goto main
    
PSECT code, delta=2, abs
ORG 100h    ; posición para el código
;------------------------------------------------
tabla_:
 clrf    PCLATH
 bsf	 PCLATH, 0
 andlw	 00001111B
 addwf   PCL		    ; El valor del PC se suma con lo que haya en w para
 retlw   00111111B	    ; 0	    ir a la linea respectiva de cada valor
 retlw   00000110B	    ; 1	    El and es para asegurar que el valor que 
 retlw   01011011B	    ; 2	    entre sea unicamente de 4 bits.
 retlw   01001111B	    ; 3	    Con el retlw regresa a al respectivo módulo
 retlw   01100110B	    ; 4	    y lo traslada al puerto A, que es donde
 retlw   01101101B	    ; 5	    está el display.
 retlw   01111101B	    ; 6
 retlw   01000111B	    ; 7
 retlw   01111111B	    ; 8
 retlw   01100111B	    ; 9
 retlw   01110111B	    ; A
 retlw   01111100B	    ; b
 retlw   00111001B	    ; c
 retlw   01011110B	    ; d
 retlw   01111001B	    ; E
 retlw   01110001B	    ; F
 return

main:
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
 
 clrf	    TRISC
 bsf	    TRISC, 0
 bsf	    TRISC, 1	    ; Los primeros dos pines tendrán los push
 bcf	    TRISC, 2	    ;En el tercer pin se asignará la salida de la alarma.   
 
 clrf	    TRISD	    ;El puerto D se utilizará para asignar el valor al PCL
 
 BANKSEL    OPTION_REG
 bcf	    T0CS
 bcf	    T0SE            ; Condifuración del TMR0 con prescaler 256
 bcf	    PSA
 bsf	    PS2
 bsf	    PS1
 bsf	    PS0
 
 
 BANKSEL    TMR0
 movlw	    12
 movwf	    TMR0	    ; Valor n calculado para el timer
 
 BANKSEL    OSCCON
 bcf	    OSCCON, 3	    ; Oscilador interno a 500Khz
 bsf	    OSCCON, 4
 bsf	    OSCCON, 5
 bcf	    OSCCON, 6
 
 BANKSEL    PORTA	    ; comenzar los outputs en 0
 clrf	    PORTA
 clrf	    PORTB
 clrf	    PORTD
 clrf	    PORTC
 
 goto loop
 
loop:
   call inc_B
   BANKSEL PORTC
   btfsc   PORTC, 0	    ; Aumenta el display con el primer push
   call inc_disp
   btfsc   PORTC, 1
   call dec_disp	    ; Decrementa el display con el otro push
   movf    PORTB, w
   subwf   PORTD, w
   bcf	   PORTC, 2
   btfsc   STATUS, 2
   call comp_
   goto loop
    

inc_B:
    btfss   T0IF	    ; TMR0 configurado para los 500ms
    goto $-1
    BANKSEL PORTB
    incf    PORTB	    ; Aumenta B con cada banderazo del timer
    bcf	    T0IF
    return  
    
inc_disp:
    btfsc   PORTC, 0	    ; Sistema de antirrebote
    goto    $-1
    incf    PORTD	    ; El contador D incrementa y se guarda en w
    movf    PORTD, w	    ; cuando va a tabla se lleva ese valor
    call    tabla_
    movwf   PORTA
    return
    
dec_disp: 
    btfsc   PORTC, 1	    ; Sistema antirrebote
    goto    $-1
    decf    PORTD	    ; El contador D decrementa y se guarda en w
    movf    PORTD, w	    ; Igualmente lleva w a tabla
    call    tabla_
    movwf   PORTA
    return   
    
comp_:
    clrf    PORTB
    bsf	    PORTC, 2
    return
END