; PERRIER Pierre, CE-OUGNA Sarah - ESIEE Paris
; 12/2018 - Evalbot (Cortex M3 de Texas Instrument)
; Projet - CacheBot (Jeu de cache-cache entre deux robots)



		AREA    |.text|, CODE, READONLY
		ENTRY
		EXPORT	__main
		
		; Import des fonctions du fichier RK_Led_Switch_Bumper.s
		IMPORT LED_SWITCH_INIT 				; Initialise les LED, Switchs et Bumpers
		IMPORT ALLUME_DROITE				; Allume la LED Droite
		IMPORT ALLUME_GAUCHE				; Allume la LED Gauche
		IMPORT ETEINT_DROITE				; Eteint la LED Droite
		IMPORT ETEINT_GAUCHE				; Eteint la LED Gauche
			
		; Import des fonctions du fichier RK_Moteur.s
		IMPORT	MOTEUR_INIT					; initialise les moteurs (configure les pwms + GPIO)
		
		IMPORT	MOTEUR_DROIT_ON				; activer le moteur droit
		IMPORT  MOTEUR_DROIT_OFF			; d?activer le moteur droit
		IMPORT  MOTEUR_DROIT_AVANT			; moteur droit tourne vers l'avant
		IMPORT  MOTEUR_DROIT_ARRIERE		; moteur droit tourne vers l'arri?re
		IMPORT  MOTEUR_DROIT_INVERSE		; inverse le sens de rotation du moteur droit
		
		IMPORT	MOTEUR_GAUCHE_ON			; activer le moteur gauche
		IMPORT  MOTEUR_GAUCHE_OFF			; d?activer le moteur gauche
		IMPORT  MOTEUR_GAUCHE_AVANT			; moteur gauche tourne vers l'avant
		IMPORT  MOTEUR_GAUCHE_ARRIERE		; moteur gauche tourne vers l'arri?re
		IMPORT  MOTEUR_GAUCHE_INVERSE		; inverse le sens de rotation du moteur gauche
			
		
		IMPORT	SWITCH_INIT
		IMPORT	BUMPER_INIT


__main	
		; Configure les LED, Switchs et Bumpers
		BL  LED_SWITCH_INIT
		
		BL 	SWITCH_INIT
		BL	BUMPER_INIT

		; Configure les PWM + GPIO
		BL	MOTEUR_INIT	   


; Lis l'?tat du bouton poussoir 1, si le bouton est pouss?, alors le programme va ? la branche "Cache",
; Sinon, le programme va ? la branche "ReadState2" qui lit le bouton poussoir 2
READ_BTN_1
		ldr r11,[r7]
		CMP r11,#0x00
		BNE READ_BTN_2
		BL GO
		
		
; Lis l'?tat du bouton poussoir 2, si le bouton est pouss?, alors le programme va ? la branche "Cherche",
; Sinon, le programme retourne ? la branche "ReadState" qui lit le bouton poussoir 1
READ_BTN_2
		ldr r11,[r10]
		CMP r11,#0x00
		BNE READ_BTN_1
		BL COUNT

COUNT
		BL 	WAIT2
		BL 	ALLUME_GAUCHE
		BL 	ALLUME_DROITE
		BL	WAIT2
		BL 	ETEINT_GAUCHE
		BL 	ETEINT_DROITE
		subs r12, #1
		CMP	r12, #0x00
        BNE COUNT
		BL	READ_BTN_1
		
GO	
		; Activer les deux moteurs droit et gauche
		BL	MOTEUR_DROIT_ON
		BL	MOTEUR_GAUCHE_ON
		
		ldr r12, =0x00

; Ici d?bute la boucle qui fera suivre un pattern ? notre robot
loop	
		; Eteindre la LED Gauche puis allumer la LED droite
		BL ETEINT_GAUCHE
		BL ETEINT_DROITE
		
		; Evalbot avance droit devant
		BL	MOTEUR_DROIT_AVANT	   
		BL	MOTEUR_GAUCHE_AVANT
		
		; Avancement pendant deux p?riodes (quatre WAIT),
		; A chaque ?tape de l'avancement, 
		; On v?rifie s'il y a collision en lisant l'?tat des Bumpers gr?ce ? la branche ReadCollision
		BL 	ReadCollision
	
		; Le robot vient d'effectuer un aller-retour avec un d?calage vers la gauche,
		; Il ne lui reste plus qu'? effectuer ce m?me pattern de d?placement
		; Jusqu'? ce qu'il entre en contact avec le robot qui se cache
		BL 	loop 	; Retour au d?but de la branche loop
		
		
; Branche v?rifiant l'?tat des Bumpers : si un des deux est appuy?, 
; Cela signifie que notre robot est entr? en contact avec l'autre, 
; On va alors ? la branche GAGNE
; Sinon, on revient o? on en ?tait dans le code avec BX LR
ReadCollision
		ldr r11,[r5]
		CMP r11,#0x00
		BEQ COLLISION_DROITE
		ldr r11,[r4]
		CMP r11,#0x00
		BEQ COLLISION_GAUCHE 
		BX LR
		
		
; Code ? effectuer par le robot qui cherche une fois qu'il a trouv? l'autre robot (donc gagn?)
COLLISION_DROITE
		ADD r12, #1
		; D?sactiver les deux moteurs droit et gauche, le robot s'arr?te donc
		BL	MOTEUR_DROIT_ARRIERE
		BL	MOTEUR_GAUCHE_ARRIERE
		
		; Eteindre les deux LEDs (Droite et Gauche)
		BL 	ETEINT_GAUCHE
		BL 	ETEINT_DROITE
		
		BL  ALLUME_DROITE
		BL	WAIT2
		BL 	ETEINT_DROITE
		BL	WAIT2
		BL  ALLUME_DROITE
		BL	WAIT2
		BL 	ETEINT_DROITE
		
		BL	MOTEUR_DROIT_AVANT
		BL	WAIT2
				
		BL	loop

; Code ? effectuer par le robot qui cherche une fois qu'il a trouv? l'autre robot (donc gagn?)
COLLISION_GAUCHE
		ADD r12, #1
		; D?sactiver les deux moteurs droit et gauche, le robot s'arr?te donc
		BL	MOTEUR_DROIT_ARRIERE
		BL	MOTEUR_GAUCHE_ARRIERE
		
		; Eteindre les deux LEDs (Droite et Gauche)
		BL 	ETEINT_GAUCHE
		BL 	ETEINT_DROITE
		
		BL  ALLUME_GAUCHE
		BL	WAIT2
		BL 	ETEINT_GAUCHE
		BL	WAIT2
		BL  ALLUME_GAUCHE
		BL	WAIT2
		BL 	ETEINT_GAUCHE
				
		BL	MOTEUR_GAUCHE_AVANT
		BL	WAIT2
				
		BL	loop
		
		
; Boucle d'attente pour le d?placement
WAIT	ldr r1, =0x8FFFFF
wait1	subs r1, #1
        bne wait1
		
		; retour ? la suite du lien de branchement
		BX	LR
		
; Boucle d'attente pour le clignotement des LED
WAIT2	ldr r1, =0x002FFFFF
wait2	subs r1, #1
        bne wait2
		
		; retour ? la suite du lien de branchement
		BX	LR

		NOP
        END