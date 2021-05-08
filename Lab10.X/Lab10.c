/*
 * File:   Lab10.c
 * Author: swimm
 *
 * Created on 3 de mayo de 2021, 10:27 AM
 * Las edited on 5 de mayo
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

//int escribir=0;
//int n = 0;
char word[] = "lol";
//char palabra[]="Buenas jovenes";
int op;
void UART_write(unsigned char* word){   //Función que transmite datos
    while (*word != 0){                 //Verifica que el puntero aumente
        TXREG = (*word);                //Envía el caracter que toca de la cadena
        while(!TXSTAbits.TRMT);         //Espera a que se haya enviado el dato
        word++;                         //Aumenta el apuntador para ir al
    }                                   //siguente caracter
    return;
}

void main(void) {
    
    ANSELH = 0;             //Solo puertos digitales
    ANSEL = 0;
    
    TRISA = 0x00;           //Puertos A y B como salidas
    TRISB = 0x00;
    PORTA = 0;
    PORTB = 0;
    OSCCON = 0B1110111;     //Oscilador interno a 4MHz
    
    INTCONbits.INTE = 1;    //Interrupciones encendidas
    INTCONbits.PEIE = 1;
    
    
    
    
    SPBRG = 12;             //Configuración de la frecuencia de transmisión
    TXSTAbits.BRGH = 0;     //y lectura de datos
    BAUDCTLbits.BRG16 = 0;
    
    PIE1bits.RCIE = 0;      //Se activa la interrupción
    TXSTAbits.SYNC = 0;               //Configuración de pines
    TXSTAbits.TXEN = 1;
    TXSTAbits.TX9 = 0;      //Transmisión de 8 bits
    
    RCSTAbits.SPEN = 1;
    RCSTAbits.RX9 = 0;      //Recepción de 8bits
    RCSTAbits.CREN = 1;
    PIR1bits.TXIF = 0;
    PIR1bits.RCIF = 0;
    INTCONbits.GIE = 1;     //Comienzan las interrupciones
    
    while (1){
        UART_write("Que accion desea ejecutar? \r \0"); //Envía la cadena a la
        __delay_ms(50);                                 //función y espera
        UART_write("[1] Desplegar Cadena de Caracteres \r \0");//un momento
        __delay_ms(50);
        UART_write("[2] Cambiar PORTA \r \0");
        __delay_ms(50);
        UART_write("[3] Cambiar PORTB \r \0");
        __delay_ms(1000);
        
        while(!RCIF);           //Espera a que se registre una recepción
        __delay_ms(50);
        
        if (RCREG == '1'){
            UART_write("Buenas jovenes \r \0"); //Envía la cadena si se envió
        }                                       //un "1"
        else if (RCREG == '2'){
            UART_write("Ingrese el valor: \r \0");
            while(!RCIF);           //Si se envía un "2", espera a que se vuelva
            PORTA = RCREG;          //a enviar un valor y lo muestrea en PORTA
                }
            
        else if (RCREG == '3'){
            UART_write("Ingrese el valor: \r \0");
            while(!RCIF);           //Mismo caso con el PORTB
            PORTB = RCREG;
                }
            }
        }
     
    


