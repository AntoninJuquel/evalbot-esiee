; This register controls the clock gating logic in normal Run mode
SYSCTL_PERIPH_GPIO EQU		0x400FE108	; SYSCTL_RCGC2_R (p291 datasheet de lm3s9b92.pdf)

; The GPIODATA register is the data register
GPIO_PORTF_BASE		EQU		0x40025000	; GPIO Port F (APB) base: 0x4002.5000 (p416 datasheet de lm3s9B92.pdf)

; configure the corresponding pin to be an output
; all GPIO pins are inputs by default
GPIO_O_DIR   		EQU 	0x00000400  ; GPIO Direction (p417 datasheet de lm3s9B92.pdf)

; The GPIODR2R register is the 2-mA drive control register
; By default, all GPIO pins have 2-mA drive.
GPIO_O_DR2R   		EQU 	0x00000500  ; GPIO 2-mA Drive Select (p428 datasheet de lm3s9B92.pdf)

; Digital enable register
; To use the pin as a digital input or output, the corresponding GPIODEN bit must be set.
GPIO_O_DEN  		EQU 	0x0000051C  ; GPIO Digital Enable (p437 datasheet de lm3s9B92.pdf)

; Broches select
BROCHE4_5			EQU		0x30		; led1 & led2 sur broche 4 et 5

		AREA    |.text|, CODE, READONLY
	  	ENTRY
		
		; Export des fonctions contenues dans le fichier
		EXPORT LED_SWITCH_INIT
		EXPORT ALLUME_DROITE
		EXPORT ALLUME_GAUCHE
		EXPORT ETEINT_DROITE
		EXPORT ETEINT_GAUCHE

; Fonction d'initialisation (configuration des LED, Switchs et Bumpers)
LED_SWITCH_INIT

		; ;; Enable the Port E, F & D peripheral clock 		(p291 datasheet de lm3s9B96.pdf)
		; ;;									
		ldr r8, = SYSCTL_PERIPH_GPIO  			;; RCGC2
        mov r0, #0x00000038  					;; Enable clock sur GPIO D et F o? sont branch?s les leds (0x28 == 0b111000)
		; ;;														 									      (GPIO::FEDCBA)
        str r0, [r8]
		
		; ;; "There must be a delay of 3 system clocks before any GPIO reg. access  (p413 datasheet de lm3s9B92.pdf)
		nop	   									;; tres tres important....
		nop	   
		nop	   									;; pas necessaire en simu ou en debbug step by step...
	
		;^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^CONFIGURATION LED

        ldr r8, = GPIO_PORTF_BASE+GPIO_O_DIR    ;; 1 Pin du portF en sortie (broche 4 : 00010000)
        ldr r0, = BROCHE4_5 	
        str r0, [r8]
		
		ldr r8, = GPIO_PORTF_BASE+GPIO_O_DEN	;; Enable Digital Function 
        ldr r0, = BROCHE4_5		
        str r0, [r8]
		
		ldr r8, = GPIO_PORTF_BASE+GPIO_O_DR2R	;; Choix de l'intensit? de sortie (2mA)
        ldr r0, = BROCHE4_5			
        str r0, [r8]
		
		mov r2, #0x000       					;; pour eteindre LED
     
		; allumer la led broche 4 (BROCHE4_5)
		mov r3, #BROCHE4_5		;; Allume LED1&2 portF broche 4&5 : 00110000
		
		ldr r8, = GPIO_PORTF_BASE + (BROCHE4_5<<1)  ; @data Register = @base + (mask<<1) ==> LED 1
		ldr r9, = GPIO_PORTF_BASE + (BROCHE4_5<<3)  ; @data Register = @base + (mask<<1) ==> LED 2
		
		BX	LR
		
		
; Fonction pour allumer la LED Droite
ALLUME_DROITE

		str r3, [r8]  							; Allume LED1 portF broche 4 : 00010000 (contenu de r3)  
		BX	LR	
		
		
; Fonction pour ?teindre la LED Droite
ETEINT_DROITE
		str r2, [r8]
		BX LR
		
		
; Fonction pour allumer la LED Gauche
ALLUME_GAUCHE

		str r3, [r9]  							; Allume LED2 portF broche 5 : 00100000 (contenu de r3)
		BX	LR	
		
		
; Fonction pour ?teindre la LED Gauche		
ETEINT_GAUCHE
		str r2, [r9]
		BX LR
		
		END 