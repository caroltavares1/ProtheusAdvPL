#Include 'Protheus.ch'



user function lerArq
	Local aArea := GetArea()
	//Definindo o arquivo a ser lido
	cDirOrig := 'C:\Arquivos\N-Lidos\'
	cDirDest := 'C:\Arquivos\Lidos\'
	cArquivo := "produtos.txt"

	//Se o arquivo pode ser aberto
	FT_FUSE(cDirOrig+cArquivo)
	Do While !FT_FEOF()
		cBuffer := FT_FREADLN()
		aDados := Separa(cBuffer,',',.T.)
		//Gera apontamento
		U_ApontaOp(aDados[1], aDados[2],aDados[3], aDados[4])
		FT_FSKIP()
	Enddo
	FT_FUSE()

	//Copia o arquivo
	__CopyFile(cDirOrig+cArquivo, cDirDest+cArquivo)

	If FERASE(cDirOrig+cArquivo) == -1
		MsgStop('Arquivo original não deletado!')
	Endif

	RestArea(aArea)
return
