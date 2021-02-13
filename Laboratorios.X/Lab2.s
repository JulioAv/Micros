
; PIC16F887 Configuration Bit Settings

; Assembly source line config statements

PROCESSOR 16F887
#include <xc.inc>

; CONFIG1
  CONFIG  FOSC = XT		; Oscillator Selection bits (RCIO oscillator: I/O function on RA6/OSC2/CLKOUT pin, RC on RA7/OSC1/CLKIN)
  CONFIG  WDTE = OFF            ; Watchdog Timer Enable bit (WDT disabled and can be enabled by SWDTEN bit of the WDTCON register)
  CONFIG  PWRTE = ON            ; Power-up Timer Enable bit (PWRT enabled)
  CONFIG  MCLRE = OFF           ; RE3/MCLR pin function select bit (RE3/MCLR pin function is digital input, MCLR internally tied to VDD)
  CONFIG  CP = OFF              ; Code Protection bit (Program memory code protection is disabled)
  CONFIG  CPD = OFF             ; Data Code Protection bit (Data memory code protection is disabled)
  CONFIG  BOREN = OFF           ; Brown Out Reset Selection bits (BOR disabled)
  CONFIG  IESO = OFF            ; Internal External Switchover bit (Internal/External Switchover mode is disabled)
  CONFIG  FCMEN = OFF           ; Fail-Safe Clock Monitor Enabled bit (Fail-Safe Clock Monitor is disabled)
  CONFIG  LVP = ON              ; Low Voltage Programming Enable bit (RB3/PGM pin has PGM function, low voltage programming enabled)

; CONFIG2
  CONFIG  BOR4V = BOR40V        ; Brown-out Reset Selection bit (Brown-out Reset set to 4.0V)
  CONFIG  WRT = OFF             ; Flash Program Memory Self Write Enable bits (Write protection off)

PSECT udata_bank0 ;common memory
	;1 byte
	cont_small: DS 1 ;1 byte
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
    bsf	    STATUS, 5	; banco 11
    bsf	    STATUS, 6
    
    BANKSEL ANSEL	;Puertos digitales unicamente
    clrf    ANSEL
    clrf    ANSELH
    
;---------------------------------------    
    bcf	    STATUS, 5	; banco 01
    bsf	    STATUS, 6
    
        
    BANKSEL TRISA	; Primeros bits de A son inputs
    clrf    TRISA  
    bsf	    TRISA, 5
    bsf	    TRISA, 6
    bsf	    TRISA, 7    
    
    BANKSEL TRISB
    clrf    TRISB	; Solo los primeros bits de B son outputs para que no
    bsf	    TRISB, 4	; cuente con los últimos bits tambien
    bsf	    TRISB, 5
    bsf	    TRISB, 6
    bsf	    TRISB, 7
    
    BANKSEL TRISC
    clrf    TRISC
    bsf	    TRISC, 0	; Los primeros bits de C seran las entradas de
    bsf	    TRISC, 1	; los pushbottons
    bsf	    TRISC, 2
    bsf	    TRISC, 3
    bsf	    TRISC, 4
    
    
    BANKSEL TRISD
    clrf    TRISD
    bsf	    TRISD, 4	; Mismo caso con el puerto B
    bsf	    TRISD, 5
    bsf	    TRISD, 6
    bsf	    TRISD, 7
;------------------------------------------    
    bcf	    STATUS, 5	; banco 00
    bcf	    STATUS, 6
    
loop:
    btfsc   PORTC, 0	; Si el interruptor se oprime va a la instrucción
    goto    inc_B	; correspondiente, si no, se salta el goto y sigue
    btfsc   PORTC, 1
    goto    dec_B
    btfsc   PORTC, 2
    goto    inc_D
    btfsc   PORTC, 3
    goto    dec_D
    btfsc   PORTC, 4
    goto    adder_
    goto loop		; Termina de verificar puertos y vuelve al inicio
    
inc_B:
    btfsc   PORTC, 0	; Si se mantiene oprimido no pasará nada hasta que
    goto $-1		; que se suelte el push (antirrebote)
    incf    PORTB, F	; Incrementa el puerto
    return		; Vuelve al ciclo principal

dec_B:
    btfsc   PORTC, 1	; Mismo caso pero decrementa
    goto $-1
    decf    PORTB, F
    return
    
inc_D:
    btfsc   PORTC, 2	; Mismo caso que en B pero para D
    goto $-1
    incf    PORTD, F
    return

dec_D:
    btfsc   PORTC, 3
    goto $-1
    decf    PORTD, F
    return
    
adder_:
    btfsc   PORTC, 4	; Sistema de antirrebote
    goto $-1
    movf    PORTB, 0	; Mueve el puerto B al registro F
    addwf   PORTD, 0	; Le suma al registro F el puerto D
    movwf   PORTA	; Mueve el registro F al puerto A
    return
    

    
delay_small:
    movlw   150		;valor inicial del contador
    movwf   cont_small
    decfsz  cont_small, 1   ;decrementar el contador
    goto    $-1		; ejecutar linea anterior
    return


END