; Adventure IDE
; Tested on AHK v1.1.33.02 Unicode 32/64-bit, Windows XP/7/10

; Script compiler directives
;@Ahk2Exe-SetMainIcon %A_ScriptDir%\Icons\Adventure.ico
;@Ahk2Exe-SetCompanyName AmberSoft
;@Ahk2Exe-SetDescription Adventure IDE x64
;@Ahk2Exe-SetVersion 3.0.3

; Script options
#SingleInstance Off
#NoEnv
#MaxMem 640
#NoTrayIcon
#KeyHistory 0
SetBatchLines -1
DetectHiddenWindows On
SetWinDelay -1
SetControlDelay -1
SetWorkingDir %A_ScriptDir%
FileEncoding UTF-8
ListLines Off
#SingleInstance, force

Files := [] ; Store filenames passed as parameters
Loop %0% {
    Loop Files, % %A_Index%
        Files.Push(A_LoopFileLongPath)
}
Param = %1%
0 := 0

command_pid = %2%


xml_path := Param
if(xml_path == "")
{
    msgbox, 请先选择节点
    ExitApp
}

my_xml := new xml("xml")
fileread, xml_file_content,% A_ScriptDir "\..\Menus\超级命令.xml"
my_xml.file := A_ScriptDir "\..\Menus\超级命令.xml"
if(xml_file_content == "")
{
    msgbox, 请先创建节点
    ExitApp
}
my_xml.XML.LoadXML(xml_file_content)
cmds := xml_parse(my_xml)

; Send files to a running instance of the program
If (Files.Length() && (hPrevInst := WinExist("Adventure v")) && Param != "/new") {
    For Each, File in Files {
        SendFile(File, hPrevInst)
    }

    WinActivate ahk_id %hPrevInst%
    ExitApp
}

#Include %A_ScriptDir%\Lib\Scintilla.ahk
#Include %A_ScriptDir%\Include\Globals.ahk

If (!LoadSciLexer(SciLexer)) {
    MsgBox 0x10, %g_AppName% - Error
    , % "Failed to load library """ . SciLexer . """.`n`n" . GetErrorMessage(A_LastError) . "`nThe program will exit."
    ExitApp
}

OnError("ErrorHandler") ; AHK v1.1.29+

g_GetFileInfo := GetProcAddress("Shell32.dll", "SHGetFileInfoW") ; For GetFileIcon
g_SendMessage := GetProcAddress("user32.dll", "SendMessageW") ; SB_UpdateFileDesc

CreateIniFile() ; Settings file creation/location
LoadSettings()

Menu Tray, UseErrorLevel   ; Suppress menu warnings
Menu Tray, Icon, %IconLib% ; Main icon

; Main window
Gui Main: New, +LabelOn +hWndg_hWndMain +Resize +0x2000000 +MinSize680 -DPIScale, %g_AppName% v%g_Version%
Gui Main: Default

; Startup boost: minimum initialization of menu items
AddMenu("MenuFile", "&New File`tCtrl+N", "M_NewTab", IconLib, -2)
Menu MenuEdit, Add, &Undo`tCtrl+Z, Undo
AddMenu("MenuSearch", "&Find...`tCtrl+F", "ShowFindDialog", IconLib, -26)
AddMenu("MenuSession", "Save Session...", "ShowSaveSessionDialog", IconLib, -36)
AddMenu("MenuFavorites", "Add File to Favorites", "M_AddFavorite", IconLib, -38)
Menu MenuView, Add, Tab Bar, MenuHandler
Menu MenuLexer, Add, Text File, M_SetLexType, Radio
Menu MenuOptions, Add, Enable &Autocomplete`tF12, ToggleAutoComplete
AddMenu("MenuRun", "Run with &Associated Application`tF9", "RunFile", IconLib, -55)
AddMenu("MenuTools", "Configure Tools...", "ShowToolsDialog", IconLib, -58)
If (A_PtrSize == 8) {
    AddMenu("MenuAHK", "Run with AHK 64-&bit`tF9", "M_RunScript64", IconLib, -61)
    AddMenu("MenuAHK", "Run with AHK 32-bit`tShift+F9", "M_RunScript32", IconLib, -62)
} Else {
    AddMenu("MenuAHK", "Run with AHK 32-bit`tF9", "M_RunScript32", IconLib, -62)
    AddMenu("MenuAHK", "Run with AHK 64-&bit`tShift+F9", "M_RunScript64", IconLib, -61)
}
AddMenu("MenuHelp", "Adventure &Help File", "OpenHelpFile", IconLib, -90)

Menu MainMenuBar, Add, % " &File ", :MenuFile
Menu MainMenuBar, Add, % " &Edit ", :MenuEdit
Menu MainMenuBar, Add, % " &Search ", :MenuSearch
Menu MainMenuBar, Add, % " Sessio&ns ", :MenuSession
Menu MainMenuBar, Add, % " F&avorites ", :MenuFavorites
Menu MainMenuBar, Add, % " &View ", :MenuView
Menu MainMenuBar, Add, % " Synta&x ", :MenuLexer
Menu MainMenuBar, Add, % " &Options ", :MenuOptions
Menu MainMenuBar, Add, % " &Run ", :MenuRun
Menu MainMenuBar, Add, % " &Tools ", :MenuTools
Menu MainMenuBar, Add, % " AH&K ", :MenuAHK
Menu MainMenuBar, Add, % " &Help ", :MenuHelp
Gui Menu, MainMenuBar

; Initial dimensions of the main window
IniRead g_InitialX, %IniFile%, Window, x
IniRead g_InitialY, %IniFile%, Window, y
IniRead g_InitialW, %IniFile%, Window, w, 952
IniRead g_InitialH, %IniFile%, Window, h, 611
IniRead ShowState, %IniFile%, Window, State, 3 ; SW_MAXIMIZE

If (g_InitialX != "ERROR") {
    SetWindowPlacement(g_hWndMain, g_InitialX, g_InitialY, g_InitialW, g_InitialH, 0)
} Else {
    Gui Show, w%g_InitialW% h%g_InitialH% Hide
}

Gui Font, s9, Segoe UI

Gui Add, StatusBar, hWndg_hStatusBar gSB_Handler
GuiControlGet g_StatusBar, Pos, %g_hStatusBar%

Gui Add, Edit, hWndg_hHiddenEdit x0 y0 w0 h0

CreateTabControl()

LoadFileTypes() ; From FileTypes.xml

; Initial instance of Scintilla
Sci_GetIdealSize(SciX, SciY, SciW, SciH)
Sci[1] := New Scintilla(g_hWndMain, SciX, SciY, SciW, SciH, 0x50000000, 0x200)

; Scintilla theme
If (!LoadTheme(g_ThemeFile, g_ThemeName)) {
    LoadTheme(g_ThemeFile := A_ScriptDir . "\Themes\Themes.xml", "Shenanigans")
}
Sci_Config(1, g_DefLexType)

CreateToolbar()

ShowWindow(g_hWndMain, ShowState)
WinActivate ahk_id %g_hWndMain%

ApplyToolbarSettings()
SetStatusBar()
Sci[1].GrabFocus()
SetIndent()
#Include %A_ScriptDir%\Include\Menu.ahk
Try {
    Menu MenuViewTabBar, Check, % (g_TabBarPos == 1 ? "Top" : "Bottom")
    Menu MenuViewTabBar, Check, % (g_TabBarStyle == 1 ? "Standard" : "Buttons")
}

; Dispatch messages
OnMessage(0x204, "OnWM_RBUTTONDOWN")
OnMessage(0x100, "OnWM_KEYDOWN")
OnMessage(0x104, "OnWM_SYSKEYDOWN")
OnMessage(0x203, "OnWM_LBUTTONDBLCLK")
OnMessage(0x4A,  "OnWM_COPYDATA")
OnMessage(0x1C,  "OnWM_ACTIVATEAPP")
OnMessage(0x211, "OnWM_ENTERMENULOOP")
OnMessage(0x212, "OnWM_EXITMENULOOP")
OnMessage(0x117, "OnWM_INITMENUPOPUP")
OnMessage(0x214, "OnWM_SIZING")
OnMessage(0x1A,  "OnWM_SETTINGCHANGE")
OnMessage(10000, "CustomMessage")
OnMessage(0x16,  "OnWM_ENDSESSION")
If (g_ToolDesc) {
    OnMessage(0x11F, "OnWM_MENUSELECT")
}

;LoadFileHistory()
LoadRecentMenu()

If (Files.Length()) {
    OpenFilesEx(Files)

} Else If (g_LoadLastSession) {
    LoadStartupSession(g_LastSessionName)
}

LoadTemplatesMenu()
g_hCursorDragMove := LoadImage(A_ScriptDir . "\Icons\DragMove.cur", 32, 32, 2)
g_hWndShell := CreateShellMenuWindow()
CreateTabContextMenu()
LoadAhkSettings()
SetAhkPath()
StartAutoSave()
LoadSessionsMenu()
LoadFavoritesMenu()
LoadToolsMenu()
LoadSyntaxMenu(g_LexTypes)
LoadAhkHelpMenu()
SetMenuColor("MainMenuBar", g_MenuColor)

If (g_LoadLastSession) {
    Try {
        Menu MenuSavedSessions, Default, %g_LastSessionName%
    }
}

LoadUserList(g_DefUserList)

PreloadTypes := ["AHK"]
PreloadAutoComplete(PreloadTypes)

DeleteOldBackups()

If (!A_IsUnicode) {
    Gui Main: +OwnDialogs
    MsgBox 0x10, Error, %g_AppName% is incompatible with the ANSI build of AutoHotkey.
    ExitApp
}


OpenFile(A_ScriptDir "\..\tmp\tmp.ahk")
Return ; End of the auto-execute section.

SetWindowTitle(FullPath := "") {
    WinSetTitle ahk_id%g_hWndMain%,, % g_AppName . " v" . g_Version . (FullPath != "" ? " - " . FullPath : "")
}

TabHandler() {
    Local n := TabEx.GetSel()

    ShowWindow(Sci[n].hWnd)
    Loop % Sci.Length() {
        If (A_Index != n) {
            ShowWindow(Sci[A_Index].hWnd, 0)
        }
    }

    Sci[n].GrabFocus()
    UpdateToolbar(n)
    UpdateStatusBar(n)
    SetWindowTitle(Sci[n].FullName)
    Sci[n].LastAccessTime := A_Now . A_MSec
    CheckModified(n)
}

CreateToolbar() {
    Local TB_IL := IL_Create(32), TB_Btns, Extra

    IL_Add(TB_IL, IconLib, -2)   ; New Tab
    IL_Add(TB_IL, IconLib, -6)   ; Open
    IL_Add(TB_IL, IconLib, -8)   ; Save
    IL_Add(TB_IL, IconLib, -9)   ; Save All
    IL_Add(TB_IL, IconLib, -21)  ; Cut
    IL_Add(TB_IL, IconLib, -22)  ; Copy
    IL_Add(TB_IL, IconLib, -23)  ; Paste
    IL_Add(TB_IL, IconLib, -19)  ; Undo
    IL_Add(TB_IL, IconLib, -20)  ; Redo
    IL_Add(TB_IL, IconLib, -26)  ; Find
    IL_Add(TB_IL, IconLib, -27)  ; Replace
    IL_Add(TB_IL, IconLib, -29)  ; Find in Files
    IL_Add(TB_IL, IconLib, -31)  ; Mark Current Line
    IL_Add(TB_IL, IconLib, -32)  ; Mark Selected Text
    IL_Add(TB_IL, IconLib, -34)  ; Clear All Markers
    IL_Add(TB_IL, IconLib, -44)  ; Line Numbers
    IL_Add(TB_IL, IconLib, -45)  ; Symbols Margin
    IL_Add(TB_IL, IconLib, -46)  ; Fold Margin
    IL_Add(TB_IL, IconLib, -49)  ; Syntax Highlighting
    IL_Add(TB_IL, IconLib, -50)  ; AutoBrackets
    IL_Add(TB_IL, IconLib, -51)  ; Autocomplete
    IL_Add(TB_IL, IconLib, -52)  ; Calltips
    IL_Add(TB_IL, IconLib, -53)  ; Show White Spaces
    IL_Add(TB_IL, IconLib, -47)  ; Word Wrap
    IL_Add(TB_IL, IconLib, -48)  ; Read Only
    IL_Add(TB_IL, IconLib, -55)  ; Execute
    IL_Add(TB_IL, IconLib, -90)  ; Help

    TB_Btns = 
    (LTrim
        -
        New File
        Open
        Save
        Save All
        -
        Cut
        Copy
        Paste
        -
        Undo,,,, 2110
        Redo,,,, 2111
        -
        Find
        Replace
        Find in Files
        -
        Mark Current Line
        Mark Selected Text
        Clear All Markers
        -
        Line Numbers,,,, 2140
        Symbols Margin,,,, 2141
        Fold Margin,,,, 2150
        Syntax Highlighting,,,, 2180
        AutoBrackets,,,, 2181
        Autocomplete,,,, 2185
        Calltips,,,, 2186
        Show White Spaces and Line Endings,,,, 2190
        -
        Word Wrap,,,, 2160
        Read Only,,,, 2170
        -
        Execute,,, DROPDOWN SHOWTEXT
        -
        Help
    )

    Extra := (g_TabBarPos == 1) ? "+E0x200" : ""
    g_hToolbar := Toolbar_Create("ToolbarHandler", TB_Btns, TB_IL, "FLAT LIST TOOLTIPS", Extra, "", 65536, 9)
}

ToolbarHandler(hWnd, Event, Text, Pos, Id, Left, Bottom) {
    Static SkipClick := 0
    Local n, ItemID, FullPath, WorkingDir, FileExt, CMFlags := 0, Verb

    If (Event == "DropDown") {
        If (!g_ShellMenu1) {
            ShowShellMenuDlg()
            Return
        }

        SkipClick := 1

        If (g_ShellMenu1 && !DllCall("IsMenu", "Ptr", g_hShellMenu) && WinExist("ahk_id" . g_hWndShell)) {
            n := TabEx.GetSel()
            FullPath := Sci[n].FullName
            If (!FileExist(FullPath)) {
                Return
            }

            SplitPath FullPath,, WorkingDir, FileExt
            FixRootDir(WorkingDir)

            If (IsAhkFileExt(FileExt)) {
                CMFlags |= 0x20 ; CMF_NODEFAULT
            }

            If (GetKeyState("Shift", "P")) {
                CMFlags |= 0x100 ; CMF_EXTENDEDVERBS
            }

            g_hShellMenu := GetShellContextMenu(FullPath, CMFlags)

            ItemID := ShowPopupMenu(g_hShellMenu, 0x100, Left, Bottom, g_hWndShell) ; TPM_RETURNCMD

            If (ItemID) {
                Verb := GetShellMenuItemVerb(g_pIContextMenu, ItemID)
                OutputDebug Shell context menu item: ID: %ItemID%, Verb: "%Verb%".

                If (Verb == "paste") {
                    PasteFile(WorkingDir)

                } Else {
                    If (Sci[n].GetModify()) {
                        Gui Main: +OwnDialogs
                        MsgBox 0x4, %g_AppName%, Save the file before proceeding with the requested action?
                        IfMsgBox Yes, {
                            If (!SaveFile(n)) {
                                SkipClick := 0
                                DestroyShellMenu(g_hShellMenu)
                                Return
                            }
                        }
                    }

                    RunShellMenuCommand(g_pIContextMenu, ItemID, WorkingDir, g_hWndMain, Left, Bottom)
                }

                SkipClick := 0
            }

            Else {
                WinActivate ahk_id %g_hWndMain%
                SkipClick := 1
            }

            DestroyShellMenu(g_hShellMenu)
        }

        Return
    }

    If (Event != "Click") {
        Return
    }

    If (SkipClick > 0) {
        SkipClick := 0
        Return
    }

    If (Text == "Execute") {
        Execute()

    } Else If (Text == "New File") {
        NewTab(g_DefLexType)
    } Else If (Text == "Open") {
        ChooseFile()
    } Else If (Text == "Save") {
        SaveFile(TabEx.GetSel())
    } Else If (Text == "Save All") {
        SaveAllFiles()

    } Else If (Text == "Undo") {
        Undo()
    } Else If (Text == "Redo") {
        Redo()

    } Else If (Text == "Cut") {
        Cut()
    } Else If (Text == "Copy") {
        CopyEx(TabEx.GetSel(), CRLF, "", 0x1)
    } Else If (Text == "Paste") {
        Paste()

    } Else If (Text == "Find") {
        ShowFindDialog()
    } Else If (Text == "Replace") {
        ShowReplaceDialog()
    } Else If (Text == "Find in Files") {
        FindInFiles()

    } Else If (Text == "Mark Current Line") {
        ToggleBookmark(g_MarkerBookmark)
    } Else If (Text == "Mark Selected Text") {
        MarkSelectedText()
    } Else If (Text == "Clear All Markers") {
        ClearAllMarkers()

    } Else If (Text == "Line Numbers") {
        ToggleLineNumbers()
    } Else If (Text == "Symbols Margin") {
        ToggleSymbolMargin()
    } Else If (Text == "Fold Margin") {
        ToggleCodeFolding()
    } Else If (Text == "Word Wrap") {
        ToggleWordWrap()
    } Else If (Text == "Read Only") {
        ToggleReadOnly()
    } Else If (Text == "Syntax Highlighting") {
        ToggleSyntaxHighlighting()
    } Else If (Text == "AutoBrackets") {
        ToggleAutoBrackets()
    } Else If (Text == "Autocomplete") {
        ToggleAutoComplete()
    } Else If (Text == "Calltips") {
        ToggleCalltips()
    } Else If (ID == 2190) { ; Show White Spaces and Line Endings
        ToggleAllVisible()

    } Else If (Text == "Help") {
        OpenHelpFile()
    }
}

SetStatusBar() {
    Gui Main: Default
    SB_SetParts()
    ; File Type | Line:Pos | Selections | Doc Status | Typing Mode | File Encoding
    Gui +DPIScale
    SB_SetParts(212, 180, 212, 144, 62)
    Gui -DPIScale
    SB_SetText(g_Overtype ? "Overtype" : "    Insert", g_SBP_OverMode)
    SB_SetText(A_FileEncoding, g_SBP_Encoding)
    UpdateStatusBar(1)
}

SB_Handler() {
    If (A_GuiEvent == "RightClick") {
        If (A_EventInfo == g_SBP_Encoding) {
            UpdateEncodingMenu(TabEx.GetSel(), MenuGetHandle("MenuEncoding"))
            Menu MenuEncoding, Show

        } Else If (A_EventInfo == g_SBP_CursorPos) {
            ShowJumpList()
        }
    }
}

; Message handling

OnSize(GuiHwnd, EventInfo, GuiWidth, GuiHeight) {
    If (EventInfo == SIZE_MINIMIZED) {
        Return
    }

    Gui Main: Default
    GuiControlGet, TabCtl, Pos, %g_hTab%
    GuiControl Move, %g_hToolbar%, w%A_GuiWidth%

    If (g_TabBarPos == 1) {
        TabCtlY := g_ToolbarH + g_TBEdgeH
        SciY := TabCtlY + TabCtlH ; + 1
        SciH := GuiHeight - g_StatusBarH - SciY ; + 1 ; g_TBEdgeH
    } Else {
        TabCtlY := GuiHeight - g_StatusBarH - TabCtlH
        SciY := g_ToolbarH
        SciH := GuiHeight - g_StatusBarH - TabCtlH - SciY
    }

    TabCtlW := GuiWidth
    SciW := GuiWidth + 1

    GuiControl MoveDraw, %g_hTab%, y%TabCtlY% w%TabCtlW%

    Loop % Sci.Length() {
        SetWindowPos(Sci[A_Index].hWnd, 0, 0, SciW, SciH, 0, 0x16) ; SWP_NOMOVE | SWP_NOZORDER | SWP_NOACTIVATE
    }
}

OnDropFiles(GuiHwnd, aFiles, CtrlHwnd, X, Y) {
    ExpandLinks(aFiles)
    OpenFilesEx(aFiles)
}

ExpandLinks(ByRef aFiles) {
    Loop % aFiles.Length() {
        If (GetFileExt(aFiles[A_Index]) = "LNK") {
            FileGetShortcut % aFiles[A_Index], ResolvedTarget
            aFiles[A_Index] := ResolvedTarget
        }
    }
}

OnWM_ENDSESSION(wParam, lParam) {
    If (g_RememberSession) {
        SaveSessionOnExit()
    }

    Quit()
}

OnClose() { ; M
    If (g_RememberSession) {
        SaveSessionOnExit()
    }

    If (g_AskToSaveOnExit) {
        CloseAllTabs(True)
    } Else {
        Quit()
    }

    Return 1 ; By default, GuiClose as a function hides the GUI. This can be prevented by returning true.
}

Quit() {
    If (g_DbgStatus) {
        Debug_Stop()
        DBGp_StopListening(g_DbgSocket)
    }

    Loop % Sci.Length() {
        AddToFileHistory(A_Index, Sci[A_Index].FullName)
    }

    SaveSettings()

    DllCall("DestroyCursor", "Ptr", g_hCursorDragMove)
    DllCall("DestroyWindow", "Ptr", g_hWndShell)
    IL_Destroy(TabExIL)
    FileDelete %g_TempFile%

    ExitApp
}

OnWM_LBUTTONDBLCLK(wParam, lParam, msg, hWnd) {
    If (hWnd == g_hWndMain) {
        NewTab(g_DefLexType)
        Return
    }

    Return
}

OnWM_RBUTTONDOWN(wParam, lParam, msg, hWnd) {
    Local x, y

    If (hWnd == g_hTab) {
        g_TabIndex := TabHitTest(g_hTab, lParam & 0xFFFF, lParam >> 16)
        ShowTabContextMenu()
        Return 0

    } Else If (GetClassName(hWnd) == "Scintilla") {
        GetMousePos(x, y, "Window")
        ShowSciPopupMenu(x, y)
        Return 0
    }

    ;Return 0
}

OnWM_KEYDOWN(wParam, lParam, msg, hWnd) {
    Local hWndActive, ShiftP, CtrlP, NextTab, n

    hWndActive := WinExist("A")

    ShiftP := GetKeyState("Shift", "P")
    CtrlP := GetKeyState("Ctrl", "P") && !GetKeyState("vkA5", "P") ; vkA5: AltGr = Ctrl + Alt

    ; Main window
    If (hWndActive == g_hWndMain) {
        If (CtrlP) {
            If (wParam == 9) { ; Ctrl + Tab
                NextTab := TabEx.GetSel()
                If (ShiftP) {
                    NextTab := (NextTab == 1) ? TabEx.GetCount() - 1 : NextTab - 2
                } Else If (NextTab == TabEx.GetCount()) {
                    NextTab := 0
                }
                SendMessage 0x1330, NextTab,,, ahk_id %g_hTab% ; TCM_SETCURFOCUS.
                Sleep 0 ; This line and the next are necessary only for certain tab controls.
                SendMessage 0x130C, NextTab,,, ahk_id %g_hTab% ; TCM_SETCURSEL
                TabHandler()
                Return 0

            } Else If (wParam == 13) { ; Ctrl + Enter
                M_AutoComplete()
                Return 0

            } Else If (wParam == 32) { ; Ctrl + Space
                M_ShowCalltip()
                Return 0

            } Else If (wParam == 93) { ; Ctrl + AppsKey
                ShowJumpList()
                Return 0

            } Else If (wParam == 0x6B) { ; ^Numpad+
                ZoomIn()
                Return 0

            } Else If (wParam == 0x6D) { ; ^Numpad-
                ZoomOut()
                Return 0

            } Else If (wParam == 0x60) { ; ^Numpad0
                ResetZoom()
                Return 0

            } Else If (ShiftP && wParam == 0x26) { ; Ctrl + Shift + Up
                MoveLineUp()
                Return 0

            } Else If (ShiftP && wParam == 0x28) { ; Ctrl + Shift + Down
                MoveLineDown()
                Return 0

            } Else If (wParam == 0x28) { ; Ctrl + Down
                DuplicateLine()
                Return 0

            } Else If (ShiftP && wParam == 34) { ; Ctrl + Shift + Pg Dn
                NextCalltip()
                Return 0

            } Else If (ShiftP && wParam == 33) { ; Ctrl + Shift + Pg Up
                NextCalltip(1)
                Return 0
            }
        }

        If (wParam == 113) { ; F2
            ToggleBookmark(ShiftP ? g_MarkerError : g_MarkerBookmark)
            KeyWait F2, T.3 ; Wait for 300 ms before changing the bookmark icon
            If (ErrorLevel) {
                RemoveBookmark(g_MarkerBookmark)
                ToggleBookmark(g_MarkerError)
            }
            Return 0

        } Else If (wParam == 114) { ; F3
            If (ShiftP) {
                GoSub FindPrev
            } Else {
                GoSub FindNext
            }
            Return 0

        } Else If (wParam == 0x2D) { ; Insert
            If (CtrlP) {
                InsertCalltip()
                Return 0
            } Else {
                Gui Main: Default
                SB_SetText((g_Overtype := !g_Overtype) ? "Overtype" : "    Insert", g_SBP_OverMode)
                Return ; No return value, either true of false, in this case
            }

        } Else If (wParam == 27) { ; Esc
            Return EscPressed()
        }

    } Else If (hWndActive == g_hWndFindReplace) {
        ; Ctrl+F, release F, press V: CtrlP is false
        /*
        If (wParam == 86) { ; ^V
            KeyWait Ctrl, LD T.0 ; Logically pressed
            If (!ErrorLevel) {
                Send ^V
                Return False
            }
        }
        */

    } Else If (hWndActive == g_hWndFHM && wParam == 0x74) {
        FHM_OnToolbar(0, "Click", "Refresh (F5)", 0, 0)
        Return False
    }

    ; Any window
    If (CtrlP) {
        If (wParam == 120) { ; ^F9
            RunSelectedText()
            Return 0

        } Else If (wParam == 78) { ; ^N
            NewTab(g_DefLexType)
            Return 0

        } Else If (wParam == 87) { ; ^W
            M_CloseTab()
            Return 0

        } Else If (wParam == 79) { ; ^O
            ChooseFile()
            Return 0

        } Else If (ShiftP && wParam == 83) { ; ^+S
            SaveFileAs(TabEx.GetSel())
            Return 0

        } Else If (wParam == 83) { ; ^S
            SaveFile(TabEx.GetSel())
            Return 0

        } Else If (wParam == 71) { ; ^G
            ShowGoToLineDialog()
            Return 0
        }
    }

    If (wParam == 120) { ; F9
        Execute()
        Return 0

    } Else If (wParam == 0x70) { ; F1
        n := TabEx.GetSel()
        Sci[n].Type == "AHK" ? OpenAhkHelpFile(GetSelectedText(n)) : OpenHelpFile()
        Return 0

    } Else If (wParam == 93) { ; AppsKey
        If (GetClassName(GetFocus()) == "Scintilla") {
            ShowSciPopupMenu(A_CaretX, A_CaretY)
        }
        Return 0

    } Else If (wParam == 115) { ; F4
        ToggleBreakpoint()
        Return 0

    ; AHK debugger
    } Else If ((wParam > 115 && wParam < 120) || wParam == 19) {
        If (Sci[TabEx.GetSel()].Type != "AHK") {
            Return
        }

        If (wParam == 116) { ; F5
            Debug_Start() ; Start/continue

        } Else If (wParam == 117) { ; F6
            ShiftP ? Debug_StepOut() : Debug_StepInto()

        } Else If (wParam == 118) { ; F7
            Debug_StepOver()

        } Else If (wParam == 119) { ; F8
            Debug_Stop()

        } Else If (wParam == 19) { ; Pause/Break
            Debug_Pause()
        }

        Return 0
    }
}

OnWM_SYSKEYDOWN(wParam, lParam, msg, hWnd) {
    If (wParam == 120) { ; Alt+F9
        If (Sci[TabEx.GetSel()].Type == "AHK" && g_AhkPathEx != "") {
            RunScript(g_AhkPathEx)
        }
        Return False

    } Else If (wParam == 116) { ; Alt+F5
        Debug_Start(g_AhkPathEx)
        Return False
    }
}

; File selection dialog
ChooseFile() { ; M
    Static Filters := ""
    Local n, StartPath, Flags, Files, aFiles

    n := TabEx.GetSel()
    If (Sci[n].FullName != "") {
        SplitPath % Sci[n].FullName,, StartPath
    } Else {
        StartPath := g_OpenDir
    }

    If (!g_FiltersLoaded || Filters == "") {
        If (LoadFileFilters()) {
            Loop % g_aFilters.Length() {
                Filters .= g_aFilters[A_Index].Value . "|"
            }
        }
    }
    If (Filters == "") {
        Filters := "All Files (*.*)"
    }

    ; OFN_: EXPLORER, ALLOWMULTISELECT, PATHMUSTEXIST, FILEMUSTEXIST, HIDEREADONLY
    Flags := 0x80000 | 0x200 | 0x800 | 0x1000 | 0x4
    If (!SelectFileEx(Files, 0, Flags, g_hWndMain, "Open", StartPath, Filters)) {
        Return 0
    }

    aFiles := StrSplit(Files, "`n")
    OpenFilesEx(aFiles)

    Return 1
}

IsFileOpened(FullPath) {
    Loop % Sci.Length() {
        If (Sci[A_Index].FullName = FullPath) {
            Return A_Index
        }
    }
    Return 0
}

OpenFile(FullPath, Reload := 0, FailSilently := 0, Encoding := "UTF-8-RAW") {
    Local n, oFile, Text, Filename, FileExt, Icon, Type, Timestamp

    n := IsFileOpened(FullPath)
    If (n && !Reload) {
        TabEx.SetSel(n)
        Return n
    }

    _Open:
    Try {
        oFile := FileOpen(FullPath, "r", Encoding)

        ; Encodings currently supported by Adventure: UTF-8, UTF-8 without BOM, UTF-16 LE.
        ; Files that do not have a UTF-8 or UTF-16 LE byte order mark are saved as UTF-8 without BOM.
        Encoding := oFile.Position ? oFile.Encoding : "UTF-8-RAW"
        Text := oFile.Read()
        oFile.Close()

    } Catch {
        If (FailSilently) {
            Return 0
        }

        MsgBox 0x15, Error, % "File: " . FullPath . "`n`n" . GetErrorMessage(A_LastError)
        IfMsgBox Retry, {
            GoTo _Open
        } Else {
            Return 0
        }
    }

    SplitPath FullPath, Filename, g_OpenDir, FileExt

    n := TabEx.GetSel()
    Type := GetLexTypeByExt(FileExt)
    Icon := GetIconForTab(FullPath, FileExt)

    ; New tab
    If ((Sci[n].Filename != "" || Sci[n].GetModify()) && !Reload) {
        n := NewTab(Type, Icon, Filename)

    ; Existing tab
    } Else {
        TabEx.SetText(n, Filename)
        TabEx.SetIcon(n, Icon)
        SetWindowTitle(FullPath)

        Sci_Config(n, Type)

        Gui Main: Default
        SB_SetText(GetFileTypeDesc(FileExt), g_SBP_FileType)
    }

    Sci[n].SetText("", Text, 1)
    Sci[n].EmptyUndoBuffer()
    Sci[n].FullName := FullPath
    Sci[n].Filename := Filename
    Sci[n].Encoding := Encoding
    Sci[n].SetSavePoint()

    FileGetTime Timestamp, %FullPath%
    Sci[n].LastWriteTime := Timestamp

    AddToRecentFiles(FullPath)

    Return n
}

OpenFileEx(FullPath, Reload := 0, Metadata := 1) {
    Local n, Index

    n := OpenFile(FullPath, Reload)
    If (n && Metadata) {
        Index := GetFileHistoryIndex(FullPath)
        If (Index) {
            ApplyMetadata(n, g_aoFiles[Index])
        }
    }

    Return n
}

OpenFiles(aFiles, ActiveTab := 0, FailSilently := 0) {
    Loop % aFiles.Length() {
        OpenFile(aFiles[A_Index], 0, FailSilently)
    }

    If (ActiveTab) {
        Sleep -1
        TabEx.SetSel(ActiveTab)
    }
}

OpenFilesEx(aFiles, ActiveTab := 0, Metadata := 1) {
    Local n, FullPath, Index

    DllCall("LockWindowUpdate", "Ptr", g_hWndMain)

    Loop % aFiles.Length() {
        FullPath := aFiles[A_Index]
        n := OpenFile(FullPath)
        If (n) {
            Index := GetFileHistoryIndex(FullPath)
            If (Index) {
                ApplyMetadata(n, g_aoFiles[Index])
            }
        }
    }

    If (ActiveTab) {
        Sleep -1
        TabEx.SetSel(ActiveTab)
    }

    DllCall("LockWindowUpdate", "Ptr", 0)
}

OpenSingleFile:
    OpenFileEx(A_ThisMenuItem)
Return

M_ReopenFile() {
    ReopenFile(TabEx.GetSel())
}

ReopenFile(n) {
    Local Result

    If (Sci[n].FullName == "") {
        Return 0
    }

    If (n != TabEx.GetSel()) {
        TabEx.SetSel(n)
    }

    If (Sci[n].GetModify()) {
        Result := MessageBox(g_hWndMain, "The file was modified. Save before reloading?", Sci[n].Filename, 0x33)
        If ((Result == 6 && !SaveFile(n)) || Result == 2) { ; Yes + !Save || Cancel
            Return 0
        }
    }

    AddToFileHistory(n, Sci[n].FullName)

    Return OpenFileEx(Sci[n].FullName, True)
}

SaveFileAs:
    SaveFileAs(TabEx.GetSel())
Return

SaveFileAs(n) {
    Local StartPath, SelectedFile, Filename, FileExt, LexType

    TabEx.SetSel(n)

    StartPath := (Sci[n].Filename != "") ? Sci[n].FullName : g_SaveDir

    Gui Main: +OwnDialogs
    FileSelectFile SelectedFile, S16, %StartPath%, Save, % GetFileFilter(n)
    If (ErrorLevel) {
        Return
    }

    SplitPath SelectedFile, Filename,, FileExt
    If (FileExt == "") {
        DefExt := GetDefaultFileExt(Sci[n].Type)
        If (DefExt != "" && !FileExist(SelectedFile . "." . DefExt)) {
            SelectedFile .= "." . DefExt
            SplitPath SelectedFile, Filename,, FileExt
        }
    }

    Sci[n].FullName := SelectedFile
    Sci[n].Filename := Filename

    LexType := GetLexTypeByExt(FileExt)
    If (LexType != "") { ; If (LexType != Sci[n].Type)
        Sci_Config(n, LexType)
    }

    SetWindowTitle(SelectedFile)

    Return SaveFile(n)
}

SaveFile:
    SaveFile(TabEx.GetSel())
Return

SaveFile(n) {
    Local SciText, FullPath, Encoding, TempName, Timestamp

    If (Sci[n].Filename == "") {
        Return SaveFileAs(n)
    }

    SciText  := GetText(n)
    FullPath := Sci[n].FullName
    Encoding := GetSaveEncoding(n)


    write2xml(xml_path, SciText)

    ; Backup the file before saving
    If (g_BackupOnSave) {
        If (BackupDirCreated()) {
            TempName := GetTempFileName(g_BackupDir, "ahk.tmp")
            If (FileExist(FullPath)) {
                FileCopy %FullPath%, %TempName%, 1
            } Else {
                FileAppend %SciText%, %TempName%, %Encoding%
            }
        }
    }

    If (WriteFile(FullPath, SciText, Encoding) < 0) {
        SetWindowTitle("Error saving file: " . FullPath)
        Return 0
    }

    Sci[n].SetSavePoint()
    SavePointChanged(n)
    TabEx.SetIcon(n, GetIconForTabN(n))
    Repaint(Sci[n].hWnd) ; ?

    SplitPath FullPath,, g_SaveDir

    AddToRecentFiles(FullPath)

    FileGetTime Timestamp, %FullPath%
    Sci[n].LastWriteTime := Timestamp

    Return 1
}

SaveAllFiles() { ; M
    Loop % Sci.Length() {
        If (Sci[A_Index].GetModify()) {
            SaveFile(A_Index)
        }
    }
}

WriteFile(FullPath, String, Encoding := "UTF-8") {
    Local f, Bytes

    f := FileOpen(FullPath, "w", Encoding)
    If (!IsObject(f)) {
        ErrorMsgBox("Error saving """ . FullPath . """.`n`n" . GetErrorMessage(A_LastError), "Main")
        Return -1
    }

    Bytes := f.Write(String)
    f.Close()

    Return Bytes
}

GetSaveEncoding(n) {
    Local Encoding

    If (Sci[n].Encoding == "CP1252") {
        Encoding := "UTF-8-RAW"
    } Else {
        Encoding := IsValidEncoding(Sci[n].Encoding) ? Sci[n].Encoding : "UTF-8"
    }

    Return Encoding
}

IsValidEncoding(Encoding) {
    Local K, V

    For K, V in g_oEncodings {
        If (Encoding == K) {
            Return 1
        }
    }

    Return 0
}

SetSaveEncoding(ItemName) { ; M
    Local n := TabEx.GetSel()

    If (ItemName == "UTF-16 LE") {
        Sci[n].Encoding := "UTF-16"
    } Else If (ItemName == "UTF-8 without BOM") {
        Sci[n].Encoding := "UTF-8-RAW"
    } Else {
        Sci[n].Encoding := "UTF-8"
    }

    Gui Main: Default
    SB_SetText(ItemName, g_SBP_Encoding)

    Sci[n].FullName != "" ? SaveFile(n) : SaveFileAs(n)
}

GetFileEncodingDisplayName(n) {
    Local Encoding := g_oEncodings[Sci[n].Encoding]
    Return Encoding != "" ? Encoding : "UTF-8"
}

SaveCopy() { ; M
    Local n := TabEx.GetSel(), FileDir, FileExt, NameNoExt, StartPath, SelectedFile

    If (Sci[n].Filename != "") {
        SplitPath % Sci[n].FullName,, FileDir, FileExt, NameNoExt
        StartPath := FileDir . "\" . NameNoExt . " - Copy." . FileExt
    } Else {
        StartPath := g_SaveDir
    }

    Gui Main: +OwnDialogs
    FileSelectFile SelectedFile, S16, %StartPath%, Save a Copy, % GetFileFilter(n)
    If (ErrorLevel) {
        Return
    }

    If (WriteFile(SelectedFile, GetText(n), GetSaveEncoding(n)) > -1) {
        AddToRecentFiles(SelectedFile)
    }
}

AddMenu(MenuName, MenuItemName := "", Subroutine := "MenuHandler", Icon := "", IconIndex := 0) {
    Menu, %MenuName%, Add, %MenuItemName%, %Subroutine%

    If (Icon != "") {
        Menu, %MenuName%, Icon, %MenuItemName%, %Icon%, %IconIndex%
    }
}

MenuAddFile(MenuName, MenuItem, MenuHandler, FullPath) {
    Try {
        Menu, %MenuName%, Add, %MenuItem%, %MenuHandler%
        Menu, %MenuName%, Icon, %MenuItem%, % "HICON:" . GetFileIcon(FullPath)
    }
}

MenuHandler:
    MessageBox(g_hWndMain, "Not implemented yet.", g_AppName, 0x40)
Return

AddToRecentFiles(FullPath) {
    Local ItemPos, ItemID
    Static hMenuRecent := 0

    If (!FileExist(FullPath)) {
        Return 0
    }

    Loop % g_aRecentFiles.Length() {
        If (FullPath = g_aRecentFiles[A_Index]) { ; Case-insensitive filename comparison
            Try {
                Menu MenuRecent, Delete, %FullPath%
            }
            g_aRecentFiles.RemoveAt(A_Index)
            Break
        }
    }
    g_aRecentFiles.Push(FullPath)

    Try {
        Menu MenuRecent, Insert, 1&, %FullPath%, OpenSingleFile
        Menu MenuRecent, Icon, %FullPath%, % "HICON:" . GetFileIcon(FullPath)
        Menu MenuFile, Enable, Recent &Files
    }

    If (!hMenuRecent) {
        hMenuRecent := MenuGetHandle("MenuRecent")
    }

    If (g_aRecentFiles.Length() > g_MaxRecent) {
        ItemPos := g_aRecentFiles.Length() - 1 ; Zero-based
        ItemID := GetMenuItemID(hMenuRecent, ItemPos)
        DeleteMenu(hMenuRecent, ItemID, 0)
        g_aRecentFiles.RemoveAt(1)
    }

    Return 1
}

LoadRecentMenu() {
    Local aItems
    aItems := StrSplit(g_oXMLFileHistory.selectSingleNode("/history/recent").getAttribute("items"), "|")

    Loop % aItems.Length() {
        AddToRecentFiles(g_aoFiles[aItems[A_Index]].Path)
    }
}

OpenAllRecentFiles() { ; M
    Local a := []

    Loop % g_aRecentFiles.Length() {
        a.Push(g_aRecentFiles[A_Index])
    }

    OpenFilesEx(a)
}

LoadSessionsMenu() {
    Local oNodes, oNode, Name, aItems, aFiles, Active

    oNodes := g_oXMLFileHistory.selectNodes("/history/sessions/session")
    For oNode in oNodes {
        Name := oNode.getAttribute("name")

        aItems := StrSplit(oNode.getAttribute("items"), "|")
        aFiles := []
        Loop % aItems.Length() {
            aFiles.Push(g_aoFiles[aItems[A_Index]].Path)
        }

        Active := oNode.getAttribute("active")

        AddSession(Name, aFiles, aItems, Active ? Active : 1)
    }

    If (!oNodes.length) {
        Menu MenuSession, Disable, Saved Sessions
    } Else {
        EnableSubMenu("MenuSession", "Saved Sessions", "MenuSavedSessions")
    }
}

LoadFavoritesMenu() {
    Local aItems := StrSplit(g_oXMLFileHistory.selectSingleNode("/history/favorites").getAttribute("items"), "|")
    If (aItems.Length()) {
        Menu MenuFavorites, Add
    }

    Loop % aItems.Length() {
        AddFavorite(g_aoFiles[aItems[A_Index]].Path)
    }
}

ShowAbout() {
    Gui About: New, LabelAbout -MinimizeBox OwnerMain
    Gui Color, White
    Gui Add, Picture, x9 y10 w64 h64, %IconLib%
    Gui Font, s20 W700 Q4 c00ADEF, Verdana
    Gui Add, Text, x80 y8 w200, Adventure
    ResetFont()
    Gui Add, Text, x245 y23, v%g_Version%
    FileGetVersion SciVer, %SciLexer%
    Gui Add, Text, x81 y41, Scintilla %SciVer%
    Gui Add, Text, x81 y58 w365 +0x4000
    , % "AutoHotkey " . A_AhkVersion
    . " " . (A_IsUnicode ? "Unicode" : "ANSI")
    . " " . (A_PtrSize == 8 ? "64-bit" : "32-bit")
    Gui Add, Link, x81 y102 w200 h16
    , <a href="https://sourceforge.net/projects/autogui/">SourceForge Project Page</a>
    Gui Add, Link, x81 y124 w200 h16
    , <a href="https://autohotkey.com/boards/viewforum.php?f=64">Adventure in the AHK Forum</a>
    Gui Add, Link, x81 y146 w200 h16, <a href="Help\Credits.htm">Credits</a>
    Gui Add, Text, x0 y189 w463 h1 +0x5
    Gui Add, Text, x0 y190 w463 h48 -Background
    Gui Add, Button, gAboutClose x371 y203 w80 h24 Default, OK
    Gui Show, w463 h239, About
    ControlFocus Button1, About
    Gui +LastFound
    SendMessage 0x80, 0, DllCall("LoadIcon", "Ptr", 0, "Ptr", 32516, "Ptr") ; WM_SETICON, OIC_INFORMATION
    SetModalWindow(1)
}

AboutClose() {
    AboutEscape:
    SetModalWindow(0)
    Gui About: Destroy
    Return
}

CreateTabContextMenu() {
    AddMenu("MenuTabContext", "Close Tab", "TCM_CloseTab", IconLib, -17)
    Menu MenuTabContext, Add
    AddMenu("MenuTabContext", "Duplicate Tab Contents", "TCM_DuplicateTab", IconLib, -12)
    AddMenu("MenuTabContext", "Copy File Path to Clipboard", "TCM_CopyFilePath", IconLib, -13)
    AddMenu("MenuTabContext", "Open Folder in File Manager", "TCM_OpenFolder", IconLib, -14)
    AddMenu("MenuTabContext", "Open in a New Window", "TCM_OpenNewInstance", IconLib, -11)
    Menu MenuTabContext, Add
    If (g_ShellMenu2) {
        AddMenu("MenuTabContext", "Explorer Context Menu", "ShowShellMenuDlg", IconLib, -57)
    } Else {
        AddMenu("MenuTabContext", "File Properties", "TCM_ShowFileProperties", IconLib, -16)
    }
    SetMenuColor("MenuTabContext", g_MenuColor)
}

ShowTabContextMenu() {
    Local FullPath, State, hMenuTabContext, hShellMenu := 0, Filename, X, Y, ItemID, WorkingDir, Verb

    FullPath := Sci[g_TabIndex].FullName
    State := FileExist(FullPath) ? "Enable" : "Disable"
    Menu MenuTabContext, %State%, Open Folder in File Manager
    Menu MenuTabContext, %State%, Copy File Path to Clipboard
    Menu MenuTabContext, %State%, Open in a New Window
    Try {
        Menu MenuTabContext, %State%, File Properties
    }

    hMenuTabContext := MenuGetHandle("MenuTabContext")

    If (g_ShellMenu2) {
        hShellMenu := GetShellContextMenu(FullPath, GetKeyState("Shift", "P") ? 0x100 : 0)

        Filename := Sci[g_TabIndex].Filename
        DllCall("InsertMenu", "Ptr", hShellMenu, "Uint", 0, "Uint", 0x400|0x800, "Ptr", 0, "Ptr", 0)
        DllCall("InsertMenu", "Ptr", hShellMenu, "Uint", 0, "Uint", 0x400|0x002, "Ptr", 0, "Ptr", &Filename)

        ; MENUITEMINFOW
        NumPut(VarSetCapacity(lpmii, A_PtrSize == 8 ? 80 : 48, 0), lpmii, 0, "UInt") ; cbSize
        NumPut(0x5, lpmii, 4, "UInt") ; fMask (MIIM_STATE | MIIM_SUBMENU)
        NumPut(State == "Enable" ? 0 : 3, lpmii, 12, "UInt") ; fState (MFS_ENABLED or MFS_DISABLED)
        NumPut(hShellMenu, lpmii, A_PtrSize == 8 ? 24 : 20, "Ptr") ; hSubMenu
        DllCall("SetMenuItemInfo", "Ptr", hMenuTabContext, "UInt", g_ShellMenu2Pos, "Int", True, "Ptr", &lpmii)
    }

    GetMousePos(X, Y, "Screen")

    ItemID := ShowPopupMenu(hMenuTabContext, 0x100, X, Y, g_hWndShell)

    If (!ItemID) {
        DestroyShellMenu(hShellMenu)
        Return

    } Else If (ItemID < 11000 && hShellMenu) {
        WorkingDir := GetFileDir(FullPath)

        Verb := GetShellMenuItemVerb(g_pIContextMenu, ItemID)
        OutputDebug Shell context menu item: ID: %ItemID%, Verb: "%Verb%".

        If (Verb == "paste") {
            PasteFile(WorkingDir)

        } Else {
            If (Sci[g_TabIndex].GetModify()) {
                Gui Main: +OwnDialogs
                MsgBox 0x4, %g_AppName%, Save the file before proceeding with the requested action?
                IfMsgBox Yes, {
                    If (!SaveFile(g_TabIndex)) {
                        DestroyShellMenu(hShellMenu)
                        Return
                    }
                }
            }

            RunShellMenuCommand(g_pIContextMenu, ItemID, WorkingDir, g_hWndMain, X, Y)
        }

    } Else { ; IDs attributed by AHK start at 11003
        SendMessage 0x111, %ItemID%, 0,, ahk_id %g_hWndMain% ; WM_COMMAND
    }

    If (g_ShellMenu2) {
        DestroyShellMenu(hShellMenu)
    }
}

; Open file/folder in Explorer or in a custom file manager
OpenFolder(StartPath := "", FileManager := "", Params := "") {
    Local Attrib := FileExist(StartPath)
    If (Attrib == "") {
        Return
    }

    ; Custom file manager (Shift pressed ensures Explorer)
    If (FileExist(FileManager) && !GetKeyState("Shift", "P")) {
        RunEx(FileManager . (Params != "" ? " " . Params : "") . " """ . StartPath . """")

    } Else {
        If (InStr(Attrib, "D")) {
            bDir := True
        }

        RunEx("*open explorer.exe "
        . (InStr(Attrib, "D") ? """" . StartPath . """" : "/select`,""" . StartPath . """"))
    }
}

M_OpenFolder() {
    OpenFolder(Sci[TabEx.GetSel()].FullName, g_FileManagerPath, g_FileManagerParams)
}

TCM_OpenFolder() {
    OpenFolder(Sci[g_TabIndex].FullName, g_FileManagerPath, g_FileManagerParams)
}

OpenCommandPrompt() { ; M
    Local FullPath := Sci[TabEx.GetSel()].FullName, StartDir

    If (FileExist(FullPath)) {
        SplitPath FullPath,, StartDir
    } Else {
        EnvGet StartDir, SystemDrive
    }
    FixRootDir(StartDir)

    RunEx(A_Comspec, StartDir)
}

CopyFilePath() { ; M
    Clipboard := Sci[TabEx.GetSel()].FullName
}

TCM_CopyFilePath() {
    Clipboard := Sci[g_TabIndex].FullName
}

TCM_ShowFileProperties() {
    Run % "Properties " . Sci[g_TabIndex].FullName
}

Repaint(hWnd) {
    WinSet Redraw,, ahk_id %hWnd%
}

SetModalWindow(Modal := True) {
    Global
    If (Modal) {
        Gui Main: +Disabled
        OnMessage(0x100, "")
        OnMessage(0x104, "")
    } Else {
        Gui Main: -Disabled
        OnMessage(0x100, "OnWM_KEYDOWN")
        OnMessage(0x104, "OnWM_SYSKEYDOWN")
    }
}

SendFile(Filename, hPrevInst) {
    Loop 10 {
        If (SendData(Filename, hPrevInst) == True) {
            Break
        } Else {
            Sleep 100
        }
    }
}

SendData(ByRef String, ByRef hWnd) {
    Local COPYDATASTRUCT, cbSize
    VarSetCapacity(COPYDATASTRUCT, 3 * A_PtrSize, 0)
    cbSize := (StrLen(String) + 1) * (A_IsUnicode ? 2 : 1)
    NumPut(cbSize, COPYDATASTRUCT, A_PtrSize)
    NumPut(&String, COPYDATASTRUCT, 2 * A_PtrSize)
    SendMessage 0x4A, 0, &COPYDATASTRUCT,, ahk_id %hWnd%
    Return ErrorLevel
}

OnWM_COPYDATA(wParam, lParam, msg, hWnd) {
    Local Data := StrGet(NumGet(lParam + 2 * A_PtrSize)) ; COPYDATASTRUCT lpData
    OpenFileEx(Data)
    Return True
}

OnWM_ACTIVATEAPP(wParam, lParam, msg, hWnd) {
    If (wParam) {
        CheckModified(TabEx.GetSel())
    }

    Return 0
}

RestoreWindow() {
    WinGet WinState, MinMax, ahk_id %g_hWndMain%
    If (WinState == -1) { ; Minimized
        WinRestore ahk_id %g_hWndMain%
    }
}

CheckModified(n) {
    Local FullPath, Timestamp, Message

    If (Sci[n].LastWriteTime == "" || Sci[n].ChangedOutside) {
        Sci[n].ChangedOutside := False
        Return 0
    }

    FullPath := Sci[n].FullName

    If (g_CheckTimestamp) {
        ; Check if the file exists
        If (FullPath != "" && !FileExist(FullPath)) {
            OnMessage(0x1C, "")
            RestoreWindow()
            MessageBox(g_hWndMain, "File not found: " . FullPath, g_AppName, 0x30)
            Sci[n].LastWriteTime := ""
            OnMessage(0x1C, "OnWM_ACTIVATEAPP")
            Return -1
        }

        ; Check if the file has been modified outside
        FileGetTime Timestamp, %FullPath%
        If (Timestamp != Sci[n].LastWriteTime) {
            Sci[n].ChangedOutside := True
            OnMessage(0x1C, "")
            RestoreWindow()
            Message := Sci[n].Filename . " was modified outside.`nShould the file be reloaded?"
            If (MessageBox(g_hWndMain, Message, g_AppName, 0x34) == 6) { ; IDYES
                AddToFileHistory(n, FullPath)
                OpenFileEx(FullPath, True) ; Reload
            } Else {
                Sci[n].ChangedOutside := False
                Return 0
            }

            OnMessage(0x1C, "OnWM_ACTIVATEAPP")
        }
    }
}

; IPC handler
CustomMessage(wParam, lParam) {
    Local TabIndex, n, Params, Filenames

    ; Integration with Find in Files
    If (wParam == 1 && WinExist("ahk_id " . lParam)) {
        ControlGetText Params,, ahk_id %lParam%
        Params := StrSplit(Params, "|")

        n := GoToFile(Params[1])
        If (!n) {
            Return
        }
        ;Sleep -1
        WinActivate ahk_id %g_hWndMain%
        Sci[n].GrabFocus()
        GoToLineEx(n, Params[2] - 1)

    ; Request all open file names
    } Else If (wParam == 2) {
        n := TabEx.GetSel(), Filenames := ""

        If (Sci[n].FullName != "") {
            Filenames .= Sci[n].FullName . "|"
        }

        Loop % Sci.Length() {
            If (A_Index == n) {
                Continue
            }

            If (Sci[A_Index].FullName != "") {
                Filenames .= Sci[A_Index].FullName . "|"
            }
        }

        GuiControl,, %g_hHiddenEdit%, %Filenames%
        Sleep -1
        SendMessage 10000, 2, %g_hHiddenEdit%,, ahk_id %lParam%

    ; Integration with Script Directives
    } Else If (wParam == 3) {
        If (WinExist("ahk_id " . lParam)) {
            ControlGetText Params,, ahk_id %lParam%
            Sleep -1
            Sci[TabEx.GetSel()].InsertText(0, Params, 1)
            SendMessage 0x10, 0, 0,, % "ahk_id" . GetParent(lParam) ; WM_CLOSE
        }
    }
}

LoadToolsMenu() {
    Local nItems, oTool

    g_ToolsFile := GetConfigFileLocation("Tools.xml")

    g_oTools := New ToolsManager()
    If (!nItems := g_oTools.Load(g_ToolsFile)) {
        Return
    }

    If (nItems) {
        Menu MenuTools, Add
    }

    For Each, oTool in g_oTools.Items {
        Try {
            AddMenu("MenuTools", oTool.Title, "RunTool", Tools_GetIconPath(oTool.Icon), oTool.IconIndex)
        }
    }
}

RunTool(MenuItem) { ; M
    Local n := TabEx.GetSel(), oTool, File, WorkingDir, Params

    oTool := g_oTools.GetItem(MenuItem)

    File := oTool.File
    If (File == "") {
        Return
    }

    If (InStr(File, "{:")) {
        File := ExpandPlaceholders(n, File)
    }

    WorkingDir := oTool.WorkingDir
    If (WorkingDir == "") {
        WorkingDir := GetFileDir(File)
    }

    Params := oTool.Params
    If (Params != "") {
        Params := ExpandPlaceholders(n, Params)
    }

    Run "%File%" %Params%, %WorkingDir%, UseErrorLevel
    If (ErrorLevel) {
        ErrorMsgBox("Error executing """ . File . """.`n`n" . GetErrorMessage(A_LastError), "Main")
        ShowToolsDialog(MenuItem)
    }
}

ExpandPlaceholders(n, Params) {
    Local FileDir, FileExt

    If (InStr(Params, "{:FULLPATH:}")) {
        Params := StrReplace(Params, "{:FULLPATH:}", Sci[n].FullName)
    }

    If (InStr(Params, "{:FILENAME:}")) {
        Params := StrReplace(Params, "{:FILENAME:}", Sci[n].Filename)
    }

    If (InStr(Params, "{:FILEDIR:}")) {
        SplitPath % Sci[n].FullName,, FileDir
        Params := StrReplace(Params, "{:FILEDIR:}", FileDir)
    }

    If (InStr(Params, "{:FILEEXT:}")) {
        SplitPath % Sci[n].FullName,,, FileExt
        Params := StrReplace(Params, "{:FILEEXT:}", FileExt)
    }

    If (InStr(Params, "{:PROGDIR:}")) {
        Params := StrReplace(Params, "{:PROGDIR:}", A_ScriptDir)
    }

    If (InStr(Params, "{:SELTEXT:}")) {
        Params := StrReplace(Params, "{:SELTEXT:}", GetSelectedText(n))
    }

    If (InStr(Params, "{:SCIHWND:}")) {
        Params := StrReplace(Params, "{:SCIHWND:}", Sci[n].hWnd)
    }

    Return Params
}

TCM_OpenNewInstance() {
    OpenNewInstance(g_TabIndex)
}

M_OpenNewInstance() {
    OpenNewInstance(TabEx.GetSel())
}

OpenNewInstance(n) {
    Local FullPath := Sci[n].FullName, CmdLine := ""

    AddToFileHistory(n, FullPath)
    SaveFileHistory()

    If (!A_IsCompiled) {
        CmdLine := """" . A_AhkPath . """ "
    }

    CmdLine .= """" . A_ScriptFullPath . """ /new """ . FullPath . """"
    RunEx(CmdLine, GetFileDir(A_ScriptFullPath))
}

Sci_GetIdealSize(ByRef X, ByRef Y, ByRef W, ByRef H) {
    Local WindowW, WindowH

    GetClientSize(g_hWndMain, WindowW, WindowH)
    GuiControlGet, TabCtl, Main: Pos, %g_hTab%

    If (g_TabBarPos == 1) { ; Top
        Y := TabCtlY + TabCtlH
        H := WindowH - g_StatusBarH - Y
    } Else {
        Y := g_ToolbarH
        H := WindowH - g_StatusBarH - TabCtlH - Y
    }

    X := -1
    W := WindowW + 1
}

CreateTabControl() {
    Local WindowW, WindowH, TabX, TabW, TabH, TabY, Style, Ptr, NewTabProc

    GetClientSize(g_hWndMain, WindowW, WindowH)
    TabX := 0
    TabW := WindowW
    TabH := DPIScale(25)
    TabY := (g_TabBarPos == 1) ? g_ToolbarH + g_TBEdgeH : WindowH - g_StatusBarH - TabH

    Style := "+AltSubmit -Wrap -TabStop +0x2008000" . (g_TabBarStyle == 1 ? " +Theme" : " +Buttons")

    Gui Add, Tab2, hWndg_hTab gTabHandler x%TabX% y%TabY% w%TabW% h%TabH% %Style%, Untitled 1

    SendMessage 0x1329, 0, % DPIScale(24) << 16,, ahk_id %g_hTab% ; TCM_SETITEMSIZE

    Ptr := A_PtrSize == 8 ? "Ptr" : ""
    g_OldTabProc := DllCall("GetWindowLong" . Ptr, "Ptr", g_hTab, "Int", -4, "Ptr") ; GWL_WNDPROC
    NewTabProc := RegisterCallback("NewTabProc", "", 4) ;
    DllCall("SetWindowLong" . Ptr, "Ptr", g_hTab, "Int", -4, "Ptr", NewTabProc, "Ptr")

    TabEx := New GuiTabEx(g_hTab)
    TabExIL := IL_Create(10)
    IL_Add(TabExIL, IconLib, -3) ; Unsaved file
    TabEx.SetImageList(TabExIL)
    TabEx.SetIcon(1, 1)
    TabEx.SetPadding(5, 4)

    Gui Tab
}

NewTabProc(hWnd, msg, wParam, lParam) {
    Local TabIndex, DropItem, DragItem
    Static s_MouseMove := 0

    If (msg == 0x201) { ; WM_LBUTTONDOWN
        TabIndex := TabHitTest(hWnd, lParam & 0xFFFF, lParam >> 16)

        If (TabIndex) {
            s_MouseMove := 4
            If (!g_MouseCapture) {
                g_MouseCapture := 1
                DllCall("SetCapture", "Ptr", hWnd)
            }

            If (TabIndex != TabEx.GetSel()) {
                TabEx.SetSel(TabIndex)
            }
        }
        Return True

    } Else If (msg == 0x200) { ; WM_MOUSEMOVE
        If (g_MouseCapture) {
            If (s_MouseMove > 0) {
                If (--s_MouseMove == 0) {
                    DllCall("SetCursor", "Ptr", g_hCursorDragMove)
                }
            }
            Return True
        }

    } Else If (msg == 0x202) { ; WM_LBUTTONUP
        If (g_MouseCapture) {
            g_MouseCapture := 0
            DllCall("ReleaseCapture")

            If (s_MouseMove == 0) {
                DropItem := TabHitTest(hWnd, lParam & 0xFFFF, lParam >> 16)

                DragItem := TabEx.GetSel()
                If (DropItem && DropItem != DragItem) {
                    SwapTabs(DragItem, DropItem)
                }
            }
            Return True
        }

    } Else If (msg == 0x215) { ; WM_CAPTURECHANGED
        If (g_MouseCapture) {
            g_MouseCapture := 0
            DllCall("ReleaseCapture")
        }

    } Else If (msg == 0x207) { ; WM_MBUTTONDOWN
        CloseTab(TabHitTest(hWnd, lParam & 0xFFFF, lParam >> 16))
        Return True
    }

    Return DllCall("CallWindowProcA", "Ptr", g_OldTabProc, "Ptr", hWnd, "UInt", msg, "Ptr", wParam, "Ptr", lParam, "Ptr")
}

; nTab := TabHitTest(g_hTab, lParam & 0xFFFF, lParam >> 16)
TabHitTest(hTab, x, y) {
    Local TCHITTESTINFO
    VarSetCapacity(TCHITTESTINFO, 16, 0)
    NumPut(x, TCHITTESTINFO, 0)
    NumPut(y, TCHITTESTINFO, 4)
    NumPut(6, HITTESTINFO, 8) ; 6 = TCHT_ONITEM
    SendMessage 0x130D, 0, &TCHITTESTINFO,, ahk_id %hTab% ; TCM_HITTEST
    Return Int(ErrorLevel) + 1
}

; Drag: source. Drop: destination.
SwapTabs(DragItem, DropItem) {
    Local ObjSci := Sci.RemoveAt(DragItem)
    Sci.InsertAt(DropItem, ObjSci)

    Loop % Sci.Length() {
        SavePointChanged(A_Index)
        TabEx.SetIcon(A_Index, GetIconForTabN(A_Index))
    }

    TabEx.SetSel(DropItem)
}

GetIconForTabN(n) {
    Local Filename, Ext
    Filename := Sci[n].Filename
    Ext := SubStr(Filename, InStr(Filename, ".", 0, 0) + 1)
    Return GetIconForTab(Sci[n].FullName, Ext)
}

GetIconForTab(FullPath, Ext) {
    Local Icon, hIcon
    Static Icons := {}

    If (FullPath == "") {
        Return 1

    } Else {
        If (Icons.HasKey(Ext)) {
            Return Icons[Ext]
        }

        hIcon := GetFileIcon(FullPath)
        Icon := IL_Add(TabExIL, "HICON:" . hIcon)
        Icons[Ext] := Icon
        Return Icon
    }
}

SetTabBarPos:
    If (A_ThisMenuItem == "Top") {
        TabCtlY := g_ToolbarH + g_TBEdgeH
        g_TabBarPos := 1
        Menu MenuViewTabBar, Uncheck, Bottom
    } Else {
        GetClientSize(g_hWndMain, WindowW, WindowH)
        TabCtlY := WindowH - g_StatusBarH - DPIScale(25) ; 25 = TabCtlH
        g_TabBarPos := 2
        Menu MenuViewTabBar, Uncheck, Top
    }

    Control ExStyle, ^0x200,, ahk_id %g_hToolbar% ; Toggle WS_EX_CLIENTEDGE
    ; 0x37: SWP_NOSIZE | SWP_NOMOVE | SWP_NOZORDER | SWP_NOACTIVATE | SWP_DRAWFRAME
    SetWindowPos(g_hToolbar, 0, 0, 0, 0, 0, 0x37)

    GuiControl MoveDraw, %g_hTab%, y%TabCtlY%

    Sci_GetIdealSize(SciX, SciY, SciW, SciH)
    Loop % Sci.Length() {
        SetWindowPos(Sci[A_Index].hWnd, SciX, SciY, SciW, SciH, 0, 0x14) ; SWP_NOZORDER | SWP_NOACTIVATE
    }

    Menu MenuViewTabBar, Check, %A_ThisMenuItem%
Return

SetTabBarStyle:
    If (A_ThisMenuItem == "Standard") {
        GuiControl Main: -Buttons, %g_hTab%
        DllCall("UxTheme.dll\SetWindowTheme", "Ptr", g_hTab, "WStr", "Explorer", "Ptr", 0)
        g_TabBarStyle := 1
        Menu MenuViewTabBar, Uncheck, Buttons
    } Else {
        DllCall("UxTheme.dll\SetWindowTheme", "Ptr", g_hTab, "Str", " ", "Str", " ")
        GuiControl Main: +Buttons, %g_hTab%
        g_TabBarStyle := 2
        Menu MenuViewTabBar, Uncheck, Standard
    }

    Menu MenuViewTabBar, Check, %A_ThisMenuItem%
Return

ShowBackupDialog() {
    Gui BackupDlg: New, LabelBackupDlg hWndhWndBkp -MinimizeBox OwnerMain
    SetWindowIcon(hWndBkp, IconLib, -8)
    Gui Color, White
    Gui Add, Radio, x0 y0 w0 h0

    Gui Add, Pic, x-2 y-2 w556 h51, % "HBITMAP:" . Gradient(556, 51)
    Gui Font, s12 cWhite, Segoe UI
    Gui Add, Text, x11 y12 w297 h23 +0x200 +BackgroundTrans, Auto-save and Backup Settings
    ResetFont()

    Gui Add, Text, x12 y62 w69 h23 +0x200, Directory:
    Gui Add, Edit, vg_BackupDir x84 y63 w377 h21, %g_BackupDir%
    Gui Add, Button, gChooseBackupDir x466 y61 w80 h23, &Choose...

    Gui Add, CheckBox, vg_BackupOnSave x12 y93 w300 h23 +Checked%g_BackupOnSave%
    , Create a backup copy of the file before saving

    Gui Add, GroupBox, x8 y122 w539 h114, Auto-save
    Gui Add, Text, x20 y141 w139 h23 +0x200, Save automatically after
    Gui Add, Edit, vg_AutoSaveInterval x162 y142 w42 h21 +Number +Right, %g_AutoSaveInterval%
    Gui Add, Text, x212 y141 w58 h23 +0x200, minutes
    Gui Add, CheckBox, vg_AutoSaveInLoco x20 y173 w237 h23 +Checked%g_AutoSaveInLoco%
    , Save the file in its current location
    Gui Add, CheckBox, vg_AutoSaveInBkpDir x20 y204 w237 h23 +Checked%g_AutoSaveInBkpDir%
    , Save the file in the backup directory

    Gui Add, Text, x12 y243 w183 h23 +0x200, Delete backup copies older than
    Gui Add, Edit, vg_BackupDays x197 y245 w42 h21 +Number +Right, %g_BackupDays%
    Gui Add, Text, x245 y243 w45 h23 +0x200, days

    Gui Add, Text, x-1 y280 w556 h48 -Background +Border
    Gui Add, Button, gBackupDlgOK x371 y292 w84 h24 +Default, &OK
    Gui Add, Button, gBackupDlgClose x462 y292 w84 h24, &Cancel

    Gui Show, w554 h327, Auto-save and Backup Settings
}

BackupDlgClose() {
    BackupDlgEscape:
    Gui BackupDlg: Destroy
    Return
}

BackupDlgOK() {
    Gui BackupDlg: Submit

    g_BackupDir := RTrim(g_BackupDir, "\")

    If (g_AutoSaveInterval < 1) {
        g_AutoSaveInterval := 3 ; Default
    }

    DeleteOldBackups()
    ResetAutoSave()
}

ChooseBackupDir() {
    Local SelectedFolder
    Gui BackupDlg: +OwnDialogs
    FileSelectFolder SelectedFolder,,, Select Folder
    If (!ErrorLevel) {
        GuiControl, BackupDlg:, g_BackupDir, %SelectedFolder%
    }
}

AutoSaveTimer() {
    Local CRC32, Filename, FileExt, SciText, BackupName, Encoding
    Critical

    If (g_AutoSaveInLoco) {
        Loop % Sci.Length() {
            ; Only for documents with name
            If (Sci[A_Index].FullName != "" && Sci[A_Index].GetModify()) {
                SaveFile(A_Index)
            }
        }
    }

    If (g_AutoSaveInBkpDir) {
        Loop % Sci.Length() {
            If (Sci[A_Index].FullName != "" && !Sci[A_Index].GetModify()) {
                Continue ; The file has not been modified
            }

            ; Generate backup name for named documents
            If (Sci[A_Index].FullName != "") {
                If (!InStr(Sci[A_Index].BackupName, "[")) {
                    CRC32 := CRC32(Sci[A_Index].FullName)
                    SplitPath % Sci[A_Index].FullName, Filename,, FileExt
                    FileExt := "." . FileExt . ".tmp"
                    Sci[A_Index].BackupName := g_BackupDir . "\" . Filename . " [" . CRC32 . "]" . FileExt
                }
            ; For unnamed documents
            } Else If (Sci[A_Index].BackupName == "") {
                Sci[A_Index].BackupName := GetTempFileName(g_BackupDir, "tmp")
            }

            SciText := GetText(A_Index)
            If (SciText != "") {
                If (BackupDirCreated()) {
                    BackupName := Sci[A_Index].BackupName
                    FileDelete %BackupName%
                    FileAppend %SciText%, %BackupName%, % GetSaveEncoding(A_Index)
                }
            }
        }
    }
}

; Credits to jNizM
CRC32(String, Encoding = "UTF-8") {
    Local ChrLength, Length, Data, hMod, CRC32
    ChrLength := (Encoding = "CP1200" || Encoding = "UTF-16") ? 2 : 1
    Length := (StrPut(String, Encoding) - 1) * ChrLength
    VarSetCapacity(Data, Length, 0)
    StrPut(String, &Data, Floor(Length / ChrLength), Encoding)
    hMod := DllCall("Kernel32.dll\LoadLibrary", "Str", "Ntdll.dll", "Ptr")
    CRC32 := DllCall("Ntdll.dll\RtlComputeCrc32", "UInt", 0, "UInt", &Data, "UInt", Length, "UInt")
    DllCall("Kernel32.dll\FreeLibrary", "Ptr", hMod)
    Return Format("{:08X}", CRC32)
}

GetTempFileName(Dir, Ext := "tmp") {
    Local Num, Filename
    Static Attempts := 0

    Random Num, 1, 2147483647

    Filename := Dir . "\" . Num . "." . Ext
    If (FileExist(Filename)) {
        Attempts++
        If (Attempts > 10) {
            Attempts := 0
            Filename := Dir . "\" . A_Now . " " . Num . "." . Ext
            Return Filename
        }

        GetTempFileName(Dir, Ext)
    }

    Attempts := 0
    Return Filename
}

DeleteOldBackups(Ext := "tmp") {
    Local Now
    Loop %g_BackupDir%\*.%Ext% {
        Now := A_Now
        EnvSub Now, %A_LoopFileTimeModified%, Days
        If (Now >= g_BackupDays) {
            FileDelete %A_LoopFileLongPath%
        }
    }
}

BackupDirCreated() {
    If (!FileExist(g_BackupDir)) {
        FileCreateDir %g_BackupDir%
        Return !ErrorLevel
    }
    Return True
}

StartAutoSave() {
    If (g_AutoSaveInLoco || g_AutoSaveInBkpDir) {
        SetTimer AutoSaveTimer, % g_AutoSaveInterval * 60000
    }
}

ResetAutoSave() {
    Try {
        SetTimer AutoSaveTimer, Off
    }

    StartAutoSave()
}

Execute() {
    Local n, FullPath

    n := TabEx.GetSel()
    FullPath := Sci[n].FullName

    If (Sci[n].Type == "AHK" && (SubStr(FullPath, -2) = "AHK" || FullPath == "")) {
        RunScript()

    } Else {
        RunFile()
    }
}

RunFile() {
    Local n := TabEx.GetSel(), FullPath, WorkingDir, Type

    If (Sci[n].GetModify()) {
        ; Run without saving
        /*
        If (Sci[n].Filename == "") {
            Type := Sci[n].Type

            If (Type == "VBS") {
                RunTempFile(n, ".vbs", "UTF-16")
                Return
            } Else If (Type == "BAT") {
                RunTempFile(n, ".bat", "UTF-8-RAW")
                Return
            }
        }
        */

        If (!SaveFile(n)) {
            Return
        }
    }

    WorkingDir := GetFileDir(FullPath)
    FullPath := Sci[n].FullName
    If (FullPath == "") {
        Return
    }

    RunEx(FullPath . " " . Sci[n].Parameters, WorkingDir,,, g_hWndMain)
}

RunTempFile(n, FileExt, FileEnc := "UTF-16", Extra := "") {
    Local String, Params, WorkingDir, FullPath, Target

    String := GetText(n)
    Params := Sci[n].Parameters
    WorkingDir := g_TempDir
    FixRootDir(WorkingDir)
    FullPath := WorkingDir . "\Temp" . FileExt

    If (WriteFile(FullPath, String, FileEnc) != -1) {
        Target := (Params != "") ? FullPath . " " Params : FullPath
        RunEx(Target, WorkingDir)
    }
}

M_RunScript64() {
    RunScript(g_AhkPath64)
}

M_RunScript32() {
    RunScript(g_AhkPath32)
}

GetAhkPath() {
    If (GetKeyState("Shift", "P")) {
        Return (A_PtrSize == 4) ? g_AhkPath64 : g_AhkPath32
    } Else {
        Return (A_PtrSize == 4) ? g_AhkPath32 : g_AhkPath64
    }
}

RunScript(AhkPath := "") {
    Local n, Script, Params, FullPath, WorkingDir

    n := TabEx.GetSel()

    If (AhkPath == "") {
        AhkPath := GetAhkPath()
    }

    If (Sci[n].Filename != "") { ; Saved files
        If (Sci[n].GetModify() && !SaveFile(n)) {
            Return
        }

        FullPath := Sci[n].FullName
        SplitPath FullPath,, WorkingDir

    } Else { ; Unsaved scripts run from the Temp folder
        Script := GetText(n)
        FullPath := g_TempFile
        WorkingDir := g_TempDir
        FileDelete %FullPath%
        FileAppend %Script%, %FullPath%, %A_FileEncoding%
        If (ErrorLevel) {
            Return
        }
    }

    Params := Sci[n].Parameters

    FixRootDir(WorkingDir)

    If (g_CaptureStdErr) {
        AhkRunGetStdErr(n, AhkPath, FullPath, Params, WorkingDir)
    } Else {
        RunEx(AhkPath . " """ . FullPath . """ " . Params, WorkingDir,,, g_hWndMain)
    }
}

FormatAhkStdErr(AhkStdErr, ByRef File, ByRef Line) {
    Local Message, Match, Match1, Match2, Match3, Match4

    If (RegExMatch(AhkStdErr, "Us)^(.*) \((\d+)\) : ==> (.*)\s*(?:Specifically: (.*))?$", Match)) {
        Message := "File: """ . (File := Match1) . """."
        Message .= "`n`nError at line " . (Line := Match2) . "."
        If (Match4 != "") {
            Message .= "`n`nSpecifically: " . Match4
        }
        Message .= "`n`nError: " . Match3
        Return Message
    } Else {
        Return AhkStdErr
    }
}

AhkRunGetStdErr(n, AhkPath, AhkScript, Parameters, WorkingDir, AhkDbgParams := "") {
    Local CmdLine, StdErr, ExitCode, Marked, AhkStdErr, FullPath, Line

    CmdLine := """" . AhkPath . """ /ErrorStdOut " . AhkDbgParams . " """ . AhkScript . """ " . Parameters
    StdErr := RunGetStdOut(CmdLine, "CP0", WorkingDir, ExitCode)
    If (ExitCode == 2) { ; EXIT_ERROR
        Marked := 0
        AhkStdErr := FormatAhkStdErr(StdErr, FullPath, Line)
        If (Line) {
            If (AhkScript != FullPath && FullPath != g_TempFile) {
                n := GoToFile(FullPath)
            }

            If (n) {
                --Line
                GoToLineEx(n, Line)
                If (g_ShowErrorSign) {
                    If !(Sci[n].MarkerGet(Line) & (1 << g_MarkerError)) {
                        Sci[n].MarkerAdd(Line, g_MarkerError)
                        Marked := 1
                    }
                }
            }
        }

        ErrorMsgBox(AhkStdErr, "Main")
        If (g_ShowErrorSign == -1 && Marked) {
            Sci[n].MarkerDelete(Line, g_MarkerError)
        }

        ; Debug
        If (AhkDbgParams) {
            Debug_Error()
        }
    }
}

RunSelectedText() { ; M
    Local n := TabEx.GetSel(), AhkPath, SelText

    If (Sci[n].Type != "AHK") {
        If (MessageBox(g_hWndMain, "Set document type syntax as AutoHotkey?", "AutoHotkey Document", 0x1) != 1) {
            Return
        }
        SetLexType(n, GetDisplayNameByLexType("AHK"))
    }

    SelText := GetSelectedText(n)
    If (SelText == "") {
        Return
    }

    AhkPath := GetAhkPath()
    ExecScript(SelText, Sci[n].Parameters, AhkPath)
}

; %TEMP% is SFN on XP
GetTempDir() {
    Local LP

    If (g_NT6orLater) {
        Return A_Temp
    } Else {
        DllCall("GetLongPathName", "Str", A_Temp, "Str", LP, "UInt", VarSetCapacity(LP, 512, 0))
        Return LP
    }
}

OnWM_SETTINGCHANGE(wParam, lParam, msg, hWnd) {
    Local String := StrGet(lParam, "UTF-16")
    OutputDebug % "WM_SETTINGCHANGE: wParam: " . wParam . " lParam: " . String
    If (String == "Environment") {
        EnvGet g_TempDir, TEMP
        g_TempFile := g_TempDir . "\Temp.ahk"
    }
}

ShowShellMenuDlg() {
    Local Options, Option, hMenuTabContext

    Options =
    (LTrim Join|
        Enabled as a drop-down menu associated with the Execute button
        Enabled as a submenu of the context menu of tab bar buttons
        Enabled in both places
        Disabled||
    )

    Option := g_ShellMenu1 | g_ShellMenu2
    Option := InputBoxEx("Explorer Context Menu", "Warning: this feature is experimental."
    , "Explorer Context Menu Settings", Options, "DDL", "AltSubmit Choose" . Option, g_hWndMain)
    If (!ErrorLevel) {
        If (Option == 4) {
            Option := 0
        }

        g_ShellMenu1 := Option & 1
        g_ShellMenu2 := Option & 2

        hMenuTabContext := MenuGetHandle("MenuTabContext")
        DeleteMenu(hMenuTabContext, g_ShellMenu2Pos)
        Menu MenuTabContext, DeleteAll
        CreateTabContextMenu()
    }
}

LoadTemplatesMenu() {
    Loop Files, %A_ScriptDir%\Templates\*.*, F
    {
        If (A_Index > 100) { ; Limit
            Break
        }

        MenuAddFile("MenuTemplates", A_LoopFileName, "OpenTemplateFile", A_LoopFileFullPath)
    }

    Try {
        If (MenuGetHandle("MenuTemplates")) {
            AddMenu("MenuFile", "New from &Template", ":MenuTemplates", IconLib, -4)
        } Else {
            Menu MenuFile, Disable, New from &Template
        }
    }
}

OpenTemplateFile(MenuItem) {
    Local n := TabEx.GetSel(), Template, FileExt, Pos

    Template := A_ScriptDir . "\Templates\" . MenuItem
    If (!FileExist(Template)) {
        ErrorMsgBox("File not found: """ . Template . """", "Main")
        Return
    }

    If (Sci[n].GetModify() || Sci[n].Filename != "") {
        If !(n := NewTab()) {
            Return
        }
    }

    SplitPath Template,,, FileExt
    Sci_Config(n, GetLexTypeByExt(FileExt))
    FileRead Template, %Template%
    Sci[n].SetText(0, Template, 1)
    SB_UpdateFileDesc(n)

    IniRead Pos, % GetConfigFileLocation("Templates.ini"), %MenuItem%, Pos, 0
    If (Pos + 0) {
        Sci[n].GoToPos(Pos != -1 ? Pos : Sci[n].GetLength() + 1)
    }
}

SaveAsTemplate() { ; M
    Local n := TabEx.GetSel(), SelectedFile, Filename, FileExt, Pos

    Gui Main: +OwnDialogs
    FileSelectFile SelectedFile, S16, %A_ScriptDir%\Templates, Save Template
    If (ErrorLevel) {
        Return
    }

    If (WriteFile(SelectedFile, GetText(n), GetSaveEncoding(n)) < 0) {
        Return
    }

    SplitPath SelectedFile, Filename,, FileExt

    MenuAddFile("MenuTemplates", Filename, "OpenTemplateFile", SelectedFile)

    Gui Main: +OwnDialogs
    MsgBox 0x4, Template, %SelectedFile%`n`nFile saved.`n`nShould the current cursor position also be remembered?
    IfMsgBox Yes, {
        Pos := Sci[n].GetCurrentPos()
        IniWrite %Pos%, % GetConfigFileLocation("Templates.ini"), %Filename%, Pos
    }

    Sci_Config(n, GetLexTypeByExt(FileExt))
}

EscPressed() {
    Local n := TabEx.GetSel(), hCursor, Pos

    If (Sci[n].AutoCActive()) {
        Sci[n].AutoCCancel()
        Return False
    }

    If (Sci[n].CalltipActive()) {
        Sci[n].CalltipCancel()
        Return False
    }

    hCursor := DllCall("GetCursor", "Ptr")
    If (hCursor == g_hCursorDragMove) {
        DllCall("ReleaseCapture")
    }

    Pos := Sci[n].GetCurrentPos()
    Sci[n].2571() ; SCI_CLEARSELECTIONS
    Sci[n].GoToPos(Pos)

    Return False
}

; Open/Save dialog file extension filters
LoadFileFilters() {
    Local oFilter, oFilters, ID, Value
    g_aFilters := []

    oFilters := g_oXMLFileTypes.selectNodes("/ftypes/filters/filter")
    For oFilter in oFilters {
        ID  := oFilter.getAttribute("id")
        Value := oFilter.getAttribute("value")

        g_aFilters.Push({"ID": ID, "Value": Value})
    }

    Return g_FiltersLoaded := g_aFilters.Length()
}

; Get the filter based on file extension or lexer type
GetFileFilter(n) {
    Local FileExt, Filter

    If (!g_FiltersLoaded) {
        If (!LoadFileFilters()) {
            Return "All Files (*.*)"
        }
    }

    FileExt := GetFileExt(Sci[n].FullName)
    If (FileExt != "") {
        Filter := GetFilterByExt(FileExt)
        If (Filter != "") {
            Return Filter
        }
    }

    Return GetFilterByType(Sci[n].Type)
}

; Search for the first occurrence of FileExt in the filters array.
GetFilterByExt(FileExt) {
    Local Filter, Mask

    Mask := "*." . (FileExt != "" ? FileExt : "*") . ";"

    Loop % g_aFilters.Length() {
        Filter := g_aFilters[A_Index].Value
        If (InStr(Filter, Mask)) {
            Return Filter
        }
    }

    Return "(" . Mask . ")"
}

; Get the filter based on type (sublexer ID)
GetFilterByType(Type) {
    Local FilterID

    Loop % g_aFilters.Length() {
        FilterID := g_aFilters[A_Index].ID
        If (FilterID = Type) {
            Return g_aFilters[A_Index].Value
        }
    }

    Return "All Files (*.*)"
}

M_LoadLegacySession() {
    LoadLegacysSession()
}

LoadLegacysSession(SessionFile := "") {
    Local Session, FilePath, aFiles := []

    If (SessionFile == "") {
        Gui Main: +OwnDialogs
        FileSelectFile SessionFile, 3,, Select Session, Legacy Session Files (*.session)
        If (ErrorLevel) {
            Return
        }
    }

    FileRead Session, %SessionFile%
    Loop Parse, Session, `n, `r
    {
        FilePath := StrSplit(A_LoopField, "|")[1]
        If (FileExist(FilePath) && !IsPathRelative(FilePath)) {
            aFiles.Push(FilePath)
        }
    }

    If (aFiles.Length()) {
        OpenFilesEx(aFiles, 0)
    }
}

LoadStartupSession(SessionName) {
    Local oNode, aItems, nActive, aFiles := [], oFile

    If (SessionName == "") {
        Return 0
    }

    oNode := g_oXMLFileHistory.selectSingleNode("/history/sessions/session[@name='" . SessionName . "']")
    If (!IsObject(oNode)) {
        Return 0
    }

    aItems := StrSplit(oNode.getAttribute("items"), "|") ; Indexes
    nActive := oNode.getAttribute("active") ; Active tab index

    Loop % aItems.Length() {
        aFiles.Push(g_aoFiles[aItems[A_Index]].Path)
    }

    If (!aFiles.Length()) {
        Return 0
    }

    DllCall("LockWindowUpdate", "Ptr", g_hWndMain)
    OpenFiles(aFiles, nActive, True)
    ; Metadata is initially applied to the active file only.
    ApplyMetadata(nActive, g_aoFiles[aItems[nActive]])
    DllCall("LockWindowUpdate", "Ptr", 0)

    Loop % aItems.Length() {
        If (A_Index == nActive) {
            Continue
        }

        ApplyMetadata(A_Index, g_aoFiles[aItems[A_Index]])
    }

    Return 1
}

M_LoadSession(MenuItem) {
    LoadSession(MenuItem)
}

LoadSession(SessionName) {
    Local oSession, aItems, nActive, oFile, nTab

    oSession := GetSession(SessionName)
    aItems := oSession.Items
    If (!aItems.Length()) {
        Return 0
    }

    nActive := oSession.Active

    DllCall("LockWindowUpdate", "Ptr", g_hWndMain)
    Loop % aItems.Length() {
        oFile := g_aoFiles[aItems[A_Index]]
        nTab := OpenFile(oFile.Path)
        If (nTab) {
            ApplyMetadata(nTab, oFile)
        }

        If (A_Index == nActive) {
            nActive := nTab
        }
    }
    TabEx.SetSel(nActive)
    DllCall("LockWindowUpdate", "Ptr", 0)

    Try {
        Menu MenuSavedSessions, Default, %SessionName%
    }

    Return 1
}

ApplyMetadata(n, oFile) {
    If ((g_Metadata & 1) && oFile.Pos) {
        Sci[n].GoToPos(oFile.Pos)
        Sci[n].VerticalCentreCaret()
    }

    If (g_Metadata & 2) {
        Loop % oFile.Lines.Length() {
            Sci[n].MarkerAdd(oFile.Lines[A_Index], g_MarkerBookmark)
        }
    }

    If (g_Metadata & 4) {
        AddMarkers(n, oFile.Markers)
    }

    If (g_Metadata & 8) {
        AddSelections(n, oFile.Selections)
    }

    If (g_Metadata & 16) {
        Loop % oFile.Folds.Length() {
            Sci[n].2237(oFile.Folds[A_Index], 0) ; SCI_FOLDLINE, SC_FOLDACTION_CONTRACT
        }
    }
}

AddMarkers(n, aaMarkers) {
    Local StartPos

    Sci[n].SetIndicatorCurrent(1)
    Sci[n].IndicSetStyle(1, g_oColors["MarkedText"].Type)
    Sci[n].IndicSetFore(1, g_oColors["MarkedText"].Color)
    Sci[n].IndicSetAlpha(1, g_oColors["MarkedText"].Alpha)
    Sci[n].IndicSetOutlineAlpha(1, g_oColors["MarkedText"].OutlineAlpha)

    Loop % aaMarkers.Length() {
        StartPos := aaMarkers[A_Index][1]
        Sci[n].IndicatorFillRange(StartPos, aaMarkers[A_Index][2] - StartPos)
    }
}

AddSelections(n, aaSels) {
    Loop % aaSels.Length() {
        Sci[n].2573(aaSels[A_Index][1], aaSels[A_Index][2]) ; SCI_ADDSELECTION
    }
}

SaveSession(SessionName := "") {
    Local FullPath, aFiles := [], aItems := []

    If (SessionName == "") {
        ShowSaveSessionDialog()
        Return 0
    }

    Loop % Sci.Length() {
        FullPath := Sci[A_Index].FullName
        If (FullPath != "") {
            aFiles.Push(FullPath)
            aItems.Push(GetFileHistoryIndex(FullPath))
        }
    }

    AddSessionEx(SessionName, aFiles, aItems, GetActiveTabIndex())

    Return IsObject(GetSession(SessionName))
}

SaveSessionOnExit() {
    If (SaveSession("Session Saved on Exit")) {
        If (g_LastSessionName == "" && g_LoadLastSession) {
            g_LastSessionName := "Session Saved on Exit"
        }
    }
}

MultiRangeToMatrix(PDL) { ; Pipe-delimited list
    Local aInput := StrSplit(PDL, "|"), aOutput := [], Each, Item

    For Each, Item in aInput {
        aOutput.Push(StrSplit(Item, "-"))
    }

    Return aOutput
}

ArrayToPDL(Array, Delim := "|") {
    Local Output := "", Max := Array.Length()
    Loop % Max {
        Output .= Array[A_Index]
        If (A_Index < Max) {
            Output .= Delim
        }
    }
    Return Output
}

MatrixToPDL(Matrix, Delim := "|") {
    Local i, j, Output := ""
    For i in Matrix {
        For j in Matrix[i] {
            Output .= Matrix[i][j]
            If (j < Matrix[i].Length()) {
                Output .= "-"
            }
        }
        If (i < Matrix.Length()) {
            Output .= Delim
        }
    }
    Return Output
}

AddSession(Name, aFiles, aItems, Active := 1) {
    Local Index := GetSessionIndex(Name)

    If (Index) {
        g_aoSessions[Index] := {"Name": Name, "Files": aFiles, "Items": aItems, "Active": Active}
    } Else {
        If (Name == "") {
            Return 0
        }

        g_aoSessions.Push({"Name": Name, "Files": aFiles, "Items": aItems, "Active": Active})
    }

    Try {
        AddMenu("MenuSavedSessions", Name, "M_LoadSession", IconLib, -36)
    }

    Return 1
}

M_AddFavorite() {
    Local FullPath := Sci[TabEx.GetSel()].FullName

    If (!g_aFavorites.Length()) { ; No item added yet
        Menu MenuFavorites, Add
    }

    AddFavorite(FullPath)
}

AddFavorite(FullPath) {
    If (IndexOf(g_aFavorites, FullPath)) {
        Return 0
    }

    If (FileExist(FullPath)) {
        MenuAddFile("MenuFavorites", FullPath, "OpenSingleFile", FullPath)
        Return g_aFavorites.Push(FullPath)
    }
    Return 0
}

OnWM_MENUSELECT(wParam, lParam, msg, hWnd) {
    Local Flags := wParam >> 16, IsPopup := Flags & 0x10 == 0x10 ; HIWORD, MF_POPUP

    If (MenuGetName(lParam) != "MenuTools") {
        Return
    }

    VarSetCapacity(lpString, 4096)
    DllCall("GetMenuString"
    , "Ptr",  lParam
    , "UInt", wParam & 0xFFFF ; LOWORD (item ID or pos)
    , "Str",  lpString
    , "UInt", 4096
    , "UInt", IsPopup ? 0x400 : 0) ; MF_BYPOSITION = 0x400, MF_BYCOMMAND = 0

    Tooltip % g_oTools.GetItem(lpString).Desc
}

OnWM_EXITMENULOOP(wParam) {
    ToolTip ; Close tool description tooltip
    Return 0
}

; Needed for WM_INITMENUPOPUP
OnWM_ENTERMENULOOP() {
    Return 1 ; Prevent repainting problems on XP?
}

/*
lParam
The low-order word specifies the zero-based relative position of the menu item that opens the drop-down menu or submenu.
The high-order word indicates whether the drop-down menu is the window menu. If the menu is the window menu, this parameter is TRUE; otherwise, it is FALSE.
*/
OnWM_INITMENUPOPUP(wParam, lParam, msg, hWnd) {
    UpdateMenuState(wParam)
}

UpdateMenuState(hMenu) {
    Local n := TabEx.GetSel(), HasSel, HasLen, MenuName, MenuItem

    MenuName := SubStr(MenuGetName(hMenu), 5)

    If (MenuName == "View") {
        CheckMenuItem("MenuView", "&Line Numbers", g_LineNumbers)
        CheckMenuItem("MenuView", "Symbol Margin", g_SymbolMargin)
        CheckMenuItem("MenuView", "Margin Divider", g_Divider)
        CheckMenuItem("MenuView", "&Fold Margin", g_CodeFolding)
        CheckMenuItem("MenuView", "Show Folding Lines", g_FoldingLines)
        CheckMenuItem("MenuView", "&Wrap Long Lines", g_WordWrap)
        CheckMenuItem("MenuView", "Syntax &Highlighting", g_SyntaxHighlighting)
        CheckMenuItem("MenuView", "Highlight &Active Line", g_HighlightActiveLine)
        CheckMenuItem("MenuView", "Show &Indentation Lines", g_IndentGuides)

    } Else If (MenuName == "Edit") {
        HasSel := !Sci[n].GetSelectionEmpty()
        HasLen := Sci[n].GetLength()

        UpdateMenuItemState("MenuEdit", "&Undo`tCtrl+Z", Sci[n].CanUndo())
        UpdateMenuItemState("MenuEdit", "R&edo`tCtrl+Y", Sci[n].CanRedo())
        UpdateMenuItemState("MenuEdit", "Cu&t`tCtrl+X", HasSel)
        UpdateMenuItemState("MenuEdit", "&Copy`tCtrl+C", HasSel)
        UpdateMenuItemState("MenuEdit", "&Paste`tCtrl+V", Sci[n].CanPaste())
        UpdateMenuItemState("MenuEdit", "&Delete`tDel", HasLen)
        UpdateMenuItemState("MenuEdit", "Select &All`tCtrl+A", HasLen)
        UpdateMenuItemState("MenuEdit", "Comment/Uncomment`tCtrl+K", Sci[n].Type == "AHK")
        CheckMenuItem("MenuEdit", "Set as &Read-Only", Sci[n].GetReadOnly())

    } Else If (MenuName == "Lexer") {
        Loop % GetMenuItemCount(hMenu) {
            Try {
                Menu MenuLexer, Uncheck, %A_Index%&
            }
        }

        MenuItem := GetDisplayNameByLexType(Sci[n].Type)
        Try {
            Menu MenuLexer, Check, %MenuItem%
        }

    } Else If (MenuName == "Options") {
        CheckMenuItem("MenuOptions", "Enable &Autocomplete`tF12", g_AutoComplete)
        CheckMenuItem("MenuOptions", "Autocomplete &Typed Words", g_AutoCTypedWords)
        CheckMenuItem("MenuOptions", "Enable &Calltips", g_CalltipTyping)
        CheckMenuItem("MenuOptions", "Autoclose &Brackets", g_AutoBrackets)
        CheckMenuItem("MenuOptions", "Enable &Multiple Selection", g_MultiSel)

    } Else If (MenuName == "OptionsOnExit") {
        CheckMenuItem("MenuOptionsOnExit", "Remember Session", g_RememberSession)
        CheckMenuItem("MenuOptionsOnExit", "Prompt to Save Files", g_AskToSaveOnExit)

    } Else If (MenuName == "Encoding") {
        UpdateEncodingMenu(n, hMenu) ; File encoding
    }
}

UpdateEncodingMenu(n, hMenu) {
    Loop % GetMenuItemCount(hMenu) {
        Try {
            Menu MenuEncoding, Uncheck, %A_Index%&
        }
    }
    Try {
        Menu MenuEncoding, Check, % GetFileEncodingDisplayName(n)
    }
}

; Add or update file metadata (pos, selections, markers, etc)
AddToFileHistory(TabIndex, FullPath) {
    Local FileIndex

    If (!TabIndex || FullPath == "") {
        Return 0
    }

    FileIndex := GetFileHistoryIndex(FullPath)
    If (!FileIndex) {
        FileIndex := g_aoFiles.Push({"Path": FullPath})
    }

    Return UpdateMetadata(TabIndex, FileIndex)
}

UpdateMetadata(TabIndex, FileIndex) {
    If (!IsWindow(Sci[TabIndex].hWnd)) {
        Return 0
    }

    g_aoFiles[FileIndex].Pos := Sci[TabIndex].GetCurrentPos()
    g_aoFiles[FileIndex].Lines := GetMarkedLines(TabIndex, g_MarkerMask)
    g_aoFiles[FileIndex].Markers := GetMarkedText(TabIndex)
    g_aoFiles[FileIndex].Selections := GetAllSelections(TabIndex)
    g_aoFiles[FileIndex].Folds := GetAllFolds(TabIndex)

    Return FileIndex
}

LoadFileHistory() {
    Local FileLocation, oNode, oNodes

    FileLocation := GetConfigFileLocation("FileHistory.xml")
    g_oXMLFileHistory := LoadXML(FileLocation)
    If (!IsObject(g_oXMLFileHistory)) {
        Return
    }

    oNodes := g_oXMLFileHistory.selectNodes("/history/files/file")
    For oNode in oNodes {
        g_aoFiles[A_Index] := {}
        g_aoFiles[A_Index].Path := oNode.getAttribute("path")
        g_aoFiles[A_Index].Pos := oNode.getAttribute("pos")
        g_aoFiles[A_Index].Lines := StrSplit(oNode.getAttribute("lm"), "|") ; Line Markers
        g_aoFiles[A_Index].Markers := MultiRangeToMatrix(oNode.getAttribute("tm")) ; Text markers
        g_aoFiles[A_Index].Selections := MultiRangeToMatrix(oNode.getAttribute("sels")) ; Selections
        g_aoFiles[A_Index].Folds := StrSplit(oNode.getAttribute("folds"), "|") ; Folds
    }
}

ShowSaveSessionDialog() { ; M
    Global
    Local LongDate, ProposedName, Sessions := "", IL, FullPath, IL_Index, LvStyle, VScrollBarW, Col1W := 692

    RegRead LongDate, HKCU\Control Panel\International, sLongDate
    FormatTime ProposedName,, %LongDate%
    ProposedName := Format("{:U}", SubStr(ProposedName, 1, 1)) . SubStr(ProposedName, 2)

    Loop % g_aoSessions.Length() {
        Sessions .= g_aoSessions[A_Index].Name . "|"
    }

    Gui Session: New, +LabelSaveSessionDialog_On +hWndhWndSaveSessionDialog -MinimizeBox +OwnerMain
    SetWindowIcon(hWndSaveSessionDialog, IconLib, -36)
    Gui Color, White

    Gui Add, Pic, x-2 y-2 w774 h51, % "HBITMAP:" . Gradient(774, 51)
    Gui Font, s12 cWhite, Segoe UI
    Gui Add, Text, x14 y12 w214 h24 +0x200 +BackgroundTrans, Session Files
    ResetFont()

    Gui Add, Text, x14 y59 w442 h24 +0x200
    , Select the files you want to be integrated into a new or existing session list.
    Gui Add, ListView, hWndg_hLvSessionFiles x14 y89 w744 h180 +LV0x14000 +Checked -Multi, File Path|Active
    SetExplorerTheme(g_hLvSessionFiles)
    LV_ModifyColEx(Col1W, 48)
    Gui Add, Button, gSaveSessionDialog_InvertSelection x14 y280 w120 h24, &Invert Selection
    Gui Add, Button, gSaveSessionDialog_SetActiveItem x142 y280 w120 h24, Set as &Active
    Gui Add, Text, x14 y322 w748 h2 +0x10

    Gui Add, Text, x17 y328 w120 h24 +0x200, Session &Name:
    Gui Add, ComboBox, vCbxSessions x14 y360 w324, %Sessions%
    GuiControl, Text, CbxSessions, %ProposedName%

    Gui Add, Text, x-1 y394 w774 h48 +Border -Background
    Gui Add, Button, gSaveSessionDialog_Save x585 y408 w84 h24 +Default, &Save
    Gui Add, Button, gSaveSessionDialog_OnClose x677 y408 w84 h24, &Cancel

    Gui Show, w772 h442, Save Session

    ; LV file list
    IL := IL_Create()
    Loop % Sci.Length() {
        FullPath := Sci[A_Index].FullName
        If (FullPath != "") {
            IL_Index := IL_Add(IL, "HICON:" . GetFileIcon(FullPath))
            LV_Add("Check Icon" . IL_Index, FullPath)
        }
    }
    LV_SetImageList(IL, 1)

    ; Adjust scrollbar
    ControlGet LvStyle, Style,,, ahk_id %g_hLvSessionFiles%
    If (LvStyle & 0x100000) { ; WS_HSCROLL
        SysGet VScrollBarW, 2 ; SM_CXVSCROLL
        LV_ModifyCol(1, Col1W - VScrollBarW - 1)
    }

    LV_Modify(GetActiveTabIndex(), "Vis Select Col2", "   ✔") ; Active file

    SetModalWindow(1)
}

SaveSessionDialog_OnClose() {
    SaveSessionDialog_OnEscape:
    SetModalWindow(0)
    Gui Session: Destroy
    Return
}

SaveSessionDialog_InvertSelection() {
    SetListView("Session", g_hLvSessionFiles)
    Loop % LV_GetCount() {
        SendMessage 0x102C, % A_Index - 1, 0x2000,, ahk_id %g_hLvSessionFiles% ; LVM_GETITEMSTATE, LVIS_CHECKED
        LV_Modify(A_Index, Errorlevel == 0x2000 ? "-Check" : "Check")
    }
}

SaveSessionDialog_SetActiveItem() {
    SetListView("Session", g_hLvSessionFiles)
    Row := LV_GetNext()
    If (!Row) {
        Return
    }

    LV_Modify(0, "Col2", "")
    LV_Modify(Row, "Select Check Col2", "   ✔")
    SetFocus(g_hLvSessionFiles)
}

SaveSessionDialog_Save() {
    Local Row := 0, FullPath, CheckMark, ActiveTab := 1, FileIndex, aFiles := [], aItems := [], SessionName

    SetListView("Session", g_hLvSessionFiles)
    Gui Submit, NoHide

    While (Row := LV_GetNext(Row, "Checked")) {
        LV_GetText(FullPath, Row)
        LV_GetText(CheckMark, Row, 2)
        If (CheckMark != "") {
            ActiveTab := A_Index
        }

        FileIndex := GetFileHistoryIndex(FullPath)
        If (!FileIndex) {
            FileIndex := g_aoFiles.Push({"Path": FullPath})
        }

        aFiles.Push(FullPath)
        aItems.Push(GetFileHistoryIndex(FullPath))
    }

    If (aItems.Length()) {
        SessionName := CbxSessions
        If (GetSessionIndex(SessionName)) {
            Gui Session: +OwnDialogs
            MsgBox 0x31, Save Session, A session named "%SessionName%" already exists. Overwrite?
            IfMsgBox Cancel, {
                Return
            }
        }
        AddSessionEx(SessionName, aFiles, aItems, ActiveTab)
    }

    SaveSessionDialog_OnClose()
}

AddSessionEx(Name, aFiles, aItems, Active := 1) {
    AddSession(Name, aFiles, aItems, Active)
    EnableSubMenu("MenuSession", "Saved Sessions", "MenuSavedSessions")
    SetMenuColor("MenuSavedSessions", g_MenuColor)
}

ShowCmdLineParamsDialog() { ; M
    Global
    Local n, FullPath, FileExt, Executable, FileType, DefaultVerb, Command

    Gui CmdLineParam: New, +LabelCmdLineParam_On +hWndhWndCmdLineParam -MinimizeBox +OwnerMain
    SetWindowIcon(hWndCmdLineParam, IconLib, -56)
    Gui Color, White

    n := TabEx.GetSel()
    FullPath := Sci[n].FullName
    SplitPath FullPath,,, FileExt

    Executable := FindExecutable(FullPath)

    RegRead FileType, HKCR\.%FileExt%
    If (FileType != "") {
        RegRead DefaultVerb, HKCR\%FileType%\Shell
        If (ErrorLevel == 1 && DefaultVerb == "") {
            DefaultVerb := "Open"
        }
        RegRead Command, HKCR\%FileType%\Shell\%DefaultVerb%\Command
    } Else {
        Command := "(Undefined)"
    }

    Gui Add, Pic, x-2 y-2 w618 h51, % "HBITMAP:" . Gradient(618, 51)

    If (Executable != "") {
        Gui Add, Pic, x573 y6 w32 h32 +BackgroundTrans, % "HICON:" . GetFileIcon(Executable, False)
        Gui Add, Pic, x587 y27 w16 h16 +BackgroundTrans +Icon2, % "HICON:" . GetFileIcon(FullPath)
    }
    Gui Font, s12 cWhite, Segoe UI
    Gui Add, Text, x12 y12 w600 h23 +0x200 +BackgroundTrans, Command Line Parameters
    ResetFont()

    ; File association info
    Gui Add, Text, x57 y66 w503 h24 +0x200
    , Command line of the associated application based on file type:
    Gui Add, Edit, x56 y100 w504 h23 +ReadOnly -E0x200, %Command%

    ; Parameters input
    Gui Add, Text, x58 y133 w503 h24 +0x200
    , Parameters that will be appended to the current file path:
    Gui Add, Edit, hWndhEdtArgs vEdtArgs x57 y164 w504 h23, % Sci[n].Parameters
    SetFocus(hEdtArgs)

    Gui Add, Text, x-1 y220 w618 h49 -Background +Border
    Gui Add, Button, gCmdLineParam_OK x438 y232 w80 h23 +Default, &OK
    Gui Add, Button, gCmdLineParam_OnClose x524 y232 w80 h23, &Cancel

    Gui Show, w616 h268, Command Line Parameters
    SetModalWindow(1)
}

CmdLineParam_OnEscape() {
    CmdLineParam_OnClose()
}
CmdLineParam_OnClose() {
    SetModalWindow(0)
    Gui CmdLineParam: Destroy
}

CmdLineParam_OK() {
    Global
    Gui CmdLineParam: Submit, NoHide
    Sci[TabEx.GetSel()].Parameters := EdtArgs
    CmdLineParam_OnClose()
}

ShowSessionsManager() {
    ShowFileHistoryManager(1)
}

ShowFavoritesManager() {
    ShowFileHistoryManager(2)
}

ShowFileHistoryManager(ActiveTab := 1) {
    Global
    Local Checked, oTabEx, hTabExIL, TB_Options, TB_Size, Buttons1, Buttons2, Buttons3, Buttons4, LV_Options
    , SessionIcon, SessionNames, Session := "(None)", Each, Name, nFiles, sFiles, ID, FullPath, Index, hWnd

    Gui FileHistoryManager: New, +LabelFHM_On +hWndg_hWndFHM -MinimizeBox +OwnerMain
    SetWindowIcon(g_hWndFHM, IconLib, -96)

    Gui Add, Pic, x-2 y-2 w702 h51, % "HBITMAP:" . Gradient(702, 51)
    Gui Font, s12 cWhite, Segoe UI
    Gui Add, Text, hWndhTxtFHM x12 y12 w300 h23 +0x200 +BackgroundTrans, Sessions Manager
    ResetFont()

    Gui Add, Tab3, hWndg_hTabFHM gFHM_TabHandler x8 y57 w685 h375
    SendMessage 0x1329, 0, % DPIScale(23) << 16,, ahk_id %g_hTabFHM% ; TCM_SETITEMSIZE
    GuiControl,, %g_hTabFHM%, Sessions||Favorites|Recent Files|Open Files|Settings

    ; Tab icons
    oTabEx := New GuiTabEx(g_hTabFHM)
    hTabExIL := IL_Create(5)
    IL_AddEx(hTabExIL, IconLib, -36, -38, -7, -39, -37)
    oTabEx.SetImageList(hTabExIL)
    Loop 5 {
        oTabEx.SetIcon(A_Index, A_Index)
    }
    SendMessage 0x132B, 0, 5 | (3 << 16),, ahk_id %g_hTabFHM% ; TCM_SETPADDING

    ; Toolbar set
    TB_Options := "Flat List TextOnly NoDivider"
    TB_Size := "w605 h22"
    Buttons1 := "Open`nRename`nMove Up`nMove Down`nRemove"
    Buttons2 := "Open`nMove Up`nMove Down`nRemove"
    Buttons3 := "Open`nOpen All`nRemove`nRemove All"
    Buttons4 := "Activate`nReload`nClose`nClose All"

    Gui Tab, 1 ; Sessions
    Toolbar_Create("FHM_OnToolbar", Buttons1,, TB_Options,, TB_Size)

    Gui Add, TreeView, hWndg_hTvSessions gFHM_TvHandler x17 y115 w666 h308 +0x1408 -0x2 +AltSubmit -WantF2
    ; TV styles (+0x1408): TVS_EDITLABELS | TVS_SINGLEEXPAND | TVS_FULLROWSELECT, (-0x2): -TVS_HASLINES
    g_hIL_FHM := IL_Create(30, 1, 0) ; Session TV icons
    TV_SetImageList(g_hIL_FHM)
    SessionIcon := IL_Add(g_hIL_FHM, IconLib, -36)
    SetExplorerTheme(g_hTvSessions)

    SessionNames := Session . "|"
    For Each, Session in g_aoSessions {
        Name := Session.Name
        SessionNames .= Name . "|"

        nFiles := Session.Files.Length()
        sFiles := FHM_GetSessionFileCountString(nFiles)

        ID := TV_Add(Name . sFiles, 0, "Icon" . SessionIcon)
        Loop %nFiles% {
            FullPath := Session.Files[A_Index]
            Index := IL_Add(g_hIL_FHM, "HICON:" . GetFileIcon(FullPath))
            TV_Add(FullPath, ID, "Icon" . Index)
        }
    }

    LV_Options := "x17 y115 w666 h308 +LV0x14000 -Hdr -Multi +0x40"

    Gui Tab, 2 ; Favorites
    Toolbar_Create("FHM_OnToolbar", Buttons2,, TB_Options,, TB_Size)
    Gui Add, ListView, hWndg_hLvFavorites gFHM_LvHandler %LV_Options%, Favorites

    Gui Tab, 3 ; Recent
    Toolbar_Create("FHM_OnToolbar", Buttons3,, TB_Options,, TB_Size)
    Gui Add, ListView, hWndg_hLvRecentFiles gFHM_LvHandler %LV_Options%, Recent

    Gui Tab, 4 ; Open Files
    Toolbar_Create("FHM_OnToolbar", Buttons4,, TB_Options,, TB_Size)
    Gui Add, ListView, hWndg_hLvOpenFiles gFHM_LvHandler %LV_Options%, Open Files

    Gui Tab, 5 ; Settings
    Gui Add, GroupBox, x17 y86 w665 h80, Sessions
    Gui Add, Text, x30 y118 w120 h23 +0x200, Startup session:
    Gui Add, DropDownList, hWndhDdlSessions vDdlStartupSession x187 y118 w267, %SessionNames%
    Gui Add, GroupBox, x17 y170 w665 h177, File Metadata
    Gui Add, Text, x30 y190 w578 h23 +0x200
    , The following details will be preserved for recent files, session files and favorites:
    Checked := g_Metadata & 1
    Gui Add, CheckBox, vChkMetaPos x30 y215 w300 h23 Checked%Checked%, Cursor position
    Checked := g_Metadata & 2
    Gui Add, CheckBox, vChkMetaLines x30 y240 w300 h23 Checked%Checked%, Line markers
    Checked := g_Metadata & 4
    Gui Add, CheckBox, vChkMetaMarkers x30 y265 w300 h23 Checked%Checked%, Text markers
    Checked := g_Metadata & 8
    Gui Add, CheckBox, vChkMetaSels x30 y290 w300 h23 Checked%Checked%, Selections
    Checked := g_Metadata & 16
    Gui Add, CheckBox, vChkMetaFolds x30 y315 w300 h23 Checked%Checked%, Contracted folds

    If (g_LoadLastSession && IsObject(GetSession(g_LastSessionName))) {
        Session := g_LastSessionName
    } Else {
        Session := "(None)"
    }
    GuiControl ChooseString, %hDdlSessions%, %Session%

    Gui Tab

    CreateButton("FHM_OnToolbar", IconLib, -10, "x8 y456 w24 h24", "Refresh (F5)")
    Gui Add, Text, x-1 y442 w704 h55 +0x10
    Gui Add, Button, vBtnFHM_Apply gFHM_ApplySettings x523 y456 w80 h23 Hidden, &Apply
    Gui Add, Button, gFHM_OnClose x608 y456 w80 h23 Default, &Close

    Gui FileHistoryManager: Default
    For Each, hWnd in [g_hLvFavorites, g_hLvRecentFiles, g_hLvOpenFiles] {
        Gui ListView, %hWnd%
        LV_SetImageList(g_hIL_FHM, 1)
        SetExplorerTheme(hWnd)
    }

    FHM_LoadItems(g_hLvOpenFiles, g_hIL_FHM, FHM_GetOpenFiles())
    FHM_LoadItems(g_hLvFavorites, g_hIL_FHM, g_aFavorites)
    FHM_LoadItems(g_hLvRecentFiles, g_hIL_FHM, ReverseArray(g_aRecentFiles))

    If (ActiveTab != 1) {
        GuiControl Choose, %g_hTabFHM%, %ActiveTab%
        FHM_TabHandler()
    }
    Gui Show, w700 h491, File History Manager
}

FHM_GetOpenFiles() {
    Local aOpenFiles := []
    Loop % Sci.Length() {
        If (Sci[A_Index].FullName != "") {
            aOpenFiles.Push(Sci[A_Index].FullName)
        }
    }
    Return aOpenFiles
}

FHM_OnEscape() {
    FHM_OnClose()
}
FHM_OnClose() {
    Gui FileHistoryManager: Destroy
}

FHM_ApplySettings() {
    Global
    Gui FileHistoryManager: Submit, NoHide

    ; Startup session
    If (DdlStartupSession == "(None)") {
        g_LoadLastSession := False
    } Else {
        g_LoadLastSession := True
        g_LastSessionName := DdlStartupSession
    }

    ; File metadata
    g_Metadata := 0
    g_Metadata |= (ChkMetaPos ? 1 : 0)
    g_Metadata |= (ChkMetaLines ? 2 : 0)
    g_Metadata |= (ChkMetaMarkers ? 4 : 0)
    g_Metadata |= (ChkMetaSels ? 8 : 0)
    g_Metadata |= (ChkMetaFolds ? 16 : 0)
}

FHM_LoadItems(hLV, IL, aFiles) {
    Local FullPath, Index

    SetListView("FileHistoryManager", hLV)
    LV_Delete()

    Loop % aFiles.Length() {
        FullPath := aFiles[A_Index]
        Index := IL_Add(IL, "HICON:" . GetFileIcon(FullPath))
        LV_Add("Icon" . Index, FullPath)
    }
    LV_ModifyCol(1, "AutoHdr")
}

FHM_TabHandler() {
    Global
    Local TabText
    Gui FileHistoryManager: Default

    GuiControlGet TabText,, %g_hTabFHM%
    If (TabText != "Settings") {
        GuiControl,, %hTxtFHM%, % TabText . " Manager"
        GuiControl Hide, BtnFHM_Apply
    } Else {
        GuiControl,, %hTxtFHM%, %TabText%
        GuiControl Show, BtnFHM_Apply
    }
}

FHM_TvHandler(hWnd, Event, Info, Error := "") {
    Local NewName, Index, ItemID, CurrentName

    If (Event == "K" && Info == 0x71) { ; F2
        ItemID := TV_GetSelection()
        TV_GetText(CurrentName, ItemID)
        g_TempSessionName := RegExReplace(CurrentName, " \(\d+ Files\)$") ; Remove file count
        TV_Modify(ItemID,, g_TempSessionName)
        FHM_EditSessionName(ItemID)

    } Else If (Event == "e") {
        ; The user has finished editing the field. A_EventInfo contains the item ID.
        TV_GetText(NewName, Info)

        Index := GetSessionIndex(g_TempSessionName)
        g_aoSessions[Index].Name := NewName
        Try {
            Menu MenuSavedSessions, Rename, %g_TempSessionName%, %NewName%
        }

        TV_Modify(Info,, NewName . FHM_GetSessionFileCountString(g_aoSessions[Index].Files.Length()))

    } Else If (Event == "DoubleClick" && Info) {
        FHM_OnToolbar(0, "Click", "Open", 0, 0)
    }
}

FHM_EditSessionName(ItemID) {
    If (TV_GetParent(ItemID) == 0) {
        PostMessage 0x1141, 0, %ItemID%,, ahk_id %g_hTvSessions% ; TVM_EDITLABELW
    }
}

FHM_GetSessionFileCountString(nFiles) {
    Return % " (" . (nFiles == 0 ? "Empty)" : (nFiles . (nFiles > 1 ? " Files)" : " File)")))
}

FHM_LvHandler(hLV, Event, Row, Error := "") {
    Local TabText

    If (!Row || Event != "DoubleClick") {
        Return
    }

    GuiControlGet TabText,, %g_hTabFHM%
    ; Default double-click action for Favorites and Recent is "Open".
    FHM_OnToolbar(0, "Click", TabText == "Open Files" ? "Activate" : "Open", 0, 0)
}

FHM_OnToolbar(hTB, Event, Text, Pos, Id) {
    Local nTab, ItemID, ParentID, ItemString, SessionName, Row, FullPath, n, hLV, Index
    , Expanded, PrevID, NewItemID, Each, IconIndex

    If (Event != "Click") {
        Return
    }

    Gui FileHistoryManager: Default
    ControlGet nTab, Tab,,, ahk_id %g_hTabFHM%

    If (Text == "Refresh (F5)") {
        If (nTab == 1) {
            ; ...?

        } Else If (nTab == 2) {
            FHM_LoadItems(g_hLvFavorites, g_hIL_FHM, g_aFavorites)

        } Else If (nTab == 3) {
            FHM_LoadItems(g_hLvRecentFiles, g_hIL_FHM, ReverseArray(g_aRecentFiles))

        } Else If (nTab == 4) {
            FHM_LoadItems(g_hLvOpenFiles, g_hIL_FHM, FHM_GetOpenFiles())

        } Else If (nTab == 5) {
            ; Reload session list
        }

        Return
    }

    ; Sessions
    If (nTab == 1) {
        Gui TreeView, %g_hTvSessions%
        ItemID := TV_GetSelection()
        If (!ItemID) {
            Return
        }

        ParentID := TV_GetParent(ItemID) ; ParentID is 0 for root items (sessions).

        TV_GetText(ItemString, ItemID)
        If (ParentID) {
            FullPath := ItemString
            TV_GetText(ItemString, ParentID)
        }

        SessionName := RegExReplace(ItemString, " \(\d+ Files\)$")

        If (Text == "Open") {
            ParentID ? OpenFileEx(FullPath) : LoadSession(SessionName)
            FHM_UpdateLists()

        } Else If (Text == "Rename") {
            If (ParentID == 0) {
                g_TempSessionName := SessionName
                TV_Modify(ItemID,, SessionName) ; Remove file count from name before enabling the edit label.
                FHM_EditSessionName(ItemID)
            }

        } Else If (Text == "Move Up" || Text == "Move Down") {
            ItemString := ParentID ? FullPath : ItemString
            FHM_MoveSession(ParentID, ItemID, ItemString, SessionName, InStr(Text, "Up") ? 1 : 0)

        } Else If (Text == "Remove") {
            If (ParentID) {
                If (FHM_RemoveSessionFile(SessionName, FullPath)) {
                    TV_Delete(ItemID)
                }
            } Else {
                Index := GetSessionIndex(SessionName)
                If (!Index) {
                    Return
                }
                g_aoSessions.RemoveAt(Index)
                TV_Delete(ItemID)
                Try {
                    Menu MenuSavedSessions, Delete, %SessionName%
                }
                RemoveMenuItem("MenuSavedSessions", "SessionName", Index)
            }
        }

        Return
    }

    Gui ListView, % {2: g_hLvFavorites, 3: g_hLvRecentFiles, 4: g_hLvOpenFiles}[nTab]
    Row := LV_GetNext()
    If (!Row && !InStr(Text, "All", 1)) {
        Return
    }
    LV_GetText(FullPath, Row)

    ; Favorites
    If (nTab == 2) {
        If (Text == "Open") {
            OpenFileEx(FullPath)
            FHM_UpdateLists()

        } Else If (Text == "Move Up") {
            FHM_MoveFavorite(FullPath, Row, True)

        } Else If (Text == "Move Down") {
            FHM_MoveFavorite(FullPath, Row, False)

        } Else If (Text == "Remove") {
            LV_Delete(Row)
            g_aFavorites.RemoveAt(Row)
            RemoveMenuItem("MenuFavorites", FullPath, Row, 3) ; 3: menu item offset
        }
    }

    ; Recent Files
    Else If (nTab == 3) {
        If (Text == "Open") {
            OpenFileEx(FullPath)
            FHM_UpdateLists()

        } Else If (Text == "Open All") {
            OpenAllRecentFiles()
            FHM_UpdateLists()

        } Else If (Text == "Remove") {
            LV_Delete(Row)
            g_aRecentFiles.RemoveAt(IndexOf(g_aRecentFiles, FullPath))
            RemoveMenuItem("MenuRecent", FullPath, Row)

        } Else If (Text == "Remove All") {
            LV_Delete()

            Loop % g_aRecentFiles.Length() {
                Try {
                    Menu MenuRecent, Delete, % g_aRecentFiles[A_Index]
                }
            }
            UpdateMenuItemState("MenuFile", "Recent &Files", 0)

            g_aRecentFiles := []
        }
    }

    ; Open Files
    Else If (nTab == 4) {
        n := IsFileOpened(FullPath)

        If (Text == "Activate") {
            n ? TabEx.SetSel(n) : 0

        } Else If (Text == "Reload") {
            n ? ReopenFile(n) : OpenFileEx(FullPath)
            FHM_UpdateLists()

        } Else If (Text == "Close") {
            If (n && CloseTab(n)) {
                SendMessage 0x1008, Row - 1, 0,, ahk_id %g_hLvOpenFiles% ; LVM_DELETEITEM
            }

        } Else If (Text == "Close All") {
            CloseAllTabs()
            FHM_UpdateLists(1)
        }
    }
}

FHM_UpdateLists(Flags := 3) {
    If (Flags & 1) {
        SendMessage 0x1009, 0, 0,, ahk_id %g_hLvOpenFiles% ; LVM_DELETEALLITEMS
        FHM_LoadItems(g_hLvOpenFiles, g_hIL_FHM, FHM_GetOpenFiles())
    }

    If (Flags & 2) {
        SendMessage 0x1009, 0, 0,, ahk_id %g_hLvRecentFiles%
        FHM_LoadItems(g_hLvRecentFiles, g_hIL_FHM, ReverseArray(g_aRecentFiles))
    }
}

RemoveMenuItem(MenuName, ItemName, ItemPos, Offset := 0) {
    Local hMenu, ItemString, ErrMsg := ""

    hMenu := MenuGetHandle(MenuName)
    If (!hMenu) {
        ErrMsg := "Invalid menu name: " . MenuName
    }

    ItemPos := ItemPos + Offset

    If !(GetMenuString(ItemString, hMenu, ItemPos - 1) == "MENUITEM") {
        ErrMsg := "Invalid menu item: " ItemString
    }

    If (ItemString != ItemName) {
        ErrMsg := "Menu item mismatch, incorrect position: " . ItemName . " != " . ItemString
    }

    If (ErrMsg != "") {
        OutputDebug %ErrMsg%
        Return 0
    }

    Try {
        Menu %MenuName%, Delete, %ItemPos%&

    } Catch {
        OutputDebug Failed to remove menu item at position %ItemPos%.
        Return 0
    }

    Return 1
}

FHM_MoveSession(ParentID, ItemID, ItemText, SessionName, Up := True) {
    Local Expanded, RelID, NewItemID, Each, FullPath, IconIndex, SessionIndex, oSession, NewIndex, FileIndex

    Expanded := TV_Get(ItemID, "Expanded")

    If (Up) {
        RelID := TV_GetPrev(ItemID)
        If (RelID) {
            RelID := TV_GetPrev(RelID)
            If (!RelID) {
                RelID := "First"
            }
        }
    } Else {
        RelID := TV_GetNext(ItemID)
    }

    If (!RelID) {
        Return
    }

    TV_Delete(ItemID)

    SessionIndex := GetSessionIndex(SessionName)

    If (ParentID == 0) { ; Session
        NewItemID := TV_Add(ItemText, 0, RelID)

        For Each, FullPath in GetSession(SessionName).Files {
            IconIndex := IL_Add(g_hIL_FHM, "HICON:" . GetFileIcon(FullPath))
            TV_Add(FullPath, NewItemID, "Icon" . IconIndex)
        }

        ; Select a TV item without necessarily expanding it
        SendMessage 0x110B, Expanded ? 0x9 : 0x8009, %NewItemID%,, ahk_id %g_hTvSessions% ; TVM_SELECTITEM

        oSession := g_aoSessions.RemoveAt(SessionIndex)
        NewIndex := Up ? --SessionIndex : ++SessionIndex
        g_aoSessions.InsertAt(NewIndex, oSession)

        Try {
            Menu MenuSavedSessions, Delete, %SessionName%
            Menu MenuSavedSessions, Insert, %SessionIndex%&, %SessionName%, M_LoadSession
            Menu MenuSavedSessions, Icon, %SessionName%, %IconLib%, -36
        }

    } Else { ; Files within sessions
        IconIndex := IL_Add(g_hIL_FHM, "HICON:" . GetFileIcon(ItemText))
        NewItemID := TV_Add(ItemText, ParentID, RelID . " Icon" . IconIndex)
        TV_Modify(NewItemID, "Select")

        If (FileIndex := IndexOf(g_aoSessions[SessionIndex].Files, ItemText)) {
            FullPath := g_aoSessions[SessionIndex].Files.RemoveAt(FileIndex)
            g_aoSessions[SessionIndex].Files.InsertAt(FileIndex + (Up ? -1 : 1), FullPath)
        }
    }
}

FHM_MoveFavorite(MenuItem, ItemPos, Up := True, Offset := 3) {
    Local NewPos, TempItem, ItemText, NewText, Icon1, Icon2

    If (!ItemPos || (Up && ItemPos == 1) || (!Up && ItemPos >= LV_GetCount())) {
        Return
    }

    NewPos := ItemPos + (Up ? -1 : 1)

    ; Array
    TempItem := g_aFavorites.RemoveAt(ItemPos)
    g_aFavorites.InsertAt(NewPos, TempItem)

    ; ListView
    LV_GetText(ItemText, ItemPos)
    LV_GetText(NewText, NewPos)
    Icon1 := LV_GetItemIcon(g_hLvFavorites, ItemPos)
    Icon2 := LV_GetItemIcon(g_hLvFavorites, NewPos)
    LV_Modify(ItemPos, "Icon" . Icon2, NewText)
    LV_Modify(NewPos,  "Icon" . Icon1, ItemText)
    GuiControl Focus, %g_hLvFavorites%
    LV_Modify(NewPos, "Select")

    ; Menu
    ItemPos := Offset + NewPos
    Try {
        Menu MenuFavorites, Delete, %MenuItem%
        Menu MenuFavorites, Insert, %ItemPos%&, %MenuItem%, OpenSingleFile
        Menu MenuFavorites, Icon, %MenuItem%, % "HICON:" . GetFileIcon(MenuItem)
    }
}

FHM_RemoveSessionFile(SessionName, FullPath) {
    Local Index, Each, Item

    Index := GetSessionIndex(SessionName)

    For Each, Item in g_aoSessions[Index].Files {
        If (Item == FullPath) {
            g_aoSessions[Index].Files.RemoveAt(A_Index)
            g_aoSessions[Index].Items.RemoveAt(A_Index)
            Return 1
        }
    }

    Return 0
}

; Save metadata of all files
SaveMetadataAll() { ; M
    Loop % Sci.Length() {
        AddToFileHistory(A_Index, Sci[A_Index].FullName)
    }

    SaveFileHistory()

    ; Troubleshooting
    If (GetKeyState("Shift", "P")) {
        OpenFileEx(GetConfigFileLocation("FileHistory.xml"))
    }
}

GetSession(SessionName) {
    Loop % g_aoSessions.Length() {
        If (g_aoSessions[A_Index].Name = SessionName) {
            Return g_aoSessions[A_Index]
        }
    }
}

GetSessionIndex(SessionName) {
    Loop % g_aoSessions.Length() {
        If (g_aoSessions[A_Index].Name = SessionName) {
            Return A_Index
        }
    }
    Return 0
}

UpdateToolbar(n) {
    ;TB_EnableButton(2110, Sci[n].CanUndo())
    ;TB_EnableButton(2111, Sci[n].CanRedo())
    TB_CheckButton(2160, Sci[n].GetWrapMode())
    TB_CheckButton(2170, Sci[n].GetReadOnly())
}

/*
A_AhkPath for compiled scripts: the AutoHotkey directory is discovered via the registry entry HKLM\SOFTWARE\AutoHotkey\InstallDir. If there is no such entry, A_AhkPath is blank.
*/
SetAhkPath() {
    SplitPath A_AhkPath,, AhkDir
    If (AhkDir == "") {
        Return
    }

    If (g_AhkPath32 == "") {
        g_AhkPath32 := AhkDir . "\AutoHotkeyU32.exe"
    }

    If (g_AhkPath64 == "") {
        g_AhkPath64 := AhkDir . "\AutoHotkeyU64.exe"
    }
}

ShowAhkSettings() {
    Global

    Gui AhkDlg: New, +LabelAhkDlg_On +hWndhDlgAhk
    SetWindowIcon(hDlgAhk, IconLib, -37)

    Gui Add, Pic, hWndhPic x-2 y-2 w642 h51, % "HBITMAP:" . Gradient(642, 51)
    Gui Font, s12 cWhite, Segoe UI
    Gui Add, Text, x15 y14 w590 h23 +0x200 +BackgroundTrans, AutoHotkey Settings
    ResetFont()

    Gui Add, Text, x30 y68 w576 h23 +0x200, 64-bit executable:
    Gui Add, Edit, vg_AhkPath64 x30 y94 w485 h22, %g_AhkPath64%
    Gui Add, Button, vBtn1 gAhkSelectFile x523 y92 w84 h24, Browse...

    Gui Add, Text, x30 y130 w576 h23 +0x200, 32-bit executable:
    Gui Add, Edit, vg_AhkPath32 x30 y156 w485 h22, %g_AhkPath32%
    Gui Add, Button, vBtn2 gAhkSelectFile x523 y154 w84 h24, Browse...

    Gui Add, Text, x30 y192 w576 h23 +0x200, Alternative executable (Alt + F9):
    Gui Add, Edit, vg_AhkPathEx x30 y218 w485 h22, %g_AhkPathEx%
    Gui Add, Button, vBtn3 gAhkSelectFile x523 y216 w84 h24, Browse...

    Gui Add, CheckBox, vg_CaptureStdErr x30 y254 w573 h23 Checked%g_CaptureStdErr%, Capture standard error

    Gui Add, Text, x30 y284 w576 h23 +0x200, Help file:
    Gui Add, Edit, vg_AhkHelpFile x30 y310 w485 h22, %g_AhkHelpFile%
    Gui Add, Button, vBtn4 gAhkSelectFile x523 y308 w84 h24, Browse...

    Gui Add, Text, x-1 y363 w642 h49 +0x200 +Border -Background
    Gui Add, Button, gAhkDlg_OK x456 y376 w84 h24 +Default, &OK
    Gui Add, Button, gAhkDlg_OnClose x545 y376 w84 h24, &Cancel

    Gui Color, White
    Gui Show, w640 h411, AutoHotkey Settings
    SetFocus(hPic)
}

AhkDlg_OnClose() {
    AhkDlg_OnEscape:
    Gui AhkDlg: Destroy
    Return
}

AhkDlg_OK() {
    Gui AhkDlg: Submit
}

AhkSelectFile() {
    Local Filter, TargetControl, FullPath, StartPath, SelectedFile

    Filter := A_GuiControl != "Btn4" ? "Executable Files (*.exe)" : "Compiled HTML Help file (*.chm)"

    TargetControl := StrReplace(A_GuiControl, "Btn", "Edit")
    GuiControlGet FullPath, AhkDlg:, %TargetControl%
    StartPath := FileExist(FullPath) ? FullPath : A_ProgramFiles

    Gui AhkDlg: +OwnDialogs
    FileSelectFile SelectedFile, 3, %StartPath%, Select File, %Filter%
    If (!ErrorLevel) {
        GuiControl,, %TargetControl%, %SelectedFile%
    }
}

CreateButton(TB_Handler, IconRes, IconIndex, PosSize, Tooltip, Options := "Flat List NoDivider Tooltips Tabstop") {
    Local hIL := IL_Create(1)
    IL_Add(hIL, IconRes, IconIndex)
    Return Toolbar_Create(TB_Handler, Tooltip, hIL, Options,, PosSize)
}

Gradient(Width, Height) {
    Return CreateGradient(DPIScale(Width), DPIScale(Height), 1, g_aGradColors)
}

GetConfigFileLocation(Filename) {
    Return (g_SettingsLocation == 1) ? A_ScriptDir . "\Settings\" . Filename : g_AppData . "\" . Filename
}

ErrorHandler(e) {
    Local Msg, LineText

    Try {
        FileReadLine LineText, % e.File, % e.Line
    }

    Msg := e.Message . "`nFunction: " . e.What . "`nFile: """ . e.File
    . """`nLine: " . e.Line . ": " . Trim(LineText) . "`n`n" . e.Extra

    ErrorMsgBox(Msg, "Main", "Runtime Error")
    Return 1
}

GoToFile(FullPath) {
    Local n := IsFileOpened(FullPath)
    If (n) {
        TabEx.SetSel(n)
        Sleep 1
    } Else {
        Return OpenFileEx(FullPath)
    }
    Return n
}

xml_parse(xml)
{
	All:=xml.SN("//Menu/descendant::*")
    Script := ""
	while(aa:=All.Item[A_Index-1],ea:=XML.EA(aa))
    {
        c := aa
        first_child_name := SSN(c, "Item/@name").text
        if(first_child_name != "")
            Continue
        ParentName := ""
        loop
        {
		    p := c.ParentNode
            c_parent_name := SSN(p,"@name").text
            if(c_parent_name == "")
                break
            else
                ParentName := c_parent_name " >" parentname
            c := p
        }
        Script .= ParentName  ea.Name "`r`n"
    }
    return script
}

handle_command(command)
{
    global my_xml
    word_array := StrSplit(command, " >")
    pattern := ""
    for k,v in word_array
    {
        pattern .= "/*[@name='" v "']"
    }
    pattern := "//Menu" . pattern
    first_child_name := SSN(my_xml.SSN(pattern), "Item/@name").text
    if(first_child_name != "")
    {
        return
    }
    UnityPath:= my_xml.SSN(pattern).text
}
write2xml(command, data)
{
    global my_xml,command_pid
    word_array := StrSplit(command, " >")
    pattern := ""
    for k,v in word_array
    {
        pattern .= "/*[@name='" v "']"
    }
    pattern := "//Menu" . pattern
    my_xml.SSN(pattern).text := data
    my_xml.save(1)

    TargetScriptTitle := "ahk_pid " command_pid " ahk_class AutoHotkey"
    StringToSend := "data"
    result := Send_WM_COPYDATA(StringToSend, TargetScriptTitle)
    if(A_IsCompiled)
    {
        run, %A_ScriptDir%/../../menu.exe
    }
    else
    {
        run, %A_ScriptDir%/../../menu.ahk
    }
}

Class XML{
	keep:=[]
	__Get(x=""){
		return this.XML.xml
	}__New(param*){
		root:=param.1,file:=param.2,file:=file?file:root ".xml",temp:=ComObjCreate("MSXML2.DOMDocument")
		this.xml:=temp,this.file:=file,XML.keep[root]:=this
		temp.SetProperty("SelectionLanguage","XPath")
		if(FileExist(file)){
			FileRead,info,%file%
			if(info=""){
				this.xml:=this.CreateElement(temp,root)
				FileDelete,%file%
			}else
				temp.LoadXML(info),this.xml:=temp
		}else
			this.xml:=this.CreateElement(temp,root)
	}Add(XPath,att:="",text:="",dup:=0){
		p:="/",add:=(next:=this.SSN("//" XPath))?1:0,last:=SubStr(XPath,InStr(XPath,"/",0,0)+1)
		if(!next.xml){
			next:=this.SSN("//*")
			for a,b in StrSplit(XPath,"/")
				p.="/" b,next:=(x:=this.SSN(p))?x:next.AppendChild(this.XML.CreateElement(b))
		}if(dup&&add)
			next:=next.ParentNode.AppendChild(this.XML.CreateElement(last))
		for a,b in att
			next.SetAttribute(a,b)
		if(text!="")
			next.text:=text
		return next
	}CreateElement(doc,root){
		return doc.AppendChild(this.XML.CreateElement(root)).ParentNode
	}EA(XPath,att:=""){
		list:=[]
		if(att)
			return XPath.NodeName?SSN(XPath,"@" att).text:this.SSN(XPath "/@" att).text
		nodes:=XPath.NodeName?XPath.SelectNodes("@*"):nodes:=this.SN(XPath "/@*")
		while(nn:=nodes.item[A_Index-1])
			list[nn.NodeName]:=nn.text
		return list
	}Find(info*){
		static last:=[]
		doc:=info.1.NodeName?info.1:this.xml
		if(info.1.NodeName)
			node:=info.2,find:=info.3,return:=info.4!=""?"SelectNodes":"SelectSingleNode",search:=info.4
		else
			node:=info.1,find:=info.2,return:=info.3!=""?"SelectNodes":"SelectSingleNode",search:=info.3
		if(InStr(info.2,"descendant"))
			last.1:=info.1,last.2:=info.2,last.3:=info.3,last.4:=info.4
		if(InStr(find,"'"))
			return doc[return](node "[.=concat('" RegExReplace(find,"'","'," Chr(34) "'" Chr(34) ",'") "')]/.." (search?"/" search:""))
		else
			return doc[return](node "[.='" find "']/.." (search?"/" search:""))
	}Get(XPath,Default){
		text:=this.SSN(XPath).text
		return text?text:Default
	}ReCreate(XPath,new){
		rem:=this.SSN(XPath),rem.ParentNode.RemoveChild(rem),new:=this.Add(new)
		return new
	}Save(x*){
		if(x.1=1)
			this.Transform()
		if(this.XML.SelectSingleNode("*").xml="")
			return m("Errors happened while trying to save " this.file ". Reverting to old version of the XML")
		filename:=this.file?this.file:x.1.1,ff:=FileOpen(filename,0),text:=ff.Read(ff.length),ff.Close()
		if(!this[])
			return m("Error saving the " this.file " XML.  Please get in touch with maestrith if this happens often")
		if(text!=this[])
			file:=FileOpen(filename,"rw"),file.Seek(0),file.Write(this[]),file.Length(file.Position)
	}SSN(XPath){
		return this.XML.SelectSingleNode(XPath)
	}SN(XPath){
		return this.XML.SelectNodes(XPath)
	}Transform(){
		static
		if(!IsObject(xsl))
			xsl:=ComObjCreate("MSXML2.DOMDocument"),xsl.loadXML("<xsl:stylesheet version=""1.0"" xmlns:xsl=""http://www.w3.org/1999/XSL/Transform""><xsl:output method=""xml"" indent=""yes"" encoding=""UTF-8""/><xsl:template match=""@*|node()""><xsl:copy>`n<xsl:apply-templates select=""@*|node()""/><xsl:for-each select=""@*""><xsl:text></xsl:text></xsl:for-each></xsl:copy>`n</xsl:template>`n</xsl:stylesheet>"),style:=null
		this.XML.TransformNodeToObject(xsl,this.xml)
	}Under(under,node,att:="",text:="",list:=""){
		new:=under.AppendChild(this.XML.CreateElement(node)),new.text:=text
		for a,b in att
			new.SetAttribute(a,b)
		for a,b in StrSplit(list,",")
			new.SetAttribute(b,att[b])
		return new
	}
}SSN(node,XPath){
	return node.SelectSingleNode(XPath)
}SN(node,XPath){
	return node.SelectNodes(XPath)
}m(x*){
	active:=WinActive("A")
	ControlGetFocus,Focus,A
	ControlGet,hwnd,hwnd,,%Focus%,ahk_id%active%
	static list:={btn:{oc:1,ari:2,ync:3,yn:4,rc:5,ctc:6},ico:{"x":16,"?":32,"!":48,"i":64}},msg:=[],msgbox
	list.title:="XML Class",list.def:=0,list.time:=0,value:=0,msgbox:=1,txt:=""
	for a,b in x
		obj:=StrSplit(b,":"),(vv:=List[obj.1,obj.2])?(value+=vv):(list[obj.1]!="")?(List[obj.1]:=obj.2):txt.=b "`n"
	msg:={option:value+262144+(list.def?(list.def-1)*256:0),title:list.title,time:list.time,txt:txt}
	Sleep,120
	MsgBox,% msg.option,% msg.title,% msg.txt,% msg.time
	msgbox:=0
	for a,b in {OK:value?"OK":"",Yes:"YES",No:"NO",Cancel:"CANCEL",Retry:"RETRY"}
		IfMsgBox,%a%
	{
		WinActivate,ahk_id%active%
		ControlFocus,%Focus%,ahk_id%active%
		return b
	}
}

DynaRun(Script,Wait:=true,name:="Untitled"){
	static exec,started,filename
	if(!IsObject(v.Running))
		v.Running:=[]
	filename:=name,MainWin.Size(),exec.Terminate()
	if(Script~="i)m(.*)\{"=0)
		Script.="`n" "m(x*){`nfor a,b in x`nlist.=b Chr(10)`nMsgBox,,AHK Studio,% list`n}"
	if(Script~="i)t(.*)\{"=0)
		Script.="`n" "t(x*){`nfor a,b in x`nlist.=b Chr(10)`nToolTip,% list`n}"
	;shell:=ComObjCreate("WScript.Shell"),exec:=shell.Exec("AutoHotkey.exe /ErrorStdOut *"),exec.StdIn.Write(Script),exec.StdIn.Close(),started:=A_Now
	shell:=ComObjCreate("WScript.Shell"),exec:=shell.Exec("AutoHotkey.exe /ErrorStdOut *"),exec.StdIn.Write(Script),exec.StdIn.Close(),started:=A_Now
	v.Running[Name]:=exec
	return
}

Send_WM_COPYDATA(ByRef StringToSend, ByRef TargetScriptTitle)  ; 在这种情况中使用 ByRef 能节约一些内存.
; 此函数发送指定的字符串到指定的窗口然后返回收到的回复.
; 如果目标窗口处理了消息则回复为 1, 而消息被忽略了则为 0.
{
    VarSetCapacity(CopyDataStruct, 3*A_PtrSize, 0)  ; 分配结构的内存区域.
    ; 首先设置结构的 cbData 成员为字符串的大小, 包括它的零终止符:
    SizeInBytes := (StrLen(StringToSend) + 1) * (A_IsUnicode ? 2 : 1)
    NumPut(SizeInBytes, CopyDataStruct, A_PtrSize)  ; 操作系统要求这个需要完成.
    NumPut(&StringToSend, CopyDataStruct, 2*A_PtrSize)  ; 设置 lpData 为到字符串自身的指针.
    Prev_DetectHiddenWindows := A_DetectHiddenWindows
    Prev_TitleMatchMode := A_TitleMatchMode
    DetectHiddenWindows On
    SetTitleMatchMode 2
    TimeOutTime := 0  ; 可选的. 等待 receiver.ahk 响应的毫秒数. 默认是 5000
    ; 必须使用发送 SendMessage 而不是投递 PostMessage.
    SendMessage, 0x004A, 0, &CopyDataStruct,, %TargetScriptTitle%  ; 0x004A 为 WM_COPYDAT
    DetectHiddenWindows %Prev_DetectHiddenWindows%  ; 恢复调用者原来的设置.
    SetTitleMatchMode %Prev_TitleMatchMode%         ; 同样.
    return ErrorLevel  ; 返回 SendMessage 的回复给我们的调用者.
}



#Include %A_ScriptDir%\Lib\AuxLib.ahk
#Include %A_ScriptDir%\Lib\GuiTabEx.ahk
#Include %A_ScriptDir%\Lib\Toolbar.ahk
#Include %A_ScriptDir%\Lib\RunGetStdOut.ahk
#Include %A_ScriptDir%\Lib\ShellMenu.ahk
#Include %A_ScriptDir%\Lib\CommonDialogs.ahk
#Include %A_ScriptDir%\Lib\GuiButtonIcon.ahk
#Include %A_ScriptDir%\Lib\ExecScript.ahk
#Include %A_ScriptDir%\Lib\DBGp.ahk
#Include %A_ScriptDir%\Lib\LV_GroupView.ahk
#Include %A_ScriptDir%\Lib\AutoSize.ahk
#Include %A_ScriptDir%\Lib\CreateGradient.ahk

#Include %A_ScriptDir%\Include\Editor.ahk
#Include %A_ScriptDir%\Include\Settings.ahk
#Include %A_ScriptDir%\Include\Search.ahk
#Include %A_ScriptDir%\Include\Tools.ahk
#Include %A_ScriptDir%\Include\AhkDebug.ahk
#Include %A_ScriptDir%\Include\AhkHelp.ahk