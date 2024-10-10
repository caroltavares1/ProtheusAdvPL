#include "protheus.ch"

/*
==========================================================================
|Func : CONSAPI()                                                        |
|Desc : Consume APi e grava os respectivos campos na                     |
|       tabela ZLA (Laudos T�cnicos)                                     |
|Autor: Carolina Tavares --- 11/12/2023                                  |
==========================================================================
*/

User Function CONSAPI()


	Local cBaseUrl := "http://177.39.232.66:9000"
	Local cPath    := '/api/ColetaCep/ObterInspecoesOP'
	Local cJson    := ''
	local oJson
	Local cRet     := '{ "OrdProd": '
	private aDados  := {}
	private aDados2 := {}

	oJson  := JsonObject():New()
	oParse := JsonObject():New()

	cJson := '{'                                        + CRLF
	//cJson += '  "cdOp": "20750201001",  '               + CRLF
	cJson += '  "cdOp": "20007701001",  '               + CRLF
	cJson += '  "qtdRegistro": "99999999999999999999"'  + CRLF
	cJson += '}'


	//Cabe�alho
	aHeadPar := {}
	aAdd(aHeadPar, "Content-Type: application/json")

	//Monta a conex�o com o servidor REST
	oRestClient := FWRest():New(cBaseUrl) // Ex.: "http://aaaaaaa/v1"
	oRestClient:setPath(cPath) // Ex.: "/produtos"
	oRestClient:SetPostParams(cJson)

	//Publica a altera��o, e caso n�o d� certo, mostra erro
	If ! oRestClient:Post(aHeadPar)
		Aviso('Aten��o', 'Houve erro na atualiza��o no servidor!' + CRLF + ;
			'Contate o Administrador!' + CRLF + ;
			"Erro: " + oRestClient:GetLastError() + CRLF + CRLF + ;
			"Result: ", {'OK'}, 03)
	Else
		//Transforma o resultado da consulta em Json
		result := oRestClient:GetResult()
		cRet += result + '}'
		ret := oJson:FromJson(cRet)
		if ValType(ret) == "C"
			Aviso('Aten��o', 'Falha ao obter o objeto Json' + CRLF + ;
				'Contate o Administrador!' + CRLF + ;
				"Erro: " + oRestClient:GetLastError() + CRLF + CRLF + ;
				"", {'OK'}, 03)
			return
		Else
			//Chama a fun��o pra separar os itens
			u_PrintJson(oJson)
			FreeObj(oJson)
		EndIf
	EndIf
	GRAVADATA()

Return


/* Refer�ncia: https://tdn.totvs.com/display/tec/Classe+JsonObject */

user function PrintJson(jsonObj)
	local i, j
	local names
	local lenJson
	local item
	Local nPosDesc := 0

	lenJson := len(jsonObj)

	if lenJson > 0
		for i := 1 to lenJson
			u_PrintJson(jsonObj[i])
		next
	else
		names := jsonObj:GetNames()
		If len(names) > 1
			nPosProd := aScan(names, {|x| x=='cdProduto'})
			nPosDescVar := aScan(names, {|x| x=='descVariavel'})

        /*
            O If abaixo agrupa todas as combina��es de produtos e descri��es vari�veis poss�veis
            Isso ser� usado para varrer novamente os registros e agrupar os valores corretamente.
        */
			nPos := aScan(aDados, {|x| x[1] == jsonObj[names[nPosProd]]})//V� se o produto j� foi adicionado
			If nPos == 0 // se n�o foi, adiciona e adiciona tamb�m a descri��o vari�vel
				aadd(aDados, {jsonObj[names[nPosProd]]})
				nPos := aScan(aDados, {|x| x[1] == jsonObj[names[nPosProd]]})
				aadd(aDados[nPos], jsonObj[names[nPosDescVar]]) //descri��o vari�vel
			else //caso j� tenha o produto
				//varre o array pra saber se a combina��o produto e descri��o j� existe
				nPosDesc := aScan(aDados, {|x| x[2] == jsonObj[names[nPosDescVar]]})
				If nPosDesc == 0 // se n�o, adiciona
					aadd(aDados, {jsonObj[names[nPosProd]]})
					nPos := aScan(aDados, {|x| x[1] == jsonObj[names[nPosProd]]})
					aadd(aDados[len(aDados)], jsonObj[names[nPosDescVar]])

				EndIf
			EndIF

        /* Adiciona os outros valores em um outro array que ser� varrido e ordenado depois */

			nPoslse   := aScan(names, {|x| x=='LSE'})
			nPoslie   := aScan(names, {|x| x=='LIE'})
			nPosMedia := aScan(names, {|x| x=='media'})
			nPosValor := aScan(names, {|x| x=='valor'})
			aadd(aDados2, {jsonObj[names[nPosProd]],;
				jsonObj[names[nPosDescVar]],;
				jsonObj[names[nPoslse]],;
				jsonObj[names[nPoslie]],;
				jsonObj[names[nPosMedia]],;
				jsonObj[names[nPosValor]]})

		Else
			for i := 1 to len(names)
				item := jsonObj[names[i]]
				if ValType(item) == "A"
					for j := 1 to len(item)
						//chama a fun��o para cada item
						u_PrintJson(item[j])
					next j
				endif
			next i
		EndIf
	endif
return


/*  Agrupa os outros valores al�m das descri��es vari�veis
    e grava na tabela ZLA
*/

STATIC Function GRAVADATA()
	Local aArea := GetArea()
	Local aRet := {}
	Local i, j
	Local cLaudo
	Local cDescr := ''



    /*
        aDados[i][1] -> C�digo do produto
        aDados[i][2] -> Descri��o Vari�vel
        aDados[i][3] -> LSE (m�nimo esperado)
        aDados[i][4] -> LIE (m�ximo esperado)
        aDados[i][5] -> M�dia
        aDados[i][6] -> Valor
    */

	for i := 1 to len(aDados)
		for j := 1 to len(aDados2)
			if j==1
				aadd(aDados[i], {})
				aadd(aDados[i], {})
				aadd(aDados[i], {})
				aadd(aDados[i], {})
			EndIf
			if aDados2[j][1] == aDados[i][1] .AND. aDados2[j][2] == aDados[i][2]
				aadd(aDados[i][3], aDados2[j][3])
				aadd(aDados[i][4], aDados2[j][4])
				aadd(aDados[i][5], aDados2[j][5])
				aadd(aDados[i][6], aDados2[j][6])

			EndIf
		next j

		//Ordena os valores
		aSortLSE   := aSort(aDados[i][3])
		aSortLIE   := aSort(aDados[i][4])
		aSortMedia := aSort(aDados[i][5])
		aSortValor := aSort(aDados[i][6])

		DbSelectArea('ZLA')
		ZLA->(DbSetOrder(1))

		//ZLA_NLAUDO
		If i == 1 //
			DbSelectArea('SG2')
			SG2->(DbSetOrder(3))
			If SG2->(DbSeek(FWxFilial('SG2') + aDados[i][1]))
				If AllTrim(SG2->G2_DESCRI) == 'TERMOFORMAR'
					cDescr := 'T'
				ElseIf AllTrim(SG2->G2_DESCRI) == 'IMPRIMIR'
					cDescri := 'I'
				EndIf
			EndIf
			SG2->(DbCloseArea())
            /*  Nome do Laudo: Data em formato: AAAA.MM.DD.HHMMSS (NOME DA FILIAL)
            Exemplo: 2023.12.13.105609 NE
            */
			cLaudo := cValToChar(year(date())) + '.' + cValToChar(month(date())) + '.' + cValToChar(day(date()))+ '.' + replace(Time(), ':', '') +;
				" " +ALLTRIM(SM0->M0_FILIAL)
			If ! ZLA->(DbSeek(FWxFilial('ZLA') + cLaudo)) //se n�o achou
				RecLock("ZLA", .T.) //inclui
				ZLA->ZLA_FILIAL := FWxFilial('ZLA')
				ZLA->ZLA_NLAUDO := cLaudo
				ZLA->ZLA_PROCOD := aDados[i][1] //C�digo do produto
				ZLA->ZLA_TIPPRD := cDescr

				ZLA->(MsUnlock())
			EndIf
		EndIF

		DO CASE
		CASE aDados[i][2] == 'PESO'

			If ZLA->(DbSeek(FWxFilial('ZLA') + cLaudo))
				RecLock("ZLA", .F.) //ALTERA
				ZLA->ZLA_FILIAL := FWxFilial('ZLA')
				ZLA->ZLA_PROCOD := aDados[i][1] //C�digo do produto
				ZLA->ZLA_XPSME  := aSortLSE[1] //Peso m�nimo esperado
				ZLA->ZLA_XPSPE  := valorMedio(aSortMedia) //padr�o esperado
				ZLA->ZLA_XPSXE  := aSortLIE[len(aSortLIE)] //peso m�ximo esperado
				ZLA->ZLA_XPSMR  := aSortValor[1] //Peso m�nimo resultado
				ZLA->ZLA_XPSPR  := valorMedio(aSortValor) //padr�o resultado
				ZLA->ZLA_XPSXR  := aSortValor[len(aSortValor)] //peso m�ximo resultado
				ZLA->(MsUnlock())
			EndIf
		CASE aDados[i][2] == 'ALTURA TOTAL'
			If ZLA->(DbSeek(FWxFilial('ZLA') + cLaudo))
				RecLock("ZLA", .F.) //ALTERA
				ZLA->ZLA_FILIAL := FWxFilial('ZLA')
				ZLA->ZLA_PROCOD := aDados[i][1] //C�digo do produto
				ZLA->ZLA_XATME  := aSortLSE[1] //altura total m�nima esperado
				ZLA->ZLA_XATPE  := valorMedio(aSortMedia) //padr�o esperado
				ZLA->ZLA_XATXE  := aSortLIE[len(aSortLIE)] //altura total m�xima esperado
				ZLA->ZLA_XATMR  := aSortValor[1] //altura total m�nima resultado
				ZLA->ZLA_XATPR  := valorMedio(aSortValor) //padr�o resultado
				ZLA->ZLA_XATXR  := aSortValor[len(aSortValor)] //altura total m�xima resultado
				ZLA->(MsUnlock())
			EndIf
		CASE aDados[i][2] == 'VOLUME UTIL'
			If ZLA->(DbSeek(FWxFilial('ZLA') + cLaudo))
				RecLock("ZLA", .F.) //ALTERA
				ZLA->ZLA_FILIAL := FWxFilial('ZLA')
				ZLA->ZLA_PROCOD := aDados[i][1] //C�digo do produto
				ZLA->ZLA_XVUME  := aSortLSE[1] //volume �til m�nimo esperado
				ZLA->ZLA_XVUPE  := valorMedio(aSortMedia) //padr�o esperado
				ZLA->ZLA_XVUXE  := aSortLIE[len(aSortLIE)] //volume �til m�ximo esperado
				ZLA->ZLA_XVUMR  := aSortValor[1] //volume �til m�nimo resultado
				ZLA->ZLA_XVUPR  := valorMedio(aSortValor) //padr�o resultado
				ZLA->ZLA_XVUXR  := aSortValor[len(aSortValor)] //volume �til m�ximo resultado
				ZLA->(MsUnlock())
			EndIf
		CASE aDados[i][2] == 'CRUSH DE ESMAGAMENTO'
			If ZLA->(DbSeek(FWxFilial('ZLA') + cLaudo))
				RecLock("ZLA", .F.) //ALTERA
				ZLA->ZLA_FILIAL := FWxFilial('ZLA')
				ZLA->ZLA_PROCOD := aDados[i][1] //C�digo do produto
				ZLA->ZLA_XCRME  := aSortLSE[1] //crush m�nimo esperado
				ZLA->ZLA_XCRPE  := valorMedio(aSortMedia) //padr�o esperado
				ZLA->ZLA_XCRXE  := aSortLIE[len(aSortLIE)] //crush m�ximo esperado
				ZLA->ZLA_XCRMR  := aSortValor[1] //crush m�nimo resultado
				ZLA->ZLA_XCRPR  := valorMedio(aSortValor) //padr�o resultado
				ZLA->ZLA_XCRXR  := aSortValor[len(aSortValor)] //crush m�ximo resultado
				ZLA->(MsUnlock())
			EndIf
		CASE aDados[i][2] == 'VOLUME TOTAL'
			If ZLA->(DbSeek(FWxFilial('ZLA') + cLaudo))
				RecLock("ZLA", .F.) //ALTERA
				ZLA->ZLA_FILIAL := FWxFilial('ZLA')
				ZLA->ZLA_PROCOD := aDados[i][1] //C�digo do produto
				ZLA->ZLA_XVTME  := aSortLSE[1] //volume total m�nimo esperado
				ZLA->ZLA_XVTPE  := valorMedio(aSortMedia) //padr�o esperado
				ZLA->ZLA_XVTXE  := aSortLIE[len(aSortLIE)] //volume total m�ximo esperado
				ZLA->ZLA_XVTMR  := aSortValor[1] //volume total m�nimo resultado
				ZLA->ZLA_XVTPR  := valorMedio(aSortValor) //padr�o resultado
				ZLA->ZLA_XVTXR  := aSortValor[len(aSortValor)] //volume total m�ximo resultado
				ZLA->(MsUnlock())
			EndIf
		CASE aDados[i][2] == 'MEDIDAS EXT. DO TOPO'
			If ZLA->(DbSeek(FWxFilial('ZLA') + cLaudo))
				RecLock("ZLA", .F.) //ALTERA
				ZLA->ZLA_FILIAL := FWxFilial('ZLA')
				ZLA->ZLA_PROCOD := aDados[i][1] //C�digo do produto
				ZLA->ZLA_XMETME := aSortLSE[1] //medidas externas m�nima esperado
				ZLA->ZLA_XMETPE := valorMedio(aSortMedia) //padr�o esperado
				ZLA->ZLA_XMETXE := aSortLIE[len(aSortLIE)] //medidas externas m�xima esperado
				ZLA->ZLA_XMETMR := aSortValor[1] //medidas externas m�nima resultado
				ZLA->ZLA_XMETPR := valorMedio(aSortValor) //padr�o resultado
				ZLA->ZLA_XMETXR := aSortValor[len(aSortValor)] //medidas externas m�xima resultado
				ZLA->(MsUnlock())
			EndIf
		CASE aDados[i][2] == 'MEDIDAS DA BASE'
			If ZLA->(DbSeek(FWxFilial('ZLA') + cLaudo))
				RecLock("ZLA", .F.) //ALTERA
				ZLA->ZLA_FILIAL := FWxFilial('ZLA')
				ZLA->ZLA_PROCOD := aDados[i][1] //C�digo do produto
				ZLA->ZLA_XMDBME := aSortLSE[1] //medidas da base m�nima esperado
				ZLA->ZLA_XMDBPE := valorMedio(aSortMedia) //padr�o esperado
				ZLA->ZLA_XMDBXE := aSortLIE[len(aSortLIE)] //medidas da base m�xima esperado
				ZLA->ZLA_XMDBMR := aSortValor[1] //medidas da base m�nima resultado
				ZLA->ZLA_XMDBPR := valorMedio(aSortValor) //padr�o resultado
				ZLA->ZLA_XMDBXR := aSortValor[len(aSortValor)] //medidas da base m�xima resultado
				ZLA->(MsUnlock())
			EndIf
		CASE aDados[i][2] == 'ALTURA DO COLARINHO'
			If ZLA->(DbSeek(FWxFilial('ZLA') + cLaudo))
				RecLock("ZLA", .F.) //ALTERA
				ZLA->ZLA_FILIAL := FWxFilial('ZLA')
				ZLA->ZLA_PROCOD := aDados[i][1] //C�digo do produto
				ZLA->ZLA_XACME  := aSortLSE[1] //altura  m�nima esperado
				ZLA->ZLA_XACPE  := valorMedio(aSortMedia) //padr�o esperado
				ZLA->ZLA_XACXE  := aSortLIE[len(aSortLIE)] //altura m�xima esperado
				ZLA->ZLA_XACMR  := aSortValor[1] //altura  m�nima resultado
				ZLA->ZLA_XACPR  := valorMedio(aSortValor) //padr�o resultado
				ZLA->ZLA_XACXR  := aSortValor[len(aSortValor)] //altura  m�xima resultado
				ZLA->(MsUnlock())
			EndIf
		CASE aDados[i][2] == 'MEDIDAS EXT. DO COLARINHO'
			If ZLA->(DbSeek(FWxFilial('ZLA') + cLaudo))
				RecLock("ZLA", .F.) //ALTERA
				ZLA->ZLA_FILIAL := FWxFilial('ZLA')
				ZLA->ZLA_PROCOD := aDados[i][1] //C�digo do produto
				ZLA->ZLA_XMECME := aSortLSE[1] //medida externa m�nima esperado
				ZLA->ZLA_XMECPE := valorMedio(aSortMedia) //padr�o esperado
				ZLA->ZLA_XMECXE := aSortLIE[len(aSortLIE)] //medida externa m�xima esperado
				ZLA->ZLA_XMECMR := aSortValor[1] //medida externa m�nima resultado
				ZLA->ZLA_XMECPR := valorMedio(aSortValor) //padr�o resultado
				ZLA->ZLA_XMECXR := aSortValor[len(aSortValor)] //medida externa m�xima resultado
				ZLA->(MsUnlock())
			EndIf
		ENDCASE

		ZLA->(DbCloseArea())

	next i

	RestArea(aArea)

return aRet


static function valorMedio(vetor)
	Local media
	Local soma := 0
	Local nX   := 0

	For nX := 1 to len(vetor)
		soma += vetor[nX]
	next nX

	media := soma / len(vetor)

return media


