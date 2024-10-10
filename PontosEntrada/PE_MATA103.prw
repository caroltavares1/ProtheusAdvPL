#include "topconn.ch"
#include "Protheus.ch"

/*
==========================================================================
|Func : MT100TOK()                                                       |
|Desc : Ponto de entrada para a validação do documento de entrada        |
|Autor: Carolina Tavares --- 17/11/2023                                  |
==========================================================================
*/
User function MT100TOK()
    Local lMT100TOK := .F.
    Local lRet := .F.

/*
    20/11/2023 --- Carolina Tavares

    1- ROTINA DOCUMENTO DE ENTRADA.
    QUANDO NA ABA TIVER VALORES DOS SEGUINTES IMPOSTOS PIS RETENÇÃO (D1_BASEPIS),COFINS RETENÇÃO (D1_BASECOF),
    CSLL RETENÇÃO (D1_BASECSL), IRRF (D1_BASEIRR), NÃO PERMITIR INCLUIR NF OU CLASSIFICAR SEM FAZER O SEGUINTE CAMINHO:
    OUTRAS AÇOES - NAT. RENDIMENTO, POR ITEM. (DHR_NATREN)

    D1_BASEPIS, D1_BASECSL, D1_BASECOF, D1_BASEIRR  (base ou valor?)
    D1_VALPIS , D1_VALCLS , D1_VALCOF , D1_VALIRR

    2- SE TIVER INSS
    Se houver registro na tabela CDN com o campo CDN_CODLST
    para o produto + cod.serviço informado em
    B1_CODISS
*/

    Local nPosCod  := aScan( aHeader, { |x| Alltrim(x[2])=="D1_COD"} )
    Local nPosIss  := aScan( aHeader, { |x| Alltrim(x[2])=="D1_CODISS"} )
    Local nPosInss := aScan( aHeader, { |x| Alltrim(x[2])=="D1_BASEINS"})

    Local cCodProd := aCols[n,nPosCod]
    Local cCodIss  := aCols[n,nPosIss]
    Local cCodInss := aCols[n,nPosInss]

    aArea := CDN->(GetArea())
    DbSelectArea("CDN")
    CDN->(DbSetOrder(1)) //Posiciona no indice 1
    CDN->(DbGoTop())

    If !EMPTY( cCodInss ) //Se houver inss
        IF CDN->(DbSeek(FWxFilial("CDN") + cCodIss + cCodProd ))
            If !EMPTY(CDN->CDN_CODLST)
                lRet := .T.
            ENDIF
        Else
            MSGINFO( "Código de serviço inválido para esse produto: "+ cCodProd, "ERRO" )
        ENDIF
    ENDIF

    RestArea(aArea)

    Return lRet

