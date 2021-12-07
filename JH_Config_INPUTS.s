												; This register controls the clock gating logic in normal Run mode
												; SYSCTL_PERIPH_GPIO EQU		0x400FE108			
												; SYSCTL_RCGC2_R (p291 datasheet de lm3s9b92.pdf)

												; The GPIODATA register is the data register
GPIO_PORTD_BASE		EQU		0x40007000			; GPIO Port D (APB) base: 0x4000.7000 (p416 datasheet de lm3s9B92.pdf)
	
												; The GPIODATA register is the data register
GPIO_PORTE_BASE		EQU		0x40024000			; GPIO Port E (APB) base: 0x4002.5000 (p416 datasheet de lm3s9B92.pdf)

												; Digital enable register
												; To use the pin as a digital input or output, the corresponding GPIODEN bit must be set.
GPIO_O_DEN  		EQU 	0x0000051C  		; GPIO Digital Enable (p437 datasheet de lm3s9B92.pdf)
	
												
GPIO_I_PUR   		EQU 	0x00000510			
	
BROCHE6				EQU 	0x40				; SWITCH1
BROCHE7				EQU 	0x80				; SWITCH2
	
BROCHE0				EQU 	0x01				; BUMPER1
BROCHE1				EQU 	0x02				; BUMPER2
	
		AREA    |.text|, CODE, READONLY
	  	ENTRY
		
		EXPORT SWITCH_INIT
		EXPORT BUMPER_INIT

SWITCH_INIT

		nop	   									
		nop	   
		nop	   									
			
		ldr r7, = GPIO_PORTD_BASE+GPIO_I_PUR
        ldr r0, = BROCHE6 + BROCHE7
        str r0, [r7]
		
		ldr r7, = GPIO_PORTD_BASE+GPIO_O_DEN
        ldr r0, = BROCHE6 + BROCHE7	
        str r0, [r7]     
		
		ldr r7, = GPIO_PORTD_BASE + (BROCHE6<<2) ; @data Register = @base + (mask<<2) ==> SWITCH1
		ldr r10, = GPIO_PORTD_BASE + (BROCHE7<<2); @data Register = @base + (mask<<2) ==> SWITCH2
		
		BX	LR


BUMPER_INIT

		nop	   									
		nop	   
		nop	   									

		ldr r5, = GPIO_PORTE_BASE+GPIO_I_PUR	
        ldr r0, = BROCHE0 + BROCHE1
        str r0, [r5]
		
		ldr r5, = GPIO_PORTE_BASE+GPIO_O_DEN	
        ldr r0, = BROCHE0 + BROCHE1	
        str r0, [r5]     
		
		ldr r5, = GPIO_PORTE_BASE + (BROCHE0<<2); @data Register = @base + (mask<<2) ==> BUMPER1
		ldr r4, = GPIO_PORTE_BASE + (BROCHE1<<2); @data Register = @base + (mask<<2) ==> BUMPER2
		
		BX	LR
		
		
		END