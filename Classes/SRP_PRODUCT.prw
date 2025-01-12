//Bibliotecas
#Include "TOTVS.ch"

#Define LineBreak CHR(13)+CHR(10)

/*
  O princ�pio da responsabilidade �nica declara que uma classe
  deve fazer apenas uma coisa e, portanto, deve ter apenas uma
  raz�o para ser modificada.
*/

/*
===============================================================
|Func: tstClass                                               |
|Descr: Testa classes que seguem o principio da               |
|responsabilidade �nica                                       |
|Autor: Carolina tavares, Master TI --- Data                  |
===============================================================
*/
User Function tstClass
	Local aArea := FWGetArea()
	Local oProduto
	Local oVenda
	Local oImprimeVenda
	Local cNome      := "Notebook"
	Local cDescricao := "Notebook Dell Core i5 16GB 512GB SSD 15,6' Full HD"
	Local nPrecoUni  := 3100
	Local nQuant     := 5

	oProduto := Produto():New(cNome,cDescricao,nPrecoUni)
	oVenda   := Venda():New(oProduto, nQuant)
	//oVenda:calculaTotal()
	oImprimeVenda := ImprimeVenda():New(oVenda)
	oImprimeVenda:Imprime()

	FWRestArea(aArea)
Return


	Class Produto
		//Atributos
		Data cNome
		Data cDescricao
		Data nPrecoUni

		//Metodos
		Method New() CONSTRUCTOR
		Method Info()
	EndClass

Method New(cNome, cDescricao, nPrecoUni) Class Produto

	::cNome      := cNome
	::cDescricao := cDescricao
	::nPrecoUni  := nPrecoUni

Return Self


Method Info() Class Produto
	Local cMsg := ""

	cMsg := "<b>Produto: </b>" + ::cNome + LineBreak
	cMsg += "<b>Descri��o: </b>" + ::cDescricao + LineBreak
	cMsg += "<b>Pre�o:</b> R$ " + cValToChar(::nPrecoUni) +",00"
	MsgInfo(cMsg, "Informa��o")

Return


	Class Venda
		//Atributos
		Data oProduto
		Data nQuant
		Data nDesconto
		Data nTotal

		//Metodos
		Method New() CONSTRUCTOR
		Method calculaTotal()
		// Method ImprimeVenda() =>
    /*
      Viola o principio de Responsabilidade �nica onde uma classe
      deve possuir apenas uma raz�o de ser alterada
    */

	EndClass

Method New(oProduto, nQuant) Class Venda
	self:oProduto  := oProduto
	::nQuant    := nQuant
	::nDesconto := 0.05
	::nTotal    := 0
	::calculaTotal()
Return Self

Method calculaTotal() Class Venda

	::nTotal := (self:oProduto:nPrecoUni - (self:oProduto:nPrecoUni * ::nDesconto) ) * ::nQuant

Return .T.


/*
  Classe ImprimeVenda que cont�m o m�todo de impress�o da venda
*/

	Class ImprimeVenda
		//Atributos
		Data oVenda

		//Metodos
		Method New() CONSTRUCTOR
		Method Imprime()
	EndClass

Method New(oVenda) Class ImprimeVenda

	self:oVenda := oVenda

Return Self


Method Imprime() Class ImprimeVenda
	Local cMsg := ""

	cMsg := "<b>Produto: </b>" + self:oVenda:oProduto:cNome + LineBreak
	cMsg += "<b>Pre�o Total:</b> R$ " + cValToChar(self:oVenda:nTotal) +",00"
	MsgInfo(cMsg, "Venda")

Return
