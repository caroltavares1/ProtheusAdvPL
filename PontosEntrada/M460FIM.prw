
//Bibliotecas
#Include "TOPCONN.CH"
#Include 'Protheus.ch'

/*
==========================================================================
|P.E. : M460FIM()                                                        |
|Desc : Complementa a gravação da tabela SE1 - Contas a Receber          |
|       após gerar a NF de saída.                                        |
|Autor: Carolina Tavares --- 22/11/2023                                  |
==========================================================================
*/
User Function M460FIM()
    Local aAreaSF2 := SF2->(GetArea())
    Local aAreaSD2 := SD2->(GetArea())
    Local aAreaSE1 := SE1->(GetArea())
    Local cCusto
    Local cItemCta
    Local cClvl

    /*  Campos da SD2 a seren levados para a SE1
        E1_CCUSTO  = D2_CCUSTO
        E1_ITEMCTA = D2_ITEMCC
        E1_CLVL    = D2_CLVL
    */

    //Pega o pedido
    DbSelectArea("SD2")
    SD2->(DbSetorder(3))
    If SD2->(DbSeek(SF2->(F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA)))
        cCusto   := SD2->D2_CCUSTO
        cItemCta := SD2->D2_ITEMCC
        cClvl    := SD2->D2_CLVL
    Endif

    //Filtra títulos dessa nota
    cSql := "SELECT R_E_C_N_O_ AS REC FROM "+RetSqlName("SE1")
    cSql += " WHERE E1_FILIAL = '"+xFilial("SE1")+"' AND D_E_L_E_T_<>'*' "
    cSql += " AND E1_PREFIXO = '"+SF2->F2_SERIE+"' AND E1_NUM = '"+SF2->F2_DOC+"' "
    //cSql += " AND E1_TIPO = 'NF' "
    TcQuery ChangeQuery(cSql) New Alias "_QRY"

    //Enquanto tiver dados na query
    While !_QRY->(eof())
        DbSelectArea("SE1")
        SE1->(DbGoTo(_QRY->REC))

        //Se tiver dado, altera o tipo de pagamento
        If !SE1->(EoF())
            RecLock("SE1",.F.)
                Replace E1_CCUSTO  WITH cCusto
                Replace E1_ITEMCTA WITH cItemCta
                Replace E1_CLVL    WITH cClvl
            MsUnlock()
        EndIf

        _QRY->(DbSkip())
    Enddo
    _QRY->(DbCloseArea())

    RestArea(aAreaSF2)
    RestArea(aAreaSD2)
    RestArea(aAreaSE1)
Return
