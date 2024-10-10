//Bibliotecas
#Include "Protheus.ch"

/*
==========================================================================
|PE   : FA080POS()                                                       |
|Desc : Manipula variáveis antes da montagem da tela de baixas a pagar   |
|       Neste caso: Fixa o motivo de baixa como "Debito CC"              |
|Autor: Carolina Tavares --- 29/01/2024                                  |
==========================================================================
*/
User Function FA080POS()
	Local aArea    := GetArea()

	cMotBx := 'DEBITO CC'

	RestArea(aArea)
Return
