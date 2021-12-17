; Search dialog and related functions

ShowFindDialog() { ; M
    ShowSearchDialog(1)
}

ShowReplaceDialog() {
    ShowSearchDialog(2)
}

ShowHighlightsDialog() {
    ShowSearchDialog(3)
}

ShowSearchDialog(ActiveTab := 1) {
    Global
    Local CurrentTab, WhatItems, WithItems, Checked, px, py, hCbx, SelText

    If (!WinExist("ahk_id " . g_hWndFindReplace)) {
        LoadSearchHistory(WhatItems, WithItems)

        If (g_ChkF3FindNextSel) {
            g_ChkRegExMode := False
        }

        Gui FindReplaceDlg: New, LabelFR_OnDlg hWndg_hWndFindReplace -MinimizeBox OwnerMain Delimiter`n
        Gui Font, s9, Segoe UI

        Gui Add, Tab3
        , hWndhFindReplaceTab vFindReplaceTab gFR_TabHandler x8 y8 w466 h214 AltSubmit
        , Find`nReplace`nHighlights

        Gui Tab, 1 ; Find
            Gui Add, Text, x31 y45 w42 h23 +0x200, What:
            Gui Add, ComboBox, hWndg_hCbxFind1 vg_SearchString gSearchFieldHandler x84 y46 w272, %WhatItems%
            GuiControl Choose, %g_hCbxFind1%, 1

            Gui Add, Button, vBtnFindNext1 gFindNext x371 y45 w88 h25 Default, Find &Next
            Gui Add, Button, gFindPrev x371 y79 w88 h25, Find &Previous
            Gui Add, Button, gFR_SelectAllMatches x371 y113 w88 h25, Select &All
            Gui Add, Button, gFR_CountAllMatches x371 y148 w88 h25, Count
            Gui Add, Button, gFR_OnDlgClose x371 y182 w88 h25, Cancel

            Gui Add, CheckBox, vg_ChkMatchCase gSyncSearchOptions x24 y81 w160 h23, &Case sensitive
            Gui Add, CheckBox, vg_ChkWholeWord gSyncSearchOptions x24 y105 w160 h23, &Match whole word only
            Gui Add, CheckBox, vg_ChkRegExMode gSyncSearchOptions x24 y129 w160 h23, &Regular expression
            Gui Add, CheckBox, vg_ChkBackslash gSyncSearchOptions x24 y153 w160 h23, &Backslashed characters
            Gui Add, Text, x24 y182 w332 h1 +0x5
            Gui Add, CheckBox, vg_ChkF3FindNextSel gSyncSearchOptions x24 y186 w340 h23 Checked%g_ChkF3FindNextSel%
            , F3: find the next occurrence of the currently selected text

            Gui Add, GroupBox, x196 y75 w160 h99, &Origin
            Gui Add, Radio, vg_RadCurrentPos gSetSearchOrigin x209 y94 w135 h23, Current position
            Gui Add, Radio, vg_RadStartingPos gSetSearchOrigin x209 y118 w135 h23, Starting position
            Gui Add, CheckBox, vg_ChkWrapAround gSyncSearchOptions x209 y142 w135 h23, &Wrap around

        Gui Tab, 2 ; Replace
            Gui Add, Text, x31 y45 w42 h23 +0x200, What:
            Gui Add, ComboBox, hWndg_hCbxFind2 vCbxReplaceWhat gSearchFieldHandler x84 y46 w272, %WhatItems%
            GuiControl Choose, %g_hCbxFind2%, 1
            Gui Add, Text, x31 y75 w42 h23 +0x200, With:
            Gui Add, ComboBox, hWndg_hCbxReplace vCbxReplaceWith x84 y76 w272, %WithItems%
            GuiControl Choose, %g_hCbxReplace%, 1

            Gui Add, Button, vBtnFindNext2 gFindNext x371 y45 w88 h25, Find &Next
            Gui Add, Button, gFindPrev x371 y79 w88 h25, Find &Previous
            Gui Add, Button, gReplace x371 y113 w88 h25, &Replace
            Gui Add, Button, gFR_ReplaceAllMatches x371 y148 w88 h25, Replace &All
            Gui Add, Button, gFR_OnDlgClose x371 y182 w88 h25, &Cancel

            Gui Add, CheckBox, vChkMatchCase gSyncSearchOptions x24 y111 w160 h23, &Case sensitive
            Gui Add, CheckBox, vChkWholeWord gSyncSearchOptions x24 y135 w160 h23, &Match whole word only
            Gui Add, CheckBox, vChkRegExMode gSyncSearchOptions x24 y159 w160 h23, &Regular expression
            Gui Add, CheckBox, vChkBackslash gSyncSearchOptions x24 y183 w160 h23, &Backslashed characters

            Gui Add, GroupBox, x196 y105 w160 h99, &Origin
            Gui Add, Radio, vRadCurrentPos gSetSearchOrigin x209 y124 w135 h23, Current position
            Gui Add, Radio, vRadStartingPos gSetSearchOrigin x209 y148 w135 h23, Starting position
            Gui Add, CheckBox, vChkWrapAround gSyncSearchOptions x209 y172 w135 h23, &Wrap around

        Gui Tab, 3 ; Highlights
            Gui Add, DDL, x0 y0 w0 h0 -0x10000
            Gui Add, CheckBox
            , vChkHITEnabled gToggleHighlights x24 y45 w440 h23 Checked%g_Highlights%
            , Automatically &highlight text that matches the selection ("Smart Highlighting")

            Gui Add, Text, x24 y75 w158 h23 +0x200, Selection &boundary mode:
            Gui Add, DDL, vDDLHITMode x183 y76 w157 +AltSubmit
            , Single character`nLenient word range`n`nWhole word
            GuiControl Choose, DDLHITMode, % g_HITMode + 1

            Gui Add, Text, x24 y110 w158 h21, Maximum &occurrences:
            Gui Add, Edit, vEdtHITLimit x183 y108 w62 h21 +Number, %g_HITLimit%
            Gui Add, Button, vBtnHITApply x252 y106 w88 h24, &Apply

            Checked := g_HITFlags & 4 ; SCFIND_MATCHCASE
            Gui Add, CheckBox, vg_ChkHITMatchCase x24 y135 w160 h23 Checked%Checked%, Case &sensitive
            Checked := g_HITFlags & 2 ; SCFIND_WHOLEWORD
            Gui Add, CheckBox, vg_ChkHITWholeWord x24 y159 w160 h23 Checked%Checked%, &Match whole word only
            Checked := g_HITFlags & 1
            Gui Add, CheckBox, vg_ChkHITStartPos x24 y183 w160 h23 Checked%Checked%, Start at current &position

            Loop Parse, % "DDLHITMode|BtnHITApply|g_ChkHITMatchCase|g_ChkHITWholeWord|g_ChkHITStartPos", |
                GuiControl +gSetHITOptions, %A_LoopField%

            Gui Add, Button, gResetHITOptions x371 y148 w88 h25, &Reset
            Gui Add, Button, gFR_OnDlgClose x371 y182 w88 h25, &Close

        IniRead px, %IniFile%, Search, x, Center
        IniRead py, %IniFile%, Search, y, Center

        SetWindowIcon(g_hWndFindReplace, IconLib, -26)
        Gui FindReplaceDlg: Show, x%px% y%py% w481 h229 Hide, Find

        FR_SetOptions(ActiveTab)
    }

    GuiControlGet CurrentTab,, %hFindReplaceTab%
    If (CurrentTab != ActiveTab) {
        GuiControl Choose, %hFindReplaceTab%, %ActiveTab%
        FR_TabHandler()
    }

    g_FromCurrentPos := -1 ; Undefined

    SyncSearchOptions()

    If (ActiveTab < 3) {
        hCbx := ActiveTab == 1 ? g_hCbxFind1 : g_hCbxFind2

        SelText := GetSelectedTextN(TabEx.GetSel(), 1)
        If (SelText != "") {
            GuiControl Text, %hCbx%, %SelText%
        }

        SetFocus(hCbx)
        SendMessage 0x142, 0, 0xFFFF0000,, ahk_id %hCbx% ; CB_SETEDITSEL (HIWORD -1: all text is selected)
    }

    Gui FindReplaceDlg: Show
}

FR_OnDlgClose() {
    FR_OnDlgEscape:
    Gui FindReplaceDlg: Hide
    Return
}

FR_TabHandler() {
    Global
    Gui FindReplaceDlg: Default
    Gui Submit, NoHide

    If (FindReplaceTab == 2) {
        WinSetTitle ahk_id %g_hWndFindReplace%,, Replace
        SetWindowIcon(g_hWndFindReplace, IconLib, -27)
        GuiControl Text, %g_hCbxFind2%, %g_SearchString%
        WinSet Redraw,, ahk_id %g_hCbxFind2%
        GuiControl +Default, BtnFindNext2

    } Else If (FindReplaceTab == 1) {
        WinSetTitle ahk_id %g_hWndFindReplace%,, Find
        SetWindowIcon(g_hWndFindReplace, IconLib, -26)
        GuiControl Text, %g_hCbxFind1%, %CbxReplaceWhat%
        WinSet Redraw,, ahk_id %g_hCbxFind1%
        GuiControl +Default, BtnFindNext1

    } Else If (FindReplaceTab == 3) {
        WinSetTitle ahk_id %g_hWndFindReplace%,, Highlights
        SetWindowIcon(g_hWndFindReplace, IconLib, -28)
    }
}

FindNext:
    FR_Search("Next")
Return

FindPrev:
    FR_Search("Prev")
Return

Replace:
    FR_Search("Replace")
Return

FR_Search(Mode) {
    Global
    Local SearchString, OldSearchString, ReplaceWith, OldReplaceWith, n, Flags, Message, Ret := 1
    Static s_PrevString, s_PrevFound := 0, s_PrevMode

    n := TabEx.GetSel()

    If (IsWindowVisible(g_hWndFindReplace) || (IsWindow(g_hWndFindReplace) && !g_ChkF3FindNextSel)) {
        Gui FindReplaceDlg: Submit, NoHide
        GuiControlGet SearchString,, % g_hCbxFind%FindReplaceTab%, Text
        g_SearchString := SearchString
        OldReplaceWith := ReplaceWith := CbxReplaceWith

        If (g_FromCurrentPos == -1 || (g_RadStartingPos && Mode != S_PrevMode)) {
            g_FromCurrentPos := g_RadCurrentPos
        }

        Flags := GetSearchFlags()

        If (g_ChkBackslash) {
            SearchString := ConvertBackslashes(SearchString)
            ReplaceWith := ConvertBackslashes(ReplaceWith)
        }

    } Else If (g_ChkF3FindNextSel) {
        g_SearchString := SearchString := GetSelectedText(n)
        Flags := 0
        g_ChkRegExMode := False
        g_FromCurrentPos := (g_FromCurrentPos == 0) ? 0 : 1

    } Else {
        ShowSearchDialog(1)
        Return
    }

    OldSearchString := g_SearchString

    ; Search mode
    If (Mode == "Next") {
        FoundPos := FindNext(n, SearchString, Flags, g_ChkRegExMode, g_FromCurrentPos)
    } Else If (Mode == "Prev") {
        FoundPos := FindPrev(n, SearchString, Flags, g_ChkRegExMode, g_FromCurrentPos)
    } Else If (Mode == "Replace") {
        FoundPos := Replace(n, SearchString, ReplaceWith, Flags, g_ChkRegExMode, g_FromCurrentPos)
    } Else {
        Return
    }

    ; Not found: wrap around
    If (g_ChkWrapAround && FoundPos == NOTFOUND && g_FromCurrentPos && Mode != "Replace") {
        Message := GetWrapAroundMessage(Mode)

        If (IsWindowVisible(g_hWndFindReplace)) {
            FR_ShowBalloon(Message)
        } Else {
            Ret := MessageBox(g_hWndMain, Message, g_AppName, 0x1)
        }

        If (Ret == 1) {
            FoundPos := Find%Mode%(n, SearchString, Flags, g_ChkRegExMode, g_FromCurrentPos := 0)
        }
    }

    ; Not found message
    If (FoundPos == NOTFOUND) {
        Message := GetNotFoundMessage(SearchString, s_PrevFound && (g_SearchString == s_PrevString))
        FR_ShowBalloon(Message)
    }

    ; Found
    If (FoundPos != NOTFOUND) {
        g_FromCurrentPos := 1
    }

    ; Static variables
    s_PrevMode := Mode
    s_PrevFound := FoundPos ? True : False
    s_PrevString := g_SearchString

    ; Search history
    FR_AddToHistory(OldSearchString, OldReplaceWith, Mode == "Replace")
}

FindNext(n, String, Flags, RegEx, FromCurrentPos) {
    Local SciText, TempText, StartPos, Pos, Match, Length, FoundPos

    If (RegEx) {
        SciText  := GetText(n)
        TempText := GetTextRange(n, 0, Sci[n].GetCurrentPos())
        StartPos := FromCurrentPos ? StrLen(TempText) + 1 : 1

        Pos := RegExMatch(SciText, String, Match, StartPos)
        If (Pos > 0) {
            ;Length := StrPut(SubStr(SciText, Pos, StrLen(Match)), "UTF-8") - 1
            Length := StrPut(Match, "UTF-8") - 1
            FoundPos := StrPut(SubStr(SciText, 1, Pos - 1), "UTF-8") - 1
        } Else {
            FoundPos := NOTFOUND
        }

    } Else {
        Length := StrPut(String, "UTF-8") - 1 ; Length of the search string in bytes

        Sci[n].SetSearchFlags(Flags)
        Sci[n].SetTargetRange(FromCurrentPos ? Sci[n].GetCurrentPos() : 0, Sci[n].GetLength())
        ;FoundPos := Sci[n].SearchInTarget(Length, "" . String, 1)
        FoundPos := Sci[n].SearchInTarget(Length, String, 1)
    }

    If (FoundPos != NOTFOUND) {
        SetSelEx(n, FoundPos, FoundPos + Length)
    }

    Return FoundPos
}

FindPrev(n, String, Flags, RegEx, FromCurrentPos) {
    Local SciText, TempText, LimitPos, StartPos, FoundPos, Match, Length

    If (RegEx) {
        SciText := GetText(n)

        If (FromCurrentPos) {
            TempText := GetTextRange(n, 0, Sci[n].GetAnchor())
            LimitPos := StrLen(TempText)
        } Else {
            LimitPos := StrLen(SciText)
        }

        StartPos := 1
        FoundPos := 0
        Loop {
            StartPos := RegExMatch(SciText, String, Match, StartPos)
            If ((StartPos > 0) && StartPos <= LimitPos) {
                FoundPos := StartPos
                Length := StrLen(Match)
                StartPos++
                Continue
            }
            Break
        }

        FoundPos--
        If (FoundPos != NOTFOUND) {
            Length := StrPut(SubStr(SciText, FoundPos + 1, Length), "UTF-8") - 1
            FoundPos := StrPut(SubStr(SciText, 1, FoundPos), "UTF-8") - 1

            SetSelEx(n, FoundPos, FoundPos + Length, 1) ; Upward
        }

    } Else {
        Length := StrPut(String, "UTF-8") - 1

        Sci[n].SetSearchFlags(Flags)
        Sci[n].SetTargetRange(FromCurrentPos ? Sci[n].GetAnchor() : Sci[n].GetLength(), 0)
        FoundPos := Sci[n].SearchInTarget(Length, String, 1)

        If (FoundPos != NOTFOUND) {
            SetSelEx(n, FoundPos, FoundPos + Length)
        }
    }

    Return FoundPos
}

Replace(n, String, ReplaceWith, Flags, RegEx, FromCurrentPos) {
    Local SciText, TempText, FoundPos, Match, Length, SelStart, SelEnd

    ; Find without selecting.
    If (RegEx) {
        SciText := GetText(n)
        TempText := GetTextRange(n, 0, Sci[n].GetAnchor())

        FoundPos := RegExMatch(SciText, String, Match, StrLen(TempText) + 1)
        If (FoundPos > 0) {
            Length := StrPut(SubStr(SciText, FoundPos, StrLen(Match)), "UTF-8") - 1
            FoundPos := StrPut(SubStr(SciText, 1, FoundPos - 1), "UTF-8") - 1
            ReplaceWith := RegExReplace(Match, String, ReplaceWith)
        } Else {
            FoundPos := NOTFOUND
        }

    } Else {
        Length := StrPut(String, "UTF-8") - 1
        Sci[n].SetSearchFlags(Flags)
        Sci[n].SetTargetRange(Sci[n].GetAnchor(), Sci[n].GetLength())
        FoundPos := Sci[n].SearchInTarget(Length, "" . String, 1)
    }
    
    If (FoundPos != NOTFOUND) {
        If (Sci[n].GetSelText(0, 0) > 1) {
            SelStart := Sci[n].GetSelectionStart()
            SelEnd := Sci[n].GetSelectionEnd()
            ; Replace only occurs if the match is selected.
            If (SelStart == FoundPos && (FoundPos + Length) == SelEnd) {
                Sci[n].ReplaceSel(Flags, ReplaceWith, 1)
            }
        }
    }

    Return FindNext(n, String, Flags, RegEx, FromCurrentPos) ; Find and select.
}

FR_ReplaceAllMatches() {
    Local n, ReplaceWhat, ReplaceWith, Flags, Count, Msg, FromStartInfo

    Gui FindReplaceDlg: Submit, NoHide
    GuiControlGet ReplaceWhat,, %g_hCbxFind2%, Text
    GuiControlGet ReplaceWith,, %g_hCbxReplace%, Text

    n := TabEx.GetSel()
    Flags := GetSearchFlags()

    Count := ReplaceAllMatches(n, ReplaceWhat, ReplaceWith, Flags, g_ChkRegExMode, g_ChkBackslash, g_RadStartingPos)

    If (Count == 1) {
        Msg := "One occurrence replaced"
    } Else If (Count > 1) {
        Msg := Count . " occurrences replaced"
    } Else { ; 0
        Msg := "No occurrence found"
    }

    FromStartInfo := !g_RadStartingPos && Sci[n].GetCurrentPos()

    FR_ShowBalloon(Msg . (FromStartInfo ? " (from current position)." : "."))

    FR_AddToHistory(ReplaceWhat, ReplaceWith, True)
}

ReplaceAllMatches(n, ReplaceWhat, ReplaceWith, Flags, RegEx, Backslash, FromStart) {
    Local StartPos, TempText, SciText, FoundPos, Match, NewStr, String
    , MatchLen, ByteLen, BytePos, Count := 0, WhatLength, WithLength, r

    Sci[n].BeginUndoAction()

    If (Backslash) {
        ReplaceWhat := ConvertBackslashes(ReplaceWhat)
        ReplaceWith := ConvertBackslashes(ReplaceWith)
    }

    If (RegEx) {
        If (FromStart) {
            StartPos := 1
        } Else {
            TempText := GetTextRange(n, 0, Sci[n].GetSelectionStart())
            StartPos := StrLen(TempText) + 1
        }

        Loop {
            SciText := GetText(n)
            FoundPos := RegExMatch(SciText, ReplaceWhat, Match, StartPos)
            If (!FoundPos) {
                Break
            }

            NewStr := RegExReplace(Match, ReplaceWhat, ReplaceWith)

            StartPos := FoundPos + StrLen(NewStr)
            If (StartPos > StrLen(SciText)) {
                Break
            }

            MatchLen := StrLen(Match)
            If (!MatchLen) {
                StartPos++
                Continue ; Zero-length match.
            }

            ByteLen := StrPut(Match, "UTF-8") - 1
            BytePos := StrPut(SubStr(SciText, 1, FoundPos - 1), "UTF-8") - 1

            VarSetCapacity(String, StrPut(NewStr, "UTF-8") + 1)
            StrPut(NewStr, &String, "UTF-8")

            Sci[n].SetTargetRange(BytePos, BytePos + ByteLen)
            Sci[n].ReplaceTarget(StrPut(NewStr, "UTF-8") - 1, &String)

            Count++
        }

        SciText := TempText := ""

    } Else {
        WhatLength := StrPut(ReplaceWhat, "UTF-8") - 1
        WithLength := StrPut(ReplaceWith, "UTF-8") - 1

        Sci[n].SetSearchFlags(Flags)
        Sci[n].SetTargetRange(FromStart ? 0 : Sci[n].GetSelectionStart(), Sci[n].GetLength() + 1)

        While (Sci[n].SearchInTarget(WhatLength, "" . ReplaceWhat, 1) != NOTFOUND) {
            Sci[n].ReplaceTarget(WithLength, r := ReplaceWith, 1)
            Sci[n].SetTargetRange(Sci[n].GetTargetStart() + WithLength, Sci[n].GetLength() + 1)
            Count++
        }
    }

    Sci[n].EndUndoAction()

    Return Count
}

FR_SelectAllMatches:
    FR_SelectAllMatches(0)
Return

FR_CountAllMatches:
    FR_SelectAllMatches(1)
Return

FR_SelectAllMatches(CountOnly := False) {
    Local n := TabEx.GetSel(), Count

    Gui FindReplaceDlg: Submit, NoHide
    GuiControlGet g_SearchString,, %g_hCbxFind1%, Text
    SearchString := g_SearchString

    If (g_ChkBackslash) {
        SearchString := ConvertBackslashes(SearchString)
    }

    Count := SelectAllMatches(n, SearchString, GetSearchFlags(), g_ChkRegExMode, CountOnly)
    If (Count) {
        FR_AddToHistory(SearchString)
    }

    FR_ShowBalloon((Count ? Count : "No") . " " . ((Count > 1) ? "matches" : "match") . " found.")
}

SelectAllMatches(n, g_SearchString, SearchFlags, RegEx, CountOnly) {
    Local StringLength, TextLength, StrBuf, TargetStart, TargetEnd, TargetLength
    , SciText, StartPos, FoundPos, Match, MatchLen, ByteLen, BytePos, Count := 0

    If (!StringLength := StrPut(g_SearchString, "UTF-8") - 1) {
        Return 0
    }

    If (RegEx) {
        SciText := GetText(n)
        StartPos := 1

        While ((FoundPos := RegExMatch(SciText, g_SearchString, Match, StartPos)) > 0) {
            StartPos := FoundPos + 1
            If (StartPos > StrLen(SciText)) {
                Break
            }

            MatchLen := StrLen(Match)
            If (!MatchLen) {
                Continue ; Zero-length match.
            }

            ByteLen := StrPut(SubStr(SciText, FoundPos, MatchLen), "UTF-8") - 1
            BytePos := StrPut(SubStr(SciText, 1, FoundPos - 1), "UTF-8") - 1
            If (!CountOnly) {
                AddSelection(n, BytePos, BytePos + ByteLen, !Count)
            }
            Count++
        }

        SciText := ""
    } Else {
        TextLength := Sci[n].GetLength()

        Sci[n].SetSearchFlags(SearchFlags)
        Sci[n].SetTargetRange(0, TextLength)

        VarSetCapacity(StrBuf, StringLength)
        StrPut(g_SearchString, &StrBuf, "UTF-8")

        While (Sci[n].SearchInTarget(StringLength, &StrBuf) != -1) {
            TargetStart := Sci[n].GetTargetStart()
            TargetEnd := Sci[n].GetTargetEnd()

            TargetLength := TargetEnd - TargetStart
            If (!TargetLength) {
                Sci[n].SetTargetRange(++TargetEnd, TextLength)
                Continue ; Zero-length match (Scintilla RegEx)
            }

            If (!CountOnly) {
                AddSelection(n, TargetStart, TargetEnd, !Count) ; Select each occurrence
            }

            Count++

            Sci[n].SetTargetRange(TargetEnd, TextLength)
        }
    }

    Return Count
}

LoadSearchHistory(ByRef WhatItems, ByRef WithItems, Delim := "`n") {
    Local SearchHistory, Match, Match1, Match2
    WhatItems := ""
    WithItems := ""

    IniRead SearchHistory, %IniFile%, SearchHistory
    If (SearchHistory != "ERROR") {
        Loop Parse, SearchHistory, `n
        {
            ; StrSplit MaxParts requires AHK v1.1.28+.
            If (RegExMatch(A_LoopField, "(What|With)\d+=(.*)", Match)) {
                If (Match1 == "What") {
                    WhatItems .= Match2 . Delim
                } Else If (Match1 == "With") {
                    WithItems .= Match2 . Delim
                }
            }
        }
    }
}

AddToSearchHistory(hCbx, String) {
    Local ComboItems, History, Count

    ControlGet ComboItems, List,,, ahk_id %hCbx%
    History := String . "`n`n"

    Count := 0
    Loop Parse, ComboItems, `n
    {
        If (A_LoopField == String || A_LoopField == "") {
            Continue
        }

        History .= A_LoopField . "`n"

        Count++
        If (Count > 8) {
            Break
        }
    }

    GuiControl,, %hCbx%, `n%History%
}

FR_AddToHistory(FindWhat, ReplaceWith := "", Replace := False) {
    AddToSearchHistory(g_hCbxFind1, FindWhat)
    AddToSearchHistory(g_hCbxFind2, FindWhat)
    If (Replace) {
        AddToSearchHistory(g_hCbxReplace, ReplaceWith)
    }
}

GetSearchFlags() {
    Return (g_ChkMatchCase ? 4 : 0) | (g_ChkWholeWord ? 2 : 0)
}

; Convert some escape sequences
ConvertBackslashes(String) {
    Local n := TabEx.GetSel()
    Local IsCRLF := Sci[n].GetCharAt(Sci[n].GetLineEndPosition(0)) == 13

    String := StrReplace(String, "\\", "\")
    String := StrReplace(String, "\n", IsCRLF ? "`r`n" : "`n")
    String := StrReplace(String, "\t", "`t")

    Return String
}

FR_SetOptions(TabIndex := 1) {
    Local _ := (TabIndex == 1) ? "g_" : ""

    GuiControl,, % _ . "ChkMatchCase", %g_ChkMatchCase%
    GuiControl,, % _ . "ChkWholeWord", %g_ChkWholeWord%
    GuiControl,, % _ . "ChkRegExMode", %g_ChkRegExMode%
    GuiControl,, % _ . "ChkBackslash", %g_ChkBackslash%
    GuiControl,, % g_RadStartingPos ? _ . "RadStartingPos" : _ . "RadCurrentPos", 1
    GuiControl,, % _ . "ChkWrapAround", %g_ChkWrapAround%
}

SyncSearchOptions() {
    Global
    Local _, RegExMode

    Gui FindReplaceDlg: Submit, NoHide

    ; Set exclusive options
    If (A_GuiControl != "") {
        _ := (FindReplaceTab == 1) ? "g_" : ""

        If (InStr(A_GuiControl, "RegExMode")) {
            GuiControl,, % _ . "ChkMatchCase", 0
            GuiControl,, % _ . "ChkWholeWord", 0
            GuiControl,, % _ . "ChkBackslash", 0
            If (g_ChkF3FindNextSel) {
                RegExMode := _ . "ChkRegExMode"
                GuiControl % %RegExMode% ? "Disable" : "Enable", g_ChkF3FindNextSel
            }
        } Else If (A_GuiControl ~= "MatchCase|WholeWord|Backslash|F3FindNextSel") {
            GuiControl,, % _ . "ChkRegExMode", 0
            GuiControl Enable, g_ChkF3FindNextSel
        }

        Gui FindReplaceDlg: Submit, NoHide
    }

    ; Synchronize options
    If (FindReplaceTab == 1) {
        GuiControl,, ChkMatchCase, %g_ChkMatchCase%
        GuiControl,, ChkWholeWord, %g_ChkWholeWord%
        GuiControl,, ChkRegExMode, %g_ChkRegExMode%
        GuiControl,, ChkBackslash, %g_ChkBackslash%
        GuiControl,, RadCurrentPos, %g_RadCurrentPos%
        GuiControl,, RadStartingPos, %g_RadStartingPos%
        GuiControl,, ChkWrapAround, %g_ChkWrapAround%
    } Else {
        GuiControl,, g_ChkMatchCase, %ChkMatchCase%
        GuiControl,, g_ChkWholeWord, %ChkWholeWord%
        GuiControl,, g_ChkRegExMode, %ChkRegExMode%
        GuiControl,, g_ChkBackslash, %ChkBackslash%
        GuiControl,, g_RadCurrentPos, %RadCurrentPos%
        GuiControl,, g_RadStartingPos, %RadStartingPos%
        GuiControl,, g_ChkWrapAround, %ChkWrapAround%
    }
}

SetSearchOrigin() {
    SyncSearchOptions()
    Gui FindReplaceDlg: Submit, NoHide
    g_FromCurrentPos := g_RadCurrentPos
}

SearchFieldHandler() {
    Gui FindReplaceDlg: Submit, NoHide
    g_FromCurrentPos := g_RadCurrentPos
}

FR_ShowBalloon(Text, Title := "", Icon := 0) {
    If (IsWindowVisible(g_hCbxFind1) || IsWindowVisible(g_hCbxFind2)) {
        Edit_ShowBalloonTip(FR_GetChildEdit(), Text, Title, Icon)
    } Else {
        MessageBox(g_hWndMain, Text, Title != "" ? Title : g_AppName, 0)
    }
}

FR_GetChildEdit() {
    Global
    Gui FindReplaceDlg: Submit, NoHide
    Return DllCall("GetWindow", "Ptr", FindReplaceTab == 1 ? g_hCbxFind1 : g_hCbxFind2, "UInt", 5, "Ptr") ; GW_CHILD
}

GetHighlightFlags() {
    Gui FindReplaceDlg: Submit, NoHide
    Return g_ChkHITMatchCase << 2 | g_ChkHITWholeWord << 1
}

SetHITOptions() {
    Global
    Local n := TabEx.GetSel()

    Gui FindReplaceDlg: Submit, NoHide
    g_HITMode := DDLHITMode - 1
    g_HITLimit := EdtHITLimit
    g_HITFlags := GetHighlightFlags()

    Highlight(n, Sci[n].GetCurrentPos(), g_HITMode, g_HITFlags, g_HITLimit, g_ChkHITStartPos)
}

ResetHITOptions() {
    Global
    Gui FindReplaceDlg: Default
    GuiControl,, ChkHITEnabled, 1
    GuiControl Choose, DDLHITMode, 2
    GuiControl,, EdtHITLimit, 2000
    GuiControl,, g_ChkHITMatchCase, 0
    GuiControl,, g_ChkHITWholeWord, 0
    GuiControl,, g_ChkHITStartPos, 0
}

FindInFiles() {
    RunEx(A_ScriptDir . "\Tools\Find in Files\Find in Files." . (A_IsCompiled ? "exe" : "ahk") . " /A")
}

GetNotFoundMessage(SearchString, PrevFound) {
    Return (PrevFound ? "No further occurrence of """ : "Search string not found: """) . SearchString . """."
}

GetWrapAroundMessage(Mode) {
    Return Mode == "Next"
    ? "End of the document reached. Continuing from start." : "Start of the document reached. Continuing from end."
}
