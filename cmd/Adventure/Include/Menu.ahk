; Note: this file in included in the auto-exec section. Labels must not be used.

; File Menu
;AddMenu("MenuFile", "&New File`tCtrl+N", "M_NewTab", IconLib, -2)
AddMenu("MenuFile", "New from &Template",, IconLib, -4)
Menu MenuFile, Add
AddMenu("MenuFile", "&Open File...`tCtrl+O", "ChooseFile", IconLib, -6)
Menu MenuRecent, Add
AddMenu("MenuRecent", "Open All Recent Files", "OpenAllRecentFiles", IconLib, -36)
AddMenu("MenuFile", "Recent &Files", ":MenuRecent", IconLib, -7)
Menu MenuFile, Disable, Recent &Files
Menu MenuFile, Add
AddMenu("MenuFile", "&Save File`tCtrl+S", "SaveFile", IconLib, -8)
Menu MenuFile, Add, Save &As...`tCtrl+Shift+S, SaveFileAs
AddMenu("MenuFile", "Save All", "SaveAllFiles", IconLib, -9)
Menu MenuFile, Add, Save a Copy As..., SaveCopy
AddMenu("MenuFile", "Save as Template...", "SaveAsTemplate", IconLib, -5)
Menu MenuEncoding, Add, UTF-8, SetSaveEncoding, Radio
Menu MenuEncoding, Check, UTF-8
Menu MenuEncoding, Add, UTF-8 without BOM, SetSaveEncoding, Radio
Menu MenuEncoding, Add, UTF-16 LE, SetSaveEncoding, Radio
Menu MenuFile, Add, Save with Encoding, :MenuEncoding
Menu MenuFile, Add
AddMenu("MenuFile", "Reopen File", "M_ReopenFile", IconLib, -10)
AddMenu("MenuFile", "Open File in a New Window", "M_OpenNewInstance", IconLib, -11)
Menu MenuFile, Add
AddMenu("MenuFile", "Copy Contents to a New Tab", "M_DuplicateTab", IconLib, -12)
AddMenu("MenuFile", "Copy Full Path to Clipboard", "CopyFilePath", IconLib, -13)
Menu MenuFile, Add
AddMenu("MenuFile", "Open Folder in File Manager`tCtrl+E", "M_OpenFolder", IconLib, -14)
AddMenu("MenuFile", "Open in Command Prompt`tCtrl+P", "OpenCommandPrompt", IconLib, -15)
Menu MenuFile, Add
AddMenu("MenuFile", "&Close File`tCtrl+W", "M_CloseTab", IconLib, -17)
Menu MenuFile, Add, Close All Files, M_CloseAllTabs
Menu MenuFile, Add
AddMenu("MenuFile", "E&xit`tAlt+Q", "OnClose", IconLib, -18)

; Edit Menu
;Menu MenuEdit, Add, &Undo`tCtrl+Z, Undo
Menu MenuEdit, Add, R&edo`tCtrl+Y, Redo
Menu MenuEdit, Add
Menu MenuEdit, Add, Cu&t`tCtrl+X, Cut
Menu MenuEdit, Add, &Copy`tCtrl+C, Copy
Menu MenuEdit, Add, &Paste`tCtrl+V, Paste
Menu MenuEdit, Add, &Delete`tDel, Clear
Menu MenuEdit, Add, Select &All`tCtrl+A, SelectAll
Menu MenuEdit, Add
Menu MenuLineOperations, Add, Duplicate Line`tCtrl+Down, DuplicateLine
Menu MenuLineOperations, Add, Move Line Up`tCtrl+Shift+Up, MoveLineUp
Menu MenuLineOperations, Add, Move Line Down`tCtrl+Shift+Down, MoveLineDown
Menu MenuLineOperations, Add, Select Bookmarked Lines, SelectMarkedLines
Menu MenuEdit, Add, Line Operations, :MenuLineOperations
Menu MenuEdit, Add
Menu MenuSelectedText, Add, &UPPERCASE`tCtrl+Shift+U, Uppercase
Menu MenuSelectedText, Add, &lowercase`tCtrl+Shift+L, Lowercase
Menu MenuSelectedText, Add, &Title Case`tCtrl+Shift+T, TitleCase
Menu MenuEdit, Add, Selected Text, :MenuSelectedText
Menu MenuEdit, Add
Menu MenuEdit, Add, Decimal to Hexadecimal`tCtrl+Shift+H, Dec2Hex
Menu MenuEdit, Add, Hexadecimal to Decimal`tCtrl+Shift+D, Hex2Dec
Menu MenuEdit, Add
Menu MenuEdit, Add, Comment/Uncomment`tCtrl+K, ToggleComment
Menu MenuEdit, Add
Menu MenuEdit, Add, Autocomplete Keyword`tCtrl+Enter, M_AutoComplete
Menu MenuEdit, Add, Show Calltip`tCtrl+Space, M_ShowCalltip
Menu MenuEdit, Add, Insert Parameters`tCtrl+Insert, M_InsertParameters
Menu MenuEdit, Add
Menu MenuEdit, Add, &Insert Date and Time`tCtrl+D, InsertDateTime
Menu MenuEdit, Add
Menu MenuEdit, Add, Set as &Read-Only, ToggleReadOnly

; Search Menu
;Menu MenuSearch, Add, &Find...`tCtrl+F, ShowFindDialog
Menu MenuSearch, Add, Find &Next`tF3, FindNext
Menu MenuSearch, Add, Find &Previous`tShift+F3, FindPrev
AddMenu("MenuSearch", "&Replace...`tCtrl+H", "ShowReplaceDialog", IconLib, -27)
AddMenu("MenuSearch", "Automatic &Highlights...", "ShowHighlightsDialog", IconLib, -28)
Menu MenuSearch, Add
AddMenu("MenuSearch", "Find in Files...`tCtrl+Shift+F", "FindInFiles", IconLib, -29)
Menu MenuSearch, Add
AddMenu("MenuSearch", "&Go to Line...`tCtrl+G", "ShowGoToLineDialog", IconLib, -30)
Menu MenuSearch, Add
AddMenu("MenuSearch", "&Mark Current Line`tF2", "ToggleBookmark", IconLib, -31)
AddMenu("MenuSearch", "Mark &Selected Text`tCtrl+M", "MarkSelectedText", IconLib, -32)
AddMenu("MenuSearch", "Mark Line with &Error Sign`tShift+F2", "ToggleErrormark", IconLib, -33)
Menu MenuSearch, Add, Go to Next Marker`tCtrl+PgDn, GoToNextMarker
Menu MenuSearch, Add, Go to Previous Marker`tCtrl+PgUp, GoToPreviousMarker
AddMenu("MenuSearch", "Clear All Mar&kers`tAlt+M", "ClearAllMarkers", IconLib, -34)
Menu MenuSearch, Add
AddMenu("MenuSearch", "Go to Matching &Brace`tCtrl+B", "GoToMatchingBrace", IconLib, -35)

; Session Menu
;Menu MenuSession, Add, Save Session..., ShowSaveSessionDialog
AddMenu("MenuSession", "Manage Sessions...", "ShowSessionsManager", IconLib, -96)
Menu MenuSession, Add
Menu MenuSession, Add, Saved Sessions, MenuHandler
Menu MenuSession, Add
Menu MenuSession, Add, Save Metadata of All Files, SaveMetadataAll
AddMenu("MenuSession", "Load Legacy Session File...", "M_LoadLegacySession")

; Favorites
;AddMenu("MenuFavorites", "Add File to Favorites", "M_AddFavorite", IconLib, -38)
AddMenu("MenuFavorites", "Manage Favorites...", "ShowFavoritesManager", IconLib, -96)

; View Menu
;Menu MenuView, Add, Tab Bar, MenuHandler
Menu MenuViewTabBar, Add, Top, SetTabBarPos, Radio
Menu MenuViewTabBar, Add, Bottom, SetTabBarPos, Radio
Menu MenuViewTabBar, Add
Menu MenuViewTabBar, Add, Standard, SetTabBarStyle, Radio
Menu MenuViewTabBar, Add, Buttons, SetTabBarStyle, Radio
Menu MenuView, Add, Tab Bar, :MenuViewTabBar
Menu MenuView, Add
Menu MenuView, Add, &Line Numbers, ToggleLineNumbers
Menu MenuView, Add, Symbol Margin, ToggleSymbolMargin
Menu MenuView, Add, Margin Divider, ToggleDivider
Menu MenuView, Add, &Fold Margin, ToggleCodeFolding
Menu MenuView, Add
Menu MenuView, Add, Toggle Current Fold, ToggleFold
Menu MenuView, Add, &Collapse All Folds, CollapseFolds
Menu MenuView, Add, &Expand All Folds, ExpandFolds
Menu MenuView, Add, Show Folding Lines, ToggleFoldingLines
Menu MenuView, Add
Menu MenuView, Add, &Wrap Long Lines, ToggleWordWrap
Menu MenuView, Add, &Show White Spaces, ToggleWSVisible
Menu MenuView, Add, Show Line Endings, ToggleCRLFVisible
Menu MenuView, Add
Menu MenuView, Add, Syntax &Highlighting, ToggleSyntaxHighlighting
Menu MenuView, Add, Highlight &Active Line, ToggleHighlightActiveLine
Menu MenuView, Add, Show &Indentation Lines, ToggleIndentGuides
Menu MenuView, Add
AddMenu("MenuView", "Choose &Theme...", "ChooseThemeDialog", IconLib, -40)
Menu MenuView, Add
AddMenu("MenuViewZoom", "Zoom In`tCtrl+Num +", "ZoomIn", IconLib, -42)
AddMenu("MenuViewZoom", "Zoom Out`tCtrl+Num -", "ZoomOut", IconLib, -43)
Menu MenuViewZoom, Add, Reset Zoom`tCtrl+Num 0, ResetZoom
Menu MenuView, Add, Zoom, :MenuViewZoom
Menu MenuView, Add
AddMenu("MenuView", "Change Editor Font...", "ChangeEditorFont", IconLib, -41)

; Syntax Menu
;Menu MenuLexer, Add, Text File, M_SetLexType
Menu MenuLexer, Add

; Options Menu
;Menu MenuOptions, Add, Enable &Autocomplete`tF12, ToggleAutoComplete
Menu MenuOptions, Add, Autocomplete &Typed Words, ToggleTypedWords
Menu MenuOptions, Add, Load Dictionary..., ShowUserListDialog
Menu MenuOptions, Add, Enable &Calltips, ToggleCalltips
Menu MenuOptions, Add, Autoclose &Brackets, ToggleAutoBrackets
Menu MenuOptions, Add, &Indentation Settings..., ShowIndentationDialog
Menu MenuOptions, Add, Enable &Multiple Selection, ToggleMultipleSelection
Menu MenuOptions, Add
Menu MenuOptions, Add, Auto-save and Backup..., ShowBackupDialog
Menu MenuOptions, Add
Menu MenuOptionsOnExit, Add, Remember Session, ToggleRememberSession
Menu MenuOptionsOnExit, Add, Prompt to Save Files, ToggleAskToSaveOnExit
Menu MenuOptions, Add, On Exit, :MenuOptionsOnExit
Menu MenuOptions, Add
Menu MenuOptions, Add, Save Settings Now, SaveSettings

; Run Menu
;AddMenu("MenuRun", "Run with &Associated Application`tF9", "RunFile", IconLib, -55)
AddMenu("MenuRun", "Command Line &Parameters...", "ShowCmdLineParamsDialog", IconLib, -56)
Menu MenuRun, Add
AddMenu("MenuRun", "Explorer Context Menu...", "ShowShellMenuDlg", IconLib, -57)

; Tools Menu
;AddMenu("MenuTools", "Configure Tools...", "ShowToolsDialog", IconLib, -58)

; AHK Menu
;AddMenu("MenuAHK", "Run with AHK 64-&bit`tF9", "RunScript", IconLib, -61)
;AddMenu("MenuAHK", "Run with AHK 32-bit`tShift+F9", "RunScript", IconLib, -62)
AddMenu("MenuAHK", "Run &Selected Text`tCtrl+F9", "RunSelectedText", IconLib, -63)
Menu MenuAHK, Add
AddMenu("MenuAHK", "AutoHotkey Settings...", "ShowAhkSettings", IconLib, -37)
Menu MenuAHK, Add
AddMenu("MenuAHK", "AutoHotkey Debugger...", "Debug_ShowWindow", IconLib, -65)
AddMenu("MenuAHK", "Start Debugging`tF5", "M_Debug_Start", IconLib, -66)
AddMenu("MenuAHK", "Stop Debugging`tF8", "Debug_Stop", IconLib, -69)
AddMenu("MenuAHK", "Toggle Breakpoint`tF4", "ToggleBreakpoint", IconLib, -75)
Menu MenuAHK, Add
AddMenu("MenuAhkHelp", "AutoHotkey &Help File", "AhkHelp", "hh.exe")
Menu MenuWin32, Add, Declare, ReplaceConstant
Menu MenuWin32, Add, SendMessage, ReplaceConstant
Menu MenuWin32, Add, OnMessage, ReplaceConstant
AddMenu("MenuAHK", "Win32 Constant", ":MenuWin32", IconLib, -93)
AddMenu("MenuAHK", "AutoHotkey Help", ":MenuAhkHelp", IconLib, -90)

; Help Menu
;AddMenu("MenuHelp", "Adventure &Help File", "MenuHandler", IconLib, -90)
AddMenu("MenuHelp", "Keyboard Shortcuts", "ShowKeyboardShortcuts", IconLib, -86)
Menu MenuHelp, Add
AddMenu("MenuHelp", "&About", "ShowAbout", IconLib, -94)

LoadAhkHelpMenu() {
    Local Node, Nodes, StartPos, Index, SubMenu, MenuName, ChildNode, ChildNodes, MenuItemText, hIcon

    g_oXmlAhkHelpMenu := LoadXML(A_ScriptDir . "\Include\AhkHelpMenu.xml")
    If (g_oXmlAhkHelpMenu.parseError.errorCode) {
        Return
    }

    Nodes := g_oXmlAhkHelpMenu.selectSingleNode("HelpMenu").childNodes

    StartPos := 1
    For Node in Nodes {
        Index := StartPos + A_Index

        If (Node.hasChildNodes()) {
            SubMenu := True
            MenuName := "MenuAhkHelp" . Index

            ChildNodes := Node.childNodes
            For ChildNode in ChildNodes {
                MenuItemText := ChildNode.getAttribute("name")
                hIcon := GetHelpMenuItemIcon(ChildNode)
                Try {
                    AddMenu(MenuName, MenuItemText, "HelpMenuHandler", "HICON:" . hIcon)
                }
            }
        } Else {
            SubMenu := False
        }

        MenuItemText := Node.getAttribute("name")
        Try {
            Menu MenuAhkHelp, Insert, %Index%&, %MenuItemText%, % (SubMenu) ? ":" . MenuName : "HelpMenuHandler"
        }

        If (SubMenu) {
            Try {
                Menu MenuAhkHelp, Icon, %MenuItemText%, %IconLib%, -6
            }
        } Else {
            hIcon := GetHelpMenuItemIcon(Node)
            Try {
                Menu MenuAhkHelp, Icon, %MenuItemText%, HICON:%hIcon%
            }
        }
    }
}

GetHelpMenuItemIcon(Node) {
    Static hIconCHM := 0, hIconURL := 0
    Local URL, IconFile, IconIndex, Type, hIcon

    URL := Node.getAttribute("url")

    If (SubStr(URL, 1, 1) == "/") {
        If (!hIconCHM) {
            hIconCHM := LoadPicture(IconLib, "w16 Icon-91", ErrorLevel)
        }
        hIcon := DllCall("CopyIcon", "Ptr", hIconCHM, "Ptr")

    } Else {
        Type := Node.getAttribute("type")

        If (Type == 3) { ; Online resource
            If (!hIconURL) {
                hIconURL := LoadPicture(IconLib, "w16 Icon-92", ErrorLevel)
            }
            hIcon := DllCall("CopyIcon", "Ptr", hIconURL, "Ptr")

        } Else { ; Local file
            IconFile := Node.getAttribute("iconres")
            IconIndex := Node.getAttribute("iconindex")
            If (IconIndex == "") {
                IconIndex := 1
            }
            hIcon := LoadPicture(GetFullPath(IconFile), "w16 Icon" . IconIndex, ErrorLevel)
        }
    }

    Return hIcon
}

HelpMenuHandler(MenuItem, ItemPos, MenuName) {
    Local Node, URL
    Node := g_oXmlAhkHelpMenu.selectSingleNode("//MenuItem[@name=""" . MenuItem . """]")
    URL := Node.getAttribute("url")

    If (SubStr(URL, 1, 1) == "/") {
        Run HH mk:@MSITStore:%g_AhkHelpFile%::%URL%
    } Else {
        Try {
            Run %URL%
        }
    }
}

AhkHelp() {
    RunEx(g_AhkHelpFile)
}

OpenHelpFile() {
    Run %A_ScriptDir%\Help\Adventure.htm
}

ShowKeyboardShortcuts() {
    RunEx(A_ScriptDir . "\Help\Keyboard." . (A_IsCompiled ? "exe" : "ahk"))
}
