; Archivo:	Lab4.s
; Dispositivo:	PIC16F887
; Autor:	Julio Avila
; Compilador:	pic-as (v2.30), MPLABX V5.45
;
; Programa:	Displays Múltiples
; Hardware:	5 displays, 8 leds y 2 push
;
; Creado: 28 feb, 2021
; Última modificación: 5 mar, 2021
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

UP    EQU 0
DOWN  EQU 1
  
PSECT udata_bank0   
var:         DS 2
var2:		DS 2
cent:		DS 2
deci:		DS 2
uni:		DS 2
resu:		DS 2
cont1:	DS 2
    
PSECT udata_shr
W_TEMP:	DS 1	    
STATUS_TEMP:  DS 1

PSECT resVect, class=CODE, abs, delta=2
;-----------vector reset--------------;
ORG 00h     ;posicion 0000h para el reset
resetVec:
    PAGESEL main
    goto main

PSECT intVect, class=CODE, abs, delta=2
;-----------vector interrupt--------------;
ORG 04h     ;posicion 0004h para las interrupciones
    
push:
    movwf   W_TEMP
    swapf   STATUS, W
    movwf   STATUS_TEMP
    return
    
pop:
    swapf   STATUS_TEMP, W
    movwf   STATUS
    swapf   W_TEMP, F
    swapf   W_TEMP, W
    retfie
    
PSECT code, delta=2, abs
ORG 100h    ; posicion para le codigo

tabla_:
    BANKSEL PCLATH
    clrf    PCLATH
    bsf	 PCLATH, 0
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
    BANKSEL	ANSEL
    clrf	ANSEL
    clrf	ANSELH	    ; Solo puertos digitales
    
    BANKSEL	TRISA
    clrf	TRISA	    ; Todo el puerto A como output
    movlw	00000011B   ; Dos inputs para los push
    movwf	TRISB
    movlw	10000000B   ; 7 outputs para los displays
    movwf	TRISC
    movlw	11100000B   ; 5 outputs para multiplexar
    movwf	TRISD
    
    BANKSEL	OPTION_REG
    bcf		OPTION_REG, 7
    bcf		T0CS
    bcf		T0SE            ; Condifuración del TMR0 con prescaler 2
    bsf		PSA
    bcf		PS2
    bcf		PS1
    bcf		PS0
    BANKSEL	TMR0	    
    movlw	100		; Valor de TMR0 para 5ms
    movwf	TMR0
    
    BANKSEL	OSCCON
    bsf		OSCCON, 0
    bcf		OSCCON, 3	    ; Oscilador interno a 500KHz
    bsf		OSCCON, 4
    bsf		OSCCON, 5
    bcf		OSCCON, 6
    
    BANKSEL	INTCON
    bsf		GIE     
    bsf		RBIE		; Interrupciones del puerto B
    bsf		T0IE		; Interrupciones del TMR0
    
    BANKSEL	PORTA
    clrf	PORTA		; iniciar todo en 0
    clrf	PORTC
    clrf	PORTD
    clrf	var
    
    
loop:
    BANKSEL	INTCON
    btfss	RBIF		; Verificar si hay interrupción
    goto	$+4
    call	push		; push y pop para interrupciones
    call	int_B
    call	pop
    call	decimal		; módulo para convertir a decimal
    call	timer		; módulo para definir displays
    goto	loop
    
int_B:
    BANKSEL	PORTB		; Interrupción del puero B
    btfss	PORTB, 0
    call	inc_A
    btfss	PORTB, 1
    call	dec_A
    return
    
inc_A:
    BANKSEL	PORTB
    btfss	PORTB, 0	; incremento de la variable y se muestrea
    goto	$-1		; en el puerto A
    incf	var
    movf	var, 0
    movwf	PORTA
    return
    
dec_A:
    BANKSEL	PORTB		; Decremento de la variable y Puerto A
    btfss	PORTB, 1
    goto	$-1
    decf	var
    movf	var, 0
    movwf	PORTA
    return
    
sep_nibble1:
    movf	var, 0		; la variable se mueve a w para ir a tabla
    andlw	00001111B	; and para solo usar los primeros 4 bits
    call	tabla_
    BANKSEL	PORTC
    movwf	PORTC		; muestreo de la tabla en el puerto C
    return

sep_nibble2:
    swapf	var, 0
    andlw	00001111B
    call	tabla_
    BANKSEL	PORTC
    movwf	PORTC
    return
    
decimal:
    clrf	cont1
    movlw	1100100B	    ; cien en binario
    movwf	var2
    movf	var, 0
    subwf	var2, 0		    ; le resta 100 a la variable
    BANKSEL	STATUS
    btfsc	STATUS, 0	    ; cuando la resta da menor a 100, sigue
    incf	cont1		    ; con el proceso y la cantidad de veces
    btfsc	STATUS, 0	    ; que tuvo que restar se vuelve la centena
    goto	$-5
    movwf	resu
    movf	cont1, 0
    movwf	cent
    ;---------------------;
    clrf	cont1
    movlw	00001010B	    ; mismo caso pero ahora con 10 y comienza
    movwf	var2		    ; a restar desde el valor obtenido de la resta
    movf	resu, 0
    subwf	var2
    btfsc	STATUS, 0
    incf	cont1
    btfsc	STATUS, 0
    goto	$-4
    movwf	resu		    ; ahora almacena la cantidad de restas
    movf	cont1, 0	    ; en las decenas
    movwf	deci
    ;---------------------;
    movf	resu, 0		    ; el resultado de todas las restas a
    movwf	uni		    ; unidades
    return
    
sep_nibble3:
    movf	cent, 0
    andlw	00001111B
    call	tabla_
    BANKSEL	PORTC
    movwf	PORTC
    return
    
sep_nibble4:
    movf	deci, 0
    andlw	00001111B
    call	tabla_
    BANKSEL	PORTC
    movwf	PORTC
    return
   
sep_nibble5:
    movf	uni, 0
    andlw	00001111B
    call	tabla_
    BANKSEL	PORTC
    movwf	PORTC
    return
    

timer:
    BANKSEL	INTCON		    ; interrupción de TMR0
    btfss	T0IF
    goto	$-1
    ;------------------------;
    BANKSEL	PORTD
    clrf	PORTC
    movlw	00000010B	    ; Se enciende unicamente la señal para
    movwf	PORTD		    ; encender el display respectivo del valor
    call	sep_nibble1	    ; Desplegado en el puerto C
    call	reset_tmr
    btfss	T0IF
    goto	$-1
    ;------------------------;
    BANKSEL	PORTD
    clrf	PORTC
    movlw	00000001B	    ; Mismo caso con todos los displays
    movwf	PORTD
    call	sep_nibble2
    call	reset_tmr
    btfss	T0IF
    goto	$-1
    ;------------------------;
    BANKSEL	PORTD
    clrf	PORTC
    movlw	00000100B
    movwf	PORTD
    call	sep_nibble3
    call	reset_tmr
    btfss	T0IF
    goto	$-1
    ;------------------------;
    BANKSEL	PORTD
    clrf	PORTC
    movlw	00001000B
    movwf	PORTD
    call	sep_nibble4
    call	reset_tmr
    btfss	T0IF
    goto	$-1
    ;------------------------;
    BANKSEL	PORTD
    clrf	PORTC
    movlw	00010000B
    movwf	PORTD
    call	sep_nibble5
    call	reset_tmr
    btfss	T0IF
    goto	$-1
    return
    
reset_tmr:
    BANKSEL	TMR0
    movlw	100		    ; Reinicio del TMR0
    movwf	TMR0
    bcf		T0IF
    return
    
END