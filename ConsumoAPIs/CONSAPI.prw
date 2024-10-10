#include "protheus.ch"

/*
==========================================================================
|Func : CONSAPI()                                                        |
|Desc : Consume APi e grava os respectivos campos na                     |
|       tabela ZLA (Laudos Técnicos)                                     |
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


	//Cabeçalho
	aHeadPar := {}
	aAdd(aHeadPar, "Content-Type: application/json")

	//Monta a conexão com o servidor REST
	oRestClient := FWRest():New(cBaseUrl) // Ex.: "http://aaaaaaa/v1"
	oRestClient:setPath(cPath) // Ex.: "/produtos"
	oRestClient:SetPostParams(cJson)

	//Publica a alteração, e caso não dê certo, mostra erro
	If ! oRestClient:Post(aHeadPar)
		Aviso('Atenção', 'Houve erro na atualização no servidor!' + CRLF + ;
			'Contate o Administrador!' + CRLF + ;
			"Erro: " + oRestClient:GetLastError() + CRLF + CRLF + ;
			"Result: ", {'OK'}, 03)
	Else
		//Transforma o resultado da consulta em Json
		result := oRestClient:GetResult()
		cRet += result + '}'
		ret := oJson:FromJson(cRet)
		if ValType(ret) == "C"
			Aviso('Atenção', 'Falha ao obter o objeto Json' + CRLF + ;
				'Contate o Administrador!' + CRLF + ;
				"Erro: " + oRestClient:GetLastError() + CRLF + CRLF + ;
				"", {'OK'}, 03)
			return
		Else
			//Chama a função pra separar os itens
			u_PrintJson(oJson)
			FreeObj(oJson)
		EndIf
	EndIf
	GRAVADATA()

Return


/* Referência: https://tdn.totvs.com/display/tec/Classe+JsonObject */

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
            O If abaixo agrupa todas as combinações de produtos e descrições variáveis possíveis
            Isso será usado para varrer novamente os registros e agrupar os valores corretamente.
        */
			nPos := aScan(aDados, {|x| x[1] == jsonObj[names[nPosProd]]})//Vê se o produto já foi adicionado
			If nPos == 0 // se não foi, adiciona e adiciona também a descrição variável
				aadd(aDados, {jsonObj[names[nPosProd]]})
				nPos := aScan(aDados, {|x| x[1] == jsonObj[names[nPosProd]]})
				aadd(aDados[nPos], jsonObj[names[nPosDescVar]]) //descrição variável
			else //caso já tenha o produto
				//varre o array pra saber se a combinação produto e descrição já existe
				nPosDesc := aScan(aDados, {|x| x[2] == jsonObj[names[nPosDescVar]]})
				If nPosDesc == 0 // se não, adiciona
					aadd(aDados, {jsonObj[names[nPosProd]]})
					nPos := aScan(aDados, {|x| x[1] == jsonObj[names[nPosProd]]})
					aadd(aDados[len(aDados)], jsonObj[names[nPosDescVar]])

				EndIf
			EndIF

        /* Adiciona os outros valores em um outro array que será varrido e ordenado depois */

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
						//chama a função para cada item
						u_PrintJson(item[j])
					next j
				endif
			next i
		EndIf
	endif
return


/*  Agrupa os outros valores além das descrições variáveis
    e grava na tabela ZLA
*/

STATIC Function GRAVADATA()
	Local aArea := GetArea()
	Local aRet := {}
	Local i, j
	Local cLaudo
	Local cDescr := ''



    /*
        aDados[i][1] -> Código do produto
        aDados[i][2] -> Descrição Variável
        aDados[i][3] -> LSE (mínimo esperado)
        aDados[i][4] -> LIE (máximo esperado)
        aDados[i][5] -> Média
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
			If ! ZLA->(DbSeek(FWxFilial('ZLA') + cLaudo)) //se não achou
				RecLock("ZLA", .T.) //inclui
				ZLA->ZLA_FILIAL := FWxFilial('ZLA')
				ZLA->ZLA_NLAUDO := cLaudo
				ZLA->ZLA_PROCOD := aDados[i][1] //Código do produto
				ZLA->ZLA_TIPPRD := cDescr

				ZLA->(MsUnlock())
			EndIf
		EndIF

		DO CASE
		CASE aDados[i][2] == 'PESO'

			If ZLA->(DbSeek(FWxFilial('ZLA') + cLaudo))
				RecLock("ZLA", .F.) //ALTERA
				ZLA->ZLA_FILIAL := FWxFilial('ZLA')
				ZLA->ZLA_PROCOD := aDados[i][1] //Código do produto
				ZLA->ZLA_XPSME  := aSortLSE[1] //Peso mínimo esperado
				ZLA->ZLA_XPSPE  := valorMedio(aSortMedia) //padrão esperado
				ZLA->ZLA_XPSXE  := aSortLIE[len(aSortLIE)] //peso máximo esperado
				ZLA->ZLA_XPSMR  := aSortValor[1] //Peso mínimo resultado
				ZLA->ZLA_XPSPR  := valorMedio(aSortValor) //padrão resultado
				ZLA->ZLA_XPSXR  := aSortValor[len(aSortValor)] //peso máximo resultado
				ZLA->(MsUnlock())
			EndIf
		CASE aDados[i][2] == 'ALTURA TOTAL'
			If ZLA->(DbSeek(FWxFilial('ZLA') + cLaudo))
				RecLock("ZLA", .F.) //ALTERA
				ZLA->ZLA_FILIAL := FWxFilial('ZLA')
				ZLA->ZLA_PROCOD := aDados[i][1] //Código do produto
				ZLA->ZLA_XATME  := aSortLSE[1] //altura total mínima esperado
				ZLA->ZLA_XATPE  := valorMedio(aSortMedia) //padrão esperado
				ZLA->ZLA_XATXE  := aSortLIE[len(aSortLIE)] //altura total máxima esperado
				ZLA->ZLA_XATMR  := aSortValor[1] //altura total mínima resultado
				ZLA->ZLA_XATPR  := valorMedio(aSortValor) //padrão resultado
				ZLA->ZLA_XATXR  := aSortValor[len(aSortValor)] //altura total máxima resultado
				ZLA->(MsUnlock())
			EndIf
		CASE aDados[i][2] == 'VOLUME UTIL'
			If ZLA->(DbSeek(FWxFilial('ZLA') + cLaudo))
				RecLock("ZLA", .F.) //ALTERA
				ZLA->ZLA_FILIAL := FWxFilial('ZLA')
				ZLA->ZLA_PROCOD := aDados[i][1] //Código do produto
				ZLA->ZLA_XVUME  := aSortLSE[1] //volume útil mínimo esperado
				ZLA->ZLA_XVUPE  := valorMedio(aSortMedia) //padrão esperado
				ZLA->ZLA_XVUXE  := aSortLIE[len(aSortLIE)] //volume útil máximo esperado
				ZLA->ZLA_XVUMR  := aSortValor[1] //volume útil mínimo resultado
				ZLA->ZLA_XVUPR  := valorMedio(aSortValor) //padrão resultado
				ZLA->ZLA_XVUXR  := aSortValor[len(aSortValor)] //volume útil máximo resultado
				ZLA->(MsUnlock())
			EndIf
		CASE aDados[i][2] == 'CRUSH DE ESMAGAMENTO'
			If ZLA->(DbSeek(FWxFilial('ZLA') + cLaudo))
				RecLock("ZLA", .F.) //ALTERA
				ZLA->ZLA_FILIAL := FWxFilial('ZLA')
				ZLA->ZLA_PROCOD := aDados[i][1] //Código do produto
				ZLA->ZLA_XCRME  := aSortLSE[1] //crush mínimo esperado
				ZLA->ZLA_XCRPE  := valorMedio(aSortMedia) //padrão esperado
				ZLA->ZLA_XCRXE  := aSortLIE[len(aSortLIE)] //crush máximo esperado
				ZLA->ZLA_XCRMR  := aSortValor[1] //crush mínimo resultado
				ZLA->ZLA_XCRPR  := valorMedio(aSortValor) //padrão resultado
				ZLA->ZLA_XCRXR  := aSortValor[len(aSortValor)] //crush máximo resultado
				ZLA->(MsUnlock())
			EndIf
		CASE aDados[i][2] == 'VOLUME TOTAL'
			If ZLA->(DbSeek(FWxFilial('ZLA') + cLaudo))
				RecLock("ZLA", .F.) //ALTERA
				ZLA->ZLA_FILIAL := FWxFilial('ZLA')
				ZLA->ZLA_PROCOD := aDados[i][1] //Código do produto
				ZLA->ZLA_XVTME  := aSortLSE[1] //volume total mínimo esperado
				ZLA->ZLA_XVTPE  := valorMedio(aSortMedia) //padrão esperado
				ZLA->ZLA_XVTXE  := aSortLIE[len(aSortLIE)] //volume total máximo esperado
				ZLA->ZLA_XVTMR  := aSortValor[1] //volume total mínimo resultado
				ZLA->ZLA_XVTPR  := valorMedio(aSortValor) //padrão resultado
				ZLA->ZLA_XVTXR  := aSortValor[len(aSortValor)] //volume total máximo resultado
				ZLA->(MsUnlock())
			EndIf
		CASE aDados[i][2] == 'MEDIDAS EXT. DO TOPO'
			If ZLA->(DbSeek(FWxFilial('ZLA') + cLaudo))
				RecLock("ZLA", .F.) //ALTERA
				ZLA->ZLA_FILIAL := FWxFilial('ZLA')
				ZLA->ZLA_PROCOD := aDados[i][1] //Código do produto
				ZLA->ZLA_XMETME := aSortLSE[1] //medidas externas mínima esperado
				ZLA->ZLA_XMETPE := valorMedio(aSortMedia) //padrão esperado
				ZLA->ZLA_XMETXE := aSortLIE[len(aSortLIE)] //medidas externas máxima esperado
				ZLA->ZLA_XMETMR := aSortValor[1] //medidas externas mínima resultado
				ZLA->ZLA_XMETPR := valorMedio(aSortValor) //padrão resultado
				ZLA->ZLA_XMETXR := aSortValor[len(aSortValor)] //medidas externas máxima resultado
				ZLA->(MsUnlock())
			EndIf
		CASE aDados[i][2] == 'MEDIDAS DA BASE'
			If ZLA->(DbSeek(FWxFilial('ZLA') + cLaudo))
				RecLock("ZLA", .F.) //ALTERA
				ZLA->ZLA_FILIAL := FWxFilial('ZLA')
				ZLA->ZLA_PROCOD := aDados[i][1] //Código do produto
				ZLA->ZLA_XMDBME := aSortLSE[1] //medidas da base mínima esperado
				ZLA->ZLA_XMDBPE := valorMedio(aSortMedia) //padrão esperado
				ZLA->ZLA_XMDBXE := aSortLIE[len(aSortLIE)] //medidas da base máxima esperado
				ZLA->ZLA_XMDBMR := aSortValor[1] //medidas da base mínima resultado
				ZLA->ZLA_XMDBPR := valorMedio(aSortValor) //padrão resultado
				ZLA->ZLA_XMDBXR := aSortValor[len(aSortValor)] //medidas da base máxima resultado
				ZLA->(MsUnlock())
			EndIf
		CASE aDados[i][2] == 'ALTURA DO COLARINHO'
			If ZLA->(DbSeek(FWxFilial('ZLA') + cLaudo))
				RecLock("ZLA", .F.) //ALTERA
				ZLA->ZLA_FILIAL := FWxFilial('ZLA')
				ZLA->ZLA_PROCOD := aDados[i][1] //Código do produto
				ZLA->ZLA_XACME  := aSortLSE[1] //altura  mínima esperado
				ZLA->ZLA_XACPE  := valorMedio(aSortMedia) //padrão esperado
				ZLA->ZLA_XACXE  := aSortLIE[len(aSortLIE)] //altura máxima esperado
				ZLA->ZLA_XACMR  := aSortValor[1] //altura  mínima resultado
				ZLA->ZLA_XACPR  := valorMedio(aSortValor) //padrão resultado
				ZLA->ZLA_XACXR  := aSortValor[len(aSortValor)] //altura  máxima resultado
				ZLA->(MsUnlock())
			EndIf
		CASE aDados[i][2] == 'MEDIDAS EXT. DO COLARINHO'
			If ZLA->(DbSeek(FWxFilial('ZLA') + cLaudo))
				RecLock("ZLA", .F.) //ALTERA
				ZLA->ZLA_FILIAL := FWxFilial('ZLA')
				ZLA->ZLA_PROCOD := aDados[i][1] //Código do produto
				ZLA->ZLA_XMECME := aSortLSE[1] //medida externa mínima esperado
				ZLA->ZLA_XMECPE := valorMedio(aSortMedia) //padrão esperado
				ZLA->ZLA_XMECXE := aSortLIE[len(aSortLIE)] //medida externa máxima esperado
				ZLA->ZLA_XMECMR := aSortValor[1] //medida externa mínima resultado
				ZLA->ZLA_XMECPR := valorMedio(aSortValor) //padrão resultado
				ZLA->ZLA_XMECXR := aSortValor[len(aSortValor)] //medida externa máxima resultado
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


