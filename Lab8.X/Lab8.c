/*
 * File:   Lab8.c
 * Author: Julio Avila
 *
 * Created on 19 de abril de 2021, 02:28 PM
 * Last edited: 19 de abril, 2021
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
#define _XTAL_FREQ 1000000
#define __delay_us(x) _delay((unsigned long)((x)*(_XTAL_FREQ/4000000.0)))

#include <xc.h>

char cont = 0;
char val1 = 0;
char dec =0;
char cen = 0;
char uni= 0;
int disp;
char display[10] = {0B00111111, 0B00000110, 0B01011011, 0B01001111, 
0B01100110, 0B01101101, 0B01111101, 0B00000111, 0B01111111, 0B01100111};
//Valores para el display

void __interrupt()isr(void){
    if (ADIF){                      //Verifica si hay interrupción del módulo
        if (ADCON0bits.CHS == 0){   //y verifica cual es el canal a convertir,
            PORTB = ADRESH;         //el canal 0 lo muestra en el puerto B y el
        }                           //canal 1 lo almacena en cont que despues
        else{                       //se descompone en la división
            cont = ADRESH;
        }
        PIR1bits.ADIF = 0;
    }    
    
    if (T0IF) {                     //Verifica si hay overflow del tmr0
        switch (disp){              //y dependiendo del display que
            case 0:                 //toque desplegar, llama al respectivo
                PORTD = 0x00;       //valor desde el arreglo display
                PORTC = 0x00;       //limpia los puertos C y D y designa
                PORTD = 0x04;       //cual será el siguiente display
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
                //PORTCbits.RC7 = 1;
                disp =0;
                break;
        }
        INTCONbits.T0IF = 0;    //Se limpia el IF y se reinicia
        TMR0 = 178;
        
    }
}
void main(void) {
    ANSEL = 0x03;               //Los primeros dos pines analógicos
    ANSELH = 0x00;
    
    TRISA = 0x03;
    TRISB = 0x00;
    TRISC = 0x00;
    TRISD = 0x00;
    
    OSCCON = 0B1000111;         //Oscilador a 1MHz
    OPTION_REG = 0B01000011;    //Prescaler a 16
    TMR0 = 178;
    
    PORTB = 0x00;               //Se inicia todo en 0
    PORTC = 0x00;
    PORTD = 0x00;
    
    ADCON0bits.ADCS0 = 0;       //Conversión clock a FOSC/2
    ADCON0bits.ADCS1 = 0;
    ADCON0bits.GO_DONE = 0;
    ADCON0bits.CHS = 0;         //Se inicia con el canal 0
    ADCON0bits.ADON = 1;        //Se enciende el módulo
    
    ADCON1bits.ADFM = 0;        //Justificado a la izquierda para ADRESH
    ADCON1bits.VCFG0 = 0;       //VSS y VDD como pines de referencia
    ADCON1bits.VCFG1 = 0;
    
    INTCONbits.GIE = 1;         //Se activan las interrupciones globales y
    INTCONbits.T0IE = 1;        //periféricas para activar TMR0 y ADC
    INTCONbits.PEIE = 1;
    PIE1bits.ADIE = 1;
    ADCON0bits.GO = 1;          //Comienza la conversión
    
    while (1){
        cen = cont/100;         //División para los valores del display
        val1 = cont%100;
        dec = val1/10;
        uni = val1%10;
        
        if (ADCON0bits.GO == 0){        //Si no hay conversión en curso se
            if (ADCON0bits.CHS == 0){   //determina cual es el siguiente canal
                ADCON0bits.CHS = 1;     //a convertir y se realiza un delay
            }                           //para esperar a que el capacitor
            else{                       //se regule, luego se activa la bandera
                ADCON0bits.CHS = 0;     //indicando que ya se realizó la
            }                           //conversión
            __delay_us(50);
            ADCON0bits.GO = 1;
                
        }
    }
    
}
