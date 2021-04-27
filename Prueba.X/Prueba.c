/*
 * File:   Prueba.c
 * Author: swimm
 *
 * Created on 27 de abril de 2021, 02:26 PM
 */
#pragma config FOSC = INTRC_NOCLKOUT// Oscillator Selection bits (INTOSCIO oscillator: I/O function on RA6/OSC2/CLKOUT pin, I/O function on RA7/OSC1/CLKIN)
#pragma config WDTE = OFF       // Watchdog Timer Enable bit (WDT disabled and can be enabled by SWDTEN bit of the WDTCON register)
#pragma config PWRTE = ON       // Power-up Timer Enable bit (PWRT enabled)
#pragma config MCLRE = OFF      // RE3/MCLR pin function select bit (RE3/MCLR pin function is digital input, MCLR internally tied to VDD)
#pragma config CP = OFF         // Code Protection bit (Program memory code protection is disabled)
#pragma config CPD = OFF        // Data Code Protection bit (Data memory code protection is disabled)
#pragma config BOREN = OFF      // Brown Out Reset Selection bits (BOR disabled)
#pragma config IESO = OFF       // Internal External Switchover bit (Internal/External Switchover mode is disabled)
#pragma config FCMEN = OFF      // Fail-Safe Clock Monitor Enabled bit (Fail-Safe Clock Monitor is disabled)
#pragma config LVP = ON         // Low Voltage Programming Enable bit (RB3/PGM pin has PGM function, low voltage programming enabled)

// CONFIG2
#pragma config BOR4V = BOR40V   // Brown-out Reset Selection bit (Brown-out Reset set to 4.0V)
#pragma config WRT = OFF        // Flash Program Memory Self Write Enable bits (Write protection off)
#define _XTAL_FREQ 500000
#define __delay_us(x) _delay((unsigned long)((x)*(_XTAL_FREQ/4000000.0)))


#include <xc.h>

void __interrupt()isr(void){
    if (INTCONbits.T0IF){
        PORTAbits.RA0 = ~(PORTAbits.RA0);
        PORTAbits.RA1 = ~(PORTAbits.RA1);
        TMR0 = 12;
        INTCONbits.T0IF = 0;
    }
}
void main(void) {
    ANSEL = 0x00;
    ANSELH = 0x00;
    TRISA = 0x00;
    PORTA = 0x01;
    OPTION_REGbits.T0CS = 0;
    OPTION_REGbits.T0SE = 1;
    OPTION_REGbits.PSA = 0;
    OPTION_REGbits.PS = 0B111;
    
    OSCCONbits.IRCF = 0B011;
    OSCCONbits.SCS = 1;
    
    INTCONbits.GIE = 1;
    INTCONbits.T0IE =1;
    INTCONbits.T0IF = 0;
    TMR0 = 12;
    
    while(1){
        
    }
}
