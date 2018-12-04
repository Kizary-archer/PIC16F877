
;================================================
; Настройка и конфигурация микроконтроллера
;================================================
	LIST  p=16F877
	#include <p16F877.inc> 
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
LIGHTS_FULL           equ 0x20
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
	CLRF TRISB	
;	BSF TRISB,0x00 ;кнопка				
	BCF STATUS,RP0		;переходим в банк 0	
		
;===============================================
; Закончили настройку
;===============================================
LOOP:

	BSF STATUS,C
	CLRF PORTD
	CLRF LIGHTS_FULL	
	movlw B'11111111'
	movwf PORTB

RUNNING_LIGHTS:

	RLF PORTD,1
	GOTO XOR0
XOR_FALSE:
	BTFSC PORTB,.0 ;нажатие кнопки
	GOTO BUTTON_CLICK
GOTO RUNNING_LIGHTS

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
	GOTO RUNNING_LIGHTS
	
LDEC:

	BCF PORTD,C
	GOTO RUNNING_LIGHTS
	

 XOR255:

    MOVF      PORTD,W   ; копировать из PORTD в W
    BCF       STATUS,Z ; опустим флаг Z в ноль
    XORLW     .255     ; проводим сравнение с числом 255(все светодиоды горят)
    BTFSC     STATUS,Z ; делаем бит-проверку Z-флага
	GOTO DEC_LIGHTS
	GOTO MODIFICATION_LIGHTS

; если Z=1, то выполняется следующая инструкция, иначе – пропускается

 XOR0:

    MOVF      PORTD,W   ; копировать из PORTD в W
    BCF       STATUS,Z ; опустим флаг Z в ноль
    XORLW     .0     ; проводим сравнение с числом 0(все светодиоды погасли)
    BTFSC     STATUS,Z ; делаем бит-проверку Z-флага
	GOTO LOOP
	GOTO XOR_FALSE

DEC_LIGHTS:

BSF LIGHTS_FULL,.0
GOTO MODIFICATION_LIGHTS


End