//Bibliotecas
#Include "Protheus.ch"
#INCLUDE "TOPCONN.CH"
#INCLUDE "totvs.ch"
#INCLUDE "parmtype.ch"
#INCLUDE "tbiconn.ch"


static oBmpOK := loadBitmap(GetResource(), "LBOK")
static oBmpNO := loadBitmap(GetResource(), "LBNO")

/*
==========================================================================
|Func : ImpItem()                                                        |
|Desc : Função para escolher produtos e importá-los                      |
|       no grid de itens das planilhas de contratos                      |
|Autor: Carolina Tavares --- 30/11/2023                                  |
==========================================================================
*/
User Function ImpItem()
    Local aArea := GetArea()
    //Objetos da Janela
    Private oDlgPvt
    Private oMsGetAFA
    Private aHeadAFA := {}
    Private aColsAFA := {}
    Private aColsRet := {}

    Private oBtnFech
    Private oBtnLege
    //Tamanho da Janela
    Private    nJanLarg    := 1000
    Private    nJanAltu    := 300
    //Fontes
    Private    cFontUti   := "Tahoma"
    Private    oFontAno   := TFont():New(cFontUti,,-38)
    Private    oFontSub   := TFont():New(cFontUti,,-20)
    Private    oFontSubN  := TFont():New(cFontUti,,-20,,.T.)
    Private    oFontBtn   := TFont():New(cFontUti,,-14)
     
    //Criando o cabeçalho da Grid
    //              Título         Campo     Máscara   Tamanho          Decimal   Valid              Usado  Tipo F3     Combo
    aAdd(aHeadAFA, {"        "  , "CHECK" , "@BMP",  02,  00, ".T.", ".T.", "C", "",    ""} )
    aAdd(aHeadAFA, {"Código"    , "AFA_PROJET", "",  TamSX3("AFA_PROJET")[01],  0, "", ".T.", "C", "",    ""} )
    aAdd(aHeadAFA, {"Versão"    , "AFA_REVISA", "",  TamSX3("AFA_REVISA")[01],  0, "", ".T.", "C", "",    ""} )
    aAdd(aHeadAFA, {"Tarefa"    , "AFA_TAREFA", "",  TamSX3("AFA_TAREFA")[01],  0, "", ".T.", "C", "",    ""} )
    aAdd(aHeadAFA, {"Descrição" , "AF9_DESCRI", "",  TamSX3("AF9_DESCRI")[01],  0, "", ".T.", "C", "",    ""} )
    aAdd(aHeadAFA, {"Item"      , "AFA_ITEM"  , "",  TamSX3("AFA_ITEM")[01]  ,  0, "", ".T.", "C", "",    ""} )
    aAdd(aHeadAFA, {"Produto"   , "AFA_PRODUT", "",  TamSX3("AFA_PRODUT")[01],  0, "", ".T.", "C", "",    ""} )
    aAdd(aHeadAFA, {"Quantidade", "AFA_QUANT" , "",  TamSX3("AFA_QUANT")[01] ,  0, "", ".T.", "N", "",    ""} )
    aAdd(aHeadAFA, {"Data      ", "AFA_DATPRF", "",  TamSX3("AFA_DATPRF")[01],  0, "", ".T.", "D", "",    ""} )
    aAdd(aHeadAFA, {"Custo     ", "AFA_CUSTD" , "",  TamSX3("AFA_CUSTD")[01] ,  0, "", ".T.", "N", "",    ""} )

    Processa({|| fCarAcols()}, "Processando")
 
    //Criação da tela com os dados que serão informados
    DEFINE MSDIALOG oDlgPvt TITLE "Recursos do Projeto" FROM 000, 000  TO nJanAltu, nJanLarg COLORS 0, 16777215 PIXEL
        //Labels gerais
        @ 004, 003 SAY "Listagem de"         SIZE 200, 030 FONT oFontSub  OF oDlgPvt COLORS RGB(031,073,125) PIXEL
        @ 014, 003 SAY "Recursos do Projeto" SIZE 200, 030 FONT oFontSubN OF oDlgPvt COLORS RGB(031,073,125) PIXEL

        //Botões
        @ 006, (nJanLarg/2-001)-(0067*01) BUTTON oBtnFech  PROMPT "Cancelar"      SIZE 065, 018 OF oDlgPvt ACTION (oDlgPvt:End())     FONT oFontBtn PIXEL
        @ 006, (nJanLarg/2-001)-(0067*02) BUTTON oBtnLege  PROMPT "Adicionar"       SIZE 065, 018 OF oDlgPvt ACTION (addProj())       FONT oFontBtn PIXEL

        //Grid dos grupos
        oMsGetAFA := MsNewGetDados():New(    029,;                //nTop      - Linha Inicial
                                            003,;                //nLeft     - Coluna Inicial
                                            (nJanAltu/2)-3,;     //nBottom   - Linha Final
                                            (nJanLarg/2)-3,;     //nRight    - Coluna Final
                                            ,;                   //nStyle    - Estilos para edição da Grid (GD_INSERT = Inclusão de Linha; GD_UPDATE = Alteração de Linhas; GD_DELETE = Exclusão de Linhas)
                                            "AllwaysTrue()",;    //cLinhaOk  - Validação da linha
                                            ,;                   //cTudoOk   - Validação de todas as linhas
                                            "",;                 //cIniCpos  - Função para inicialização de campos
                                            {},;                 //aAlter    - Colunas que podem ser alteradas
                                            ,;                   //nFreeze   - Número da coluna que será congelada
                                            9999,;               //nMax      - Máximo de Linhas
                                            ,;                   //cFieldOK  - Validação da coluna
                                            ,;                   //cSuperDel - Validação ao apertar '+'
                                            ,;                   //cDelOk    - Validação na exclusão da linha
                                            oDlgPvt,;            //oWnd      - Janela que é a dona da grid
                                            aHeadAFA,;           //aHeader   - Cabeçalho da Grid
                                            aColsAFA)            //aCols     - Dados da Grid

        oMsGetAFA:oBrowse:BLDBLCLICK := {|| checkField(@oMsGetAFA)}

        //Desativa as manipulações
        oMsGetAFA:lActive := .F.

    ACTIVATE MSDIALOG oDlgPvt CENTERED

    RestArea(aArea)
Return aColsRet

/*------------------------------------------------*
 | Func.: fCarAcols                               |
 | Desc.: Função que carrega o aCols              |
 *------------------------------------------------*/

Static Function fCarAcols()
    Local aArea  := GetArea()
    Local cQry   := ""

    //Seleciona dados do documento de entrada
    cQry := " SELECT "                                                  + CRLF
    cQry += "     AFA_PROJET, "                                         + CRLF
    cQry += "     AFA_REVISA, "                                         + CRLF
    cQry += "     AFA_TAREFA, "                                         + CRLF
    cQry += "     AF9_DESCRI, "                                         + CRLF
    cQry += "     AFA_ITEM,   "                                         + CRLF
    cQry += "     AFA_PRODUT, "                                         + CRLF
    cQry += "     AFA_QUANT, "                                          + CRLF
    cQry += "     AFA_DATPRF,"                                          + CRLF
    cQry += "     AFA_CUSTD"                                            + CRLF
    cQry += " FROM "                                                    + CRLF
    cQry += "     " + RetSQLName('AFA') + " AFA,"                       + CRLF
    cQry += "     " + RetSQLName('AF9') + " AF9,"                       + CRLF
    cQry += "     " + RetSQLName('AF8') + " AF8 "                       + CRLF
    cQry += " WHERE "                                                   + CRLF
    cQry += "     AFA_FILIAL = '" + FWxFilial('AFA') + "' "             + CRLF
    cQry += "     AND AF9_FILIAL = '" + FWxFilial('AF9') + "' "         + CRLF
    cQry += "     AND AF8_FILIAL = '" + FWxFilial('AF8') + "' "         + CRLF
    cQry += "     AND AFA_PROJET BETWEEN '" + MV_PAR01 + "' "           + CRLF
    cQry += "     AND '" + MV_PAR02 + "' "                              + CRLF
    cQry += "     AND AFA_PROJET = AF9_PROJET"                          + CRLF
    cQry += "     AND AFA_REVISA = AF9_REVISA"                          + CRLF
    cQry += "     AND AFA_TAREFA = AF9_TAREFA"                          + CRLF
    cQry += "     AND AFA_PROJET = AF8_PROJET"                          + CRLF
    cQry += "     AND AF8_ENCPRJ != '1'"                                + CRLF
    cQry += "     AND AFA.D_E_L_E_T_ = ' ' "                            + CRLF
    cQry += "     AND AF9.D_E_L_E_T_ = ' ' "                            + CRLF
    cQry += "     AND AF8.D_E_L_E_T_ = ' ' "                            + CRLF
    TCQuery cQry New Alias "QRY_AFA"
     
    //Enquanto houver dados
    QRY_AFA->(DbGoTop())
    While ! QRY_AFA->(EoF())

        //Adiciona o item no aCols
        aAdd(aColsAFA, { ;
            oBmpNO,;
            QRY_AFA->AFA_PROJET,;
            QRY_AFA->AFA_REVISA,;
            QRY_AFA->AFA_TAREFA,;
            QRY_AFA->AF9_DESCRI,;
            QRY_AFA->AFA_ITEM,;
            QRY_AFA->AFA_PRODUT,;
            QRY_AFA->AFA_QUANT,;
            dtoc(stod(QRY_AFA->AFA_DATPRF)),; //formata data
            QRY_AFA->AFA_CUSTD,;
            .F.;
        })

        QRY_AFA->(DbSkip())
    EndDo
    QRY_AFA->(DbCloseArea())

/*     IF(len(aColsAFA)==0)
        MSGALERT("Não há itens a serem adicionados. O projeto deve ter sido encerrado ou não possui tarefas cadastradas")
    EndIf */

    RestArea(aArea)
Return

/*------------------------------------------------*
 | Func.: checkField                               |
 | Desc.: Função que marca e desmarca o checkbox   |
*-------------------------------------------------*/
static function checkField(oMsGetAFA)

    Local nLine   := oMsGetAFA:nAt
    Local nColumn := aScan(oMsGetAFA:aHeader, {|x| x[2] == 'CHECK'})
    Local oCheck  := oMsGetAFA:aCols[nLine, nColumn]

    If oCheck == oBmpNO
        oMsGetAFA:aCols[nLine, nColumn] := oBmpOK
    else
        oMsGetAFA:aCols[nLine, nColumn] := oBmpNO

    EndIf

    oMsGetAFA:Refresh()

return

/*-------------------------------------------------*
 | Func.: addProj                                |
 | Desc.: Função que adiciona os itens da tarefa |
*--------------------------------------------------*/

static function addProj()
    Local nx := 0

    for nx := 1 to len(oMsGetAFA:aCols)
        If oMsGetAFA:aCols[nx, 1]:cname == 'LBOK'
            //adiciona o item
            aadd(aColsRet,oMsGetAFA:aCols[nx] )
        EndIf
    next

    oDlgPvt:End()
return




