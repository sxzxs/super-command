Global g_Version := "3.0.3"
, g_AppName := "Adventure"
, g_hWndMain
, g_AppData := A_AppData . "\AmberSoft\Adventure"
, g_SettingsLocation
, IniFile
, g_InitialX
, g_InitialY
, g_InitialW
, g_InitialH
, Sci := []
, SciLexer := A_ScriptDir . (A_PtrSize == 8 ? "\SciLexer64.dll" : "\SciLexer32.dll")
, g_FontName
, g_FontSize
, IconLib := A_ScriptDir . "\Icons\Adventure.icl"
, g_hToolbar
, g_ToolbarH := DPIScale(31)
, g_TBEdgeH := 2
, g_hTab := 0
, g_TabBarPos
, g_TabBarStyle
, g_OldTabProc
, g_MouseCapture := 0
, g_hCursorDragMove
, TabEx
, TabExIL
, g_TabIndex := 1
, g_TabCounter := 1
, g_GetFileInfo
, g_hHiddenEdit
, g_NT6orLater := DllCall("Kernel32.dll\GetVersion") & 0xFF > 5
, g_TempDir := GetTempDir()
, g_hWndFindReplace := 0
, g_SearchString
, g_ChkMatchCase
, g_ChkWholeWord
, g_ChkRegExMode
, g_ChkBackslash
, g_RadStartingPos
, g_RadCurrentPos
, g_ChkWrapAround
, g_ChkF3FindNextSel
, g_hCbxFind1
, g_hCbxFind2
, g_hCbxReplace
, g_Highlights
, g_HITFlags
, g_ChkHITMatchCase
, g_ChkHITWholeWord
, g_ChkHITStartPos
, g_HITMode
, g_HITLimit
, g_FromCurrentPos := -1
, NOTFOUND := -1
, g_oColors := {}
, g_ThemeFile := A_ScriptDir . "\Themes\Themes.xml"
, g_ThemeName
, g_ThemeNameEx
, g_oXMLFileTypes
, g_oFileExts := {}
, g_oLexTypes := {}
, g_oKeywords := {}
, g_oProps := {}
, g_LexTypes
, g_DefLexType
, g_aFilters
, g_FiltersLoaded := 0
, g_OpenDir
, g_SaveDir
, g_oEncodings := {"CP1252": "UTF-8 without BOM", "UTF-16": "UTF-16 LE", "UTF-8-RAW": "UTF-8 without BOM", "UTF-8": "UTF-8"}
, g_MarginNumbers := 0
, g_MarginSymbols := 1
, g_MarginDivider := 2
, g_MarginFolding := 3
, g_LineNumbers
, g_SymbolMargin
, g_MarkerBookmark := 0
, g_MarkerBreakpoint := 1
, g_MarkerDebugStep := 2
, g_MarkerError := 3
, g_MarkerMask := 1 << g_MarkerBookmark | 1 << g_MarkerBreakpoint | 1 << g_MarkerError
, g_Divider
, g_CodeFolding
, g_FoldingLines
, g_WordWrap
, g_SyntaxHighlighting
, g_HighlightActiveLine
, Indent
, g_TabSize
, g_IndentWithSpaces
, g_AutoIndent
, g_IndentGuides
, g_Overtype := False
, CRLF := "`r`n"
, g_ShowCRLF := False
, g_ShowWhiteSpaces := False
, g_AutoComplete
, g_AutoCDir := A_ScriptDir . "\AutoComplete"
, g_AutoCTriggerLen
, g_AutoCMinWordLen
, g_AutoCMaxWordLen := 50
, g_AutoCMaxItems
, g_AutoCTypedWords
, g_TypedWords := ""
, g_UserWords := ""
, g_DefUserList
, g_oAutoC := {}
, g_Calltip
, g_CalltipFlags
, g_CalltipHover
, g_CalltipTyping
, g_CalltipAutoC
, g_CalltipParams
, g_CalltipParamsIndex := 1
, g_AutoBrackets
, g_CaretWidth
, g_CaretStyle
, g_CaretBlink
, g_MultiSel
, g_BackupOnSave
, g_BackupDir
, g_BackupDays
, g_AutoSaveInterval
, g_AutoSaveInLoco
, g_AutoSaveInBkpDir
, g_AskToSaveOnExit
, g_CheckTimestamp
, g_ShellMenu1
, g_ShellMenu2
, g_ShellMenu2Pos := 7
, g_pIContextMenu
, g_pIContextMenu2
, g_pIContextMenu3
, g_hShellMenu := 0
, g_hWndShell := 0
, g_CaptureStdErr
, g_ShowErrorSign
, g_AhkPath64
, g_AhkPath32
, g_AhkPathEx
, g_TempFile := g_TempDir . "\Temp.ahk"
, g_AhkHelpFile
, g_oXmlAhkHelpMenu
, g_DbgStatus := 0
, g_DbgSession
, g_DbgSocket
, g_DbgStack
, g_DbgLocalVariables
, g_DbgGlobalVariables
, g_aBreakpoints := []
, g_hWndVarList := 0
, g_ReloadVarListOnBreak := 1
, g_ShowIndexedVariables := 1
, g_ShowObjectMembers := 1
, g_ShowReservedClassMembers := 0
, g_DbgCaptureStderr := 1
, g_AttachDebugger := 0
, g_hStatusBar
, g_StatusBarH
, g_SendMessage
, g_SBP_FileType := 1
, g_SBP_CursorPos := 2
, g_SBP_SelInfo := 3
, g_SBP_DocStatus := 4
, g_SBP_OverMode := 5
, g_SBP_Encoding := 6
, g_aJumpList := []
, g_oXMLFileHistory
, g_aoFiles := []
, g_aoSessions := []
, g_aFavorites := []
, g_aRecentFiles := []
, g_MaxRecent
, g_hWndFHM := 0
, g_hTabFHM
, g_hTvSessions
, g_hLvFavorites
, g_hLvRecentFiles
, g_hLvOpenFiles
, g_hIL_FHM
, g_TempSessionName
, g_Metadata
, g_LastSessionName
, g_LoadLastSession
, g_RememberSession
, g_hLvSessionFiles
, g_aGradColors
, g_oTools
, g_ToolsFile
, g_hWndTools := 0
, g_hLvTools
, g_ToolDesc
, g_MenuColor
, g_FileManagerPath
, g_FileManagerParams
, g_hLvSyntax
, g_hWndDbg := 0
, g_hTabDbg
, g_hLvVariables
, g_hLvCallStack
, g_hLvErrorStream
, g_hLvBreakpoints
, g_hLvDbgAttach
, g_DebugPort
, SIZE_MINIMIZED := 1
, g_WordPrefix := "[#.@$]"
, g_ShellRecent := 1
