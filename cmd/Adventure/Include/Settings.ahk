LoadSettings() {
    ; Default directories
    IniRead g_OpenDir, %IniFile%, Options, OpenDir, %A_MyDocuments%
    IniRead g_SaveDir, %IniFile%, Options, SaveDir, %A_MyDocuments%
    ; Tab bar
    IniRead g_TabBarPos, %IniFile%, Options, TabBarPos, 2
    IniRead g_TabBarStyle, %IniFile%, Options, TabBarStyle, 2
    ; Font
    IniRead g_FontName, %IniFile%, Options, FontName, Lucida Console
    IniRead g_FontSize, %IniFile%, Options, FontSize, 14
    ; Lexers
    IniRead g_DefLexType, %IniFile%, Options, DefLexType, TXT
    IniRead g_LexTypes, %IniFile%, Options, LexTypes
    , AHK|AU3|BAT|C|CPP|CS|CSS|HTML|INI|JAVA|JS|JSON|MAKE|PAS|PL|PHP|PS1|PY|RB|SQL|VB|VBS|XML
    ; Theme
    IniRead g_ThemeName, %IniFile%, Options, ThemeName, Shenanigans
    IniRead g_ThemeNameEx, %IniFile%, Options, ThemeNameEx, Default
    ; Editor features
    IniRead g_Metadata, %IniFile%, Options, Metadata, 7
    IniRead g_TabSize, %IniFile%, Options, TabSize, 4
    IniRead g_MultiSel, %IniFile%, Options, MultiSel, 0
    IniRead g_WordWrap, %IniFile%, Options, WordWrap, 1
    IniRead g_SyntaxHighlighting, %IniFile%, Options, SyntaxHighlighting, 1
    IniRead g_AutoBrackets, %IniFile%, Options, AutoBrackets, 1
    IniRead g_HighlightActiveLine, %IniFile%, Options, HighlightActiveLine, 1
    IniRead g_IndentWithSpaces, %IniFile%, Options, IndentWithSpaces, 1
    IniRead g_AutoIndent, %IniFile%, Options, AutoIndent, 1
    IniRead g_IndentGuides, %IniFile%, Options, IndentGuides, 0
    IniRead g_FoldingLines, %IniFile%, Options, FoldingLines, 16
    ; Caret
    IniRead g_CaretWidth, %IniFile%, Options, CaretWidth, 2
    IniRead g_CaretStyle, %IniFile%, Options, CaretStyle, 1
    IniRead g_CaretBlink, %IniFile%, Options, CaretBlink, 500
    ; Margins
    IniRead g_LineNumbers, %IniFile%, Options, LineNumbers, 0
    IniRead g_SymbolMargin, %IniFile%, Options, SymbolMargin, 1
    IniRead g_Divider, %IniFile%, Options, Divider, 1
    IniRead g_CodeFolding, %IniFile%, Options, CodeFolding, 0
    ; Explorer menu
    IniRead ShellMenu, %IniFile%, Options, ShellMenu, 0
    g_ShellMenu1 := ShellMenu & 1
    g_ShellMenu2 := ShellMenu & 2
    ; AutoComplete
    IniRead g_AutoComplete, %IniFile%, Options, AutoComplete, 1
    IniRead g_AutoCTriggerLen, %IniFile%, Options, AutoCTriggerLen, 2
    IniRead g_AutoCMinWordLen, %IniFile%, Options, AutoCMinWordLen, 4
    IniRead g_AutoCMaxItems, %IniFile%, Options, AutoCMaxItems, 7
    IniRead g_AutoCTypedWords, %IniFile%, Options, AutoCTypedWords, 1
    IniRead g_DefUserList, %IniFile%, Options, DefUserList, Dictionary.ud
    ; Calltips
    IniRead g_Calltip, %IniFile%, Options, Calltips, 1
    IniRead g_CalltipFlags, %IniFile%, Options, CalltipFlags, 7
    g_CalltipTyping := g_CalltipFlags & 1
    g_CalltipAutoC := g_CalltipFlags & 2
    g_CalltipHover := g_CalltipFlags & 4
    ; Sessions
    IniRead g_LastSessionName, %IniFile%, Options, LastSessionName, %A_Space%
    IniRead g_LoadLastSession, %IniFile%, Options, LoadLastSession, 1
    IniRead g_RememberSession, %IniFile%, Options, RememberSession, 1
    ; Auto-save
    IniRead g_AutoSaveInterval, %IniFile%, Options, AutoSaveInterval, 3
    IniRead g_AutoSaveInLoco, %IniFile%, Options, AutoSaveInLoco, 0
    IniRead g_AutoSaveInBkpDir, %IniFile%, Options, AutoSaveInBkpDir, 1
    ; Backup
    IniRead g_BackupOnSave, %IniFile%, Options, BackupOnSave, 1
    IniRead g_BackupDir, %IniFile%, Options, BackupDir, %A_Temp%\Adventure
    IniRead g_BackupDays, %IniFile%, Options, BackupDays, 30
    ; File manager
    IniRead g_FileManagerPath, %IniFile%, Options, FM_Path, %A_Space%
    IniRead g_FileManagerParams, %IniFile%, Options, FM_Params, %A_Space%
    ; Miscellaneous
    IniRead g_CheckTimestamp, %IniFile%, Options, CheckTimestamp, 1
    IniRead g_MaxRecent, %IniFile%, Options, MaxRecent, 15
    IniRead g_MenuColor, %IniFile%, Options, MenuColor, 0xFAFAFA
    IniRead g_ToolDesc, %IniFile%, Options, ToolDesc, 1
    IniRead g_AskToSaveOnExit, %IniFile%, Options, AskToSaveOnExit, 1
    IniRead GradColors, %IniFile%, Options, GradColors, 0x3FBBE3|0x0080C0
    g_aGradColors := StrSplit(GradColors, "|")

    ; Find/Replace
    IniRead g_ChkMatchCase, %IniFile%, Search, MatchCase, 0
    IniRead g_ChkWholeWord, %IniFile%, Search, WholeWord, 0
    IniRead g_ChkRegExMode, %IniFile%, Search, RegExMode, 0
    IniRead g_ChkBackslash, %IniFile%, Search, Backslash, 0
    IniRead g_RadStartingPos, %IniFile%, Search, FromStart, 0
    IniRead g_ChkWrapAround, %IniFile%, Search, WrapAround, 1
    IniRead g_ChkF3FindNextSel, %IniFile%, Search, F3FindNextSel, 0
    IniRead g_Highlights, %IniFile%, Search, Highlights, 1
    IniRead g_HITMode, %IniFile%, Search, HITMode, 1
    IniRead g_HITLimit, %IniFile%, Search, HITLimit, 2000
    IniRead g_HITFlags, %IniFile%, Search, HITFlags, 0
    g_ChkHITStartPos := g_HITFlags & 1
}

LoadAhkSettings() {
    IniRead g_AhkPath64, %IniFile%, AHK, ExePath64, %A_Space%
    IniRead g_AhkPath32, %IniFile%, AHK, ExePath32, %A_Space%
    IniRead g_AhkPathEx, %IniFile%, AHK, ExePathEx, %A_Space%
    IniRead g_CaptureStdErr, %IniFile%, AHK, CaptureStdErr, 1
    IniRead g_ShowErrorSign, %IniFile%, AHK, ShowErrorSign, -1
    IniRead g_DebugPort, %IniFile%, AHK, DebugPort, 9001
    IniRead g_AhkHelpFile, %IniFile%, AHK, HelpFile, %A_ScriptDir%\Help\AutoHotkey.chm
}

; Menu item options are set in UpdateMenuState (WM_INITMENUPOPUP).

ApplyToolbarSettings() {
    If (g_LineNumbers) {
        TB_CheckButton(2140, 1)
    }

    If (g_SymbolMargin) {
        TB_CheckButton(2141, 1)
    }

    If (g_CodeFolding) {
        TB_CheckButton(2150, 1)
    }

    If (g_WordWrap) {
        TB_CheckButton(2160, 1)
    }

    If (g_SyntaxHighlighting) {
        TB_CheckButton(2180, 1)
    }

    If (g_AutoBrackets) {
        TB_CheckButton(2181, 1)
    }

    If (g_AutoComplete) {
        TB_CheckButton(2185, 1)
    }

    If (g_CalltipTyping) {
        TB_CheckButton(2186, 1)
    }
}

SaveSettings() {
    Local Pos, State, px, py, Items, FindItems, ReplaceItems

    IniWrite %g_OpenDir%, %IniFile%, Options, OpenDir
    IniWrite %g_SaveDir%, %IniFile%, Options, SaveDir

    IniWrite %g_TabBarPos%, %IniFile%, Options, TabBarPos
    IniWrite %g_TabBarStyle%, %IniFile%, Options, TabBarStyle

    IniWrite %g_FontName%, %IniFile%, Options, FontName
    IniWrite %g_FontSize%, %IniFile%, Options, FontSize

    IniWrite %g_DefLexType%, %IniFile%, Options, DefLexType
    IniWrite %g_LexTypes%, %IniFile%, Options, LexTypes

    IniWrite %g_ThemeName%, %IniFile%, Options, ThemeName
    IniWrite %g_ThemeNameEx%, %IniFile%, Options, ThemeNameEx

    IniWrite %g_Metadata%, %IniFile%, Options, Metadata
    IniWrite %g_TabSize%, %IniFile%, Options, TabSize
    IniWrite %g_MultiSel%, %IniFile%, Options, MultiSel
    IniWrite %g_WordWrap%, %IniFile%, Options, WordWrap
    IniWrite %g_SyntaxHighlighting%, %IniFile%, Options, SyntaxHighlighting
    IniWrite %g_AutoBrackets%, %IniFile%, Options, AutoBrackets
    IniWrite %g_HighlightActiveLine%, %IniFile%, Options, HighlightActiveLine
    IniWrite %g_IndentWithSpaces%, %IniFile%, Options, IndentWithSpaces
    IniWrite %g_AutoIndent%, %IniFile%, Options, AutoIndent
    IniWrite %g_IndentGuides%, %IniFile%, Options, IndentGuides

    IniWrite %g_CaretWidth%, %IniFile%, Options, CaretWidth
    IniWrite %g_CaretStyle%, %IniFile%, Options, CaretStyle
    IniWrite %g_CaretBlink%, %IniFile%, Options, CaretBlink

    IniWrite %g_LineNumbers%, %IniFile%, Options, LineNumbers
    IniWrite %g_SymbolMargin%, %IniFile%, Options, SymbolMargin
    IniWrite %g_Divider%, %IniFile%, Options, Divider
    IniWrite %g_CodeFolding%, %IniFile%, Options, CodeFolding

    IniWrite % g_ShellMenu1 | g_ShellMenu2, %IniFile%, Options, ShellMenu

    IniWrite %g_AutoComplete%, %IniFile%, Options, AutoComplete
    IniWrite %g_AutoCTriggerLen%, %IniFile%, Options, AutoCTriggerLen
    IniWrite %g_AutoCMinWordLen%, %IniFile%, Options, AutoCMinWordLen
    IniWrite %g_AutoCTypedWords%, %IniFile%, Options, AutoCTypedWords
    IniWrite %g_AutoCMaxItems%, %IniFile%, Options, AutoCMaxItems

    IniWrite %g_Calltip%, %IniFile%, Options, Calltips
    IniWrite %g_CalltipFlags%, %IniFile%, Options, CalltipFlags

    IniWrite %g_LastSessionName%, %IniFile%, Options, LastSessionName
    IniWrite %g_LoadLastSession%, %IniFile%, Options, LoadLastSession
    IniWrite %g_RememberSession%, %IniFile%, Options, RememberSession

    IniWrite %g_AutoSaveInterval%, %IniFile%, Options, AutoSaveInterval
    IniWrite %g_AutoSaveInLoco%, %IniFile%, Options, AutoSaveInLoco
    IniWrite %g_AutoSaveInBkpDir%, %IniFile%, Options, AutoSaveInBkpDir

    IniWrite %g_BackupOnSave%, %IniFile%, Options, BackupOnSave
    IniWrite %g_BackupDir%, %IniFile%, Options, BackupDir
    IniWrite %g_BackupDays%, %IniFile%, Options, BackupDays

    IniWrite %g_CheckTimestamp%, %IniFile%, Options, CheckTimestamp
    IniWrite %g_MaxRecent%, %IniFile%, Options, MaxRecent
    IniWrite %g_MenuColor%, %IniFile%, Options, MenuColor
    IniWrite %g_Gradient%, %IniFile%, Options, Gradient
    IniWrite %g_ToolDesc%, %IniFile%, Options, ToolDesc
    IniWrite %g_AskToSaveOnExit%, %IniFile%, Options, AskToSaveOnExit

    ; Main window position and size
    Pos := GetWindowPlacement(g_hWndMain)
    IniWrite % Pos.x, %IniFile%, Window, x
    IniWrite % Pos.y, %IniFile%, Window, y
    IniWrite % Pos.w, %IniFile%, Window, w
    IniWrite % Pos.h, %IniFile%, Window, h
    If (Pos.showCmd == 2) { ; Minimized
        State := (Pos.flags & 2) ? 3 : 1
    } Else {
        State := Pos.showCmd
    }
    IniWrite %State%, %IniFile%, Window, State

    ; AHK
    IniWrite %g_AhkPath64%, %IniFile%, AHK, ExePath64
    IniWrite %g_AhkPath32%, %IniFile%, AHK, ExePath32
    IniWrite %g_AhkPathEx%, %IniFile%, AHK, ExePathEx
    IniWrite %g_CaptureStdErr%, %IniFile%, AHK, CaptureStdErr
    IniWrite %g_ShowErrorSign%, %IniFile%, AHK, ShowErrorSign
    IniWrite %g_DebugPort%, %IniFile%, AHK, DebugPort
    IniWrite %g_AhkHelpFile%, %IniFile%, AHK, HelpFile

    ; Find/Replace
    If (WinExist("ahk_id" . g_hWndFindReplace)) {
        WinGetPos px, py,,, ahk_id %g_hWndFindReplace%
        IniWrite %px%, %IniFile%, Search, x
        IniWrite %py%, %IniFile%, Search, y

        Gui FindReplaceDlg: Submit, NoHide
        IniWrite %g_ChkMatchCase%, %IniFile%, Search, MatchCase
        IniWrite %g_ChkWholeWord%, %IniFile%, Search, WholeWord
        IniWrite %g_ChkRegExMode%, %IniFile%, Search, RegExMode
        IniWrite %g_ChkBackslash%, %IniFile%, Search, Backslash
        IniWrite %g_RadStartingPos%, %IniFile%, Search, FromStart
        IniWrite %g_ChkWrapAround%, %IniFile%, Search, WrapAround
        IniWrite %g_ChkF3FindNextSel%, %IniFile%, Search, F3FindNextSel
        ; Highlights
        IniWrite %g_Highlights%, %IniFile%, Search, Highlights
        IniWrite %g_HITMode%, %IniFile%, Search, HITMode
        IniWrite %g_HITLimit%, %IniFile%, Search, HITLimit
        IniWrite % GetHighlightFlags() | g_ChkHITStartPos, %IniFile%, Search, HITFlags

        ; Find/Replace history
        Items := ""

        ControlGet FindItems, List,,, ahk_id %g_hCbxFind1%
        If (FindItems != "") {
            Loop Parse, FindItems, `n
            {
                Items .= "What" . A_Index . "=" . A_LoopField . "`n"
            }
        }

        ControlGet ReplaceItems, List,,, ahk_id %g_hCbxReplace%
        If (ReplaceItems != "") {
            Loop Parse, ReplaceItems, `n
            {
                Items .= "With" . A_Index . "=" . A_LoopField . "`n"
            }
        }

        If (Items != "") {
            IniWrite %Items%, %IniFile%, SearchHistory
        }
    }

    SaveFileHistory()
}

CreateIniFile() {
    Local Sections
    IniFile := A_ScriptDir . "\Settings\Adventure.ini"

    If (!FileExist(IniFile)) {
        If (FileExist(g_AppData . "\Adventure.ini")) {
            IniFile := g_AppData . "\Adventure.ini"
            Return g_SettingsLocation := 2
        }

        Sections := "[Options]`n`n[Window]`n`n[AHK]`n`n[Search]`n`n[SearchHistory]`n"

        FileAppend %Sections%, %IniFile%, UTF-16
        If (ErrorLevel) {
            FileCreateDir %g_AppData%
            IniFile := g_AppData . "\Adventure.ini"
            WriteFile(IniFile, Sections, "UTF-16")
            Return g_SettingsLocation := 2
        }
    }

    Return g_SettingsLocation := 1
}

SaveFileHistory() {
    Local FileHistory, oXML, oRootNode, oFilesNode, oRecentNode
    , oSessionsNode, oFavoritesNode, Each, oFileNode, oNode, OutXML

    FileHistory := GetConfigFileLocation("FileHistory.xml")

    FileCopy %FileHistory%, %FileHistory%.bak, 1

    oXML := LoadXMLData("<?xml version=""1.0""?><!-- DO NOT EDIT THIS FILE! --><history></history>")

    oRootNode := oXML.documentElement ; root
    oFilesNode := oRootNode.appendChild(oXML.createElement("files"))
    oRecentNode := oRootNode.appendChild(oXML.createElement("recent"))
    oSessionsNode := oRootNode.appendChild(oXML.createElement("sessions"))
    oFavoritesNode := oRootNode.appendChild(oXML.createElement("favorites"))

    PurgeFileHistory()

    ; Files
    For Each, File in g_aoFiles {
        oFileNode := oXML.createElement("file")
        oNode := oFilesNode.appendChild(oFileNode)
        oNode.setAttribute("path", File.Path)
        oNode.setAttribute("pos", File.Pos)
        oNode.setAttribute("lm", ArrayToPDL(File.Lines))
        oNode.setAttribute("tm", MatrixToPDL(File.Markers))
        oNode.setAttribute("sels", MatrixToPDL(File.Selections))
        oNode.setAttribute("folds", ArrayToPDL(File.Folds))
    }

    ; Recent
    SetFileHistoryNodeItems(g_aRecentFiles, oRecentNode)

    ; Sessions
    For Each, Session in g_aoSessions {
        oSessionNode := oXML.createElement("session")
        oNode := oSessionsNode.appendChild(oSessionNode)
        oNode.setAttribute("name", Session.Name)
        SetFileHistoryNodeItems(Session.Files, oSessionNode)
        oNode.setAttribute("active", Session.Active)
    }

    ; Favorites
    SetFileHistoryNodeItems(g_aFavorites, oFavoritesNode)

    ; Indent
    OutXML := RegExReplace(oXML.xml, "(\<(file|session)\s)", "`r`n`t`t$1")
    OutXML := RegExReplace(OutXML, "(\<\/?(files|recent|sessions|favorites))", "`r`n`t$1")
    OutXML := StrReplace(OutXML, "</h", "`r`n</h")

    Return % WriteFile(FileHistory, OutXML, "UTF-8") != -1
}

SetFileHistoryNodeItems(aFileArray, oXMLNode) {
    Local Max, Index, PDL := ""
    Max := aFileArray.Length()
    Loop % Max {
        Index := GetFileHistoryIndex(aFileArray[A_Index])
        If (Index) {
            PDL .= Index . "|"
        }
    }
    oXMLNode.setAttribute("items", RTrim(PDL, "|"))
}

GetFileHistoryIndex(FullPath) {
    Local Index, Item
    For Index, Item in g_aoFiles {
        If (Item.Path = FullPath) {
            Return Index
        }
    }
    Return 0
}

; Keep in file history only distinct filenames (from recent, sessions and favorites)
PurgeFileHistory() {
    Local aFiles := [], Each, Session, FullPath, i

    Loop % g_aRecentFiles.Length() {
        aFiles.Push(g_aRecentFiles[A_Index])
    }

    For Each, Session in g_aoSessions {
        Loop % Session.Files.Length() {
            FullPath := Session.Files[A_Index]
            If (!IndexOf(aFiles, FullPath)) {
                aFiles.Push(FullPath)
            }
        }
    }

    Loop % g_aFavorites.Length() {
        If (!IndexOf(aFiles, g_aFavorites[A_Index])) {
            aFiles.Push(g_aFavorites[A_Index])
        }
    }

    i := 1
    Loop % g_aoFiles.Length() {
        FullPath := g_aoFiles[i].Path
        If (!IndexOf(aFiles, FullPath)) {
            g_aoFiles.RemoveAt(i)
        } Else {
            i++
        }
    }
}

TB_CheckButton(BtnID, State) {
    SendMessage 0x402, %BtnID%, %State%,, ahk_id %g_hToolbar% ; TB_CHECKBUTTON
}

/*
TB_EnableButton(BtnID, bEnable) {
    SendMessage 0x401, %BtnID%, %bEnable%,, ahk_id %g_hToolbar% ; TB_ENABLEBUTTON
}
*/
