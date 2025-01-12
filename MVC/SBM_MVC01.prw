#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'




/*
===============================================================
|Func: SBM_MVC01                                              |
|Descr: Tela MVC tipo 1 da tabela SBM                         |
|Param {type}: param1 - Descrição do parâmetro                |
|Param {type}: param2 - Descrição do parâmetro                |
|Ret {type}: Descrição do retorno                             |
|Autor: Carolina tavares, Master TI --- Data                  |
===============================================================
*/
User Function SBM_MVC01
	Local aArea := GetArea()
	Local cFunBkp := FunName()

	SetFunName("SBM_MVC01")

	Local oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("SBM")
	oBrowse:SetDescription("Cadastro de Grupo de Produtos")

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

	Local aRotinas := {}

	ADD OPTION aRotinas TITLE 'Visualizar' ACTION  'VIEWDEF.SBM_MVC01' OPERATION MODEL_OPERATION_VIEW   ACCESS 0
	ADD OPTION aRotinas TITLE 'Incluir' ACTION  'VIEWDEF.SBM_MVC01' OPERATION MODEL_OPERATION_INSERT   ACCESS 0
	/* ADD OPTION aRotinas TITLE 'Legenda' ACTION  'u_viewLeg' OPERATION 6 ACCESS 0 */

Return aRotinas



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
	Local oStSBM := FWFormStruct(1, "SBM")

	//Instanciando o modelo, não é recomendado colocar nome da user function (por causa do u_), respeitando 10 caracteres
	oModel := MPFormModel():New("mvc01M", /*bPre*/, /*bPos*/,/*bCommit*/,/*bCancel*/)

	//adiciona ao modelo um componente de formulario
	oModel:AddFields("SBMMASTER", /* cOwner */, oStSBM)

	oModel:SetDescription("Modelo de dados da SBM")

	oModel:GetModel("SBMMASTER"):SetDescription("Dados da SBM")


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
	Local oModel := FWLoadModel("SBM_MVC01")
	Local oStSBM := FWFormStruct(2,'SBM')

	oView := FWFormView():New()
	//define o modelo de dados que será usado na view
	oView:SetModel( oModel )
	// Adiciona no nosso View um controle do tipo formulário (enchoice)
	oView:AddField("VIEW_SBM", oStSBM, "SBMMASTER")
	oView:CreateHorizontalBox("TELA", 100)
	oView:SetOWnerView("VIEW_SBM", "TELA")

return oView
