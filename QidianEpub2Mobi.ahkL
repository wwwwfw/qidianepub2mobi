verDate := "2017-2-20"
	SrcFilePath = %1% ; ������

	isSelfUse := 0  ; �Ƿ����ð汾
	notSelfUse := ! isSelfUse

	if ( isSelfUse ) {
		chooseNum := 2
		FontName := "Zfull-GB"
		CoverName := "D:\etc\fox\foxbookCover.jpg"
	} else {
		chooseNum := 1
	}

	; ���� 7za kindlegen
	EnvGet, oldPATH, PATH
	EnvSet, PATH, %A_scriptdir%\bin32`;%A_scriptdir%`;C:\bin\bin32`;D:\bin\bin32`;%oldPATH%

	if ( "" != SrcFilePath ) {
		isGUI := false
		if ( ! InStr(SrcFilePath, ":\") )
			SrcFilePath := A_ScriptDir . "\" . SrcFilePath
		gosub, unzipAndShowList
		gosub, ToMobi
		ExitApp
	} else {
		isGUI := true
		Gosub, GuiInit
	}
return

GuiInit:
	Gui,Add,Button,x394 y20 w70 h60 vBtnStart gToMobi,תMobi(&S)

	Gui,Add,Groupbox,x4 y10 w380 h80 cGreen, �鼮����ͼƬ����������(�Ǳ�Ҫ�������ļ�����):
	Gui,Add,Checkbox,x14 y30 w80 h20 cGreen vCKFont gCKFont Checked%isSelfUse%, ����(&F):
	Gui,Add,ComboBox,x94 y30 w280 choose%chooseNum% vFontName Disabled%notSelfUse%, ��|Zfull-GB|FZLanTingHei-R-GBK|FZLanTingHei-DB-GBK|D:\etc\Font\lantinghei.ttf
	Gui,Add,Checkbox,x14 y60 w80 h20 cGreen vCKCover gCKCover Checked%isSelfUse%, ����(&C):
	Gui,Add,ComboBox,x94 y60 w280 choose%chooseNum% vCoverName Disabled%notSelfUse%, ��|D:\etc\fox\foxbookCover.jpg

	Gui,Add,Groupbox,x4 y100 w460 h320 cBlue, �����Epub�ļ��϶������棬˫����һ�л�תMobi��ť:
	Gui,Add, Button,x334 y100 w120 h20 gChooseFile, ѡ��Epub�ļ�(&F)

	Gui,Add,ListView,x14 y120 w440 h290 vFoxLV NoSortHdr -Multi gToMobi, �½���|�ļ���
		LV_ModifyCol(1, 260), LV_ModifyCol(2, 150)

	Gui, Add, StatusBar, , �汾: %verDate%   ����:������֮��  ��Ʒҳ: http://linpinger.github.io
	Gui,Show, w471 h440 , ��� Epub ת Mobi
return

CKFont:
	GuiControlGet, CKFont
	if ( 1 == CKFont ) {
		GuiControl, Enable, FontName
		GuiControlGet, FontName
		if ( "��" = FontName ) {
			FileSelectFile, FontName, 3
			if ( "" != FontName )
				GuiControl, text, FontName, %FontName%
		}
		if ( InStr(FontName, ":") ) {
			IfNotExist, %FontName%
			{
				FileSelectFile, FontName, 3
				if ( "" != FontName )
					GuiControl, text, FontName, %FontName%
			}
		}
		GuiControlGet, FontName
;		TrayTip, ��ʾ:, % FontName
	} else {
		GuiControl, Disable, FontName
	}
return

CKCover:
	GuiControlGet, CKCover
	if ( 1 == CKCover ) {
		GuiControl, Enable, CoverName
		GuiControlGet, CoverName
		if ( "��" = CoverName ) {
			FileSelectFile, CoverName, 3
			if ( "" != CoverName )
				GuiControl, text, CoverName, %CoverName%
		} else {
			IfNotExist, %CoverName%
			{
				FileSelectFile, CoverName, 3
				if ( "" != CoverName )
					GuiControl, text, CoverName, %CoverName%
			}
		}
		GuiControlGet, CoverName
;		TrayTip, ��ʾ:, % CoverName
	} else {
		GuiControl, Disable, CoverName
	}
return

GuiDropFiles:	; �϶��¼�
	SrcFilePath := A_GuiEvent , FileCount := A_EventInfo

	If ( A_GuiControl = "FoxLV" ) {
		gosub, unzipAndShowList
		return
	} else if ( A_GuiControl = "FontName" ) {
		GuiControl, , CKFont, 1
		GuiControl, Enable, FontName
		GuiControl, text, FontName, %SrcFilePath%
	} else if ( A_GuiControl = "CoverName" ) {
		GuiControl, , CKCover, 1
		GuiControl, Enable, CoverName
		GuiControl, text, CoverName, %SrcFilePath%
	} else {
		TrayTip, �϶���ʾ:, ���Epub�ϵ�: �����б�����`n���������ϵ�: ��������
		return
	}

	If ( FileCount != 1 ) {
		TrayTip, ��ʾ:, һ�δ���һ���ļ�
		return
	}
	TrayTip, ��ʾ:, %SrcFilePath%
return

ChooseFile: ; ѡ��epub�ļ�
	FileSelectFile, SrcFilePath, 3
	if ( "" != SrcFilePath )
		gosub, unzipAndShowList
return

unzipAndShowList:
	SplitPath, SrcFilePath, EpubFileName, EpubDir, EpubExt, EpubNameNoExt, EpubDrive

	; �Ƿ�epub�ļ�
	if ( "epub" != EpubExt ) {
		tip("����: ��׺������.epub : " . EpubFileName)
		return
	}
	tip("��ѹ��ȡ��Ϣ: " . SrcFilePath)

	wDir := EpubDir . "\epub_" . A_TickCount ; ��ʱĿ¼��ȫ�ֱ���

	FileCreateDir, %wDir%\src
	runwait, 7za x -r "%SrcFilePath%", %wDir%\src, min

	IfNotExist, %wDir%\src\title.xhtml
	{
		tip("����: ò�Ʋ�������epub")
		FileRemoveDir, %wDir%, 1
		return
	}

	; ��ȡ�鼮��Ϣ
	FileRead, html, *P65001 %wDir%\src\title.xhtml
	RegExMatch(html, "smUi)<li><b>����</b>��<a href=""http://([0-9]*).qidian.com[^>]*?>([^<]*?)</a>.*<li><b>����</b>��<a[^>]*?>([^<]*?)</a>.*<li><b>����</b>��([^<]*?)<.*<li><b>���</b>��<pre>(.*)</pre>", ff_)
	qidianid := ff_1
	bookname := ff_2
	bookauthor := ff_3
	booktype := ff_4
	bookinfo := ff_5

if ( isGUI ) {
	; ����LV����Ϊ����
	LV_ModifyCol(1, "", "�½��� in: " . bookname . "  ����: " . bookauthor)

	; ��ȡ�½��б�
	LV_Delete()
	FileRead, html, *P65001 %wDir%\src\catalog.html
	loop, parse, html, `n, `r
	{
		if ( ! InStr(A_loopfield, "href=""content"))
			continue
		ff_1 := "" , ff_2 := ""
		RegExMatch(A_loopfield, "Ui)href=""([^""]+)"">([^<]+)</a>", ff_)

		LV_Add("", FF_2, FF_1)
	}
}
	tip( EpubFileName . ": ����: " . bookname . "  ����: " . bookauthor . "  ����: " . booktype)
return

ToMobi:
if ( isGUI ) {
	if ( "FoxLV" = A_GuiControl ) { ; �������½�
		startPos := LV_GetNext(0)
	} else if ( "BtnStart" = A_GuiControl) {
		startPos := 1
	}
} else {
	startPos := 1
}

	IfNotExist, %wDir%
		gosub, unzipAndShowList

	oEpub := New FoxEpub(bookname, wDir . "\mobi")
	oEpub.BookCreator := bookauthor

if ( isGUI ) {
	GuiControlGet, CKFont
	if ( CKFont ) {
		GuiControlGet, FontName
		if ( "��" != FontName )
			oEpub.SetBodyFont(FontName)
	}

	GuiControlGet, CKCover
	if ( CKCover ) {
		GuiControlGet, CoverName
		if ( "��" != CoverName )
			IfExist, %CoverName%
				oEpub.SetCover(CoverName) ; ���÷���
	}
} else {
	if ( isSelfUse ) {
		oEpub.SetBodyFont(FontName)
		oEpub.SetCover(CoverName) ; ���÷���
	}
}
	tip("תmobi��: " . EpubFileName . " -> " . qidianid . "_" . bookname . ".mobi")

	; ��ȡ�½��б�
	FileRead, html, *P65001 %wDir%\src\catalog.html

	nowCount := 0
	loop, parse, html, `n, `r
	{
		if ( ! InStr(A_loopfield, "href=""content"))
			continue
		++ nowCount
		if ( nowCount < startPos) ; �������½�
			continue
		ff_1 := "" , ff_2 := ""
		RegExMatch(A_loopfield, "Ui)href=""([^""]+)"">([^<]+)</a>", ff_)

		FileRead, pageHtml, *P65001 %wDir%\src\%ff_1%
		pageHtml := getQiDianEpubPage(pageHtml)
		oEpub.AddChapter(ff_2, pageHtml)
	}

	oEpub.SaveTo(EpubDir . "\" . qidianid . "_" . bookname . ".mobi")
	tip("�����ת��mobi: " . EpubFileName . " -> " . qidianid . "_" . bookname . ".mobi")

	loop, 3 { ; ��ʱ����������ģʽ�»����ɾ����������
		FileRemoveDir, %wDir%, 1
		if ErrorLevel
			sleep 1000
	}
return

GuiClose:
	IfExist, %wDir%
		FileRemoveDir, %wDir%, 1
	ExitApp
return

#NoEnv
#include <FoxEpub_Class>

tip(msg="") {
	global isGUI
	if ( isGUI )
		SB_SetText(msg)
	else
		FileAppend, %msg%, *
}

getQiDianEpubPage(html) {
	RegExMatch(html, "smUi)<div class=""content"">(.*)</div>", xx_)
	html := xx_1
	StringReplace, html, html, <p>�ֻ��û��뵽m.qidian.com�Ķ���</p>, , A
	StringReplace, html, html, <p>�ֻ��Ķ�������������㡣��<a href="http://download.qidian.com/apk/QDReader.apk?k=e" target="_blank">��׿��</a>��</p>, , A
	StringReplace, html, html, `r, , A
	StringReplace, html, html, `n, , A
	StringReplace, html, html, <p>, ����, A
	StringReplace, html, html, </p>, <br/>`n, A
	return html
}

