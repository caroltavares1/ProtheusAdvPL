#Include "Protheus.ch"


/*
==========================================================================
|Func : SolicMkb()                                                       |
|Desc : Tela com dois browses com produtos e os fornecedores cadastrados |
| 		na tabela de produtos x fornecedores. O usuário marca no browse  |
|		quais produtos e com quais fornecedores ele quer fazer  a        |
|		solicitação de compras.                                          |
|Autor: Carolina Tavares --- 29/02/2024                                  |
==========================================================================
*/

User Function SolicMkb()
	Local aCoors  := FWGetDialogSize( oMainWnd )
	Private lMarker  := .T.
	Private aProds   := {}
	Private aFornecs := {}
	Private aFilter  := {}
	Private aCopyProds := {}
	Private aCopyForns := {}
	Private oBtnFech
	Private    cFontUti   := "Tahoma"
	Private    oFontAno   := TFont():New(cFontUti,,-38)
	Private    oFontSub   := TFont():New(cFontUti,,-20)
	Private    oFontSubN  := TFont():New(cFontUti,,-20,,.T.)
	Private    oFontBtn   := TFont():New(cFontUti,,-14)

	//Alimenta o array
	BUSPROD()
	BUSFOR()

	aCopyForns := aClone(aFornecs) //cópia para não perder os dados originais

	DEFINE MsDIALOG oDlgPrinc TITLE 'Produtos x Fornecedores' From aCoors[1], aCoors[2] To aCoors[3], aCoors[4] Pixel

	oTela      := FWFormContainer():New( oDlgPrinc )
	cIdHeader  := oTela:CreateHorizontalBox( 5 )
	cIdProduto := oTela:CreateHorizontalBox( 45 )
	cIdHeadFor := oTela:CreateHorizontalBox( 5 )
	cIdFornec  := oTela:CreateHorizontalBox( 43 )
	oTela:Activate( oDlgPrinc, .F. )

	oHeader  := oTela:GetPanel( cIdHeader)
	oHeadFor := oTela:GetPanel( cIdHeadFor)
	oPanelUp :=  oTela:GetPanel( cIdProduto )
	oPanelDown  := oTela:GetPanel( cIdFornec )

	@ 004, 003 SAY "Produtos"         SIZE 200, 030 FONT oFontSub  OF oHeader /* COLORS RGB(031,073,125) */ PIXEL
	@ 004, 003 SAY "Fornecedores"     SIZE 200, 030 FONT oFontSub  OF oHeadFor /* COLORS RGB(031,073,125) */ PIXEL


	@ 003, (aCoors[4]/2-001)-(0143*01)  BUTTON oBtnFech  PROMPT "Filtrar"      SIZE 060, 015 OF oHeader ACTION (filtrar())     FONT oFontBtn PIXEL
	@ 003, (aCoors[4]/2-001)-(0073*01)  BUTTON oBtnFech  PROMPT "Solicitar"      SIZE 060, 015 OF oHeader ACTION (Solic(aProds))     FONT oFontBtn PIXEL

	oBrowseUp := fwBrowse():New()
	oBrowseUp:setOwner( oPanelUp )
	oBrowseUp:SetDescription("Produtos")

	oBrowseUp:setDataArray()
	oBrowseUp:setArray( aProds )
	oBrowseUp:disableConfig()
	oBrowseUp:disableReport()

	//Create Mark Column
	oBrowseUp:AddMarkColumns({|| IIf(aProds[oBrowseUp:nAt,1], "LBOK", "LBNO")},; //Code-Block image
	{|| SelectOne(oBrowseUp, aProds, 1)},; //Code-Block Double Click
	{|| SelectAll(oBrowseUp, 1, aProds,1) }) //Code-Block Header Click

	oBrowseUp:addColumn({"Codigo"              , {||aProds[oBrowseUp:nAt,02]}, "C", "@!"    , 1,  20    ,                            , .F. , , .F.,, "aProds[oBrowseUp:nAt,02]",, .F., .T., , "ETPROD1"    })
	oBrowseUp:addColumn({"Descrição"           , {||aProds[oBrowseUp:nAt,03]}, "C", "@!"    , 1, 100    ,                            , .F. , , .F.,, "aProds[oBrowseUp:nAt,03]",, .F., .T., , "ETPROD2"    })
	oBrowseUp:addColumn({"Quantidade"          , {||aProds[oBrowseUp:nAt,04]}, "N", "@E 999,999,999"    , 1, 12 ,                    , .T. , , .F.,, "aProds[oBrowseUp:nAt,04]",, .F., .T., , "ETPROD3"    })


	oBrowseUp:setEditCell( .T. , { || .T. } ) //activa edit and code block for validation
	oBrowseUp:Activate(.T.)

	//Cria o browse inferior, que irá trazer todos os fornecedores
	oBrowseDwn := fwBrowse():New()
	oBrowseDwn:setOwner( oPanelDown )
	oBrowseDwn:SetDescription("Fornecedores")

	oBrowseDwn:setDataArray()
	oBrowseDwn:setArray( aFornecs )
	oBrowseDwn:disableConfig()
	oBrowseDwn:disableReport()

	oBrowseDwn:AddMarkColumns({|| IIf(aFornecs[oBrowseDwn:nAt,01], "LBOK", "LBNO")},; //Code-Block image
	{|| SelectOne(oBrowseDwn, aFornecs,2)},; //Code-Block Double Click
	{|| SelectAll(oBrowseDwn, 01, aFornecs,2) }) //Code-Block Header Click

	oBrowseDwn:addColumn({"Fornecedor"     , {||aFornecs[oBrowseDwn:nAt,02]}, "C", "@!"    , 1,  20  ,      , .F. , , .F.,, "aFornecs[oBrowseDwn:nAt,02]",, .F., .T.,  , "ETFORN1"    })
	oBrowseDwn:addColumn({"Nome"           , {||aFornecs[oBrowseDwn:nAt,03]}, "C", "@!"    , 1, 100  ,      , .F. , , .F.,, "aFornecs[oBrowseDwn:nAt,03]",, .F., .T.,  , "ETFORN2"    })
	oBrowseDwn:addColumn({"Produto"        , {||aFornecs[oBrowseDwn:nAt,04]}, "C", "@!"    , 1, 20   ,      , .F. , , .F.,, "aFornecs[oBrowseDwn:nAt,04]",, .F., .T.,  , "ETFORN3"    })

	oBrowseDwn:Activate(.T.)

	//Atualiza os browses e cria a janela na tela
	oBrowseUp:Refresh()
	oBrowseDwn:Refresh()

	Activate MsDialog oDlgPrinc

return .t.

Static Function SelectOne(oBrowse, aArquivo, nOpc)
	aArquivo[oBrowse:nAt,1] := !aArquivo[oBrowse:nAt,1]

	If nOpc == 1
		FiltrForn(aArquivo)
	EndIF
Return .T.

Static Function SelectAll(oBrowse, nCol, aArquivo, nOpc)
	Local _ni := 1
	For _ni := 1 to len(aArquivo)
		aArquivo[_ni,1] := lMarker
	Next
	oBrowse:Refresh()
	lMarker:=!lMarker

	If nOpc == 1
		aFornecs := aClone(aCopyForns)
		oBrowseDwn:setArray( aFornecs )
		oBrowseDwn:Refresh()
	EndIF
Return .T.

static function FiltrForn(aArquivo) //Filtra o browse de baixo de acordo com o produto marcado no de cima

	Local nX := 0
	Local nY := 0
	aFilter := {}

	for nx := 1 to len(aArquivo)
		if aArquivo[nX,1] == .T.
			for nY := 1 to len(aCopyForns)
				if aArquivo[nX,2] == aCopyForns[nY,4]
					aAdd(aFilter, aCopyForns[nY] )
				EndIf
			next nY
		EndIf
	next

	If  ascan(aArquivo, {|x| x[1] == .T. }) > 0
		aFornecs := aClone(aFilter)
		oBrowseDwn:setDataArray()
		oBrowseDwn:setArray( aFornecs )
		oBrowseDwn:Refresh()
	Else
		aFornecs := aClone(aCopyForns)
		oBrowseDwn:setDataArray()
		oBrowseDwn:setArray( aCopyForns )
		oBrowseDwn:Refresh()
	EndIF

return

//Alimenta a tabela temporaria
Static Function BUSPROD() //Produtos
	Local cQuery    as Character
	Local cQryT3    as Character

	cQuery      := ""
	cQryT3      := GetNextAlias()
	aProds := {}

	cQuery+="SELECT * FROM " + RetSqlName("SB1")
	cQuery+=" WHERE D_E_L_E_T_=''"
	If !Empty(MV_PAR02)
		cQuery+=" AND B1_GRUPO BETWEEN '" + MV_PAR01 + "' AND '"+MV_PAR02+"'"
	EndIf
	If !Empty(MV_PAR04)
		cQuery+=" AND B1_COD BETWEEN '" + MV_PAR03 + "' AND '"+MV_PAR04+"'"
	EndIf
	If !Empty(MV_PAR05)
		cQuery+=" AND B1_DESC LIKE '%" + MV_PAR01 + "%'"
	EndIf
	cQuery:=ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ) , cQryT3, .T., .F. )

	(cQryT3)->(DbGoTop())
	While (cQryT3)->(!EOF())

		aadd(aProds,{.f.,alltrim((cQryT3)->B1_COD),alltrim((cQryT3)->B1_DESC), 0 })

		(cQryT3)->(dbSkip())
	EndDo
	(cQryT3)->(dbCloseArea())
	DbSelectArea('SA1')

Return .t.

Static Function BUSFOR() //Produtos x Fornecedores
	Local cQuery    as Character
	Local cQryT3    as Character


	cQuery      := ""
	cQryT3      := GetNextAlias()
	aFornecs := {}

	cQuery+="SELECT * FROM " + RetSqlName("SA5")
	cQuery+=" WHERE D_E_L_E_T_=''"
	cQuery:=ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ) , cQryT3, .T., .F. )

	(cQryT3)->(DbGoTop())
	While (cQryT3)->(!EOF())

		aadd(aFornecs,{.f.,alltrim((cQryT3)->A5_FORNECE), alltrim((cQryT3)->A5_NOMEFOR), alltrim((cQryT3)->A5_PRODUTO)})

		(cQryT3)->(dbSkip())
	EndDo
	(cQryT3)->(dbCloseArea())
	DbSelectArea('SA1')

Return .t.


static Function Solic(aArquivo)
	Local aArea    := GetArea()
	Local nX       := 0
	Local nY       := 0
	Local nQuant   := 0
	Local aLinhas  := {}

	for nX := 1 to len(aArquivo)
		aLinhas := {}
		if aArquivo[nX,1] == .T.
			nY := 1
			while nY <= len(aFornecs)
				if aFornecs[nY,1] == .T. .AND. aFornecs[nY,4] == aArquivo[nx,2]  //estiver marcado e nquanto os produtos dos dois browses forem iguais
					nQuant := aArquivo[nX,4]
					aAdd(aLinhas, {nQuant, aFornecs[nY,4], aFornecs[nY,2]})
				EndIf
/* 			For nY := 1 to len(aFornecs)
				if aFornecs[nY,1] == .T. .AND. aFornecs[nY,4] == aArquivo[nx,2]
					nQuant := aArquivo[nX,4]
					SoliCompr(nQuant, aFornecs[nY,4], aFornecs[nY,2]) //(nquant, cprod, cFornec)
				EndIf
			next nY */
				nY := nY+1
			EndDo
			soliCompr(aLinhas)

		EndIf
	next

	//Só reseta os browsers se ambos estiverem com marcações e quantidade > 0
	If ascan(aArquivo, {|x| x[1] == .T. }) > 0 .AND. ascan(aFornecs, {|x| x[1] == .T. }) > 0 .AND. nQuant > 0
		reset()
	EndIf

	//Restaurando área armazenada
	RestArea(aArea)
Return NIL

static Function SoliCompr(aDados)

	Local aCabec := {}
	Local aLinha := {}
	Local aLinhas := {}
	Local nX := 0
	Private lMsHelpAuto := .T.
	Private lMsErroAuto := .F.

	If aDados[1,1] > 0 //quantidade

		aCabec := {{"C1_NUM",GetSxeNum("SC1","C1_NUM"),NIL},;
			{"C1_SOLICIT",Alltrim(UsrRetName(__CUSERID)),NIL},;
			{"C1_NOMAPRO",Alltrim(UsrRetName(__CUSERID)),NIL},;
			{"C1_EMISSAO",dDataBase,NIL},;
			{"C1_FILIAL",cFilAnt,NIL}}

		for nX := 1 to len(aDados)
			aLinha := {{"C1_ITEM", Padl(nX,4,'0')/* 0001 */,Nil},;
				{"C1_PRODUTO", aDados[nX,2]  ,Nil},;
				{"C1_FORNECE", aDados[nX,3],Nil},;
				{"C1_QUANT" ,aDados[nX,1], Nil}}

			aAdd(aLinhas,aLinha)
		next nX

		// Teste de Inclusao
		MSExecAuto({|x,y,z| mata110(x,y,z)},aCabec,aLinhas,3)

		If !lMsErroAuto
			ConfirmSx8()
			MsgInfo("Solicitação de Compra do produto " + aDados[1,2] + " incluída com Sucesso!")
		Else
			MostraErro()
		EndIf
	Else
		MsgAlert("Quantidade do produto " + aDados[1,2]+ " precisa ser Informada!")
	EndIf
Return(.T.)


static function reset()
	Local nX := 0

	aFornecs := aClone(aCopyForns) //restaura os dados originais dos fornecedores
	oBrowseDwn:setArray( aFornecs)

	For nX := 1 to len(aProds)
		aProds[nX,1] := .F.
		aProds[nX,4] := 0

	next

	For nX := 1 to len(aFornecs)
		aFornecs[nX,1] := .F.

	next

	oBrowseUp:Refresh()
	oBrowseDwn:Refresh()

return


static function filtrar()
	Local aPergs   := {}
	Local cGrupoDe := Space(TamSX3("B1_GRUPO")[01])
	Local cGrupoAt := Space(TamSX3("B1_GRUPO")[01])
	Local cProdDe  := Space(TamSX3("B1_COD")[01])
	Local cProdAt  := Space(TamSX3("B1_COD")[01])
	Local cArquivo := Space(100)

	aAdd(aPergs, {1, "Grupo De",  cGrupoDe,  "", ".T.", "SBM", ".T.", 80,  .F.})
	aAdd(aPergs, {1, "Grupo Até", cGrupoAt,  "", ".T.", "SBM", ".T.", 80,  .F.})
	aAdd(aPergs, {1, "Produto De",  cProdDe,  "", ".T.", "SB1", ".T.", 80,  .F.})
	aAdd(aPergs, {1, "Produto Até", cProdAt,  "", ".T.", "SB1", ".T.", 80,  .F.})
	aAdd(aPergs, {1, "Contém Descrição",     cArquivo, "", ".T.", "",    ".T.", 100, .F.})

	If ParamBox(aPergs, "Informe os parâmetros do banco")
		BUSPROD()
		oBrowseUp:setArray( aProds )
		oBrowseUp:Refresh()
	EndIf

return
