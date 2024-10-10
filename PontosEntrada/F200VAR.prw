#INCLUDE "PROTHEUS.CH"

//-------------------------------------------------------------------------------
/*/{Protheus.doc} F200VAR
Manipular as informações (variáveis) no retorno do Cnab a Receber (FINA200).

@PARAMIXB aDados[1] = Número do Título   | Variavel de origem: cNumTit
          aDados[2] = Data da Baixa       | Variavel de origem: dBaixa
          aDados[3] = Tipo do Título      | Variavel de origem: cTipo
          aDados[4] = Nosso Número       | Variavel de origem: cNsNum
          aDados[5] = Valor da Despesa    | Variavel de origem: nDespes
          aDados[6] = Valor do Desconto   | Variavel de origem: nDescont
          aDados[7] = Valor do Abatimento | Variavel de origem: nAbatim
          aDados[8] = Valor Recebido      | Variavel de origem: nValRec
          aDados[9] = Juros               | Variavel de origem: nJuros
          aDados[10] = Multa              | Variavel de origem: nMulta
          aDados[11] = Outras Despesas    | Variavel de origem: nOutrDesp
          aDados[12] = Valor do Credito   | Variavel de origem: nValCc
          aDados[13] = Data do Credito    | Variavel de origem: dDataCred
          aDados[14] = Ocorrência        | Variavel de origem: cOcorr
          aDados[15] = Motivo do banco    | Variavel de origem: cMotBan
          aDados[16] = Linha Inteira      | Variavel de origem: xBuffer
          aDados[17] = Data de Vencimento | Variavel de origem: dDtVc

/*/
//-------------------------------------------------------------------------------

/*
==========================================================================
|PE   : F200VAR()                                                        |
|Desc : Ajusta o valor recebido do retorno do CNAB de acordo com o juros |
|Autor: Carolina Tavares --- 31/01/2024                                  |
==========================================================================
*/

User Function F200VAR()

	Local aDados     := PARAMIXB
	Local aArea      := GetArea()

	nValRec := nValRec + nJuros

	aDados[1][8] := nValRec

	RestArea(aArea)

Return(aDados)
