
;================================================
; Настройка и конфигурация микроконтроллера
;================================================
	#include <p16F877a.inc>  
	__CONFIG _HS_OSC & _WDT_OFF & _PWRTE_ON & _BODEN_ON & _LVP_OFF & _CPD_OFF& _CP_OFF
;================================================
; Инициализация регистров специального назначения
;================================================

INTCON			equ 0x0B
STATUS			equ 0x03
PORTD			equ 0x08
TRISD			equ 0x88
PORTB			equ 0x06
TRISB			equ 0x86

;================================================
; Инициализация констант
;================================================

RP0			equ 0x05
C           equ 0x00
Z           equ 0x02

;================================================
; Инициализация переменных в памяти данных
;================================================
LIGHTS_FULL   equ 0x20
;LIGHTS_FULL_WAIT equ 0x21
;BOOLWAIT equ 0x22
count0 equ 25h	; задаём символьные обозначение ячеек памяти, расположенных по адресам 25h, 26h, 27h 
count1 equ 26h
count2 equ 27h
;================================================
; Начало программы
;================================================
	ORG 0x00
	goto Start

Start:
	clrf INTCON			;запрещаем все прерывания
;===============================================
; Настраиваем линии порта PORTD на выход
;===============================================

	bsf STATUS,RP0			;переходим в банк 1
	CLRF TRISD
	BSF TRISB,.6 ;кнопка				
	BCF STATUS,RP0		;переходим в банк 0	
		
;===============================================
; Закончили настройку
;===============================================
LOOP:
	BSF STATUS,C
	CLRF PORTD
	CLRF PORTB
	CLRF LIGHTS_FULL	

RUNNING_LIGHTS:

	RLF PORTD,1
	GOTO XOR0
XOR0_FALSE:
	BTFSS PORTB,.6 ;нажатие кнопки
	GOTO BUTTON_CLICK
	GOTO delay

BUTTON_CLICK:

	BTFSS PORTD,.0 ;проверка горит ли первый светодиод
	GOTO RUNNING_LIGHTS
	BTFSC STATUS,C
	GOTO RUNNING_LIGHTS
	GOTO XOR255

MODIFICATION_LIGHTS:

	BTFSC LIGHTS_FULL,.0
	GOTO LDEC
	BSF STATUS,C
	GOTO delay
	
LDEC:

	BCF PORTD,C
	GOTO delay
	

 XOR255:

    MOVF PORTD,W   ; копировать из PORTD в W
    BCF  STATUS,Z ; опустим флаг Z в ноль
    XORLW .255     ; проводим сравнение с числом 255(все светодиоды горят)
    BTFSC  STATUS,Z ; делаем бит-проверку Z-флага
	GOTO WAITBUTTON
	GOTO MODIFICATION_LIGHTS

; если Z=1, то выполняется следующая инструкция, иначе – пропускается

 XOR0:

    MOVF  PORTD,W   ; копировать из PORTD в W
    BCF   STATUS,Z ; опустим флаг Z в ноль
    XORLW .0     ; проводим сравнение с числом 0(все светодиоды погасли)
    BTFSC STATUS,Z ; делаем бит-проверку Z-флага
	GOTO LOOP
	GOTO XOR0_FALSE

DEC_LIGHTS:

	BSF LIGHTS_FULL,.0
	GOTO MODIFICATION_LIGHTS

delay:				;подпрограмма задержки
	MOVLW 0xd
	MOVWF count0
	MOVLW 0xff
loop0:
		MOVWF count1
	loop1:
			MOVWF count2
		loop2:
			DECFSZ count2,F
			GOTO loop2 ; переход на метку loop2

		DECFSZ count1,F
		GOTO loop1
	DECFSZ count0,F
	GOTO loop0
GOTO RUNNING_LIGHTS

delay2:				;подпрограмма задержки
	MOVLW 0xd
	MOVWF count0
	MOVLW 0xff
lop0:
		MOVWF count1
	lop1:
			MOVWF count2
		lop2:
			DECFSZ count2,F
			GOTO lop2 ; переход на метку loop2

		DECFSZ count1,F
		GOTO lop1
	DECFSZ count0,F
	GOTO lop0
GOTO del

WAITBUTTON:
	GOTO delay2
del:
	;BSF LIGHTS_FULL_WAIT,.0
	BTFSS PORTB,.6 ;нажатие кнопки
	GOTO DEC_LIGHTS
	GOTO WAITBUTTON
End