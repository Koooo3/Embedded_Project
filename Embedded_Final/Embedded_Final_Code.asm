
_interrupt:
	MOVWF      R15+0
	SWAPF      STATUS+0, 0
	CLRF       STATUS+0
	MOVWF      ___saveSTATUS+0
	MOVF       PCLATH+0, 0
	MOVWF      ___savePCLATH+0
	CLRF       PCLATH+0

;Embedded_Final_Code.c,13 :: 		void interrupt()
;Embedded_Final_Code.c,15 :: 		if(PIR1&20)  // Receive flag raised
	MOVLW      20
	ANDWF      PIR1+0, 0
	MOVWF      R0+0
	BTFSC      STATUS+0, 2
	GOTO       L_interrupt0
;Embedded_Final_Code.c,17 :: 		receivedbyte=RCREG;  // Read received data (byte)
	MOVF       RCREG+0, 0
	MOVWF      _receivedbyte+0
;Embedded_Final_Code.c,18 :: 		PIR1=PIR1&0XDF; // Clear receive flag
	MOVLW      223
	ANDWF      PIR1+0, 1
;Embedded_Final_Code.c,19 :: 		}
L_interrupt0:
;Embedded_Final_Code.c,20 :: 		}
L_end_interrupt:
L__interrupt10:
	MOVF       ___savePCLATH+0, 0
	MOVWF      PCLATH+0
	SWAPF      ___saveSTATUS+0, 0
	MOVWF      STATUS+0
	SWAPF      R15+0, 1
	SWAPF      R15+0, 0
	RETFIE
; end of _interrupt

_PWM_Init:

;Embedded_Final_Code.c,21 :: 		void PWM_Init()
;Embedded_Final_Code.c,26 :: 		CCP1CON = 0X0C; //Configure the CCP1 module for PWM operation
	MOVLW      12
	MOVWF      CCP1CON+0
;Embedded_Final_Code.c,27 :: 		T2CON = 0x06; //TMR2 on with 1:16 Prescale
	MOVLW      6
	MOVWF      T2CON+0
;Embedded_Final_Code.c,28 :: 		PR2 = 250; // 8us * 250 = 2ms = PWM_Period
	MOVLW      250
	MOVWF      PR2+0
;Embedded_Final_Code.c,30 :: 		TRISC = TRISC & 0xFB; // CCP1/RC2 Pin Output
	MOVLW      251
	ANDWF      TRISC+0, 1
;Embedded_Final_Code.c,31 :: 		}
L_end_PWM_Init:
	RETURN
; end of _PWM_Init

_PWM_Duty:

;Embedded_Final_Code.c,33 :: 		void PWM_Duty(unsigned char duty)
;Embedded_Final_Code.c,35 :: 		if(duty<=250) // Make sure the duty cycle is within the PWM_Period
	MOVF       FARG_PWM_Duty_duty+0, 0
	SUBLW      250
	BTFSS      STATUS+0, 0
	GOTO       L_PWM_Duty1
;Embedded_Final_Code.c,39 :: 		CCPR1L = duty;// Store the 8 bits in the CCPR1L Reg
	MOVF       FARG_PWM_Duty_duty+0, 0
	MOVWF      CCPR1L+0
;Embedded_Final_Code.c,40 :: 		}
L_PWM_Duty1:
;Embedded_Final_Code.c,41 :: 		}
L_end_PWM_Duty:
	RETURN
; end of _PWM_Duty

_UART_Init:

;Embedded_Final_Code.c,43 :: 		void UART_Init()
;Embedded_Final_Code.c,45 :: 		TRISC = TRISC | 0x80;  // Rx/Rc7 Input
	BSF        TRISC+0, 7
;Embedded_Final_Code.c,46 :: 		TRISC = TRISC & 0xBF;  // Tx/RC6 Output
	MOVLW      191
	ANDWF      TRISC+0, 1
;Embedded_Final_Code.c,47 :: 		TXSTA=0x20;            // Enable 8-bit Transmitter in Asynchronous Mode
	MOVLW      32
	MOVWF      TXSTA+0
;Embedded_Final_Code.c,48 :: 		RCSTA=0x90;            // Enable Serial Port and 8-bit continuous receive
	MOVLW      144
	MOVWF      RCSTA+0
;Embedded_Final_Code.c,49 :: 		SPBRG = 12;            // Low Speed 9600 Baud Rate with Fosc = 8Mghz
	MOVLW      12
	MOVWF      SPBRG+0
;Embedded_Final_Code.c,50 :: 		PIE1=PIE1|0X20;        // Enable Receive Interrupt
	BSF        PIE1+0, 5
;Embedded_Final_Code.c,51 :: 		INTCON=INTCON|0xC0;    // Enable GIE and PIE
	MOVLW      192
	IORWF      INTCON+0, 1
;Embedded_Final_Code.c,52 :: 		}
L_end_UART_Init:
	RETURN
; end of _UART_Init

_main:

;Embedded_Final_Code.c,58 :: 		void main()
;Embedded_Final_Code.c,60 :: 		TRISB=0X00; // PORTB is going to connect to the input pins from the H-Bridge to control the direction of the motors
	CLRF       TRISB+0
;Embedded_Final_Code.c,61 :: 		/*Not important*/ PORTC=0X00; // EXTRA: turning off output pins of portc just in case
	CLRF       PORTC+0
;Embedded_Final_Code.c,62 :: 		PORTB=0X00;
	CLRF       PORTB+0
;Embedded_Final_Code.c,63 :: 		UART_Init(); //Initialize Serial Communication between PIC and Arduino
	CALL       _UART_Init+0
;Embedded_Final_Code.c,64 :: 		PWM_Init();  //Initialize PWM Module to be used for Motors.
	CALL       _PWM_Init+0
;Embedded_Final_Code.c,65 :: 		while(1)
L_main2:
;Embedded_Final_Code.c,68 :: 		if(receivedbyte == stop)
	MOVF       _receivedbyte+0, 0
	XORLW      251
	BTFSS      STATUS+0, 2
	GOTO       L_main4
;Embedded_Final_Code.c,70 :: 		PORTB=0x00;  // Motors Stop.
	CLRF       PORTB+0
;Embedded_Final_Code.c,71 :: 		PWM_Duty(0); // Duty cycle = 0
	CLRF       FARG_PWM_Duty_duty+0
	CALL       _PWM_Duty+0
;Embedded_Final_Code.c,72 :: 		}
L_main4:
;Embedded_Final_Code.c,75 :: 		if(receivedbyte == right)
	MOVF       _receivedbyte+0, 0
	XORLW      253
	BTFSS      STATUS+0, 2
	GOTO       L_main5
;Embedded_Final_Code.c,77 :: 		PORTB= 0X06; // Motors in Differet Directions. Turn right.
	MOVLW      6
	MOVWF      PORTB+0
;Embedded_Final_Code.c,78 :: 		}
L_main5:
;Embedded_Final_Code.c,79 :: 		if(receivedbyte == left)
	MOVF       _receivedbyte+0, 0
	XORLW      252
	BTFSS      STATUS+0, 2
	GOTO       L_main6
;Embedded_Final_Code.c,81 :: 		PORTB=0X09; // Motors in Differet Directions. Turn left.
	MOVLW      9
	MOVWF      PORTB+0
;Embedded_Final_Code.c,82 :: 		}
L_main6:
;Embedded_Final_Code.c,83 :: 		if(receivedbyte == forward)
	MOVF       _receivedbyte+0, 0
	XORLW      255
	BTFSS      STATUS+0, 2
	GOTO       L_main7
;Embedded_Final_Code.c,85 :: 		PORTB=0X05;  // Motors Both Forward.
	MOVLW      5
	MOVWF      PORTB+0
;Embedded_Final_Code.c,86 :: 		}
L_main7:
;Embedded_Final_Code.c,87 :: 		if(receivedbyte == backward)
	MOVF       _receivedbyte+0, 0
	XORLW      254
	BTFSS      STATUS+0, 2
	GOTO       L_main8
;Embedded_Final_Code.c,89 :: 		PORTB= 0X0A; // Motors Both Backward.
	MOVLW      10
	MOVWF      PORTB+0
;Embedded_Final_Code.c,90 :: 		}
L_main8:
;Embedded_Final_Code.c,93 :: 		the next received bytes will control the speed.*/
	MOVF       _receivedbyte+0, 0
	MOVWF      FARG_PWM_Duty_duty+0
	CALL       _PWM_Duty+0
;Embedded_Final_Code.c,101 :: 		}
	GOTO       L_main2
;Embedded_Final_Code.c,102 :: 		}
L_end_main:
	GOTO       $+0
; end of _main
