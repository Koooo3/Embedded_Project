unsigned char receivedbyte=0X00;
#define Fosc 8000000 // Oscillator Freq 8Mghz
#define TMR2PRESCALE 16

#define forward 0XFF
#define backward 0XFE
#define right 0XFD
#define left 0XFC
#define stop 0xFB

//unsigned int PWM_freq = 500;  // PWM_Period = 2ms

void interrupt()
{
     if(PIR1&20)  // Receive flag raised
     {
            receivedbyte=RCREG;  // Read received data (byte)
            PIR1=PIR1&0XDF; // Clear receive flag
      }
}
void PWM_Init()
{
     /*Fosc = 8Mghz, Finp = 2Mghz, Tinp = 0.5us, Tinc = 0.5us
     With 1:16 Prescale, Tinc = 8us (TMR2 increments every 8us)*/

     CCP1CON = 0X0C; //Configure the CCP1 module for PWM operation
     T2CON = 0x06; //TMR2 on with 1:16 Prescale
     PR2 = 250; // 8us * 250 = 2ms = PWM_Period
     //PR2 = (Fosc / (PWM_freq*4*TMR2PRESCALE)) - 1;
     TRISC = TRISC & 0xFB; // CCP1/RC2 Pin Output
}

void PWM_Duty(unsigned char duty)
{
     if(duty<=250) // Make sure the duty cycle is within the PWM_Period
     {
            //We will be using only 8 bits for the duty cycle
            //duty resolution = 8-bits
            CCPR1L = duty;// Store the 8 bits in the CCPR1L Reg
     }
}

void UART_Init()
{
    TRISC = TRISC | 0x80;  // Rx/Rc7 Input
    TRISC = TRISC & 0xBF;  // Tx/RC6 Output
    TXSTA=0x20;            // Enable 8-bit Transmitter in Asynchronous Mode
    RCSTA=0x90;            // Enable Serial Port and 8-bit continuous receive
    SPBRG = 12;            // Low Speed 9600 Baud Rate with Fosc = 8Mghz
    PIE1=PIE1|0X20;        // Enable Receive Interrupt
    INTCON=INTCON|0xC0;    // Enable GIE and PIE
}
/* We will not be transimtting anything using the PIC. That said,
We will not write a function for transmitting using UART. However,
we will be receiving data from the Arduino. We will receive the data
using an interrupt and not using a dedicated receive function.*/

void main()
{
  TRISB=0X00; // PORTB is going to connect to the input pins from the H-Bridge to control the direction of the motors
  /*Not important*/ PORTC=0X00; // EXTRA: turning off output pins of portc just in case
  PORTB=0X00;
  UART_Init(); //Initialize Serial Communication between PIC and Arduino
  PWM_Init();  //Initialize PWM Module to be used for Motors.
  while(1)
  {
      /*If receivedbyte was stop. stop the motor and clear the duty cycle.*/
      if(receivedbyte == stop)
      {
              PORTB=0x00;  // Motors Stop.
              PWM_Duty(0); // Duty cycle = 0
      }

      /*Determining the direction, then the speed*/
      if(receivedbyte == right)
      {
              PORTB= 0X06; // Motors in Differet Directions. Turn right.
      }
      if(receivedbyte == left)
      {
              PORTB=0X09; // Motors in Differet Directions. Turn left.
      }
      if(receivedbyte == forward)
      {
              PORTB=0X05;  // Motors Both Forward.
      }
      if(receivedbyte == backward)
      {
              PORTB= 0X0A; // Motors Both Backward.
      }

      PWM_Duty(receivedbyte); /* After determining the direction,
      the next received bytes will control the speed.*/

      /*If receivedbyte was a direction byte, it will be of a value
      greater than 250. That said, the PWM_Duty function will not
      accept it and will not change the CCPR1L Reg. Meaning that
      direction bytes do not affect the duty cycle. Check the if
      statement in the PWM_Duty function.*/

  }
}