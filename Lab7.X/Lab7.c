/*
 * File:   Lab7.c
 * Author: Julio Avila
 *
 * Created on 13 de abril de 2021, 09:38 AM
 * Last edited on 13 de abril
 */
// CONFIG1
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


#include <xc.h>

char cont = 0;
char val1 = 0;
char dec =0;
char cen = 0;
char uni= 0;
int disp;
char display[10] = {0B00111111, 0B00000110, 0B01011011, 0B01001111, 
0B01100110, 0B01101101, 0B01111101, 0B01000111, 0B01111111, 0B01100111};

void __interrupt()isr(void){
    if (RBIF){
        if (RB0==0){
            PORTA++;
            INTCONbits.RBIF = 0;
    }
        else if (RB1==0) {
            PORTA--;
            INTCONbits.RBIF = 0;
    }
}
    if (T0IF) {
        switch (disp){
            case 0: 
                PORTD = 0x00;
                PORTC = 0x00;
                PORTD = 0x04;
                PORTC = display[uni];
                disp = 1;
                break;
            case 1: 
                PORTD = 0x00;
                PORTC = 0x00;
                PORTD = 0x02;
                PORTC = display[dec];
                disp = 2;
                break;
            case 2: 
                PORTD = 0x00;
                PORTC = 0x00;
                PORTD = 0x01;
                PORTC = display[cen];
                disp =0;
                break;
        }
        PORTBbits.RB2=~PORTBbits.RB2;
        INTCONbits.T0IF = 0;
        TMR0 = 217;
        
    }
}

void main(void) {
    ANSEL = 0x00;
    ANSELH = 0x00;
    
    TRISA = 0x00;
    TRISB = 0x03;
    TRISC = 0x00;
    TRISD = 0x00;
    
    OSCCON = 0B0110111;      // Oscilador a 500KHz
    OPTION_REG = 0B01000011; // TMR0 con 16 de prescaler
    TMR0 = 217;
    IOCB = 0x03;
    
    PORTA = 0x00;
    PORTC = 0x00;
    PORTD = 0X00;
    
    INTCONbits.GIE = 1;
    INTCONbits.T0IE = 1;
    INTCONbits.RBIE = 1;
        
    while (1){
        cont = PORTA;
        cen = PORTA/100;
        val1 = cont%100;
        dec = val1/10;
        uni = val1%10;
    }
    
}

