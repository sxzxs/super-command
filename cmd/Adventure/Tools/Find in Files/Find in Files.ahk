; Find in Files v1.1.0

; Script options
#SingleInstance Off
#NoEnv
#NoTrayIcon
SetBatchLines -1
DetectHiddenWindows On
SetWorkingDir %A_ScriptDir%

; Global variables
Global g_AppName := "Find in Files"
, g_Version := "1.1.0"
, g_AppData := A_AppData . "\AmberSoft\Adventure"
, g_hWndMain
, g_IniFile
, g_Stoped := True
, g_hLvResults
, g_hCbxTarget
, g_hCbxFilter
, g_hCbxString
, g_MaxHistory
, g_SingleMatch
, g_ThousandSep
, g_ParamTarget := ""
, g_ParamFilter := ""
, g_ParamString := ""
, g_ParamStart := False
, g_ParamAdvent := False
, g_AdventPath
, g_AdventData
, g_AhkIncludes
, g_hEdtIPC
, g_VScrollBarW
, g_hWndQuickView
, g_hBtnMenu
, g_NT6orLater := DllCall("GetVersion") & 0xFF > 5
, g_IconLib := A_ScriptDir . "\..\..\Icons\Find in Files.icl"
, g_ParamFocus := False
, g_hWndShell
, g_pIContextMenu
, g_pIContextMenu2
, g_pIContextMenu3
, g_aTimestamps := []
, g_pCbData
, g_LastSortedCol := 0
, g_ColumnMode := 1
, g_TargetDelim := "|"
, g_FilterDelim := ";"

g_AdventPath := GetAdventPath()

; Command line parameters
Loop %0% {
    Param := %A_Index%

    If (InStr(Param, "/target:")) {
        g_ParamTarget := StrReplace(Param, "/target:")

    } Else If (InStr(Param, "/filter:")) {
        g_ParamFilter := StrReplace(Param, "/filter:")

    } Else If (InStr(Param, "/string:")) {
        g_ParamString := StrReplace(Param, "/string:",,, 1)

    } Else If (InStr(Param, "/start")) {
        g_ParamStart := True

    } Else If (InStr(Param, "/A")) {
        g_ParamAdvent := True

    } Else If (Param == "/focus") {
        g_ParamFocus := True
    }
}
ParamCount = %0%

If (A_ScreenDPI != 96) {
    MsgBox 0x10, High-DPI, %g_AppName% has not yet been adapted to High-DPI display scaling.
    ExitApp
}

; Settings file
g_IniFile := GetIniFileLocation("Find in Files.ini")

IniRead g_SingleMatch, %g_IniFile%, Options, SingleMatch, 1
IniRead g_MaxHistory,  %g_IniFile%, Options, MaxHistory, 15

; Search history
TargetHistory  := GetHistory("TargetHistory")
If (TargetHistory == "") {
    TargetHistory := A_MyDocuments . "`n`n"
}
FilterHistory := GetHistory("FilterHistory")
StringHistory := GetHistory("StringHistory", 0)

SetMainIcon(g_IconLib)

; Main window
Gui 1: New, +hWndg_hWndMain +LabelOn +Resize +Delimiter`n, %g_AppName%
Gui Font, s9, Segoe UI

Gui Add, Edit, hWndg_hEdtIPC x0 y0 w0 h0 ; For initial focus and data exchange

IniRead InitialX, %g_IniFile%, Window, x
IniRead InitialY, %g_IniFile%, Window, y
IniRead InitialW, %g_IniFile%, Window, w
IniRead InitialH, %g_IniFile%, Window, h
IniRead ShowState, %g_IniFile%, Window, State, 1

; Initial position and size
If (FileExist(g_IniFile)) {
    SetWindowPlacement(g_hWndMain, InitialX, InitialY, InitialW, InitialH, 0)
} Else {
    Gui Show, y100 w794 h484 Hide, %g_AppName%
}

GetClientSize(g_hWndMain, GuiWidth, GuiHeight)

w := GuiWidth - 8 - 6 - 84 - 6
Gui Add, Tab3, hWndhTab x8 y8 w%w% h220, Search

cw := GuiWidth - 111 - 8 - 80 - 14 - 6 - 84 - 6
Gui Add, Text, x22 y47 w86 h23 +0x200, Search in:
Gui Add, ComboBox, hWndg_hCbxTarget vCbxTarget x111 y47 w%cw%, %TargetHistory%

x := GuiWidth - 12 - 84 - 80 - 14
If (g_NT6orLater) {
    Gui Add, Button, hWndhBtnBrowse gBrowse x%x% y46 w80 h24, &Browse...
} Else {
    Gui Add, Button, hWndhBtnBrowse gBrowse x%x% y46 w23 h24, ...
    Gui Add, Button, hWndg_hBtnMenu gShowMenu xp+28 y46 w52 h24, Menu
    If (!g_ParamAdvent) {
        GuiControl +Disabled, %g_hBtnMenu%
    }
}

Gui Add, Text, x22 y88 w86 h23 +0x200, Filters:
Gui Add, ComboBox, hWndg_hCbxFilter vFilters x111 y88 w%cw%, %FilterHistory%

sw := GuiWidth - 22 - 14 - 6 - 84 - 6
Gui Add, Text, hWndhSep1 x22 y120 w%sw% h2 +0x10

Gui Add, Text, x22 y130 w86 h23 +0x200, Find Text:
Gui Add, ComboBox, hWndg_hCbxString vTextToFind x111 y130 w%cw%, %StringHistory%

Gui Add, Text, hWndhSep2 x22 y162 w%sw% h2 +0x10

; Search options
Gui Add, CheckBox, vChkRecurse x22 y171 w160 h23 +Checked, &Search subdirectories
Gui Add, CheckBox, vChkSingleMatch x22 y194 w160 h23 +Checked%g_SingleMatch%, &One match per file
Gui Add, CheckBox, vChkMatchCase gSetExclusivity x190 y171 w160 h23, &Case sensitive
Gui Add, CheckBox, vChkWholeWords gSetExclusivity x190 y194 w160 h23, &Match whole words
Gui Add, CheckBox, vChkRegEx gSetExclusivity x358 y171 w160 h23, &Regular Expression
Gui Add, CheckBox, vChkBackslashes gSetExclusivity x358 y194 w160 h23, Convert &backslashes
Gui Add, CheckBox, vChkNotContaining x526 y171 w160 h23, &Not containing the text
Gui Add, CheckBox, vChkHexSearch gSetExclusivity x526 y194 w160 h23, &Hexadecimal search

Gui Tab

x := GuiWidth - 84 - 6
Gui Add, Button, hWndhBtnStart gPerformSearch x%x% y7 w84 h24 +Default, Start
Gui Add, Button, hWndhBtnCancel gCancelSearch x%x% y38 w84 h24, Cancel
Gui Add, Button, hWndhBtnHelp gShowHelp x%x% y69 w84 h24, Help

Gui Add, StatusBar, vStatusBar
GuiControlGet sb, Pos, msctls_statusbar321

; Main ListView (search results)
w := GuiWidth - 16
h := GuiHeight - 235 - 8 - sbH
Gui Add, ListView, hWndg_hLvResults vLV gLvHandler x8 y235 w%w% h%h% +LV0x14000 -Multi
, Filename`nSize`nDate modified
LV_ModifyCol(1, 455)
LV_ModifyCol(2, 70)
LV_SetCol3Width(g_hLvResults)
CreateLvCallback(g_hLvResults)
DllCall("UxTheme.dll\SetWindowTheme", "Ptr", g_hLvResults, "WStr", "Explorer", "Ptr", 0)

If (g_ParamAdvent) {
    Menu SplitButtonMenu, Add, Current Directory, MenuHandler
    Menu SplitButtonMenu, Add, Current File, MenuHandler
    Menu SplitButtonMenu, Add, Current File and Its Includes, MenuHandler
    Menu SplitButtonMenu, Add, All Open Files, MenuHandler
    If (g_NT6orLater) {
        SplitButton(hBtnBrowse, 16, "SplitButtonMenu", g_hWndMain)
    }
}

ShowWindow(g_hWndMain, ShowState)
WinActivate ahk_id %g_hWndMain%

; Autocomplete path
DllCall("Shlwapi.dll\SHAutoComplete", "Ptr", GetChild(g_hCbxTarget), "UInt", 0)

; Thousand separator
RegRead g_ThousandSep, HKEY_CURRENT_USER\Control Panel\International, sThousand

; Shell menu integration
g_hWndShell := CreateShellMenuWindow()

; Message handling
OnMessage(0x100, "OnWM_KEYDOWN")
OnMessage(0x232, "OnWM_EXITSIZEMOVE")
OnMessage(10000, "CustomMessage")
OnMessage(0x16,  "SaveSettings") ; WM_ENDSESSION

SysGet g_VScrollBarW, 2 ; SM_CXVSCROLL, vertical scrollbar width

; Parameters handling
If (ParamCount) {
    If (g_ParamTarget != "") {
        GuiControl Text, %g_hCbxTarget%, %g_ParamTarget%
    }

    If (g_ParamFilter != "") {
        GuiControl Text, %g_hCbxFilter%, %g_ParamFilter%
    }

    If (g_ParamString != "") {
        GuiControl Text, %g_hCbxString%, %g_ParamString%
    }

    If (g_ParamStart) {
        GoSub PerformSearch
    }

    If (g_ParamFocus) {
        GuiControl Focus, %g_hCbxString%
    }
}

Return ; End of the auto-execute section.

OnSize:
    If (A_EventInfo == 1) {
        Return
    }

    AutoXYWH("w",  hTab)
    AutoXYWH("w*", g_hCbxTarget, g_hCbxFilter, g_hCbxString)
    AutoXYWH("xt*", hBtnBrowse, g_hBtnMenu)
    AutoXYWH("w",  hSep1, hSep2)
    AutoXYWH("x",  hBtnStart, hBtnCancel, hBtnHelp)
    AutoXYWH("wh", g_hLvResults)

    KillSelection()

    LV_SetCol3Width(g_hLvResults)
Return

OnEscape() {
    Return (!g_Stoped ? g_Stoped := True : Quit())
}

OnClose() {
    Quit()
}

Quit() {
    DllCall("DestroyWindow", "Ptr", g_hWndShell)
    SaveSettings()
    ExitApp
}

PerformSearch:
    Gui Submit, NoHide

    If (CbxTarget == "") {
        hCbxEdit := GetChild(g_hCbxTarget)
        Edit_ShowBalloonTip(hCbxEdit, "Target directory or file must be specified")
        Return
    }

    LV_Delete()
    SB_SetText("")

    ; For case sensitivity in the ComboBox
    GuiControlGet TextToFind,, %g_hCbxString%, Text

    AddToHistory(g_hCbxTarget, CbxTarget)
    AddToHistory(g_hCbxFilter, Filters)
    AddToHistory(g_hCbxString, TextToFind)
    KillSelection()

    If (Filters == "" || Filters == "*") {
        Filters := "*.*"
    }

    If (InStr(Filters, g_FilterDelim) || !RegExMatch(Filters, "^.*\.(\w+|\*)$")) { ; "\*\.(\w+|\*)$"
        ; Wildcards
        Filters := StrReplace(Filters, ".", "\.")
        Filters := StrReplace(Filters, "*", ".*")
        Filters := StrReplace(Filters, "?", ".")

        aMasks := StrSplit(Filters, g_FilterDelim, " ")

        SimpleMask := False
    } Else {
        SimpleMask := True
    }

    If (ChkWholeWords) {
        ChkRegEx := True
        TextToFind := "\b\Q" . TextToFind . "\E\b"
        If (!ChkMatchCase) {
            TextToFind := "i)" . TextToFind
        }
    }

    If (ChkBackslashes) {
        ConvertBackslashes(TextToFind)
    }

    Containing := !ChkNotContaining

    ; Set column mode
    If (ChkHexSearch && Containing && TextToFind != "") {
        arr := StrSplit(TextToFind, " ")
        Loop % arr.Length() {
            arr[A_Index] := "0x" . arr[A_Index]
        }

        SetColumnMode(3, 455, "Integer 50", "Pos", "Data") ; Hex

    } Else If (TextToFind != "" && Containing) {
        SetColumnMode(2, 455, "Integer 50", "Line", "Line Text") ; Text

    } Else {
        SetColumnMode(1, 455, "Integer 70", "Size (B)", "Date modified") ; Size and date
    }

    MatchCount := 0
    FileCount  := 0
    g_Stoped := False

    TargetList := StrSplit(CbxTarget, g_TargetDelim, " ")

    For Each, Target in TargetList {
        If (g_Stoped) {
            Break
        }

        If (InStr(FileExist(Target), "D", 1)) { ; Folders
            Dir := True
            Target := RTrim(Target, "\")

            If (SimpleMask) {
                LoopMask := "\" . Filters
            } Else {
                LoopMask := "\*.*"
            }
        } Else { ; Files
            Dir := False
            LoopMask := ""
        }

        Recurse := ChkRecurse && Dir

        Loop Files, %Target%%LoopMask%, % Recurse ? "R" : ""
        {
            If (g_Stoped) {
                Break 2
            }

            If (!SimpleMask) {
                If (!RegExMatchArray(A_LoopFileName, aMasks)) {
                    Continue
                }
            }

            SB_SetText(" Searching: " . A_LoopFileFullPath)

            If (TextToFind != "") {
                Found := False

                If (ChkHexSearch) {
                    f := FileOpen(A_LoopFileFullPath, "r")

                    Matching := False
                    f.Pos := 0
                    i := 1

                    While(!f.AtEoF) {
                        If (g_Stoped) {
                            Break 3
                        }

                        ch := f.ReadUChar()

                        If (arr[i] == ch) {
                            i++
                            Matching := True
                        } Else {
                            i := 1
                            Matching := False
                        }

                        If (i > arr.Length() && Matching) {
                            Found := True

                            If (Containing) {
                                OldPos := f.Pos
                                Pos := A_Index - arr.Length()
                                ChunkPos := (Pos // 16) * 16
                                f.Seek(ChunkPos)
                                f.RawRead(Chunk, 16)
                                f.Seek(ChunkPos)
                                HexData := ""
                                Loop 16 {
                                    UChar := NumGet(Chunk, A_Index - 1, "UChar")
                                    HexData .= Format("{:02X}", UChar) . " "
                                }
                                f.Pos := OldPos

                                LV_Add("", A_LoopFileFullPath, Pos, HexData)
                                MatchCount++
                            }
                        }

                        If (ChkSingleMatch && Found) {
                            Break
                        }
                    }
                }

                Else If (ChkBackslashes) {
                    f := FileOpen(A_LoopFileFullPath, "r")
                    InitPos := f.Tell() ; BOM

                    FileRead Data, %A_LoopFileFullPath%
                    Data := StrReplace(Data, "`r`n", "`n") ; Replace CRLF with LF

                    StartingPos := 1
                    CRLFCount := 0
                    Line := 0
                    SameLine := False
                    While (FoundPos := InStr(Data, TextToFind, ChkMatchCase, StartingPos)) {
                        If (g_Stoped) {
                            Break 3
                        }

                        FoundPos := FoundPos + InitPos

                        Found := True

                        If (ChkNotContaining) {
                            Break
                        }

                        While (!f.AtEoF) {
                            If (g_Stoped) {
                                Break 4
                            }

                            Pos1 := f.Tell() ; Current pos

                            TextLine := f.ReadLine()

                            If (!SameLine) {
                                Line++

                                LineEnding := SubStr(TextLine, -1, 2)
                                If (LineEnding == "`r`n") {
                                    CRLFCount++ ; Compensate the replacement of CRLF
                                }
                            }

                            Pos2 := f.Tell() ; Position after ReadLine
                            If (Pos2 >= FoundPos + CRLFCount) {
                                LV_Add("", A_LoopFileFullPath, Line, TextLine)
                                MatchCount++

                                f.Seek(Pos1)
                                SameLine := True

                                If (ChkSingleMatch) {
                                    Break 2 ; Break 2 while loops
                                } Else {
                                    StartingPos := FoundPos + 1
                                    Break
                                }
                            } Else {
                                SameLine := False
                            }

                            StartingPos := FoundPos + 1
                        }
                    }
                }

                Else {
                    f := FileOpen(A_LoopFileFullPath, 8) ; 8: replace standalone `r with `n when reading.

                    While (!f.AtEoF) {
                        If (g_Stoped) {
                            Break 3
                        }

                        TextLine := f.ReadLine()

                        If (ChkRegEx) {
                            If (RegExMatch(TextLine, TextToFind)) {
                                Found := True
                                If (Containing) {
                                    LV_Add("", A_LoopFileFullPath, A_Index, TextLine)
                                    MatchCount++
                                }
                            }
                        } Else {
                            If (InStr(TextLine, TextToFind, ChkMatchCase)) {
                                Found := True
                                If (Containing) {
                                    LV_Add("", A_LoopFileFullPath, A_Index, TextLine)
                                    MatchCount++
                                }
                            }
                        }

                        If (ChkSingleMatch && Found) {
                            Break
                        }
                    } ; End while
                }

                f.Close()

                If (ChkNotContaining && !Found) {
                    LV_Add2(A_LoopFileFullPath, A_LoopFileSize, A_LoopFileTimeModified)
                    FileCount++
                } Else If (Found && Containing) {
                    FileCount++
                }

            } Else { ; No text to find
                LV_Add2(A_LoopFileFullPath, A_LoopFileSize, A_LoopFileTimeModified)
                FileCount++
            }
        } ; End loop files
    } ; End for loop

    SB_Text := g_Stoped ? " Search aborted. " : " Search finished. "

    ; Status bar message
    If (TextToFind != "") {
        Files := FileCount > 1 ? "files" : "file"
        If (MatchCount) {
            Matches := MatchCount > 1 ? "matches" : "match"
            SB_Text .= MatchCount . " " . Matches . " in " . FileCount . " " . Files . "."

        } Else {
            If (ChkNotContaining && FileCount) {
                SB_Text .= "No match found in " . FileCount . " " . Files . "."
            } Else {
                SB_Text .= "No match found."
            }
        }
    } Else {
        If (FileCount == 1) {
            SB_Text .= "1 file found."
        } Else If (FileCount > 1){
            SB_Text .= FileCount . " files found."
        } Else {
            SB_Text .= "No files found."
        }
    }

    SB_SetText(SB_Text, 1)

    LV_SetCol3Width(g_hLvResults)

    GuiControl Focus, %g_hLvResults%

    g_Stoped := True
Return

CancelSearch() {
    If (g_Stoped) {
        Quit()
    }

    g_Stoped := True
}

FormatDate(DateTime) {
    FormatTime DateTime, %DateTime% D1 ; D1: short date
    Return RegExReplace(DateTime, "(.*)\s(.*)", "$2 $1")
}

LV_Add2(FilePath, FileSize, FileTime) {
    LV_Add("", FilePath, FormatBytes(FileSize, g_ThousandSep), FormatDate(FileTime))
}

ShowHelp() {
    Try {
        Run %A_ScriptDir%\..\..\Help\Find in Files.htm
    }
}

Browse:
    GuiControlGet Dir,, CbxTarget
    SplitPath Dir,, StartingFolder
    Gui +OwnDialogs
    FileSelectFolder SelectedFolder, *%StartingFolder%,, Select Folder
    If (!ErrorLevel) {
        GuiControl, Text, CbxTarget, %SelectedFolder%
    }
Return

GetWindowPlacement(hWnd) {
    Local WINDOWPLACEMENT, Result := {}
    NumPut(VarSetCapacity(WINDOWPLACEMENT, 44, 0), WINDOWPLACEMENT, 0, "UInt")
    DllCall("GetWindowPlacement", "Ptr", hWnd, "Ptr", &WINDOWPLACEMENT)
    Result.x := NumGet(WINDOWPLACEMENT, 28, "Int")
    Result.y := NumGet(WINDOWPLACEMENT, 32, "Int")
    Result.w := NumGet(WINDOWPLACEMENT, 36, "Int") - Result.x
    Result.h := NumGet(WINDOWPLACEMENT, 40, "Int") - Result.y
    Result.flags := NumGet(WINDOWPLACEMENT, 4, "UInt") ; 2 = WPF_RESTORETOMAXIMIZED
    Result.showCmd := NumGet(WINDOWPLACEMENT, 8, "UInt") ; 1 = normal, 2 = minimized, 3 = maximized
    Return Result
}

SetWindowPlacement(hWnd, x, y, w, h, showCmd) {
    Local WINDOWPLACEMENT
    NumPut(VarSetCapacity(WINDOWPLACEMENT, 44, 0), WINDOWPLACEMENT, 0, "UInt")
    NumPut(x, WINDOWPLACEMENT, 28, "Int")
    NumPut(y, WINDOWPLACEMENT, 32, "Int")
    NumPut(w + x, WINDOWPLACEMENT, 36, "Int")
    NumPut(h + y, WINDOWPLACEMENT, 40, "Int")
    NumPut(showCmd, WINDOWPLACEMENT, 8, "UInt")
    Return DllCall("SetWindowPlacement", "Ptr", hWnd, "ptr", &WINDOWPLACEMENT)
}

SaveSettings() {
    CreateIniFile()

    IniWrite %g_MaxHistory%, %g_IniFile%, Options, MaxHistory

    GuiControlGet g_SingleMatch,, ChkSingleMatch
    IniWrite %g_SingleMatch%, %g_IniFile%, Options, SingleMatch

    Pos := GetWindowPlacement(g_hWndMain)
    IniWrite % Pos.x, %g_IniFile%, Window, x
    IniWrite % Pos.y, %g_IniFile%, Window, y
    IniWrite % Pos.w, %g_IniFile%, Window, w
    IniWrite % Pos.h, %g_IniFile%, Window, h
    If (Pos.showCmd == 2) { ; Minimized
        State := (Pos.flags & 2) ? 3: 1
    } Else {
        State := Pos.showCmd
    }
    IniWrite %State%, %g_IniFile%, Window, State

    SaveHistory(g_hCbxTarget, "TargetHistory")
    SaveHistory(g_hCbxFilter, "FilterHistory")
    SaveHistory(g_hCbxString, "StringHistory")
}

SaveHistory(hCbx, Section) {
    Local Items := "", History

    ControlGet History, List,,, ahk_id %hCbx%
    If (History != "") {
        Loop Parse, History, `n
        {
            Items .= A_Index . "=" . A_LoopField . "`n"
        }
    }

    If (Items != "") {
        IniWrite %Items%, %g_IniFile%, %Section%
    }
}

GetHistory(Section, DefaultItem := True) {
    Local Items := "", History

    Loop % g_MaxHistory {
        IniRead History, %g_IniFile%, %Section%, %A_Index%
        If (History != "ERROR") {
            Items .= History . (A_Index == 1 && DefaultItem ? "`n`n" : "`n")
        }
    }
    Return Items
}

AddToHistory(hCbx, String) {
    If (String == "") {
        Return
    }

    ControlGet ComboItems, List,,, ahk_id %hCbx%

    History := String . "`n`n"

    Counter := 0
    Loop Parse, ComboItems, `n
    {
        If (A_LoopField == String || A_LoopField == "") {
            Continue
        }

        History .= A_LoopField . "`n"

        Counter++
        If (Counter > (g_MaxHistory - 2)) {
            Break
        }
    }

    GuiControl,, %hCbx%, `n%History%
}

FormatBytes(n, sThousand := ".") {
/*
    If (n > 999) {
        n /= 1024
        Unit := " K"
    } Else {
        Unit := " B"
    }
*/
    a := ""
    Loop % StrLen(n) {
        a .= SubStr(n, 1 - A_Index, 1)
        If (Mod(A_Index, 3) == 0) {
            a .= sThousand
        }
    }

    a := RTrim(a, sThousand)

    b := ""
    Loop % StrLen(a) {
        b .= SubStr(a, 1 - A_Index, 1)
    }

    Return b . Unit
}

RegExMatchArray(Haystack, aNeedle) {
    Loop % aNeedle.Length() {
        If (RegExMatch(Haystack, "i)^" . aNeedle[A_Index] . "$")) {
            Return True
        }
    }
    Return False
}

;OnContextMenu(hWnd, hCtrlHwnd, EventInfo, IsRightClick, X, Y)
OnContextMenu() {
    Local Row, FullPath, WorkingDir, hMenuShell, X, Y, ItemID, Verb

    If (A_GuiControl == "LV" && Row := LV_GetNext()) {
        LV_GetText(FullPath, Row, 1)
        If (!FileExist(FullPath)) {
            Return
        }

        SplitPath FullPath,, WorkingDir
        FixRootDir(WorkingDir)

        hMenuShell := GetShellContextMenu(FullPath, GetKeyState("Shift", "P") ? 0x100 : 0) ; CMF_EXTENDEDVERBS
        If (!hMenuShell) {
            Return
        }

        CoordMode Mouse, Screen
        MouseGetPos X, Y

        ItemID := ShowPopupMenu(hMenuShell, 0x100, X, Y, g_hWndShell) ; TPM_RETURNCMD
        If (ItemID) {
            Verb := GetShellMenuItemVerb(g_pIContextMenu, ItemID)
            If (Verb == "paste") {
                PasteFile(WorkingDir)
            } Else {
                RunShellMenuCommand(g_pIContextMenu, ItemID, WorkingDir, g_hWndMain, X, Y)
            }
        }

        DestroyShellMenu(hMenuShell)
    }
}

LvHandler(CtrlHwnd, GuiEvent, EventInfo, ErrLevel := "") {
    Local Row, FullPath, Ext, Line, Up, CbData

    ; LV items
    If (GuiEvent == "DoubleClick") {
        Row := LV_GetNext()
        If (Row) {
            LV_GetText(FullPath, Row, 1)
            SplitPath FullPath,,, Ext

            If (Ext = "AHK" || Ext = "TXT") {
                GuiControlGet TextToFind,, %g_hCbxString%, Text
                If (g_ColumnMode == 2 && TextToFind != "") {
                    LV_GetText(Line, Row, 2)
                } Else {
                    Line := 1
                }

                GuiControl,, %g_hEdtIPC%, %FullPath%|%Line%|%TextToFind%

                OpenWithAdventure()
            }
        }

    ; Column click
    } Else If (GuiEvent == "ColClick") {
        If (g_LastSortedCol == EventInfo) {
            Up := False
            g_LastSortedCol := 0
        } Else {
            Up := True
        }

        If (EventInfo == 1) { ; Filename
            LV_SortArrow(g_hLvResults, 1, Up ? "Up" : "Down")
        }

        If (g_ColumnMode == 1) {
            If (EventInfo == 2) { ; Size
                ShowThousandSeparator(False)
                LV_ModifyCol(2, "Sort" . (Up ? " SortDesc" : ""))
                ShowThousandSeparator(True)
                LV_SortArrow(g_hLvResults, 2, Up ? "Desc" : "Asc")

            } Else If (EventInfo == 3) { ; Date
                GetTimestampsAll()
                CbData := Object(g_pCbData)
                CbData.Even := !CbData.Even
                SendMessage 0x1051, g_pCbData, CbData.Callback,, % "ahk_id" . CbData.hLV ; LVM_SORTITEMSEX
                LV_SortArrow(CbData.hLV, 3, CbData.Even ? "Up" : "Down")
            }
        }

        If (Up) {
            g_LastSortedCol := EventInfo
        }
    }
}

OpenWithAdventure() {
    SendMessage 10000, 1, %g_hEdtIPC%,, % "ahk_id " . GetAdventHandle(g_AdventPath)
}

ShowThousandSeparator(Show := 1) {
    Local Size

    If (Show) {
        Loop % LV_GetCount() {
            LV_GetText(Size, A_Index, 2)
            LV_Modify(A_Index,,, FormatBytes(Size, g_ThousandSep))
        }

    } Else {
        Loop % LV_GetCount() {
            LV_GetText(Size, A_Index, 2)
            LV_Modify(A_Index,,, StrReplace(Size, g_ThousandSep))
        }
    }
}

; http://ahkscript.org/boards/viewtopic.php?t=1079
AutoXYWH(DimSize, cList*) {
    Static cInfo := {}

    If (DimSize = "reset") {
        Return cInfo := {}
    }

    For i, ctrl in cList {
        ctrlID := A_Gui ":" ctrl
        If (cInfo[ctrlID].x = "") {
            GuiControlGet i, %A_Gui%: Pos, %ctrl%
            MMD := InStr(DimSize, "*") ? "MoveDraw" : "Move"
            fx := fy := fw := fh := 0
            For i, dim in (a := StrSplit(RegExReplace(DimSize, "i)[^xywh]"))) {
                If (!RegExMatch(DimSize, "i)" . dim . "\s*\K[\d.-]+", f%dim%)) {
                    f%dim% := 1
                }
            }

            If (InStr(DimSize, "t")) {
                GuiControlGet hWnd, %A_Gui%: hWnd, %ctrl%
                hParentWnd := DllCall("GetParent", "Ptr", hWnd, "Ptr")
                VarSetCapacity(RECT, 16, 0)
                DllCall("GetWindowRect", "Ptr", hParentWnd, "Ptr", &RECT)
                DllCall("MapWindowPoints", "Ptr", 0, "Ptr", DllCall("GetParent", "Ptr", hParentWnd, "Ptr"), "Ptr", &RECT, "UInt", 1)
                ix := ix - NumGet(RECT, 0, "Int")
                iy := iy - NumGet(RECT, 4, "Int")
            }

            cInfo[ctrlID] := {x: ix, fx: fx, y: iy, fy: fy, w: iw, fw: fw, h: ih, fh: fh, gw: A_GuiWidth, gh: A_GuiHeight, a: a, m: MMD}
        } Else If (cInfo[ctrlID].a.1) {
            dgx := dgw := A_GuiWidth - cInfo[ctrlID].gw, dgy := dgh := A_GuiHeight - cInfo[ctrlID].gh
            Options := ""
            For i, dim in cInfo[ctrlID]["a"] {
                Options .= dim . (dg%dim% * cInfo[ctrlID]["f" . dim] + cInfo[ctrlID][dim]) . A_Space
            }
            GuiControl, % A_Gui ":" cInfo[ctrlID].m, % ctrl, % Options
        }
    }
}

GetClientSize(hWnd, ByRef Width, ByRef Height) {
    Local RECT
    VarSetCapacity(RECT, 16, 0)
    DllCall("GetClientRect", "Ptr", hWnd, "Ptr", &RECT)
    Width  := NumGet(RECT, 8,  "int")
    Height := NumGet(RECT, 12, "int")
}

ShowWindow(hWnd, nCmdShow := 1) {
    DllCall("ShowWindow", "Ptr", hWnd, "UInt", nCmdShow)
}

GetChild(hWnd) {
    Return DllCall("GetWindow", "Ptr", hWnd, "UInt", 5, "Ptr") ; GW_CHILD
}

Edit_ShowBalloonTip(hEdit, Text, Title := "", Icon := 0) {
    Local EDITBALLOONTIP
    NumPut(VarSetCapacity(EDITBALLOONTIP, 4 * A_PtrSize, 0), EDITBALLOONTIP)
    NumPut(A_IsUnicode ? &Title : WStr(Title, _), EDITBALLOONTIP, A_PtrSize, "Ptr")
    NumPut(A_IsUnicode ? &Text : WStr(Text, _), EDITBALLOONTIP, A_PtrSize * 2, "Ptr")
    NumPut(Icon, EDITBALLOONTIP, A_PtrSize * 3, "UInt")
    SendMessage 0x1503, 0, &EDITBALLOONTIP,, ahk_id %hEdit% ; EM_SHOWBALLOONTIP
    Return ErrorLevel
}

WStr(ByRef AStr, ByRef WStr) {
    Local Size := StrPut(AStr, "UTF-16")
    VarSetCapacity(WStr, Size * 2, 0)
    StrPut(ASTr, &WStr, "UTF-16")
    Return &Wstr
}

ConvertBackslashes(ByRef String) {
    StringReplace String, String, \\, ☺, All
    StringReplace String, String, \n, `n, All
    ;StringReplace String, String, \r, `r, All
    StringReplace String, String, \t, %A_Tab%, All
    StringReplace String, String, ☺, \, All
}

SetExclusivity() {
    Local Options := {}, Item
    Options.ChkRegEx := ["ChkMatchCase", "ChkWholeWords", "ChkBackslashes", "ChkHexSearch"]
    Options.ChkMatchCase := ["ChkRegEx", "ChkHexSearch"]
    Options.ChkWholeWords := ["ChkRegEx", "ChkHexSearch", "ChkBackslashes"]
    Options.ChkBackslashes := ["ChkRegEx", "ChkWholeWords", "ChkHexSearch"]
    Options.ChkHexSearch := ["ChkRegEx", "ChkMatchCase", "ChkWholeWords", "ChkBackslashes"]

    For Each, Item in Options[A_GuiControl] {
        GuiControl,, %Item%, 0
    }
}

OnWM_EXITSIZEMOVE() {
    KillSelection()
}

; EM_SETSEL to remove the automatic selection in comboboxes
KillSelection() {
    SendMessage 0xB1, 0, 0,, % "ahk_id " . GetChild(g_hCbxTarget)
    SendMessage 0xB1, 0, 0,, % "ahk_id " . GetChild(g_hCbxFilter)
    SendMessage 0xB1, 0, 0,, % "ahk_id " . GetChild(g_hCbxString)
}

TrackPopupMenu(Menu, hCtl, hWnd, Flags := 0x8) { ; 0x8 = TPM_TOPALIGN | TPM_RIGHTALIGN
    Local wx, wy, ww, wh, cx, cy, cw, ch, x, y, hMenu

    WingetPos wx, wy, ww, wh, ahk_id %hWnd%
    ControlGetPos cx, cy, cw, ch,, ahk_id %hCtl%
    x := wx + cx + cw
    y := wy + cy + ch
    hMenu := MenuGetHandle(Menu)

    DllCall("TrackPopupMenu", "Ptr", hMenu, "UInt", Flags, "Int", x, "Int", y, "Int", 0, "Ptr", hWnd, "Ptr", 0)
}

; Credits to gwarble, https://autohotkey.com/boards/viewtopic.php?f=6&t=22830
SplitButton(hButton, GlyphSize := 16, Menu := "", hWnd := 0) {
    Static _ := OnMessage(0x4E, "SplitButton") ; WM_NOTIFY
    Static _hWnd := hWnd
    Static _hButton
    Static _Menu := "SplitButton_Menu"

    If (Menu == 0x4E) {
        hCtrl := NumGet(GlyphSize+0, 0, "Ptr") ;-> lParam -> NMHDR -> hCtrl
        If (hCtrl == _hButton) { ; BCN_DROPDOWN for SplitButton
            id := NumGet(GlyphSize+0, A_PtrSize * 2, "uInt")
            If (id == 0xFFFFFB20) {
                TrackPopupMenu(_Menu, _hButton, _hWnd)
            }
        }
    } Else { ; Initialize
        If (Menu != "") {
            _Menu := Menu
        }

        _hWnd := hWnd
        _hButton := hButton
        Winset Style, +0xC, ahk_id %hButton% ; BS_SPLITBUTTON
        VarSetCapacity(BUTTON_SPLITINFO, A_PtrSize == 8 ? 32 : 20, 0)
        NumPut(8, BUTTON_SPLITINFO, 0, "Int") ; mask (BCSIF_SIZE)
        NumPut(GlyphSize, BUTTON_SPLITINFO, 4 + A_PtrSize * 2, "Int") ; size
        SendMessage 0x1607, 0, &BUTTON_SPLITINFO,, ahk_id %hButton% ; BCM_SETSPLITINFO
        Return
    }
}

MenuHandler(ItemName, ItemPos, MenuName) {
    Local CurrentFile, CurrentDir

    ; Adventure message: request a pipe-delimited list of all open files
    SendMessage 10000, 2, %g_hWndMain%,, % "ahk_id " . GetAdventHandle(g_AdventPath)
    Loop 10 {
        If (g_AdventData == "") {
            Sleep 10
        }
    }

    If (g_AdventData != "") {
        CurrentFile := StrSplit(g_AdventData, "|")[1]
    } Else {
        Return
    }

    If (ItemPos == 1) { ; Current directory
        SplitPath CurrentFile,, CurrentDir
        GuiControl Text, CbxTarget, %CurrentDir%

    } Else If (ItemPos == 2) { ; Current file
        GuiControl Text, CbxTarget, %CurrentFile%

    } Else If (ItemPos == 3) { ; Includes
        g_AhkIncludes := ""
        Try {
            EnumIncludes(CurrentFile, Func("EnumIncludesCallback"))
        }

        If (g_AhkIncludes != "") {
            GuiControl Text, CbxTarget, % CurrentFile . g_TargetDelim . g_AhkIncludes
        }

    } Else { ; All open files
        GuiControl Text, CbxTarget, %g_AdventData%
    }
}

EnumIncludesCallback(Param) {
    g_AhkIncludes .= Param . g_TargetDelim
    Return True ; Must return true to continue enumeration
}

GetAdventPath() {
    Return % A_ScriptDir . "\..\..\Adventure." . (A_IsCompiled ? "exe" : "ahk")
}

GetAdventHandle(AdventPath) {
    If (!hWnd := WinExist("Adventure v")) {
        Try {
            Run %AdventPath%,,, AutoGUIPID
        } Catch e {
            MsgBox 0x10, Error %A_LastError%, % e.Message . "`n`n" . e.Extra
            Return
        }

        WinWaitActive ahk_pid %AutoGUIPID%,, 3
        If (ErrorLevel) {
            MsgBox 0x15, Error, Window activation timed out. Try again?
            IfMsgBox Retry, {
                GetAdventHandle(AdventPath)
            }
            Return
        } Else {
            WinGet hWnd, ID, ahk_pid %AutoGUIPID%
        }
    }

    Return hWnd
}

CustomMessage(wParam, lParam) {
    If (wParam == 2) { ; Message sent by Adventure
        ControlGetText g_AdventData,, ahk_id %lParam%
        ControlSetText,,, ahk_id %lParam%
    }
}

; For XP
ShowMenu() {
    TrackPopupMenu("SplitButtonMenu", g_hBtnMenu, g_hWndMain)
}

LV_SetCol3Width(hLV, GapForVScroll := False) {
    Local LVW, LVH, Col3W, Style

    GetClientSize(hLV, LVW, LVH)
    Col3W := LVW - LV_GetColWidth(hLV, 1) - LV_GetColWidth(hLV, 2)

    ControlGet Style, Style,,, ahk_id %hLV%
    If ((Style & 0x100000) || GapForVScroll) { ; WS_HSCROLL
        Col3W := Col3W - g_VScrollBarW
    }

    LV_ModifyCol(3, Col3W)
}

LV_GetColWidth(hLV, ColN) {
    Local hHdr, HDITEM, cbHDITEM

    SendMessage 0x101F, 0, 0,, ahk_id %hLV% ; LVM_GETHEADER
    hHdr := ErrorLevel

    cbHDITEM := (4 * 6) + (A_PtrSize * 6)
    VarSetCapacity(HDITEM, cbHDITEM, 0)
    NumPut(0x1, HDITEM, 0, "UInt") ; mask (HDI_WIDTH)
    SendMessage, % A_IsUnicode ? 0x120B : 0x1203, ColN - 1, &HDITEM,, ahk_id %hHdr% ; HDM_GETITEMW
    Return (ErrorLevel != "FAIL") ? NumGet(HDITEM, 4, "UInt") : 0
}

OnWM_KEYDOWN(wParam, lParam, msg, hWnd) {
    ; Autocomplete list
    If (wParam == 13 || wParam == 27) { ; Enter or Esc
        If (IsAutoSuggestDropDownVisible()) {
            WinHide ahk_class Auto-Suggest Dropdown
            Return False ; So as to prevent the activation of the default button (Start).
        }

    } Else If (wParam == 0x70) { ; F1
        ShowHelp()

    } Else If (wParam == 0x72) { ; F3
        GoSub QuickView
    }
}

QuickView:
    Data := ""
    Row := LV_GetNext()
    If (Row) {
        LV_GetText(FullPath, Row, 1)

        If (FileExist(FullPath)) {
            FileRead Data, %FullPath%
        } Else {
            Gui 1: +OwnDialogs
            MsgBox 0x10, Error, "%FullPath%"`n`nFile not found.
            Return
        }
    }

    Title := "Quick View - " . FullPath

    If (!WinExist("ahk_id" . g_hWndQuickView)) {
        BGColor := 0x1F609F
        FGColor := 0xFFFFFF

        Gui QuickView: New, +LabelQV_On +hWndg_hWndQuickView +Resize
        hIcon := LoadPicture(g_IconLib, "Icon2 w16", ErrorLevel)
        SendMessage 0x80, 0, hIcon,, ahk_id %g_hWndQuickView% ; WM_SETICON

        Gui Add, CheckBox, x0 y0 w0 h0
        Gui Font, s9 c%FGColor%, FixedSys
        Gui Color, %BGColor%

        Gui Add, Edit, hWndhEdtView x8 y0 w830 h530 +ReadOnly -E0x200, %Data%

        Gui Show, w838 h530, %Title%
    } Else {
        GuiControl,, %hEdtView%, %Data%
        Gui QuickView: Show,, %Title%
    }

    GuiControl Focus, %hEdtView%
Return

QV_OnSize() {
    Global
    GuiControl Move, %hEdtView%, % "w" . (A_GuiWidth - 8) . " h" . A_GuiHeight    
}

QV_OnClose() {
    QV_OnEscape:
    Gui QuickView: Hide
    Return
}

FixRootDir(ByRef Dir) {
    If (SubStr(Dir, 0, 1) == ":") {
        Dir := Dir . "\"
    }
}

GetIniFileLocation(Filename) {
    Local FullPath, AppCfgFile
    FullPath := A_ScriptDir . "\..\..\Settings\" . Filename

    If (!FileExist(FullPath)) {
        AppCfgFile := g_AppData . "\" . Filename
        If (FileExist(AppCfgFile)) {
            Return AppCfgFile
        }
    }

    Return FullPath
}

CreateIniFile() {
    Local Sections

    If (!FileExist(g_IniFile)) {
        Sections := "[Options]`n`n[Window]`n`n[TargetHistory]`n`n[FilterHistory]`n`n[StringHistory]`n"

        FileAppend %Sections%, %g_IniFile%, UTF-16
        If (ErrorLevel) {
            FileCreateDir %g_AppData%
            g_IniFile := g_AppData . "\Find in Files.ini"
            FileDelete %g_IniFile%
            FileAppend %Sections%, %g_IniFile%, UTF-16
        }
    }
}

CreateLvCallback(hLV) {
    Local Callback, Data
    Callback := RegisterCallback("SortItems", "F")
    Data := {"hLV": hLV, "Even": 1, "Callback": Callback}
    g_pCbData := Object(Data)
}

SortItems(a, b, pCbData) {
    Local CbData := Object(pCbData), T1, T2

    T1 := g_aTimestamps[a + 1]
    T2 := g_aTimestamps[b + 1]

    ; https://docs.microsoft.com/en-us/windows/win32/controls/lvm-sortitemsex
    ; The comparison function must return a negative value if the first item should precede the second,
    ; a positive value if the first item should follow the second, or zero if the two items are equivalent.
    If (T1 != T2) {
        Return (T1 > T2 ? CbData.Even * 2 - 1 : 1 - CbData.Even * 2)
    }

    Return 0
}

GetTimestampsAll() {
    Local FullPath, Timestamp
    g_aTimestamps := []

    Gui 1: Default
    Gui ListView, LV
    Loop % LV_GetCount() {
        LV_GetText(FullPath, A_Index, 1)
        FileGetTime Timestamp, %FullPath%, M
        g_aTimestamps.Push(Timestamp)
    }
}

; Original version by Solar: http://www.autohotkey.com/forum/viewtopic.php?t=69642
; Parameters:
;   hLV: ListView handle
;   Col: 1-based index of the column
;   Dir: Optional direction to set the arrow: "asc" or "up", "desc" or "down".
LV_SortArrow(hLV, Col := 1, Dir := "") {
    Local LVM_GETCOLUMN, LVM_SETCOLUMN, lvColumn, fmt, i
    LVM_GETCOLUMN := A_IsUnicode ? (4191, LVM_SETCOLUMN := 4192) : (4121, LVM_SETCOLUMN := 4122)

    Col -= 1
    VarSetCapacity(lvColumn, A_PtrSize + 4, 0), NumPut(1, lvColumn, "UInt") ; LVCF_FMT (LVCOLUMN mask)
    SendMessage LVM_GETCOLUMN, Col, &lvColumn,, ahk_id %hLV%

    If ((fmt := NumGet(lvColumn, 4, "Int")) & 1024) {
        If (Dir && Dir = "asc" || Dir = "up") {
            Return            
        }
        NumPut(fmt & ~1024 | 512, lvColumn, 4, "Int")

    } Else If (fmt & 512) {
        If (Dir && Dir = "desc" || Dir = "down") {
            Return            
        }
        NumPut(fmt & ~512 | 1024, lvColumn, 4, "Int")

    } Else {
        ; HDM_GETITEMCOUNT := 4608, LVM_GETHEADER := 4127
        Loop % DllCall("SendMessage", "Ptr", DllCall("SendMessage", "Ptr", hLV, "UInt", 4127), "UInt", 4608)
            If ((i := A_Index - 1) != Col)
                DllCall("SendMessage", "Ptr", hLV, "UInt", LVM_GETCOLUMN, "UInt", i, "Ptr", &lvColumn)
                ,NumPut(NumGet(lvColumn, 4, "Int") & ~1536, lvColumn, 4, "Int")
                ,DllCall("SendMessage", "Ptr", hLV, "UInt", LVM_SETCOLUMN, "UInt", i, "Ptr", &lvColumn)
        NumPut(fmt | (Dir && Dir = "desc" || Dir = "down" ? 512 : 1024), lvColumn, 4, "Int")
    }

    Return DllCall("SendMessage", "Ptr", hLV, "UInt", LVM_SETCOLUMN, "UInt", Col, "Ptr", &lvColumn)
}

SetColumnMode(Mode, Col1W, Col2Opts, Col2Text, Col3Text) {
    LV_ModifyCol(2, Col2Opts, Col2Text)
    LV_ModifyCol(3,, Col3Text)
    LV_ModifyCol(1, Col1W)
    LV_SetCol3Width(g_hLvResults, True)
    If (g_ColumnMode != Mode) {
        LV_SortArrow(g_hLvResults, 0)
        g_ColumnMode := Mode
    }
}

SetMainIcon(IconRes, IconIndex := 1) {
    Try {
        Menu Tray, Icon, % A_IsCompiled ? A_ScriptName : IconRes, %IconIndex%
    }
}

IsAutoSuggestDropDownVisible() {
    Local DHW := A_DetectHiddenWindows, Vis
    DetectHiddenWindows Off
    Vis := WinExist("ahk_class Auto-Suggest Dropdown")
    DetectHiddenWindows %DHW%
    Return Vis
}

#Include %A_ScriptDir%\..\..\Lib\ShellMenu.ahk
#Include %A_ScriptDir%\..\..\Lib\EnumIncludes.ahk
