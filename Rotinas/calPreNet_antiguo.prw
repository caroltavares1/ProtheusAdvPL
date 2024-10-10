#Include 'Protheus.ch'


**************************************************************************************
// FunÃ§Ã£o : | calcPrNet ->  Gatilho| (C6_XCUSTO, C6_XFRETE, C6_XRENT) -> C6_PRCVEN |
// Modulo : ""                                                                       |
// Fonte  : calPreNet.prw                                                            |
// ---------+--------------------------+-------------------------------------------- +
// Data     | Autor             	   | Descricao                                   |
// ---------+--------------------------+---------------------------------------------+
// 31/10/23 | Carolina Tavares         | Calculo de preÃ§o - Pedido de Venda         |
**************************************************************************************

User Function calcPrNet()
    Local aArea
    Local nFreteNet := 0
    Local nPrecoNet := 0
    Local nPosFrete := aScan( aHeader, { |x| Alltrim(x[2])=="C6_XFRETE"} )
    Local nPosCusto := aScan( aHeader, { |x| Alltrim(x[2])=="C6_XCUSTO"} )
    Local nPosRent  := aScan( aHeader, { |x| Alltrim(x[2])=="C6_XRENT" } )
    Local nFrete    := aCols[n,nPosFrete]
    Local nCusto    := aCols[n,nPosCusto]
    Local nRent     := aCols[n,nPosRent]
    Local cCli      := M->C5_CLIENTE
    Local cLoja     := M->C5_LOJACLI
    Local cEstDest  := ''
    Local cMVEst    := GetMV("MV_ESTADO")
    Local cMVNorte  := GetMV("MV_NORTE")
    Local nPos      := 0

    If EMPTY( nFrete ) .OR. EMPTY( nCusto ) .OR. ;
     EMPTY( nRent )//se um dos campos estiver vazio, não faz nada
        return 0
    Else

        aArea := SA1->(GetArea())
        DbSelectArea("SA1")
        SA1->(DbSetOrder(1)) //Posiciona no indice 1
        SA1->(DbGoTop())

        cEstDest := Posicione("SA1",1,FWxFilial("SA1") + cCli + cLoja,"A1_EST")

        RestArea(aArea)

        nPos := At(cEstDest, cMVNorte) //caso a alíquota seja 7% (não usado no momento)

        If cEstDest == cMVEst // se o estado de destino for igual a o estado de origem (PE) o icms é 18%
            nFreteNet := nFrete * 0.9075
        else // alíquota é 12%
            nFreteNet := nFrete * 0.7986
        EndIf

        nPrecoNet := nCusto + nRent + nFreteNet

    EndIF

/*
    Frete Net => =SE(J236=18%;Q236*0,9075;Q236*0,7986)
    If ICMS == 18%
        FreteNet = FreteCheio * 0.9075
    Else
        FreteNet = FreteCheio * 0.7986

    PreÃ§oNet = CUSTO MP + FRETE NET + RENT

*/

return nPrecoNet


/*/{Protheus.doc} Function Name
@Description Calcula o custo do produto
@Type Gatilho| C6_PRODUTO -> C6_XCUSTO
@Author Carolina Tavares
@Since  	 06/11/2023
/*/
User Function calcCusto()
    Local nRet := 0
    Local nPosProd  := aScan( aHeader, { |x| Alltrim(x[2])=="C6_PRODUTO"} )
    Local nPosLocal := aScan( aHeader, { |x| Alltrim(x[2])=="C6_LOCAL"}   )
    Local cProd     := aCols[n,nPosProd]
    Local cLocal    := aCols[n,nPosLocal]

    nRet := calcest(cProd, cLocal,dDataBase)[2]/calcest(cProd, cLocal,dDataBase)[1]

Return nRet
