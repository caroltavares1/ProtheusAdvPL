#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'




/*
===============================================================
|Func: MVC02                                              |
|Descr: Tela MVC tipo 1 da tabela SBM                         |
|Param {type}: param1 - Descrição do parâmetro                |
|Param {type}: param2 - Descrição do parâmetro                |
|Ret {type}: Descrição do retorno                             |
|Autor: Carolina tavares, Master TI --- Data                  |
===============================================================
*/
User Function MVC02
	Local aArea := GetArea()
	Local cFunBkp := FunName()

	SetFunName("MVC02")

	Local oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("SC5")
	oBrowse:SetDescription("Cadastro de pedidos de vendas")

	oBrowse:Activate()
	SetFunName(cFunBkp)
	RestArea(aArea)
Return Nil



/*
===============================================================
|Func: MenuDef                                                |
|Descr: Menu MVC                                              |
|Param {type}: param1 - Descrição do parâmetro                |
|Param {type}: param2 - Descrição do parâmetro                |
|Ret {type}: Descrição do retorno                             |
|Autor: Carolina tavares, Master TI --- Data                  |
===============================================================
*/
Static Function MenuDef

Return FWMVCMenu( "MVC02" )


/*
===============================================================
|Func: ModelDef                                               |
|Descr: Model MVC                                             |
|Param {type}: param1 - Descrição do parâmetro                |
|Param {type}: param2 - Descrição do parâmetro                |
|Ret {type}: Descrição do retorno                             |
|Autor: Carolina tavares, Master TI --- Data                  |
===============================================================
*/

Static Function ModelDef

	Local oModel := Nil

	//cria a estrutura a ser usada no modelo de dados
	Local oStSC5 := FWFormStruct(1, "SC5")
	Local oStSC6 := FWFormStruct(1, "SC6")

	//Instanciando o modelo, não é recomendado colocar nome da user function (por causa do u_), respeitando 10 caracteres
	oModel := MPFormModel():New("MVC02M")

    /* A relação de dependência entre as entidades é de Master-Detail, ou seja, há 1 ocorrência do Pai
    para N ocorrências do Filho (1-n)  */
    oModel:AddFields("SC5MASTER", /* cOwner */, oStSC5) //estrutura pai
    oModel:AddGrid("SC6DETAIL", "SC5MASTER", oStSC6) //estrutura filha depende do

    oModel:SetRelation( 'SC6DETAIL', { { 'SC6_FILIAL', 'xFilial( "SC6" )' },;
                    {'C6_NUM', 'C5_NUM' } },;
                    SC6->( IndexKey( 1 ) ) )


    //É preciso definir a descricao do modelo e de cada componente do modelo
    oModel:SetDescription("Modelo de pedidos de vendas")
    oModel:GetModel("SC5MASTER"):SetDescription("Dados do pedido de venda")
    oModel:GetModel("SC6DETAIL"):SetDescription("Dados dos itens do pedido de venda")


return oModel


/*
===============================================================
|Func: ViewDef                                                |
|Descr: View MVC                                              |
|Param {type}: param1 - Descrição do parâmetro                |
|Param {type}: param2 - Descrição do parâmetro                |
|Ret {type}: Descrição do retorno                             |
|Autor: Carolina tavares, Master TI --- Data                  |
===============================================================
*/

static function ViewDef
	Local oView
	Local oModel := FWLoadModel("MVC02") //precisa ser o nome do fonte
	Local oStSC5 := FWFormStruct(2,'SC5')
	Local oStSC6 := FWFormStruct(2,'SC6')

	oView := FWFormView():New()

	oView:SetModel(oModel)
	//adiciona o controle
	oView:AddField("VIEW_SC5", oStSC5, "SC5MASTER")
	oView:AddGrid("VIEW_SC6", oStSC6, "SC6DETAIL")

	oView:CreateHorizontalBox("SUPERIOR", 40)
	oView:CreateHorizontalBox("INFERIOR", 60)

	oView:SetOWnerView("VIEW_SC5", "SUPERIOR")
	oView:SetOWnerView("VIEW_SC6", "INFERIOR")


return oView
