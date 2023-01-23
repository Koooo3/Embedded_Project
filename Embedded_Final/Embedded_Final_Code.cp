#line 1 "C:/Users/USER10/Desktop/Embedded_Final/Embedded_Final_Code.c"
unsigned char receivedbyte=0X00;
#line 13 "C:/Users/USER10/Desktop/Embedded_Final/Embedded_Final_Code.c"
void interrupt()
{
 if(PIR1&20)
 {
 receivedbyte=RCREG;
 PIR1=PIR1&0XDF;
 }
}
void PWM_Init()
{
#line 26 "C:/Users/USER10/Desktop/Embedded_Final/Embedded_Final_Code.c"
 CCP1CON = 0X0C;
 T2CON = 0x06;
 PR2 = 250;

 TRISC = TRISC & 0xFB;
}

void PWM_Duty(unsigned char duty)
{
 if(duty<=250)
 {


 CCPR1L = duty;
 }
}

void UART_Init()
{
 TRISC = TRISC | 0x80;
 TRISC = TRISC & 0xBF;
 TXSTA=0x20;
 RCSTA=0x90;
 SPBRG = 12;
 PIE1=PIE1|0X20;
 INTCON=INTCON|0xC0;
}
#line 58 "C:/Users/USER10/Desktop/Embedded_Final/Embedded_Final_Code.c"
void main()
{
 TRISB=0X00;
 PORTC=0X00;
 PORTB=0X00;
 UART_Init();
 PWM_Init();
 while(1)
 {

 if(receivedbyte ==  0xFB )
 {
 PORTB=0x00;
 PWM_Duty(0);
 }


 if(receivedbyte ==  0XFD )
 {
 PORTB= 0X06;
 }
 if(receivedbyte ==  0XFC )
 {
 PORTB=0X09;
 }
 if(receivedbyte ==  0XFF )
 {
 PORTB=0X05;
 }
 if(receivedbyte ==  0XFE )
 {
 PORTB= 0X0A;
 }
#line 93 "C:/Users/USER10/Desktop/Embedded_Final/Embedded_Final_Code.c"
 PWM_Duty(receivedbyte);
#line 101 "C:/Users/USER10/Desktop/Embedded_Final/Embedded_Final_Code.c"
 }
}
