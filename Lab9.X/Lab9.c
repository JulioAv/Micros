/*
 * File:   Lab9.c
 * Author: Julio Avila
 *
 * Created on 26 de abril de 2021, 09:34 AM
 * Last edited on 26 de abril
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
#define _XTAL_FREQ 8000000
#define __delay_us(x) _delay((unsigned long)((x)*(_XTAL_FREQ/4000000.0)))


#include <xc.h>

void __interrupt()isr(void){
    if (ADIF){                      //Verifica si hay interrupción del módulo
        if (ADCON0bits.CHS == 0){   //y verifica cual es el canal a convertir,
            CCPR1L = (ADRESH>>1)+125;//el canal 0 lo muestrea en el primer       
        }                           //PWM con una transformación para que 
        else{                       //tome los bits más significativos, el 
            CCPR2L = (ADRESH>>1)+125;//mismo caso para el segundo PWM pero en
        }                           //el canal 1
        PIR1bits.ADIF = 0;
    }    
    return;
}

void main(void) {
    ANSEL = 0x03;               //Los primeros dos pines analógicos
    ANSELH = 0x00;
    
    OSCCON = 0B1110111;         //Oscilador a 8MHz    
    
    ADCON0bits.ADCS0 = 0;       //Conversión clock a FOSC/2
    ADCON0bits.ADCS1 = 1;
    ADCON0bits.GO_DONE = 0;
    ADCON0bits.CHS = 0;         //Se inicia con el canal 0
    ADCON0bits.ADON = 1;        //Se enciende el módulo
    
    ADCON1bits.ADFM = 0;        //Justificado a la izquierda para ADRESH
    ADCON1bits.VCFG0 = 0;       //VSS y VDD como pines de referencia
    ADCON1bits.VCFG1 = 0;
    
    INTCONbits.GIE = 1;         //Se activan las interrupciones globales y      
    INTCONbits.PEIE = 1;        //periféricas para activar ADC
    //PIE1bits.TMR2IE = 1;
    PIE1bits.ADIE = 1;
    //**********Configuración del PWM*************
    TRISA = 0x03;
    TRISCbits.TRISC2 = 1;       //Los puertos del PWM como entradas
    TRISCbits.TRISC1 = 1;       
    PR2 = 255;                  //Valor para obtener el periodo
    CCP1CONbits.P1M = 0B00;     //Módulo configurado en modo PWM
    CCP1CONbits.CCP1M = 0B1100;
    CCPR1L = 0x0F;              //Valor inicial para el módulo
    CCP1CONbits.DC1B = 0;
    
    T2CONbits.TOUTPS = 0;       //TMR2 configurado sin postescaler y con
    T2CONbits.T2CKPS = 0B11;    //prescaler a 16
    
    CCP2CONbits.CCP2M = 0B1100; //Segundo PWM configurado
    T2CONbits.TMR2ON = 1;       //Se inicia el TMR2
    PIR1bits.TMR2IF = 0;
    
    while(PIR1bits.TMR2IF == 0);//Se espera un ciclo del TMR
    PIR1bits.TMR2IF = 0;
    TRISCbits.TRISC2 = 0;       //Se ponen como salidas los pines
    TRISCbits.TRISC1 = 0;       
    
   //*********************************************** 
    ADCON0bits.GO = 1;          //Comienza la conversión
  
    
    while (1){
        
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
