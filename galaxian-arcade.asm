; **************************************************************************************
; * IST-UL
; * Grupo 04
; * Identificação: João Barbosa 99087, João Pinto 99093, Matilde Tocha 99108
; * Descrição: Projeto Nave

; **************************************************************************************
; * Constantes
; **************************************************************************************
DEFINE_LINHA     EQU 600AH          ; endereço do comando para definir a linha
DEFINE_COLUNA    EQU 600CH          ; endereço do comando para definir a coluna
DEFINE_PIXEL     EQU 601AH          ; endereço do comando para escrever um pixel
COR_CANETA		 EQU 6014H			; endereço do comando para especificar a cor da caneta
SEL_ECRA		 EQU 6004H			; endereço do comando que seleciona o ecrã especificado
MOSTRA_ECRA 	 EQU 6006H			; endereço do comando que mostra o ecrã especificado

IMAGEM_FRONTAL	 EQU 6046H			; endereço do comando para selecionar o cenário fontal a visualizar
FUNDO_IMAGEM     EQU 6042H			; endereço do comando para selecionar o cenário de fundo a visualizar
FUNDO_VID_SOM    EQU 605AH	        ; endereço do comando para iniciar a reprodução do som/vídeo especificado

LOOP_VID		 EQU 605CH			; endereço do comando que reproduz o som/vídeo especificado em ciclo até ser parado
PAUSA_VID_SOM	 EQU 605EH          ; endereço do comando para pausar a reprodução do som/vídeo especificado a reproduzir
CONTINUA_VID_SOM EQU 6060H			; endereço do comando para continuar a reprodução do som/vídeo especificado em pausa
TERMINA_VID_SOM  EQU 6066H          ; endereço do comando para terminar a reprodução do som/vídeo especificado

APAGA_ECRAS      EQU 6002H          ; endereço do comando para apagar todos os pixels de todos os ecrãs
APAGA_FRONTAL	 EQU 6044H			; endereço do comando para apagar o cenário frontal
APAGA_FUNDO	     EQU 6040H          ; endereço do comando para apagar o cenário de fundo e o aviso de nenhum cenário selecionado

LINHA_NAVE       EQU 31             ; linha em que o pixel vai ser desenhado (inicial)
COLUNA_NAVE      EQU 29             ; coluna em que o pixel vai ser desenhado (inicial)

ESQ				 EQU 0FFFFH			; valor que indica a direção da nave (move-a para a esquerda)
DIR				 EQU 1				; valor que indica a direção da nave (move-a para a direita)

DISPLAYS         EQU 0A000H  		; endereço dos displays de 7 segmentos
TEC_LIN          EQU 0C000H 		; endereço das linhas do teclado
TEC_COL          EQU 0E000H  		; endereço das colunas do teclado

LINHA            EQU 10H     		; valor inicial para varrimento
SEM_TECLA        EQU 0FFFFH			; valor para indicar se nenhuma tecla foi premida
MULTI            EQU 4H	   		    ; valor a ser multiplicado (fórmula conversão)

ENERGIA          EQU 100            ; valor inicial da energia
DECREMENTA_5     EQU 0FFFBH         ; valor usado para decrementar a energia    
INCREMENTA_5	 EQU 5				; valor usado para incrementar a energia
INCREMENTA_10	 EQU 10             ; valor usado para incrementar a energia

MENU_INICIAL     EQU 0				; estado do jogo, menu inicial, antes do começo do mesmo
ON_GAME          EQU 1				; estado do jogo, durante 
ON_PAUSE         EQU 2				; estado do jogo, em pausa
GAME_OVER        EQU 3				; estado do jogo, terminado

LIM_MAX_ECRA     EQU 57     		; limite máximo para a nave andar no ecrã

FATOR            EQU 1000           ; fator para converter o contador em decimal
DIV_FATOR        EQU 10			    ; valor para converter o contador em decimal

TABELA           EQU 2              ; fator que ajuda a percorrer as tabelas

COLUNA_OVNI      EQU 29				; coluna inicial do ovni
DESTRUIDO		 EQU 2				; valor do tipo de ovni (destruído por colisão)
ALCANCE_OVNI     EQU 36        	    ; alcance usado nos ovnis para os seus limites inferiores
ALCANCE_OVNI_DIR EQU 63         	; alcance usado nos ovnis para os seus limites da direita
ALCANCE_OVNI_ESQ EQU 0FFFBH			; alcance usado nos ovnis para os seus limites da esquerda

MISSIL           EQU 3              ; fator de ajuste para a coluna do míssil
ALCANCE	         EQU 14				; alcance do míssil (12 movimentos)
LINHA_MISSIL     EQU 26             ; linha em que o mísdsil vai ser desenhado (inicial)
COR_MISSIL       EQU 0FB0FH			; cor do míssil (violeta)

IMAGEM_PAUSA	 EQU 2				; valor para a seleção da imagem pausa 
IMAGEM_OVER		 EQU 3				; valor para a seleção da imagem game over

SOM_MISSIL		 EQU 2				; valor para a seleção do som do míssil
SOM_MENU 		 EQU 3				; valor para a seleção do som do menu inicial
SEM_ENERGIA		 EQU 4				; valor para a seleção do som do sem energia
SOM_OVER		 EQU 5				; valor para a seleção do som do game over
SOM_PAUSE		 EQU 6				; valor para a seleção do som do pause
SOM_UNPAUSE		 EQU 7				; valor para a seleção do som do unpause
MORE_ENERGY		 EQU 8 			 	; valor para a seleção do som do more energy

OVNI2            EQU 2         	    ; valores para percorrer a tabela de características
OVNI3            EQU 3           	; dos ovnis e escolha do desenho correto, segundo as
OVNI4          	 EQU 4				; linhas em que o ovni se encontra
OVNI5			 EQU 5
OVNI6            EQU 6
OVNI9			 EQU 9
OVNI10			 EQU 10
OVNI12           EQU 12
OVNI14			 EQU 14
; **************************************************************************************
; * Dados
; **************************************************************************************
PLACE 2000H			        		; localiza o bloco de dados para as rotinas
pilha:    TABLE 100H		  		

SP_inicial:

; Tabela das rotinas de interrupção
tab:      
			WORD rot_int_0			; rotina de atendimento da interrupção 0
			WORD rot_int_1      	; rotina de atendimento da interrupção 1
            WORD rot_int_2          ; rotina de atendimento da interrupção 2
evento_int:
			WORD 0					; se 1, indica que a interrupção 0 ocorreu
			WORD 0              	; se 1, indica que a interrupção 1 ocorreu
		    WORD 0                  ; se 1, indica que a interrupção 2 ocorreu

; ********************************************************
; TABELAS DE DESENHOS DOS OVNIS
; ********************************************************

des_ovni1:
          WORD 0                ; linha
		  WORD 0                ; coluna 
		  WORD 1                ; largura
		  WORD 1                ; altura
		  WORD 6000H			; cor
		  STRING 1, 0           ; desenho
		  
des_ovni2:
          WORD 0               
		  WORD 0
		  WORD 2
		  WORD 2
		  WORD 6000H
		  STRING 1, 1
		  STRING 1, 1
		  
des_ovi3_mau:
          WORD 0
		  WORD 0
		  WORD 3
		  WORD 3
		  WORD 0FF00H
		  STRING 1, 0, 1 
		  STRING 0, 1, 0
		  STRING 1, 0, 1, 0

des_ovni3_bom:
          WORD 0
		  WORD 0
		  WORD 3
		  WORD 3
		  WORD 0F0F0H
		  STRING 0, 1, 0
		  STRING 1, 1, 1
		  STRING 0, 1, 0, 0

des_ovni4_mau:
          WORD 0
		  WORD 0
		  WORD 4
		  WORD 4
		  WORD 0FF00H
		  STRING 1, 0, 0, 1
		  STRING 0, 1, 1, 0
		  STRING 0, 1, 1, 0
		  STRING 1, 0, 0, 1
		  
des_ovni4_bom:
          WORD 0
		  WORD 0
		  WORD 4
		  WORD 4
		  WORD 0F0F0H
		  STRING 0, 1, 1, 0
		  STRING 1, 1, 1, 1
		  STRING 1, 1, 1, 1
		  STRING 0, 1, 1, 0
		  
des_ovni5_mau:
          WORD 0
		  WORD 0
		  WORD 5
		  WORD 5
		  WORD 0FF00H
		  STRING 1, 0, 0, 0, 1
		  STRING 0, 1, 0, 1, 0
		  STRING 0, 0, 1, 0, 0
		  STRING 0, 1, 0, 1, 0
          STRING 1, 0, 0, 0, 1, 0
		  
des_ovni5_bom:
          WORD 0
		  WORD 0
		  WORD 5
		  WORD 5
		  WORD 0F0F0H
		  STRING 0, 1, 1, 1, 0
		  STRING 1, 1, 1, 1, 1
		  STRING 1, 1, 1, 1, 1
		  STRING 1, 1, 1, 1, 1
          STRING 0, 1, 1, 1, 0, 0
		  
des_ovni_boom:
          WORD 0
		  WORD 0
		  WORD 5
		  WORD 5
		  WORD 0F0FFH
		  STRING 0, 1, 0, 1, 0
		  STRING 1, 0, 1, 0, 1
		  STRING 0, 1, 0, 1, 0
		  STRING 1, 0, 1, 0, 1
          STRING 0, 1, 0, 1, 0, 0
		  
ovni1:
          WORD 0                ; linha
		  WORD 1FH              ; coluna
 		  WORD 0                ; direção  
		  WORD 0                ; existe?
		  WORD des_ovni1        ; desenho   
		  WORD 0                ; bom/ mau/ destruído
		  WORD 1                ; ecrã  
		  
ovni2:
          WORD 0
		  WORD 1FH
 		  WORD 0
		  WORD 0                      
		  WORD des_ovni1	         
		  WORD 0                     
		  WORD 2                     
		  
ovni3:
          WORD 0                 
		  WORD 1FH                    
 		  WORD 0                   
		  WORD 0                     
		  WORD des_ovni1	            
		  WORD 0                      
		  WORD 3                     
		  
ovni4:
          WORD 0                   
		  WORD 1FH                   
 		  WORD 0                      
		  WORD 0                    
		  WORD des_ovni1	         
		  WORD 0                     
		  WORD 4                    
		  
meteoritos:
          WORD ovni1
		  WORD ovni2
		  WORD ovni3
		  WORD ovni4			
			
; Tabela com as características da nave
nave:		
			WORD  LINHA_NAVE
			WORD  COLUNA_NAVE
			WORD  5			
			WORD  7
			WORD  0FFE0H			; cor da nave (amarelo)
			STRING  0, 1, 0, 1, 0, 1, 0
			STRING  1, 1, 1, 1, 1, 1, 1
			STRING  1, 0, 1, 0, 1, 0, 1
			STRING  0, 0, 1, 1, 1, 0, 0
			STRING  0, 0, 0, 1, 0, 0, 0, 0
			
; Tabela com as características da nave apagada			
pinta_missil:	
			WORD COR_MISSIL

coluna_atual_nave:
			WORD COLUNA_NAVE		; variável com a coluna em que a nave está
			
direcao_nave:
			WORD 0					; variável que indica se a nave se encontra a mover ou não
									; -1 para a esquerda e 1 para a direita

linha_atual_missil:
			WORD LINHA_MISSIL		; variável com a linha em que o míssil está

coluna_atual_missil:
			WORD 0					; variável com a coluna em que o míssil está

ha_missil:
			WORD 0					; variável que indica se é criado um míssil quando a tecla 1 é premida

estado_jogo:
            WORD 0					; variável que indica em que estado o jogo se encontra

nivel_energia:
            WORD ENERGIA			; variável do contador de energia

estado_missil:
			WORD 0					; variável que indica se a tecla 1 é premida ou não

tecla_premida:
			WORD 0                  ; variável que indica se uma tecla foi premida ou não

ultima_tecla:
			WORD 0CH                ; variável que indica a útlima tecla que foi premida

estado_ha_tecla:
			WORD 0 					; variável que indica se a mesma tecla está a ser premida
			
			WORD sem_tecla	
rot_teclado:						; tabela com as rotinas das teclas funcionais
			WORD move_esq			; se a tecla 0 for premida, a nave move para a esquerda
			WORD missil				; se a tecla 1 for premida, um míssil é disparado
			WORD move_dir			; se a tecla 2 for premida, a nave move para a direita
			WORD nada				; se a tecla 3 for premida, não acontece nada (tecla não funcional)
			WORD nada				; se a tecla 4 for premida, não acontece nada (tecla não funcional)
			WORD nada				; se a tecla 5 for premida, não acontece nada (tecla não funcional)
			WORD nada				; se a tecla 6 for premida, não acontece nada (tecla não funcional)
			WORD nada				; se a tecla 7 for premida, não acontece nada (tecla não funcional)
			WORD nada				; se a tecla 8 for premida, não acontece nada (tecla não funcional)
			WORD nada				; se a tecla 9 for premida, não acontece nada (tecla não funcional)
			WORD nada				; se a tecla A for premida, não acontece nada (tecla não funcional)
			WORD nada				; se a tecla B for premida, não acontece nada (tecla não funcional)
			WORD game_on			; se a tecla C for premida, o jogo é iniciado 
			WORD pausa				; se a tecla D for premida, o jogo é pausado ou despausado
			WORD termina   			; se a tecla E for premida, o jogo é terminado
			WORD nada				; se a tecla F for premida, não acontece nada (tecla não funcional)
			
num_aleatorio: 						
			WORD 0					; variável usada para gerar um número aleatório
; **************************************************************************************
; * Código
; **************************************************************************************

PLACE      0
inicializacoes:
    MOV  BTE, tab                   ; inicializa BTE (registo de Base da Tabela de Exceções)
	MOV	 SP, SP_inicial             ; inicializa SP com o endereço logo após a pilha
	
    EI0	                     		; permite interrupções 0
    EI1                      	    ; permite interrupções 0
    EI2                             ; permite interrupções 1
	EI                       	    ; permite interrupções (geral)
	
	MOV  R0, APAGA_FUNDO
    MOV  [R0], R1                   ; apaga o aviso de nenhum cenário selecionado (o valor de R1 não é relevante)

	MOV  R0, APAGA_ECRAS
	MOV  [R0], R1                   ; apaga todos os pixels de todos os ecrãs (o valor de R1 não é relevante)
	
	MOV  R1, 0						
	MOV  R0, DISPLAYS
	MOV  [R0], R1					; coloca os displays de energia a zero

	MOV  R1, 0
	MOV  R0, FUNDO_IMAGEM
	MOV  [R0], R1                   ; seleciona o cenário de fundo inicial

	MOV  R1, SOM_MENU
	MOV  R0, FUNDO_VID_SOM			; inicia a reprodução do som inicial
	MOV  [R0], R1					
	
	MOV  R0, LOOP_VID				; reproduz o vídeo especificado em ciclo até ser parado
	MOV  [R0], R1
	
	MOV  R0, estado_jogo
	MOV  R1, 0
	MOV  [R0], R1
	

; ciclo dos processos
ciclo:								; ciclo principal do programa
	CALL chuva_de_ovnis
	CALL teclado
	CALL ha_tecla
	CALL teclas
	CALL energia
	CALL move_nave
	CALL ciclo_missil
	CALL colisoes

	JMP  ciclo

; **************************************************************************************
; * Processos
; **************************************************************************************
	
; **************************************************************************************
; * CHUVA_DE_OVNIS: Ciclo principal da chuva de ovnis. Faz cair vários ovnis pelo ecrã, 
; * 				se o jogo estiver a decorrer e e interrupção 0 tiver ocorrido. 
; * 
; **************************************************************************************	
chuva_de_ovnis:
	PUSH R0
	PUSH R1
	PUSH R2
	
	MOV  R1, estado_jogo
	MOV  R2, [R1]
	MOV  R3, ON_GAME
	CMP  R2, R3
	JNE  sem_chuva
	
	MOV  R1, evento_int       ; verifica o estado da interrupção,
	MOV  R2, [R1]             ; caso seja zero não acontece ciclo_chuva
	CMP  R2, 0
	JEQ  sem_chuva
	
	CALL gera_aleatorio	
	MOV  R2, meteoritos
	MOV  R10, [R2]			  ; tabela de carcaterísticas do ovni 1
	CALL ciclo_chuva
	
	CALL gera_aleatorio
	ADD  R2, TABELA
	MOV  R10, [R2]			 ; tabela de carcaterísticas do ovni 2
	CALL ciclo_chuva

	CALL gera_aleatorio
	ADD  R2, TABELA
	MOV  R10, [R2]			 ; tabela de carcaterísticas do ovni 3
	CALL ciclo_chuva
	
	CALL gera_aleatorio	
	ADD  R2, TABELA
	MOV  R10, [R2]			 ; tabela de carcaterísticas do ovni 4
	CALL ciclo_chuva
	
sem_chuva:
	POP  R2
	POP  R1
	POP  R0
	RET
	
; **************************************************************************************
; * TECLADO: Processo que deteta quando se carrega numa tecla do teclado.
; *	Arguemntos: R1 - valor inicial para varrimento do teclado
; * 			R2 - endereço do periférico das linhas
; * 			R3 - endereço do periférico das colunas
; *
; **************************************************************************************
teclado:
	PUSH R0
    PUSH R1
    PUSH R2
    PUSH R3

	MOV  R1, LINHA     		        ; testar linha
    MOV  R2, TEC_LIN			    ; endereço do periférico das linhas
    MOV  R3, TEC_COL        	    ; endereço do periférico das colunas

espera_tecla:
	SHR  R1, 1         	            ; varre as 4 linhas do teclado
	CMP  R1, 0         		        ; o valor da linha é 0?
	JZ   nao_ha_tecla   		        ; se sim, então não ha tecla a ser premida
	MOVB [R2], R1      		        ; escreve no periférico de saída (linhas)
    MOVB R0, [R3]      		        ; lê do periférico de entrada (colunas)
    CMP  R0, 0         		        ; há tecla premida?
	JZ   espera_tecla			    ; se NENHUMA tecla estiver a ser premida, repete
	CALL conversor					; converte para o valor de uma tecla
    MOV  R1, tecla_premida
    MOV  [R1], R2            	    ; atualiza na variável a informação sobre se houve ou não tecla premida
	JMP  sai_teclado

nao_ha_tecla:
	MOV  R2, SEM_TECLA
    MOV  R1, tecla_premida
    MOV  [R1], R2            	    ; atualiza na variável a informação sobre se houve ou não tecla premida

sai_teclado:
    POP  R3
    POP  R2
    POP  R1
    POP  R0
    RET

; **************************************************************************************
; * HA_TECLA: Processo que aciona as funcionalidades das teclas, apenas se (...)
; * Argumentos: R2 - tecla premida
; *				R3 - última tecla que foi premida anteriormente
; *             R5 - variável que indica se a mesma tecla está a ser premida
; *
; **************************************************************************************
ha_tecla:
	PUSH R0
	PUSH R1
	PUSH R2
	PUSH R3
	PUSH R4
	PUSH R5

	MOV  R2, tecla_premida
	MOV  R3, ultima_tecla
	MOV  R0, [R2]            	    ; tecla premida	
	MOV  R1, [R3]					; útlima tecla que foi premida anteriormente
	CMP  R0, R1						; as duas teclas são iguais?
	JEQ  ha_tecla_nenhuma			; 

	MOV  R4, 1						; ativa o estado_ha_tecla para 1 
	JMP sai_ha_tecla

ha_tecla_nenhuma:
	MOV R4, 0

sai_ha_tecla:
	MOV  R5, estado_ha_tecla
	MOV  [R5], R4					; atualiza a variável de estado sobre se há ou não tecla
									; se estiver a 1, poderá chamar rotinas da tecla funcional premida
	POP  R5
	POP  R4
	POP  R3
	POP  R2
	POP  R1
	POP  R0
	RET

; **************************************************************************************
; * TECLAS: Processo que aciona as funcionalidades das teclas, apenas se a variável
; *			estado_ha_tecla estiver a 1, de modo realizar as funcionalidades das 
; * 		teclas premidas.
; * Argumentos: R0 - variável que indica se a mesma tecla está a ser premida
; *      		R1 - tecla premida
; *
; **************************************************************************************
teclas:   					  
	PUSH R1
	PUSH R2
	PUSH R3
	PUSH R4
	PUSH R5
	PUSH R6
	PUSH R7
	
	MOV  R7, estado_ha_tecla
	MOV  R2, [R7]
	MOV  R1, tecla_premida	
	CMP  R2, 0						; há tecla a ser premida?	
	JZ   sem_efeito					; se não, não acontece nada

teclas_premidas:
	MOV  R3, [R1]					; tecla premida
	MOV  R4, TABELA					; fator que ajuda a percorrer as tabelas
	MUL  R3, R4						; fórmula de conversão para percorrer a tabela das rot_teclado
	MOV  R4, rot_teclado
	ADD  R4, R3						; fórmula de conversão para percorrer a tabela das rot_teclado
	MOV  R5, [R4]					; lê a rotina correspondente à tecla premida
	CALL R5

	MOV  R5, 0						; coloca a variável do estado_ha_tecla a 0 para indicar que
	MOV  [R7], R5					; a funcionalidade da mesma já foi realizada 

sem_efeito:
	MOV  R6, ultima_tecla			; atualiza a variável da ultima_tecla, 
	MOV  R2, [R1]					; de acordo com a tecla que foi premida
	MOV  [R6], R2
	
	POP  R7
	POP  R6
	POP  R5
	POP  R4
	POP  R3
	POP  R2
	POP  R1
	RET

; **************************************************************************************
; * ENERGIA: Contador de energia do jogo. O seu valor é decrementado de 3 em 3 segundos
; *			 caso tenha ocorrido a interrupção 2 e apenas enquanto o jogo está a deccorrer.
; * 		 Quando o contador chega a 0, estado do jogo é alterado para terminado (perdeu).
; * Argumentos: R0 - variável que indica se a interrupção 1 ocorreu.
; *
; **************************************************************************************
energia:
	PUSH R0
	PUSH R1
	PUSH R2
	PUSH R4
	PUSH R5
	PUSH R6
	PUSH R7

	MOV  R4, estado_jogo			
	MOV  R7, [R4]					; variável do estado de jogo 					
	MOV  R5, ON_GAME				; estado do jogo, durante
	CMP  R7, R5						; o jogo está a decorrer?
	JNE  nao_decrementa				; se não o contador de energia não decrementa
    
	MOV  R0, evento_int
	MOV  R2, TABELA
	ADD  R0, R2
	ADD  R0, R2
	MOV  R1, [R0]
	CMP  R1, 0			 			; se não houve interrupção, não decrementa 	
	JZ   nao_decrementa
	
	MOV  R6, DECREMENTA_5
	CALL atualiza_displays
	
	MOV  R1, 0                      ; coloca a zero o valor da variável que diz se houve
	MOV  [R0], R1                   ; uma interrupção (consome evento)
	
nao_decrementa:
    POP  R7
	POP  R6
	POP  R5
	POP  R4
	POP  R2
	POP  R1
	POP  R0
	RET


; **************************************************************************************
; * MOVE_NAVE: Faz mover a nave para a direita ou esquerda, de acordo coma direção que
; * 		   lhe foi atribuída ao clicar-se na tecla 0 ou 2.
; *
; **************************************************************************************
move_nave:
	PUSH R0
    PUSH R1					
    PUSH R2						
    PUSH R3						
    PUSH R4	
	PUSH R5
	PUSH R6
	PUSH R10
 	
	MOV  R0, direcao_nave
	MOV  R1, [R0]					; direção da nave
	CMP  R1, 0						; a direção é 0 (não move)?
	JZ   nao_move					; se sim, não move
	
    MOV  R5, nave
	ADD  R5, TABELA				
    MOV  R2, [R5]                   ; coluna em que a nave está	
	
	CMP  R1, 1
	JEQ  direcao1
	JMP  direcao2
	
direcao1:
	MOV  R3, LIM_MAX_ECRA
    CMP  R2, R3                     ; já estava no limite máximo?
    JEQ  nao_move			     	; se sim, a nave já não anda mais
	JMP  mexe

direcao2:
	MOV  R3, 0
    CMP  R2, R3                     ; já estava no limite mínimo?
    JEQ  nao_move					; se sim, a nave já não anda mais	

mexe:	
	MOV  R0, nave
	MOV  R11, 0
	MOV  R6, 0
	CALL desenha					; apaga a nave da coluna atual
	
	ADD  R2, R1						; próxima coluna
	MOV  [R5], R2					; atualiza a coluna em que a nave está	
	MOV  R11, 1
	MOV  R0, nave
	MOV  R6, 0
    CALL desenha	                ; desenha a nave na coluna atual
	
nao_move:
	POP  R10
	POP  R6
	POP  R5
    POP  R4						
    POP  R3							
    POP  R2							
    POP  R1	
	POP  R0
    RET

; **************************************************************************************
; * CICLO_MISSIL: Ciclo principal do míssil. Faz disparar um míssil caso tenha ocorrido 
; *				  a interrupção 1. Só permite o disparar de um próximo míssil, após o 
; * 			  desaparecimento do míssil no ecrã.
; * Argumentos: R0 - variável que indica se a interrupção 1 ocorreu.
; *
; **************************************************************************************
ciclo_missil:
	PUSH R0
	PUSH R1
	PUSH R2
	PUSH R3
	
	MOV  R1, ON_GAME				; estado do jogo, durante
	MOV  R2, estado_jogo
	MOV  R3, [R2]					; variável do estado de jogo
	CMP  R3, R1						; o jogo está a decorrer?
	JNE  nao_dispara				; se não, não dispara 
	
	MOV  R0, evento_int
	ADD  R0, TABELA
	MOV  R1, [R0]
	CMP  R1, 0			 			; se não houve interrupção, não dispara 	
	JZ   nao_dispara
	
	CALL apaga_missil				; apaga o míssil desenhado anteriormente
	CALL cria_missil				; se a tecla 1 foi premida, vai criar um míssil	
	CALL mexe_missil				; se já houver um míssil criado, vai mexer-se pelo ecrã
	
	MOV  R1, 0						; coloca a zero o valor da variável que diz se houve 
	MOV  [R0], R1					; uma interrupção (consome evento)

nao_dispara:	
	POP  R3
	POP  R2
	POP  R1
	POP  R0
	RET

; **************************************************************************************
; * COLISOES: Ciclo principal das colisões. Verifica se ocorreu alguma colisão entre 
; *			  nave e ovnis (bom e mau) e míssil e ovnis (bom e mau).
; *
; **************************************************************************************
colisoes:
	PUSH R0
	PUSH R1
	PUSH R2
	PUSH R3
	PUSH R4

colisao_missil_ovni:	
	MOV  R2, meteoritos
	MOV  R10, [R2]			 ; tabela de carcaterísticas do ovni 1
	CALL missil_ovni
	
	ADD  R2, TABELA
	MOV  R10, [R2]			 ; tabela de carcaterísticas do ovni 2
	CALL missil_ovni
	
	ADD  R2, TABELA
	MOV  R10, [R2]			 ; tabela de carcaterísticas do ovni 3
	CALL missil_ovni
	
	ADD  R2, TABELA
	MOV  R10, [R2]			 ; tabela de carcaterísticas do ovni 4
	CALL missil_ovni

	POP  R4
	POP  R3
	POP  R2
	POP  R1
	POP  R0
	RET


; **************************************************************************************
; * Rotinas de interrupção 
; **************************************************************************************
; **************************************************************************************
; * ROT_INT_0 - Rotina de atendimento da interrupção 1
; *             Assinala o evento na componente 1 da variável evento_int
; **************************************************************************************
rot_int_0:
    PUSH R0
    PUSH R1
	 
    MOV  R0, evento_int
    MOV  R1, 1						; assinala que houve uma interrupção 1
    MOV  [R0], R1            		; na componente 1 da variável evento_int
                              
    POP  R1
    POP  R0
    RFE
; ***********************************************

; **************************************************************************************
; * ROT_INT_1 - Rotina de atendimento da interrupção 1
; *             Assinala o evento na componente 1 da variável evento_int
; **************************************************************************************
rot_int_1:
    PUSH R0
    PUSH R1
	PUSH R2
	 
    MOV  R0, evento_int
	MOV  R2, TABELA
	ADD  R0, R2
    MOV  R1, 1						; assinala que houve uma interrupção 1
    MOV  [R0], R1            		; na componente 1 da variável evento_int
     
	POP  R2
    POP  R1
    POP  R0
    RFE

; **************************************************************************************
; * ROT_INT_2 - Rotina de atendimento da interrupção 2
; *             Assinala o evento na componente 2 da variável evento_int
; **************************************************************************************
rot_int_2:
    PUSH R0
    PUSH R1
    PUSH R2	
	
    MOV  R0, evento_int
    MOV  R2, TABELA			
	ADD  R0, R2
	ADD  R0, R2
	MOV  R1, 1						; assinala que houve uma interrupção 1
    MOV  [R0], R1            		; na componente 1 da variável evento_int
                              
    POP  R2
	POP  R1
    POP  R0
    RFE

; **************************************************************************************
; * ROTINAS AUXILIARES
; **************************************************************************************

; **************************************************************************************
; * CICLO_CHUVA: Ciclo principal da chuva. Faz cair um ovni (bon ou mau) pelo ecrã, com
; * 			 uma direção associada, caso tenha occorrido a interrupção. Só permite a 
; * 			 de um novo ovni, após o desaparecimento do ovni no ecrã.
; * Argumentos: R10 - tabela com as características do ovni
; *
; **************************************************************************************
ciclo_chuva:
    PUSH R1
	PUSH R2
	PUSH R3
	PUSH R10
	PUSH R11 

    MOV  R11, 0				  ; apaga o ovni do ecrã
	CALL desenha_ovni
	CALL cria_ovni 
	CALL mexe_ovni	
	CALL escolhe_desenho	
	MOV  R11, 1				  ; desenha o ovni no ecrã
    CALL desenha_ovni	
	CALL verifica_boom

	MOV  R2, 0                ; acaba interrupção
	MOV  [R1], R2
	
sai_chuva:
	POP  R11 
	POP  R10
	POP  R3
	POP  R2
	POP  R1 
	RET

; **************************************************************************************
; *	DESENHA_OVNI: Atualiza a tabela de características do desenho escolhido e, de seguida
; *				  desenha-o no ecrã
; **************************************************************************************	
desenha_ovni:
    PUSH R0
	PUSH R1
	PUSH R2
	PUSH R3
	PUSH R4
	PUSH R5
	PUSH R6
	PUSH R10
	PUSH R11
	
	MOV  R2, OVNI6 
	ADD  R10, R2 
	
	MOV  R2, OVNI2 
	ADD  R10, R2
    MOV  R3, [R10]					; desenho escolhido
	
	MOV  R2, OVNI6
	SUB  R10, R2 
	MOV  R4, [R10]					; coluna atual do ovni
	
	MOV  R2, OVNI2
	SUB  R10, R2
	MOV  R5, [R10]					; linha atual do ovni
	
	MOV  [R3], R5					; atualiza a linha do ovni no seu desenho
	ADD  R3, TABELA
	MOV  [R3], R4					; atualiza a coluna do ovni no seu desenho
    MOV  R0, R3 
	
	MOV  R2, OVNI2
	SUB  R0, R2						; volta ao início da tabela das características do desenho
	MOV  R4, OVNI12					
	ADD  R10, R4
	MOV  R6, [R10]					; ecrã	
	
	CALL  desenha					
	JMP   sai_desenha
		
sai_desenha:
	POP  R11
	POP  R10
	POP  R6
	POP  R5 
	POP  R4
	POP  R3
	POP  R2
	POP  R1
	POP  R0
    RET	

; **************************************************************************************
; * CRIA_OVNI: Cria um ovni e atualiza as suas características existência, de direção, 
; * 		   tipo (bom ou mau) de acorodo com as probabilidades indicadas. Se já existir
; *			   um ovni no ecrã, então não cria mais nenhum.
; *
; **************************************************************************************
cria_ovni:
	PUSH R1
	PUSH R2
	PUSH R3
	PUSH R4
	PUSH R10

    ADD  R10, OVNI6	
	MOV  R1, [R10]					; existência de ovni
	CMP  R1, 0						; existe um ovni no ecrâ?
	JNZ  sai_cria_ovni		    	; se sim, então não cria
	
	MOV  R1, 1
	MOV  [R10], R1               	; atualiza a existência do ovni (ativa, agora existe)
	SUB  R10, OVNI4                   
	MOV  R2, COLUNA_OVNI  
	MOV  [R10], R2               	; coluna atual do ovni
	
	SUB  R10, OVNI2
	MOV  R2, 0
	MOV  [R10], R2              	; linha atual do ovni
	
	ADD  R10, OVNI4					; direção do ovni
	MOV  R2, num_aleatorio      	; para obtermos as direções do asteroide precisamos de  
	MOV  R3, [R2]               	; um número aleatório  
	MOV  R4, OVNI3		
	MOD  R3, R4                 	; probabilidade equitativa (3 por 3) 
	SUB  R3, 1                  	; subtrai 1 para obter os valores (-1, 0, 1) 
	MOV  [R10], R3               	; atualiza a direção do ovni
	
	ADD  R10, OVNI6					; tipo de ovni (bom ou mau)
	MOV  R3, [R2]               	; escolha entre bom ou mau 
	MOV  R1, OVNI4                  ; número aleatório 
	MOD  R3, R1                 	; probabilidade 75% mau, 25% bom 
	CMP  R3, 0                  	
	JZ   bom                   		; é bom, se e só se, o resto de divesão por 4 for 0, de modo
									; a deixar 3 possibilidades para o ovni ser mau
	MOV  R1, 1
	MOV  [R10], R1               	; atualiza o tipo de ovni (mau)
    JMP  sai_cria_ovni

bom:
    MOV  R1, 0
	MOV  [R10], R1               	; atualiza o tipo de ovni (bom)
	
sai_cria_ovni:
	POP  R10
	POP  R4 
	POP  R3
	POP  R2
	POP  R1
	RET

; **************************************************************************************
; *	ESCOLHE_DESENHO: Escolhe o desenho do ovni a ser desenhado no ecrã de acordo com a
; * 				 direção e tipo (bom ou mau), atualizando as carcaterísticas do ovni. 
; * 				 Além disso, faz aumentar o tamanho do ovni à medida que este avança 
; *					 pelo ecrã.
; *
; **************************************************************************************
escolhe_desenho:
	PUSH R1 
	PUSH R2
	PUSH R3 
	PUSH R4 
	PUSH R10
	
	MOV  R2, OVNI6
    ADD  R10, R2	
	MOV  R1, [R10]					; existência de ovni
	CMP  R1, 0						; existe um ovni no ecrã?
	JZ   sai_escolhe_desenho        ; se não, então não atualiza nada
	
	SUB  R10, R2
	MOV  R4, [R10]                	; linha atual do ovni
	
	MOV  R2, OVNI10
	ADD  R10, R2
	MOV  R2, [R10]					; desenho escolhido
	CMP  R2, DESTRUIDO 				; houve colisão?
	JEQ  escolhe_destruido			; se sim, desenha o boom

	SUB  R10, TABELA                ; desenho escolhido
	CMP  R4, OVNI2                  ; o ovni está antes da 1a linha?
	JLT  escolhe_1               	; se sim, escolhe o desenho correto
	
	MOV  R2, OVNI5
	CMP  R4, R2                  	; o ovni está antes da 4a linha?
	JLT  escolhe_2               	; se sim, escolhe o desenho correto
	
	MOV  R2, OVNI9                
	CMP  R4, R2                     ; o ovni está antes da 8a linha? 
	JLT  escolhe_3               	; se sim, escolhe o desenho correto
	
	MOV  R2, OVNI14
	CMP  R4, R2 					; o ovni está antes da 13a linha? 			
	JLT  escolhe_4               	; se sim, escolhe o desenho correto
   
	MOV  R2, OVNI2
    ADD  R10, R2					
	MOV  R1, [R10]                  ; tipo do ovni (bom ou  mau)
	CMP  R1, 0                   	; é bom?
	JEQ   escolhe_5_bom           	; se sim, escolhe o desenho bom 
    MOV  R1, des_ovni5_mau			; desenho 5x5 mau
	JMP  injeta5

escolhe_5_bom:
    MOV R1, des_ovni5_bom			; desenho 5x5 bom	  	
	
injeta5:
	MOV  R2, OVNI2
    SUB  R10, R2
	MOV  [R10], R1                 	; atualiza o desenho
	JMP  sai_escolhe_desenho     
    
escolhe_1:
	MOV  R1, des_ovni1	    	   	; desenho 1x1 sem tipo
									; ainda não sabemos se vai ser bom ou mau, está longe da nave 
	MOV  [R10], R1     				; atualiza o desenho            	
	JMP  sai_escolhe_desenho      

escolhe_2:
    MOV  R1, des_ovni2	       		; desenho 2x2 sem tipo
	MOV  [R10], R1                 	; atualiza o desenho      
	JMP  sai_escolhe_desenho      

escolhe_3:
	MOV  R2, OVNI2
    ADD  R10, R2
	MOV  R1, [R10]                 	; tipo do ovni (bom ou mau)
	CMP  R1, 0                    	; é bom?
	JZ   escolhe_3_bom            	; se sim, escolhe o desenho bom
    MOV  R1, des_ovi3_mau		  	; desenho 3x3 mau
	JMP  injeta3

escolhe_3_bom:
    MOV  R1, des_ovni3_bom		  	; desenho 3x3 bom      
	
injeta3:
	MOV  R2, OVNI2
    SUB  R10, R2                        
	MOV  [R10], R1					; atualiza o desenho  
	JMP  sai_escolhe_desenho
	
escolhe_4:
	MOV  R2, OVNI2
    ADD  R10, R2                    
	MOV  R1, [R10]                  ; tipo do ovni  (bom ou mau)
	CMP  R1, 0						; é bom?
	JZ   escolhe_4_bom            	; se sim, escolhe o desenho bom
    MOV  R1, des_ovni4_mau		  	; desenho 4x4 mau
	JMP  injeta4

escolhe_4_bom:
    MOV  R1, des_ovni4_bom		  	; desenho 4x4 bom

injeta4:
	MOV  R2, OVNI2
    SUB  R10, R2                    ; atualiza o desenho  
	MOV  [R10], R1 	
	JMP  sai_escolhe_desenho

escolhe_destruido:
	SUB  R10, OVNI2
	MOV  R2, des_ovni_boom
	MOV  [R10], R2
	
sai_escolhe_desenho:
	POP  R10
	POP  R4 
	POP  R3
	POP  R2
	POP  R1
    RET 

; **************************************************************************************
; *	MEXE_OVNI: Faz mexer o ovni pelo ecrã, até chegar aos limites do mesmo e desaparecer.
; * 
; **************************************************************************************
mexe_ovni:
	PUSH R1
	PUSH R2
	PUSH R3
	PUSH R4
	PUSH R10
	
	MOV  R4, R10    				; cópia do R10
	
	MOV  R3, OVNI6
	ADD  R10, R3                  
	MOV  R1, [R10]					; existência de ovni
	CMP  R1, 0						; existe ovni no ecrã
	JZ   sai_mexe_ovni		   		; se não, não mexe
	
	SUB  R10, R3
	MOV  R1, [R10]             		; linha atual ovni
	ADD  R1, 1                 		; próxima linha
	MOV  [R10], R1              	; atualiza a linha atual 
	
	MOV  R3, OVNI2
	ADD  R10, R3
	MOV  R1, [R10]              	; coluna atual ovni
	
	ADD  R10, R3
	MOV  R2, [R10]              	; direção do ovni
	ADD  R1, R2               	 	; soma-se, obtendo a diagonal para esquerda ou para a direita  
	SUB  R10, R3                 	; ou reta para baixo sendo o registo -1, 1 ou 0, respetivamente
	MOV  [R10], R1              	; atualiza a coluna atual
	
	CALL alcance_ovnis

sai_mexe_ovni:
	POP  R10
	POP  R4
	POP  R3
	POP  R2
	POP  R1
	RET
	
; **************************************************************************************
; *	ALCANCE_OVNIS: Verifica se o ovni já chegou aos limites do ecrã e, se sim, faz 
; * 			   desaparecê-lo.
; *
; **************************************************************************************	
alcance_ovnis:
	PUSH R0
	PUSH R1
	PUSH R2
	PUSH R3
	PUSH R4
	PUSH R5
	PUSH R10
	
	MOV  R1, R4
	MOV  R2, OVNI4
	ADD  R1, R2						
	MOV  R3, [R1]					; direção do ovni
	CMP  R3, 0						; o ovni está a cair na vertical?
	JEQ  limite_inferior			; se sim, verifica os limites inferiores
	
	CMP  R3, 1						; o ovni está a cair na diagonal direita?
	JEQ  limite_dir					; se sim, verifica os limites da direita
	MOV  R0, ALCANCE_OVNI_ESQ		; limite da esquerda
	MOV  R2, OVNI2					
	SUB  R1, R2						
	MOV  R5, [R1]					; coluna atual do ovni
	CMP  R0, R5						; o ovni encontra-se no limite do ecrã?
	JEQ  desaparece					; se sim, desaparece
	JMP  sai_alcance_ovnis
	
limite_inferior:
	MOV  R0, ALCANCE_OVNI			; limite inferior 
	MOV  R2, OVNI4
	SUB  R1, R2
	MOV  R5, [R1]					; coluna atual do ovni
	CMP  R0, R5						; o ovni encontra-se no limite do ecrã?
	JEQ  desaparece					; se sim, desaparece
	JMP  sai_alcance_ovnis
	
limite_dir:
	MOV  R0, ALCANCE_OVNI_DIR		; limite superior 
	MOV  R2, OVNI2
	SUB  R1, R2
	MOV  R5, [R1]                   ; coluna atual do ovni 
	CMP  R0, R5                     ; o ovni enconta-se no limite do ecrã? 
	JEQ  desaparece                 ; se sim, desaparece
	JMP  sai_alcance_ovnis
	
desaparece:
	MOV  R1, R4
	MOV  R3, OVNI6
	ADD  R1, R3						
	MOV  R4, 0						
	MOV  [R1], R4					; atualiza a existência do ovni para 0 (não existe)

sai_alcance_ovnis:
	POP  R10
	POP  R5
	POP  R4
	POP  R3
	POP  R2
	POP  R1
	POP  R0
	RET
	
; **************************************************************************************
; * VERIFICA_BOOM:
; *
; **************************************************************************************
verifica_boom:
	PUSH R0
	PUSH R1
	PUSH R2
	PUSH R6
	PUSH R10
	
	MOV  R0, 10
	ADD  R10, R0
	MOV  R1, [R10]
	CMP  R1, 2
	JNE  sai_verifica_boom

 	SUB  R10, OVNI4
	MOV  R2, 0
	MOV  [R10], R2
	
sai_verifica_boom:	
	POP R10
	POP R6
	POP R2
	POP R1
	POP R0
	RET	

; **************************************************************************************
; * GERA_ALEATORIO: Gera um número aleatório para depois ser usado na criação entre 
; *					naves inimigas ou asteróides e direção (centro, diagonal esquerda, 
; *					diagonal direita).
; *
; **************************************************************************************
gera_aleatorio:
	PUSH R0
	PUSH R1

	MOV  R0, num_aleatorio
	MOV  R1, [R0]
	ADD  R1, 1						; adiciona 1 à variável num_aleatorio, de modo a estar 
	MOV  [R0], R1					; sempre a gerar novas probabilidades para a criação
									; de naves inimigas, asteróides e escolha de direção
	POP  R1
	POP  R0
	RET

; **************************************************************************************
; * CONVERSOR: Converte o valor da linha e da coluna num valor de 0 - 3.
; *             Converte a linha coma respetiva coluna numa tecla.
; * Argumentos: R1 - linha a converter
; *             R0 - coluna a converter
; *
; **************************************************************************************
conversor:
	PUSH R0
	PUSH R1

	MOV  R2, 0					   ; contador de conversão das linhas
	MOV  R3, 0			           ; contador de conversão das colunas

conversor_linhas:
	SHR  R1, 1   	   		       ; faz com que o valor da linha fique a zero, para se contabilizar (converter)
	CMP  R1, 0				       ; o valor da coluna já está a 0?
	JZ   conversor_colunas	       ; se sim, o valor já está convertido
	ADD  R2, 1         		       ; contador que dá o valor convertido das linhas
	JMP  conversor_linhas	       ; enquanto não for zero, repete

conversor_colunas:     		       ; este ciclo vai converter o valor da coluna num valor de 0-3
	SHR  R0,1          		       ; faz com que o valor da coluna fique a zero, para se contabilizar (converter)
	CMP  R0,0				       ; o valor da coluna já está a 0?
	JZ	 conversor_tecla  	       ; se sim, o valor já está convertido
	ADD  R3,1          		       ; contador que dá o valor convertido da coluna
	JMP  conversor_colunas	       ; enquanto não for zero, repete

conversor_tecla:
	MOV  R0, MULTI	   		       ; serve para a fórmula de conversão
	MUL  R2, R0        		       ; fórmula para converter o valor da tecla premida
	ADD  R2, R3        		       ; fórmula para converter o valor da tecla premida

	POP  R1
	POP  R0
	RET

; **************************************************************************************
; * NADA: Teclas não funcionais do teclado. Não alteram o estado do jogo.
; *
; **************************************************************************************
nada:
	RET

; **************************************************************************************
; * SEM_TECLA: Se nenhuma tecla for premida, então coloca a direção da nave a 0, de modo
; * 		   a que as teclas 0 e 2 funcionem em regime contínuo.
; *
; **************************************************************************************
sem_tecla:
	PUSH R0
	PUSH R1

	MOV  R0, direcao_nave
	MOV  R1, 0
	MOV  [R0], R1

	POP  R1
	POP  R0
	RET
	
; **************************************************************************************
; * MOVE_ESQ: Verifica o estado do jogo, para a nave ser movida para a esquerda se e só 
; * 		  se o jogo estiver a decorrer. Atualiza a variável da direção da nave, de
; * 		  de modo a que esta se mova para a direção pertendida (esquerda).
; *
; **************************************************************************************
move_esq:
	PUSH R0
    PUSH R1					
    PUSH R2						
    PUSH R3							
 
	MOV  R1, ON_GAME				; estado do jogo, durante
	MOV  R2, estado_jogo
	MOV  R3, [R2]					; variável do esatdo do jogo
	CMP  R3, R1					    ; o jogo está a decorrer?
	JNE  nao_move_esq				; se não, a nave não anda para a esquerda
	
	MOV  R0, direcao_nave			; variável da direção da nave	
	MOV  R1, ESQ					
	MOV  [R0], R1					; atualiza a variável para a nave se mover para a esquerda

nao_move_esq:					
    POP  R3							
    POP  R2							
    POP  R1	
	POP  R0
    RET

; **************************************************************************************
; * MOVE_DIR: Verifica o estado do jogo, para a nave ser movida para a direita se e só 
; * 		  se o jogo estiver a decorrer. Atualiza a variável da direção da nave, de
; * 		  de modo a que esta se mova para a direção pertendida (direita).
; *
; **************************************************************************************
move_dir:
	PUSH R0
    PUSH R1						
    PUSH R2							
    PUSH R3									
	
	MOV  R1, ON_GAME				; estado do jogo, durante
	MOV  R2, estado_jogo
	MOV  R3, [R2]					; variável do estado do jogo
	CMP  R3, R1						; o jogo está a decorrer?
	JNE  nao_move_dir				; se não, a nave não anda para a direita
	
	MOV  R0, direcao_nave			; variável da direção da nave
	MOV  R1, DIR
	MOV  [R0], R1					; atualiza a variável para a nave se mover para a esquerda

nao_move_dir:						
    POP  R3							
    POP  R2							
    POP  R1	
	POP  R0
    RET

; **************************************************************************************
; * MISSIL: Faz disparar um míssil da nave e só dispara de novo quando esse tiver 
; *         chegado ao seu alcance.
; * 
; **************************************************************************************	
missil:
	PUSH R0							
	PUSH R1	
	PUSH R2
	
	MOV  R0, estado_jogo
	MOV  R1, [R0]
	MOV  R2, ON_GAME
	CMP  R1, R2
	JNE  sai_missil
	
	MOV  R0, estado_missil 				
	MOV  R1, [R0]					; estado do míssil
	CMP  R1, 0						
	JNZ  sai_missil					; se estiver a 1, então o míssil pode ser criado
	MOV  R1, 1
	MOV  [R0], R1					; se não estiver a 1, o estado vai mudar
	

sai_missil:	
	POP  R2
	POP  R1							
	POP  R0						
	RET
	
; **************************************************************************************
; * GAME_ON: Inicia o jogo, reproduzindo o vídeo de fundo, som de fundo e desenha a nave
; * 		na sua posição inicial.   
; *
; **************************************************************************************
game_on:
	PUSH R0
	PUSH R1
	PUSH R2
	PUSH R3
	PUSH R6
	PUSH R7

	MOV R0, MENU_INICIAL			; estado do jogo, menu inicial, antes do começo do mesmo
	MOV R1, estado_jogo		
	MOV R2, [R1]					; variável do estado do jogo
	CMP R2, R0						; o jogo encontra-se no menu principal?
	JEQ comeca
	
	MOV  R0, GAME_OVER				; estado do jogo, terminado
	CMP  R2, R0						; o jogo encontra-se terminado?
	JNE  sai_game_on				; se não, então não inicia o jogo
	
comeca:	
	MOV  R1, APAGA_ECRAS
	MOV  [R1], R2

	MOV  R0, APAGA_FUNDO
	MOV  R1, 0
	MOV  [R0], R1

	MOV  R7, ENERGIA
	MOV  R0, nivel_energia
	MOV  [R0], R7
	CALL converte_deci				; escreve a energia inicial nos displays
	
	MOV  R0, SOM_MENU
	MOV  R1, TERMINA_VID_SOM
	MOV  [R1], R0					; termina o som de início 
	
	MOV  R0, SOM_OVER
	MOV  [R1], R0					; termina o som de game over

	MOV  R0, 0
	MOV  R1, FUNDO_VID_SOM
	MOV  [R1], R0					; inicia a reprodução do vídeo de fundo do jogo
	
	MOV  R0, 1
	MOV  [R1], R0 					; inicia a reprodução do som de fundo do jogo 
	
	MOV  R1, LOOP_VID
	MOV  [R1], R0					; reproduz o som de fundo do jogo em ciclo, até ser parado
	
	MOV  R0, 0
	MOV  [R1], R0					; reproduz o vídeo de fundo do jogo em ciclo, até ser parado
	
	MOV  R0, ha_missil
	MOV  R1, 0
	MOV  [R0], R1
	
	MOV  R0, 0
	MOV  R1, ovni1
	ADD  R1, OVNI6
	MOV  [R1], R0

	MOV  R0, 0
	MOV  R1, ovni2
	ADD  R1, OVNI6
	MOV  [R1], R0

	MOV  R0, 0
	MOV  R1, ovni3
	ADD  R1, OVNI6
	MOV  [R1], R0

	MOV  R0, 0
	MOV  R1, ovni4
	ADD  R1, OVNI6
	MOV  [R1], R0	
	
	MOV  R1, nave
	ADD  R1, TABELA
	MOV  R2, COLUNA_NAVE
	MOV  [R1], R2
	
	MOV  R0, nave
	MOV  R11, 1	
	MOV  R6, 0						; ecrã
    CALL desenha	                ; desenha a nave na posição inicial		    
   
    MOV R0, ON_GAME					; estado do jogo, durante
	MOV R1, estado_jogo
	MOV [R1], R0					; atualiza a variável do estado do jogo

sai_game_on:
	POP  R7
	POP  R6
	POP  R3
	POP  R2
	POP  R1
	POP  R0
	RET

; **************************************************************************************
; * PAUSA: Pausa e despausa o jogo, parando de reproduzir o vídeo de fundo e som de fundo. 
; * 	   Seleciona a imagem de fundo de pausa e som. Só é possível pausar se 
; *        estiver ON_GAME, ou seja, se o jogo estiver a decorrer.    
; *
; **************************************************************************************	
pausa:
	PUSH R0
	PUSH R1
	PUSH R2
	PUSH R3
	PUSH R4

	MOV  R0, estado_jogo			; variável do estado do jogo
	MOV  R1, [R0]
	MOV  R2, ON_GAME				; estado do jogo, durante
	CMP  R1, R2						; o jogo encontra-se a decorrer?
	JNE  verifica_pausa				; se não, não pausa
	
	MOV  R2, ON_PAUSE
	MOV  [R0], R2
	
	MOV  R4, PAUSA_VID_SOM
	MOV  R3, 0
	MOV  [R4], R3					; pausa o vídeo de background do jogo
	
	MOV  R3, 1
	MOV  [R4], R3					; pausa o som de background do jogo
	
	MOV  R4, IMAGEM_FRONTAL
	MOV  R3, IMAGEM_PAUSA			; seleciona a imagem frontal de pausa
	MOV  [R4], R3
	
	JMP  nao_pausa
	
verifica_pausa:	
	MOV  R2, ON_PAUSE
	CMP  R1, R2
	JNE  nao_pausa

	MOV  R4, APAGA_FRONTAL
	MOV  [R4], R3					; apaga a imagem frontal de pausa
	
	MOV  R4, CONTINUA_VID_SOM
	MOV  R3, 1
	MOV  [R4], R3					; continua o som de background do jogo
	
	MOV  R3, 0
	MOV  [R4], R3					; continua o vídeo de background do jogo
	
	MOV  R1, ON_GAME
	MOV  [R0], R1
	
nao_pausa:
	POP  R4
	POP  R3
	POP  R2
	POP  R1
	POP  R0
	RET

; **************************************************************************************
; * TERMINA: Termina o jogo em qualquer estado do jogo, exceto a   
; *
; **************************************************************************************
termina:
	PUSH R0
	PUSH R1
	PUSH R2
	PUSH R3
	PUSH R4

	MOV  R0, estado_jogo
	MOV  R1, [R0]
	MOV  R2, MENU_INICIAL
	CMP  R1, R2
	JEQ  sai_termina
	
	MOV  R2, GAME_OVER
	CMP  R1, R2
	JEQ  sai_termina
	
	MOV  R1, APAGA_ECRAS
	MOV  [R1], R2
	
	MOV  R1, APAGA_FRONTAL
	MOV  R2, IMAGEM_PAUSA
	MOV  [R1], R2					; apaga a imagem frontal de pausa					
	
	MOV  R2, TERMINA_VID_SOM
	MOV  R3, 0						
	MOV  [R2], R3					; termina a reprodução do vídeo de background do jogo
	
	MOV  R3, 1
	MOV  [R2], R3					; termina a reprodução do som de background do jogo
	
	MOV  R2, FUNDO_IMAGEM
	MOV  R3, IMAGEM_OVER
	MOV  [R2], R3
	
	MOV  R2, FUNDO_VID_SOM
	MOV  R3, SOM_OVER
	MOV  [R2], R3
	
	MOV  R4, GAME_OVER
	MOV  [R0], R4

sai_termina:
	POP  R4
	POP  R3
	POP  R2
	POP  R1
	POP  R0
	RET
	
; **************************************************************************************
; * ATUALIZA_DISPLAYS: Atualiza os displays de acordo com o contador de energia	 
; *
; **************************************************************************************
atualiza_displays:
    PUSH  R0
	PUSH  R1
	PUSH  R5
	PUSH  R7
	PUSH  R11
	
    MOV  R5, nivel_energia			
	MOV  R7,[R5]					; variável do contador de energia 
	
	MOV  R0, ENERGIA
	CMP  R7, R0
	JEQ  sai_display
	
	ADD  R7, R6						
	MOV  [R5], R7					; atualiza a variavel do contador de energia
	CALL converte_deci		
	
	CMP  R7, 0						; o contador de energia já chegou a 0?
	JNZ  sai_display
    
	MOV  R0, ha_missil
	MOV  R1, 0
	MOV  [R0], R1
	
	ADD  R10, OVNI6
	MOV  R0, 0
	MOV  [R10], R0
	
	MOV  R0, GAME_OVER				; estado do jogo, terminado 
	MOV  R1, estado_jogo			
	MOV  [R1], R0					; atualiza a variavel estado de jogo

	MOV  R0, APAGA_ECRAS
	MOV  [R0], R1
	
	MOV  R0, TERMINA_VID_SOM		
	MOV  R1, 0
	MOV  [R0], R1					; termina a reprodução do vídeo do background do jogo
	
	MOV  R1, 1
	MOV  [R0], R1					; termina a reprodução do som do background do jogo
	
	MOV  R0, FUNDO_IMAGEM
	MOV  R1, 1
	MOV  [R0], R1					; seleciona o a imagem de fundo do game over
	
	MOV  R0, FUNDO_VID_SOM
	MOV  R1, SEM_ENERGIA
	MOV  [R0], R1					; reproduz o som do game over
	
sai_display:
    POP  R11
	POP  R7
	POP  R5
	POP  R1
	POP  R0
	RET

; **************************************************************************************
; * CONVERTE_DECI: Converte em decimal o valor do contador de energia e escreve-o 
; * 			   nos displays.
; *
; **************************************************************************************
; inicializações	
converte_deci:	
	PUSH R0					
	PUSH R1					
	PUSH R2					
	PUSH R3					
	PUSH R4	
	PUSH R5

	MOV  R5, nivel_energia
	
	MOV  R0, FATOR			; fator conversor em decimal
	MOV  R1, DIV_FATOR		; valor que divide o fator até ser 1
	MOV  R2, 0				; resultado final (convertido)
	
loop_converte:
	MOV  R3, [R5]			; guarda o valor do contador 
	MOD  R3, R0				; fórmula de conversão em decimal
	DIV  R0, R1				; fórmula de conversão em decimal
	MOV  R4, R3				; fórmula de conversão em decimal
	DIV  R4, R0				; fórmula de conversão em decimal
	SHL  R2, 4				; fórmula de conversão em decimal
	OR   R2, R4				; fórmula de conversão em decimal
	CMP  R0, 1				; repete ciclo até fator ser 1
	JNE  loop_converte
	MOV  R0, DISPLAYS		; endereço do periférico dos displays
	MOV  [R0], R2			; escreve nos displays o valor do contador convertido em decimal
	
	POP  R5
	POP  R4				
	POP  R3					
	POP  R2					
	POP  R1					
	POP  R0					
	RET						

; **************************************************************************************
; * APAGA_MISSIL: Apaga o míssil desenhado anteriormente no ecrã.
; * Argumentos: R0 - variável com a linha em que o míssil está
; *				R1 - variável com a coluna em que o míssil está 
; *
; **************************************************************************************
apaga_missil:
	PUSH R0
	PUSH R1
	PUSH R2
	PUSH R3

	MOV R0, SEL_ECRA
    MOV R1, 0
    MOV [R0], R1

	MOV  R0, linha_atual_missil
	MOV  R1, [R0]
	MOV  R0, coluna_atual_missil
	MOV  R2, [R0]
	MOV  R3, 0						; coloca a cor do pixel a 0 para o apagar
	CALL escreve_pixel

	POP R3
	POP R2
	POP R1
	POP R0	
	RET

; **************************************************************************************
; * CRIA_MISSIL: Verifica se a tecla 1 foi premida e, se sim, cria um míssil ativando,
; * 			 através do 1, a variável ha_missil para indicar que há um míssil no
; *				 ecrã. Esta variável so é desativada quando o míssil chega ao seu alcance.
; *
; **************************************************************************************
cria_missil:
	PUSH R0
	PUSH R1
	PUSH R2
	PUSH R3
	PUSH R6

	MOV  R0, estado_missil					
	MOV  R1, [R0]					; estado do míssil
	CMP  R1, 0						; a tecla 1 foi premida?
	JZ   sai_cria_missil			; se não, o míssil nao é criado
	MOV  R1, 0                      ; coloca a variável do estado_missil a 0 para indicar que 
	MOV  [R0], R1					; já foi criado um míssil
	
	MOV  R2, ha_missil				
	MOV  R3, [R2]
	CMP  R3, 0						; há um míssil no ecrã?
	JNZ  sai_cria_missil			; se sim, não se vai criar outro até este desaparecer
	
	MOV  R3, 1						; cria um míssil, ativando a variável
	MOV  [R2], R3	
	
	MOV  R6, DECREMENTA_5
	CALL atualiza_displays
	
	MOV  R1, SOM_MISSIL					   
	MOV  R0, FUNDO_VID_SOM
	MOV  [R0], R1				    ; inicia a reprodução do som missil
	
	MOV  R3, nave					
	ADD  R3, TABELA
	MOV  R2, [R3]					; coluna em que a nave está

	ADD  R2, MISSIL 				; coluna em que o míssil deve ser disparado, 3 colunas à frente
	MOV  R3, coluna_atual_missil	; coluna atual do míssil
	MOV  [R3], R2					; atualiza a varíavel com a nova coluna onde o míssil está
	
	MOV  R3, linha_atual_missil		; linha em que o míssil está
	MOV  R2, LINHA_MISSIL			; linha inicial por onde o míssil deve ser disparar
	MOV  [R3], R2					; atualiza a variável com a nova linha em que o míssil está
	
sai_cria_missil:
	POP  R6
	POP  R3
	POP  R2
	POP  R1
	POP  R0
	RET	

; **************************************************************************************
; *	MEXE_MISSIL: Desenha e mexe o míssil no ecrã até chegar ao seu alcance (12 movimentos).
; * 			 Só mexe se houver míssil, ou seja, a variável ha_missil estiver ativada
; * 			 através do 1.
; *
; **************************************************************************************
mexe_missil:
	PUSH R0
	PUSH R1
	PUSH R2
	PUSH R3
	PUSH R4
	PUSH R5
	PUSH R6
	
	MOV  R0, ha_missil				 
	MOV  R1, [R0]					; há um missil no ecrã?
	CMP  R1, 0						; se não, não é desenhado nenhum míssil, bem mexe
	JZ   nao_mexe
	
mexendo: 							; desenha e mexe o míssil pelo ecrã
	MOV R0, SEL_ECRA
    MOV R1, 0
    MOV [R0], R1
	
    MOV  R0, linha_atual_missil			
    MOV  R1, [R0]					; linha em que o míssil está
	MOV  R4, coluna_atual_missil	; coluna em que o míssil está
	MOV  R2, [R4]
	
    SUB  R1, 1               		; próxima linha
	MOV  [R0], R1
	CALL alcance_missil	
	
	MOV  R4, pinta_missil
	MOV  R5, [R4]
	MOV  R6, COR_CANETA
	MOV  [R6], R5	
	
	MOV  R3, 1
    CALL escreve_pixel        		; desenha o míssil na próxima linha
	JMP  nao_mexe
	
nao_mexe:
	POP  R6
	POP  R5
	POP  R4
	POP  R3
	POP  R2
	POP  R1
	POP  R0
	RET

; **************************************************************************************
; *	ALCANCE_MISSIL: Verifica se o míssil já chegou ao seu alcance e, se sim, desativa a 
; * 				variável ha_missil através do 0, de modo a que este desapareça do ecrã
; *					e um próximo seja disparado por meio da tecla 1.
; *
; **************************************************************************************
alcance_missil:
	PUSH R0
	PUSH R1
	PUSH R2
	PUSH R3

	MOV  R0, linha_atual_missil				
	MOV  R1, [R0]					; linha em que o míssil está
	MOV  R2, ALCANCE				; alcance do míssil (12 movimentos)
	CMP  R1, R2						; já está na linha de alcance?
	JLE  chegou						; se sim, desativa a variável ha_missil
	JMP  sai_alcance	
	
chegou:	
	MOV  R0, ha_missil
	MOV  R1, 0
	MOV  [R0], R1

sai_alcance:
	POP  R3
	POP  R2
	POP  R1
	POP  R0
	RET

; **************************************************************************************
; * MISSIL_OVNI: Verifica se houve uma colisão entre missil e ovni.
; *
; **************************************************************************************
missil_ovni:
	PUSH R0
	PUSH R1
	PUSH R2
	PUSH R3
	PUSH R4
	PUSH R5
	PUSH R6
	PUSH R7
	PUSH R8
	PUSH R10

	MOV  R0, ha_missil
	MOV  R1, [R0]
	CMP  R1, 0
	JZ   sai_missil_ovni

	MOV  R1, [R10]					; linha atual do ovni
	
	ADD  R10, OVNI2
	MOV  R2, [R10]					; coluna atual do ovni
	
	MOV  R3, linha_atual_missil
	MOV  R7, [R3]
	MOV  R4, coluna_atual_missil
	MOV  R8, [R4]
	
	CMP  R7, R1
	JGT  sai_missil_ovni
	
	ADD  R10, OVNI6
	MOV  R5, [R10]
	ADD  R5, OVNI4					; desenho do ovni
	MOV  R6, [R5]					; altura do ovni
	SUB  R1, R6
	CMP  R7, R1
	JLT  sai_missil_ovni
	
	CMP  R8, R2
	JLT  sai_missil_ovni
	
	ADD  R5, OVNI2
	MOV  R6, [R5]					; largura do ovni
	ADD  R2, R6
	CMP  R8, R2
	JGT  sai_missil_ovni
	
	ADD  R10, OVNI2
	MOV  R1, [R10]					; tipo do ovni (bom ou mau)
	CMP  R1, 0 
	JZ 	 ha_colisao
	
incrementa: 
	MOV  R2, FUNDO_VID_SOM
	MOV  R3, MORE_ENERGY
	MOV  [R2], R3
	
	MOV  R6, INCREMENTA_5
	CALL atualiza_displays

ha_colisao:	
	MOV  R1, DESTRUIDO
	MOV  [R10], R1

	MOV  R2, 0
	MOV  R1, ha_missil
	MOV  [R1], R2
	
sai_missil_ovni:
	POP  R10
	POP  R8
	POP  R7
	POP  R6
	POP  R5
	POP  R4
	POP  R3
	POP  R2
	POP  R1
	POP  R0
	RET

; **************************************************************************************
; * NAVE_OVNI: Verifica se houve uma colisão entre nave e ovni.
; *
; **************************************************************************************
nave_ovni:
	PUSH R0
	PUSH R1
	PUSH R2
	PUSH R3
	PUSH R4
	PUSH R5
	PUSH R6
	PUSH R7
	PUSH R10


	
	POP  R10
	POP  R7
	POP  R6
	POP  R5
	POP  R4
	POP  R3
	POP  R2
	POP  R1
	POP  R0
	RET
; **************************************************************************************
; * DESENHA: Escreve todos os pixels da nave no ecrã.
; *
; **************************************************************************************
desenha:
    PUSH R1							
    PUSH R2							
    PUSH R3							
	PUSH R4							
	PUSH R5						
	PUSH R6						
	PUSH R7
	PUSH R8
	PUSH R9
	PUSH R10

	MOV  R1, SEL_ECRA
	MOV  [R1], R6

	MOV  R1, [R0]					; linha onde a nave deve ser desenhada
	ADD  R0, TABELA
	MOV  R2, [R0]					; coluna onde a nave deve ser desenhada
	MOV  R10, R2
	ADD  R0, TABELA
	MOV  R4, [R0]					; altura
	ADD  R0, TABELA
	MOV  R5, [R0]					; largura	
	MOV  R8, R5
	
	ADD  R0, TABELA
	
	CMP  R11, 0
	JZ   apaga_desenho
	
	MOV  R6, [R0]					; cor da caneta
	MOV  R7, COR_CANETA
	MOV  [R7], R6					; muda a cor da caneta para a prentendida
	ADD  R0, TABELA
	JMP  desenha_coluna
	
apaga_desenho:
	ADD  R0, TABELA
	MOV  R6, 0
	MOV  R7, COR_CANETA
	MOV  [R7], R6					; muda a cor da caneta para a prentendida
	
desenha_coluna:						; este ciclo vai desenhar a nave linha a linha	
	MOVB  R3, [R0]
	
	CALL escreve_pixel
	ADD  R0, 1 
	ADD  R2, 1
	SUB  R8, 1
	JNZ  desenha_coluna

desenha_linha:
	SUB  R1, 1
	SUB  R4, 1
	MOV  R2, R10
	MOV  R8, R5
	CMP  R4, 0
	JNZ  desenha_coluna
	
desenhada:	
	POP	 R10
	POP  R9
	POP  R8
	POP  R7						
	POP  R6					
    POP  R5						
	POP  R4	 					
	POP  R3					
    POP  R2						
    POP  R1							
    RET

; **************************************************************************************
; * ESCREVE_PIXEL: Rotina que escreve um pixel na linha e coluna indicadas.
; * Argumentos:   R1 - linha
; *               R2 - coluna
; *               R3 - cor do pixel
; *
; **************************************************************************************
escreve_pixel:
    PUSH R0	
	PUSH R4

	MOV  R4, 32
	CMP  R1, R4
	JGE  sai_escreve_pixel

	MOV  R4, 64
	CMP  R2, R4
	JGE  sai_escreve_pixel
	
	MOV  R4, 0
	CMP  R2, R4
	JLT  sai_escreve_pixel

    MOV  R0, DEFINE_LINHA
    MOV  [R0], R1                   ; seleciona a linha

    MOV  R0, DEFINE_COLUNA
    MOV  [R0], R2                   ; seleciona a coluna

    MOV  R0, DEFINE_PIXEL
    MOV  [R0], R3                   ; altera a cor do pixel na linha e coluna selecionadas


sai_escreve_pixel:
	POP  R4
    POP  R0							
    RET


	
