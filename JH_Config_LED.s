												; This register controls the clock gating logic in normal Run mode
SYSCTL_PERIPH_GPIO EQU		0x400FE108			; SYSCTL_RCGC2_R (p291 datasheet de lm3s9b92.pdf)

												; The GPIODATA register is the data register
GPIO_PORTF_BASE		EQU		0x40025000			; GPIO Port F (APB) base: 0x4002.5000 (p416 datasheet de lm3s9B92.pdf)

												; configure the corresponding pin to be an output
												; all GPIO pins are inputs by default
GPIO_O_DIR   		EQU 	0x00000400 		 	; GPIO Direction (p417 datasheet de lm3s9B92.pdf)

												; The GPIODR2R register is the 2-mA drive control register
												; By default, all GPIO pins have 2-mA drive.
GPIO_O_DR2R   		EQU 	0x00000500  		; GPIO 2-mA Drive Select (p428 datasheet de lm3s9B92.pdf)

												; Digital enable register
												; To use the pin as a digital input or output, the corresponding GPIODEN bit must be set.
GPIO_O_DEN  		EQU 	0x0000051C  		; GPIO Digital Enable (p437 datasheet de lm3s9B92.pdf)

BROCHE4				EQU		0x10 				; LED1
BROCHE5				EQU		0x20 				; LED2

		AREA    |.text|, CODE, READONLY
	  	ENTRY
		
												; Export des fonctions
		EXPORT LED_INIT
		EXPORT ALLUME_DROITE
		EXPORT ALLUME_GAUCHE
		EXPORT ETEINT_DROITE
		EXPORT ETEINT_GAUCHE

												; Config des LED
LED_INIT
										
		ldr r8, = SYSCTL_PERIPH_GPIO			; Enable the Port F peripheral clock  (p291 datasheet de lm3s9B96.pdf)	
        mov r0, #0x00000038  					; Enable clock sur GPIO F
        str r0, [r8]
		
		nop
		nop	   
		nop	   									

        ldr r8, = GPIO_PORTF_BASE+GPIO_O_DIR    ; 2 Pins du portF en sortie
        ldr r0, = BROCHE4 + BROCHE5 	
        str r0, [r8]
		
		ldr r8, = GPIO_PORTF_BASE+GPIO_O_DEN	; Enable Digital Function 
        ldr r0, = BROCHE4 + BROCHE5		
        str r0, [r8]
		
		ldr r8, = GPIO_PORTF_BASE+GPIO_O_DR2R	; Choix de l'intensité de sortie (2mA)
        ldr r0, = BROCHE4 + BROCHE5			
        str r0, [r8]
		
		mov r2, #0x000       					; pour eteindre LED
     
		mov r3, #BROCHE4 + BROCHE5				; Allume LED1&2 portF broche 4&5
				
		BX	LR
		
		
ALLUME_DROITE
		ldr r8, = GPIO_PORTF_BASE + (BROCHE4<<2)
		str r3, [r8]  							; Allume LED1 portF broche 4 (contenu de r3)  
		BX	LR	
		
		
ETEINT_DROITE
		ldr r8, = GPIO_PORTF_BASE + (BROCHE4<<2)
		str r2, [r8]
		BX LR
		
		
ALLUME_GAUCHE
		ldr r8, = GPIO_PORTF_BASE + (BROCHE5<<2)
		str r3, [r8]  							; Allume LED2 portF broche 5 (contenu de r3)
		BX	LR	
		
			
ETEINT_GAUCHE
		ldr r8, = GPIO_PORTF_BASE + (BROCHE5<<2)
		str r2, [r8]
		BX LR
		
		END 