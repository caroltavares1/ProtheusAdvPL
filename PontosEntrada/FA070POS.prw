#Include 'Protheus.ch'


/*
==========================================================================
|PE   : FA070POS()                                                       |
|Desc : Manipula variáveis antes da montagem da tela de baixas a receber |
|       Neste caso: Fixa o motivo de baixa como "Credito CC"             |
|Autor: Carolina Tavares --- 29/01/2024                                  |
==========================================================================
*/
User Function FA070POS()
	Local aArea := GetArea()

	cMotBx := 'CREDITO CC'

	RestArea(aArea)
Return
