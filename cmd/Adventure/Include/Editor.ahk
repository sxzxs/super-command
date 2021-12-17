; https://www.scintilla.org/ScintillaDoc.html

Sci_Config(n, Type := "") {
    Sci[n].Type := Type

    Sci[n].SetCodePage(65001) ; UTF-8

    Sci[n].SetWrapMode(g_WordWrap)
    Sci[n].SetScrollWidthTracking(True)

    ; Font
    Sci[n].StyleSetFont(STYLE_DEFAULT, "" . g_FontName, 1)
    Sci[n].StyleSetSize(STYLE_DEFAULT, g_FontSize)
    Sci[n].SetExtraAscent(2) ; Increase space between lines

    ; Indentation
    Sci[n].SetTabWidth(g_TabSize)
    Sci[n].SetUseTabs(!g_IndentWithSpaces) ; Indent with spaces
    Sci[n].SetIndentationGuides(g_IndentGuides ? 3 : 0)

    ; Caret
    Sci[n].SetCaretWidth(g_CaretWidth)
    Sci[n].SetCaretStyle(g_CaretStyle)
    Sci[n].SetCaretPeriod(g_CaretBlink)

    ; Language-specific and theme
    Sci[n].SetLexer(GetLexerByLexType(Type))
    LoadLexerData(Type, g_ThemeNameEx)
    SetKeywords(n, Type)
    ApplyTheme(n, Type)
    SetProperties(n, Type)

    ; Line numbers margin
    Sci[n].SetMarginTypeN(g_MarginNumbers, 1) ; SC_MARGIN_NUMBER
    Sci[n].MarginLen := 0
    SetLineNumberWidth(n)
    Sci[n].SetMarginLeft(g_MarginNumbers, 2) ; Left padding

    ; Symbol margin
    DefineMarkers(n)
    Sci[n].SetMarginTypeN(g_MarginSymbols, 6) ; SC_MARGIN_SYMBOL (0) | SC_MARGIN_COLOUR (6)
    Sci[n].SetMarginSensitiveN(g_MarginSymbols, True)
    ShowSymbolMargin(g_SymbolMargin)

    ; Margin divider
    Sci[n].SetMarginTypeN(g_MarginDivider, 6)
    ShowDivider(g_Divider)

    ; Fold margin
    Sci[n].SetFoldFlags(g_FoldingLines) ; SC_FOLDFLAG_LINEAFTER_CONTRACTED (16)
    If (g_CodeFolding) {
        SetCodeFolding(n)
    }

    ; Keyboard shortcuts
    Sci[n].AssignCmdKey(SCK_END, SCI_LINEENDWRAP)
    Sci[n].AssignCmdKey(SCK_HOME, SCI_HOMEWRAP)
    Sci[n].AssignCmdKey(SCK_END  | (SCMOD_SHIFT << 16), SCI_LINEENDWRAPEXTEND)
    Sci[n].AssignCmdKey(SCK_HOME | (SCMOD_SHIFT << 16), SCI_HOMEWRAPEXTEND)

    ; Multiple selection
    Sci[n].SetMultipleSelection(g_MultiSel)
    Sci[n].SetAdditionalSelectionTyping(g_MultiSel) ; g_MultiTyping
    Sci[n].SetMultipaste(g_MultiSel) ; g_MultiPaste
    Sci[n].SetVirtualSpaceOptions(1) ; SCVS_RECTANGULARSELECTION

    Sci[n].UsePopup(0) ; Custom context menu
    Sci[n].SetMouseDwellTime(1000) ; Calltip hover time

    ; AutoComplete settings
    If (g_AutoComplete) {
        SetAutoComplete(n)
        If (!g_oAutoC[Type].bLoaded) {
            LoadAutoComplete(Type)
        }
    }

    Sci[n].Notify := "OnWM_NOTIFY"

    If (g_ShowWhiteSpaces) {
        ShowWhiteSpaces(g_ShowWhiteSpaces, g_ShowCRLF)
    }
}

SetLineNumberWidth(n) {
    Local LineCount, LineCountLen, String, PixelWidth

    If (g_LineNumbers) {
        LineCount := Sci[n].GetLineCount()
        LineCountLen := StrLen(LineCount)
        If (LineCountLen < 2) {
            LineCountLen := 2
        }

        If (LineCountLen != Sci[n].MarginLen) {
            Sci[n].MarginLen := LineCountLen

            If (LineCount < 100) {
                String := "99"
            } Else {
                String := ""
                LineCountLen := StrLen(LineCount)
                Loop %LineCountLen% {
                    String .= "9"
                }
            }

            PixelWidth := Sci[n].TextWidth(STYLE_LINENUMBER, "" . String, 1) + 8
            Sci[n].SetMarginWidthN(g_MarginNumbers, PixelWidth)
        }
    } Else {
        Sci[n].SetMarginWidthN(g_MarginNumbers, 0)
        Sci[n].MarginLen := 0
    }
}

DefineMarkers(n) {
    Static XPMLoaded := 0, PixmapBreakpoint, PixmapBookmark, PixmapError

    If (!XPMLoaded) {
        FileRead PixmapBreakpoint, %A_ScriptDir%\Icons\Breakpoint.xpm
        FileRead PixmapBookmark, %A_ScriptDir%\Icons\Handpoint3.xpm
        FileRead PixmapError, %A_ScriptDir%\Icons\Error.xpm
        XPMLoaded := 1
    }

    ; Bookmark marker
    Sci[n].MarkerDefine(g_MarkerBookmark, 25) ; 25 = SC_MARK_PIXMAP
    Sci[n].MarkerDefinePixmap(g_MarkerBookmark, "" . PixmapBookmark, 1)

    ; Breakpoint marker
    Sci[n].MarkerDefine(g_MarkerBreakpoint, 25)
    Sci[n].MarkerDefinePixmap(g_MarkerBreakpoint, "" . PixmapBreakpoint, 1)

    ; Debug step marker
    Sci[n].MarkerDefine(g_MarkerDebugStep, SC_MARK_SHORTARROW)
    Sci[n].MarkerSetBack(g_MarkerDebugStep, CvtClr(0xA2C93E))

    ; Error marker
    Sci[n].MarkerDefine(g_MarkerError, 25)
    Sci[n].MarkerDefinePixmap(g_MarkerError, "" . PixmapError, 1)
}

SetCodeFolding(n) {
    Sci[n].SetProperty("fold", "1", 1, 1)
    Sci[n].SetProperty("fold.compact", "1", 1, 1) ; 0?
    Sci[n].SetProperty("fold.comment", "1", 1, 1)
    Sci[n].SetProperty("fold.preprocessor", "1", 1, 1) ; Automatic folding

    Sci[n].SetMarginTypeN(g_MarginFolding, SC_MARGIN_SYMBOL)
    Sci[n].SetMarginWidthN(g_MarginFolding, 14)
    Sci[n].SetMarginMaskN(g_MarginFolding, SC_MASK_FOLDERS)
    Sci[n].SetMarginSensitiveN(g_MarginFolding, True)

    Sci[n].MarkerDefine(SC_MARKNUM_FOLDER, SC_MARK_BOXPLUS)
    Sci[n].MarkerDefine(SC_MARKNUM_FOLDEROPEN, SC_MARK_BOXMINUS)
    Sci[n].MarkerDefine(SC_MARKNUM_FOLDEREND, SC_MARK_BOXPLUSCONNECTED)
    Sci[n].MarkerDefine(SC_MARKNUM_FOLDEROPENMID, SC_MARK_BOXMINUSCONNECTED)
    Sci[n].MarkerDefine(SC_MARKNUM_FOLDERMIDTAIL, SC_MARK_TCORNER)
    Sci[n].MarkerDefine(SC_MARKNUM_FOLDERSUB, SC_MARK_VLINE)
    Sci[n].MarkerDefine(SC_MARKNUM_FOLDERTAIL, SC_MARK_LCORNERCURVE)

    ApplyFoldMarginColors(n)
}

ApplyFoldMarginColors(n) {
    Loop 7 {
        i := A_Index + 24
        Sci[n].MarkerSetFore(i, g_oColors["FoldMargin"].BBC) ; Folding button background color
        Sci[n].MarkerSetBack(i, g_oColors["FoldMargin"].DLC) ; Drawing lines color
    }

    Sci[n].SetFoldMarginColour(1, g_oColors["FoldMargin"].MBC)
    Sci[n].SetFoldMarginHiColour(1, g_oColors["FoldMargin"].MBC)
}

M_NewTab() {
    NewTab(g_DefLexType)
}

NewTab(Type := "", TabIcon := 1, TabTitle := "") {
    Local TabIndex, SciX, SciY, SciW, SciH

    g_TabCounter++

    ; Tab
    TabTitle := TabTitle == "" ? "Untitled " . g_TabCounter : TabTitle
    TabIndex := TabEx.Add(TabTitle, TabIcon)
    If (!TabIndex) {
        Return 0
    }

    ; Scintilla
    Sci_GetIdealSize(SciX, SciY, SciW, SciH)
    Sci[TabIndex] := New Scintilla(g_hWndMain, SciX, SciY, SciW, SciH, 0x50000000, 0x200)
    Sci_Config(TabIndex, Type)
    TabEx.SetSel(TabIndex)

    Sci[TabIndex].Number := g_TabCounter ; Untitled number

    Sci[TabIndex].LastAccessTime := A_Now . A_MSec

    Return TabIndex
}

TCM_DuplicateTab() {
    DuplicateTab(g_TabIndex)
}

M_DuplicateTab() {
    DuplicateTab(TabEx.GetSel())
}

DuplicateTab(n) {
    Local Index := NewTab(Sci[n].Type)
    If (Index) {
        Sci[Index].Encoding := Sci[n].Encoding
        Sci[Index].SetText("", GetText(n), 1)
    }
    Return Index
}

TCM_CloseTab() {
    CloseTab(g_TabIndex)
}

M_CloseTab() {
    CloseTab(TabEx.GetSel())
}

CloseTab(TabIndex, Confirm := True, Multiple := False, Exiting := False) {
    Local SkipConfirmation, Result, IsActiveTab, NewIndex, FullPath

    If (TabIndex == 0) {
        Return 0
    }

    SkipConfirmation := False

    If (Confirm && Sci[TabIndex].GetModify()) {
        TabEx.SetSel(TabIndex)

        Result := ConfirmCloseTab(TabEx.GetText(TabIndex), Multiple)
        If (Result == "Yes") {
            If (!SaveFile(TabIndex)) {
                Return 0
            }

        } Else If (Result == "NoToAll") {
            If (Exiting) {
                Quit()
            }

            SkipConfirmation := True

        } Else If (Result == "Cancel") {
            Sci[TabIndex].GrabFocus()
            Return 0
        }
    }

    FullPath := Sci[TabIndex].FullName

    If (TabEx.GetCount() > 1) {
        IsActiveTab := (TabIndex == TabEx.GetSel())

        AddToFileHistory(TabIndex, FullPath)

        SendMessage 0x1308, TabIndex - 1, 0,, ahk_id %g_hTab% ; TCM_DELETEITEM
        DestroyWindow(Sci[TabIndex].hWnd)
        Sci.RemoveAt(TabIndex)

        If (IsActiveTab) {
            NewIndex := GetPreviousTab() - 1
            SendMessage 0x1330, NewIndex,,, ahk_id %g_hTab% ; TCM_SETCURFOCUS
            Sleep 0
            SendMessage 0x130C, NewIndex,,, ahk_id %g_hTab% ; TCM_SETCURSEL
            TabHandler()
        } Else {
            Repaint(g_hWndMain)
        }
    } Else { ; First and only tab
        AddToFileHistory(TabIndex, FullPath)
        SetReadOnly(TabIndex, 0)
        ClearFile(1)
        Sci[1].GrabFocus()
        SetWindowTitle()
        Sci_Config(1, g_DefLexType)
        UpdateStatusBar(1)
    }

    AddToRecentFilesEx(FullPath)

    Return SkipConfirmation ? -1 : 1
}

ClearFile(n) {
    Sci[n].FullName := ""
    Sci[n].Filename := ""
    Sci[n].Encoding := "UTF-8"
    Sci[n].LastWriteTime  := ""
    Sci[n].LastAccessTime := A_Now . A_MSec
    Sci[n].BackupName := ""
    Sci[n].Parameters := ""
    Sci[n].Type := g_DefLexType
    Sci[n].ClearAll()
    Sci[n].SetSavePoint()
    TabEx.SetIcon(n, 1)
    Repaint(Sci[n].hWnd)
}

M_CloseAllTabs() {
    CloseAllTabs()
}

CloseAllTabs(Exiting := False) {
    Local Unsaved := 0, Confirm, NoToAll, Aborted := False, nTabs, Ret

    Loop % Sci.Length() {
        If (Sci[A_Index].GetModify()) {
            Unsaved++
        }
    }

    Confirm := Unsaved
    NoToAll := Unsaved > 1

    Loop % nTabs := Sci.Length() {
        Ret := CloseTab(nTabs--, Confirm, NoToAll, Exiting)
        If (Ret == -1) { ; No to All
            Confirm := False
        } Else If (Ret == 0) { ; (Yes + !Save) || Cancel
            Aborted := True
            Break
        }
    }

    If (Exiting && !Aborted) {
        Quit()
    }

    If (!Aborted) {
        Sci[1].Number := g_TabCounter := 1
        TabEx.SetText(1, "Untitled 1")
    }

    Repaint(g_hWndMain)
    Return !Aborted
}

ConfirmCloseTab(Title, NoToAllBtn := False) {
    Local Text, Buttons, Result

    Text := "The file was modified. Do you want to save it?"
    If (NoToAllBtn) {
        Buttons := [[6, "Yes"], [7, "No"], [10, "No to All"], [2, "Cancel"]]
        Result := SoftModalMessageBox(Text, Title, Buttons, 1, 0x31, "", 0, -1, g_hWndMain)
    } Else {
        Result := DllCall("MessageBox", "Ptr", g_hWndMain, "Str", Text, "Str", Title, "UInt", 0x33)
    }

    Return {6: "Yes", 7: "No", 10: "NoToAll", 2: "Cancel"}[Result]
}

GetText(n) {
    Local Text, Len := Sci[n].GetLength() + 1
    VarSetCapacity(Text, Len, 0)
    Sci[n].2182(Len, &Text) ; SCI_GETTEXT
    Return StrGet(&Text, "UTF-8")
}

GetSelectedText(n) {
    Local SelText, SelLen := Sci[n].GetSelText() - 1
    VarSetCapacity(SelText, SelLen, 0)
    Sci[n].GetSelText(0, &SelText)
    Return StrGet(&SelText, SelLen, "UTF-8")
}

SetSelectedText(n, Text) {
    Sci[n].ReplaceSel("", Text, 1)
}

SetSelectedTextN(n, Text, SelN := 1, Select := False) {
    Local SelStart, SelEnd, Len, t
    GetSelectionPos(n, SelStart, SelEnd, SelN)
    Sci[n].SetTargetRange(SelStart, SelEnd)
    Len := StrPut(Text, "UTF-8") - 1
    Sci[n].ReplaceTarget(Len, t := Text, 1)
    If (Select) {
        AddSelection(n, SelStart, SelStart + Len)
    }
}

GetCurrentLine() {
    Local n, LineNum, LineLen, LineText
    n := TabEx.GetSel()
    LineNum := Sci[n].LineFromPosition(Sci[n].GetCurrentPos())
    LineLen := Sci[n].LineLength(LineNum) + 1
    VarSetCapacity(LineText, LineLen, 0)
    Sci[n].GetCurLine(LineLen, &LineText)
    Return RTrim(StrGet(&LineText, "UTF-8"), CRLF)
}

GetCurrentWord(ByRef Word, StartPos := -1) {
    Local n, Pos, PrevChar, WordStartPos, WordEndPos

    n := TabEx.GetSel()
    Pos := (StartPos == -1) ? Sci[n].GetCurrentPos() : StartPos

    ; SCI_WORDSTARTPOSITION(int pos, bool onlyWordCharacters) → int
    WordStartPos := Sci[n].WordStartPosition(Pos, True)
    PrevChar := Chr(Sci[n].GetCharAt(WordStartPos - 1))
    If (PrevChar ~= g_WordPrefix) {
        WordStartPos--
    }
    WordEndPos := Sci[n].WordEndPosition(Pos, True)

    Word := GetTextRange(n, WordStartPos, WordEndPos)
    Return [WordStartPos, WordEndPos]
}

GetTextRange(n, StartPos, EndPos) {
    Local Text, Sci_TextRange
    VarSetCapacity(Text, Abs(StartPos - EndPos) + 1, 0)
    VarSetCapacity(Sci_TextRange, 8 + A_PtrSize, 0)
    NumPut(StartPos, Sci_TextRange, 0, "UInt")
    NumPut(EndPos, Sci_TextRange, 4, "UInt")
    NumPut(&Text, Sci_TextRange, 8, "Ptr")
    Sci[n].2162(0, &Sci_TextRange) ; SCI_GETTEXTRANGE
    Return StrGet(&Text,, "UTF-8")
}

; Scintilla notification handler
OnWM_NOTIFY(wParam, lParam, msg, hWnd, Obj) {
    Static s_PrevWord := "", s_PrevWordPos := 0
    Local n, CurPos, Line, LexType, BracePos, BraceMatch, Indentation, WordPos, WordLen, Calltip, Word, Keyword

    If (!IsObject(Obj)) {
        Return
    }

    n := TabEx.GetSel()
    CurPos := Sci[n].GetCurrentPos()

    If (Obj.SCNCode == SCN_UPDATEUI) {
        ; The updated field is set to the bit set of things changed since the previous notification.
        ; SC_UPDATE_CONTENT 	0x01 	Contents, styling or markers have been changed.
        ; SC_UPDATE_SELECTION 	0x02 	Selection has been changed.
        ; SC_UPDATE_V_SCROLL 	0x04 	Scrolled vertically.
        ; SC_UPDATE_H_SCROLL 	0x08 	Scrolled horizontally.

        If (Obj.Updated < 4) {
            If (g_Highlights) {
                Highlight(n, CurPos, g_HITMode, g_HITFlags, g_HITLimit, g_ChkHITStartPos)
            }
        } Else {
            If (Sci[n].CalltipActive()) {
                Sci[n].CalltipCancel()
            }
        }

        ; Brace matching
        BracePos := CurPos - 1
        BraceMatch := Sci[n].BraceMatch(BracePos, 0)
        If (BraceMatch == -1) {
            BracePos := CurPos
            BraceMatch := Sci[n].BraceMatch(CurPos, 0)
        }

        If (BraceMatch != -1) {
            Sci[n].BraceHighlight(BracePos, BraceMatch)
        } Else {
            Sci[n].BraceHighlight(-1, -1)
        }

        SB_UpdateLinePos(n)
        SB_UpdateSelInfo(n)

    } Else If (Obj.SCNCode == SCN_MODIFIED) {
        ;OutputDebug % Obj.ModType
/*
        If (Obj.ModType & 8 == 8) {
            OutputDebug % Obj.Line
        }
*/
        If (Obj.LinesAdded) {
            SetLineNumberWidth(n)
        }

    } Else If (Obj.SCNCode == SCN_SAVEPOINTREACHED) {

        SavePointChanged(n)

    } Else If (Obj.SCNCode == SCN_SAVEPOINTLEFT) {

        SavePointChanged(n)

    } Else If (Obj.SCNCode == SCN_CHARADDED) {

        ; Auto-indent
        If (Obj.Ch == 13 && g_AutoIndent && !GetKeyState("Shift", "P")) {
            Line := Sci[n].LineFromPosition(CurPos)
            Indentation := Sci[n].GetLineIndentation(Line - 1)
            Sci[n].SetLineIndentation(Line, Indentation)
            If (Indentation) {
                Sci[n].GoToPos(Sci[n].GetLineIndentPosition(Line))
            }
        }

        LexType := Sci[n].Type
        WordPos := Sci[n].WordStartPosition(CurPos, True)

        ; Collect user typed keywords
        If (g_AutoComplete && g_AutoCTypedWords
        && (WordPos != s_PrevWordPos)) {

            GetCurrentWord(Word, s_PrevWordPos)
            WordLen := StrLen(Word)
            If (Word != s_PrevWord
            && (WordLen >= g_AutoCMinWordLen && WordLen <= g_AutoCMaxWordLen)) {
                g_TypedWords .= Word . "|"
            }

            s_PrevWord := Word
        }
        s_PrevWordPos := WordPos

        ; AutoComplete
        If (g_AutoComplete) {
            ShowAutoCList(n, g_AutoCTriggerLen)
        }

        ; Calltips ; "(", "," or " ".
        If ((Obj.Ch == 40 || Obj.Ch == 44 || Obj.Ch == 32)
        && g_CalltipTyping && g_oAutoC[LexType].bLoaded) {

            WordPos := GetCurrentWord(Word, CurPos - 1)
            If (StrLen(Word) > 2) {
                ShowCalltip(n, GetCalltip(Word), WordPos[1])
            }
        }

        ; Autoclose brackets ([{""}])
        If (g_AutoBrackets) {
            AutoCloseBrackets(n, CurPos, Obj.Ch)
        }

    } Else If (Obj.SCNCode == SCN_AUTOCCOMPLETED && g_CalltipAutoC) {

        Keyword := StrGet(Obj.Text,, "UTF-8")
        Calltip := GetCalltip(Keyword, True)
        ShowCalltip(n, Calltip, GetCurrentWord(Word)[1])

    } Else If (Obj.SCNCode == SCN_DWELLSTART) {

        If (g_CalltipHover && Obj.Position != -1) {
            If (g_DbgStatus && Sci[n].Type == "AHK") {
                If (AhkDebugCalltip(n, Obj.Position)) {
                    Return
                }
            }

            WordPos := GetCurrentWord(Word, Obj.Position)
            ShowCalltip(n, GetCalltip(Word, False), WordPos[1])
        }

    } Else If (Obj.SCNCode == SCN_DWELLEND) {

        Sci[n].CalltipCancel()

    } Else If (Obj.SCNCode == SCN_CALLTIPCLICK) {

        OnCalltipClick(n, Obj.Position, CurPos)

    } Else If (Obj.SCNCode == SCN_MARGINCLICK) {

        OnMarginClick(n, Obj.Margin, Obj.Position)

    } Else If (Obj.SCNCode == SCN_ZOOM) {
        Sci[n].MarginLen := 0
        SetLineNumberWidth(n)
    }

    Return
}

Highlight(n, CurPos, WordMode := 1, SearchFlags := 0, Limit := 2000, FromPos := False) {
    ; Word boundary mode: 0 = single char, 1 = lenient word range, 2 = whole word

    Local TextLength, WordStartPos, WordEndPos, SelStart, SelEnd
    , String, StringLength, MatchCount, TargetStart, TargetEnd, bWord

    TextLength := Sci[n].GetLength()

    ; Clear previous highlights
    Sci[n].SetIndicatorCurrent(2)
    Sci[n].IndicatorClearRange(0, TextLength)

    If (!GetSelectionPos(n, SelStart, SelEnd, 0)) {
        Return
    }

    WordStartPos := Sci[n].WordStartPosition(CurPos, WordMode)
    WordEndPos := Sci[n].WordEndPosition(CurPos, WordMode)

    bWord := WordMode == 1 && Sci[n].2691(SelStart, SelEnd) ; SCI_ISRANGEWORD

    If ((WordMode == 1 && !bWord)
    || (WordMode == 2 && (WordStartPos != SelStart || WordEndPos != SelEnd))
    || Sci[n].LineFromPosition(SelStart) != Sci[n].LineFromPosition(SelEnd)) {
        Return
    }

    String := GetTextRange(n, SelStart, SelEnd)

    Sci[n].IndicSetStyle(2, g_oColors["IdenticalText"].Type) ; Default: INDIC_STRAIGHTBOX (8)
    Sci[n].IndicSetFore(2, g_oColors["IdenticalText"].Color)
    Sci[n].IndicSetAlpha(2, g_oColors["IdenticalText"].Alpha)
    Sci[n].IndicSetOutlineAlpha(2, g_oColors["IdenticalText"].OutlineAlpha)

    Sci[n].SetSearchFlags(SearchFlags)

    FromPos ? Sci[n].SetTargetStart(WordEndPos) : Sci[n].2690() ; SCI_TARGETWHOLEDOCUMENT
    StringLength := StrPut(String, "UTF-8") - 1

    MatchCount := 0
    While (Sci[n].SearchInTarget(StringLength, "" . String, 1) != -1 && ++MatchCount < Limit) {
        TargetStart := Sci[n].GetTargetStart()
        TargetEnd := Sci[n].GetTargetEnd()
        If (TargetEnd != SelEnd) {
            Sci[n].SetIndicatorCurrent(2)
            Sci[n].IndicatorFillRange(TargetStart, TargetEnd - TargetStart)
        }

        Sci[n].SetTargetStart(TargetEnd)
        Sci[n].SetTargetEnd(TextLength)
    }
}

; Called by TabHandler and SetStatusBar
UpdateStatusBar(n) {
    SB_UpdateLinePos(n)
    SB_UpdateSelInfo(n)
    SB_UpdateDocStatus(n)
    SB_UpdateFileDesc(n)

    If (g_DbgStatus) {
        If (Sci[n].FullName = g_DbgSession.CurrentFile) {
            SB_SetText("Debugging", g_SBP_FileType)
            SB_SetIcon(IconLib, -65, g_SBP_FileType)
        } Else {
            SendMessage 0x40F, % g_SBP_FileType - 1, 0,, ahk_id %g_hStatusBar% ; SB_SETICON (remove icon)
        }
    }
}

SB_UpdateFileDesc(n) {
    Local Desc := (Sci[n].Filename == "") ? g_oLexTypes[Sci[n].Type].DN : GetFileTypeDesc(GetFileExt(Sci[n].Filename))
    DllCall(g_SendMessage, "Ptr", g_hStatusBar, "UInt", 0x40B, "Ptr", g_SBP_FileType - 1, "WStr", Desc) ; SB_SETTEXTW
}

SB_UpdateLinePos(n) {
    Local Pos, Line, Col, Sels, Text

    Pos := Sci[n].GetCurrentPos()
    Line := Sci[n].LineFromPosition(Pos) + 1
    Col := Sci[n].GetColumn(Pos) + 1
    Sels := Sci[n].GetSelections()

    Text := Line . ":" . Col . (Sels > 1 ? " (carets: " . Sels . ")" : "")

    Gui Main: Default
    SB_SetText(Text, g_SBP_CursorPos)
}

SB_UpdateSelInfo(n) {
    Local SelStart, SelEnd, SelLen, TotalLen := 0, SelCount := 0, Text := ""

    If (!Sci[n].GetSelectionEmpty()) { ; Return 1 if every selected range is empty else 0

        Loop % Sci[n].GetSelections() {
            GetSelectionPos(n, SelStart, SelEnd, A_Index)
            SelLen := SelEnd - SelStart
            If (SelLen) {
                TotalLen += SelLen
                SelCount++
            }
        }

        Text := TotalLen . (TotalLen > 1 ? " bytes " : " byte ")
        . (SelCount > 1 ? "in " . SelCount . " selections" : "selected")
    }

    Gui Main: Default
    SB_SetText(Text, g_SBP_SelInfo)
}

SB_UpdateDocStatus(n) {
    If (n != TabEx.GetSel()) {
        Return
    }

    Gui Main: Default

    If (Sci[n].GetReadOnly()) {
        SB_SetText("Read only", g_SBP_DocStatus)
    } Else If (Sci[n].GetModify()) {
        SB_SetText("Modified", g_SBP_DocStatus)
    } Else {
        SB_SetText("", g_SBP_DocStatus)
    }

    SB_SetText(GetFileEncodingDisplayName(n), g_SBP_Encoding)
}

; Called by SCN_SAVEPOINTREACHED, SCN_SAVEPOINTLEFT, SaveFile and SwapTabs.
SavePointChanged(n) {
    TabCaption := Sci[n].Filename != "" ? Sci[n].Filename : "Untitled " . Sci[n].Number
    TabEx.SetText(n, TabCaption . (Sci[n].GetModify() ? " *" : ""))
    SB_UpdateDocStatus(n)
}

Undo() { ; M
    Local n := TabEx.GetSel()
    Sci[n].Undo()
    Repaint(Sci[n].hWnd) ; ?
}

Redo() { ; M
    Sci[TabEx.GetSel()].Redo()
}

Cut() { ; M
    Local n := TabEx.GetSel()

    If (Sci[n].GetSelections() > 1) {
        CopyEx(n, CRLF)
        Sci[n].Clear()
    } Else {
        Sci[n].Cut()
    }
}

Copy() { ; M
    Local n := TabEx.GetSel()

    If (Sci[n].GetSelections() > 1) {
        CopyEx(n, CRLF)
    } Else {
        Sci[n].Copy()
    }
}

CopyEx(n, Delim := "`r`n", Prepend := "", Flags := 0) {
    Local aSels, nSels, SelText, Output := ""

    aSels := GetAllSelections(n) ; Only non-empty selections
    nSels := aSels.Length()

    Loop %nSels% {
        SelText := GetTextRange(n, aSels[A_Index][1], aSels[A_Index][2])
        If (Prepend != "") {
            Output .= Prepend
        }

        Output .= SelText

        If (A_Index != nSels) {
            Output .= Delim
        }
    }

    If ((Flags & 1) && Output == "") { ; Copy entire document if selection is empty
        Output := GetText(n)
    }

    If (Output != "") {
        Clipboard := Output
    }
}

Paste() { ; M
    Sci[TabEx.GetSel()].Paste()
}

Clear() { ; M
    Sci[TabEx.GetSel()].Clear() ; Delete
}

SelectAll() { ; M
    Sci[TabEx.GetSel()].SelectAll()
}

DuplicateLine() { ; M
    Sci[TabEx.GetSel()].LineDuplicate()
}

MoveLineUp() { ; M
    MoveLine(1)
}

MoveLineDown() { ; M
    MoveLine(0)
}

MoveLine(Up := 1) {
    Local n, CurPos, CurCol, SelLen, CurLine, Markers, NewPos

    n := TabEx.GetSel()
    CurPos := Sci[n].GetCurrentPos()
    CurCol := Sci[n].GetColumn(CurPos)
    SelLen := Sci[n].GetSelText() - 1
    CurLine := Sci[n].LineFromPosition(CurPos)
    Markers := Sci[n].MarkerGet(CurLine)
    Sci[n].MarkerDelete(CurLine, -1) ; -1: all markers from line

    Up ? Sci[n].MoveSelectedLinesUp() : Sci[n].MoveSelectedLinesDown()

    ; Restore symbol margin markers (single line)
    NewPos := Sci[n].GetCurrentPos()
    Sci[n].MarkerAddSet(Sci[n].LineFromPosition(NewPos), Markers)

    ; If there is no selection, maintain the cursor position
    if (!SelLen) {
        Sci[n].GoToPos(NewPos + CurCol)
    }
}

; Pressing Ctrl + Enter activates the autocomplete list even if the feature is turned off.
M_AutoComplete() {
    Local n := TabEx.GetSel()
    Local Type := Sci[n].Type

    SetAutoComplete(n)
    If (!g_oAutoC[Type].bLoaded) {
        If (!LoadAutoComplete(Type)) {
            Return
        }
    }

    ShowAutoCList(n, 1)
}

M_ShowCalltip() {
    Local WordPos := GetCurrentWord(Word)
    ShowCalltip(TabEx.GetSel(), GetCalltip(Word), WordPos[1])
}

M_InsertParameters() {
    InsertCalltip()
}

InsertDateTime() { ; M
    Local n, CurrentPos, TimeString
    n := TabEx.GetSel()
    CurrentPos := Sci[n].GetCurrentPos()
    FormatTime TimeString, D1
    Sci[n].InsertText(CurrentPos, "" . TimeString, 1)
    Sci[n].GoToPos(CurrentPos + StrPut(TimeString, "UTF-8") - 1)
}

ToggleReadOnly() { ; M
    Local n, ReadOnly
    n := TabEx.GetSel()
    ReadOnly := !Sci[n].GetReadOnly()
    SetReadOnly(n, ReadOnly)
    SB_UpdateDocStatus(n)
}

SetReadOnly(n, ReadOnly) {
    Sci[n].SetReadOnly(ReadOnly)
    TB_CheckButton(2170, ReadOnly)
    CheckMenuItem("MenuEdit", "Set as &Read-Only", ReadOnly)
}

ShowGoToLineDialog() { ; M
    Local Line, n
    Line := InputBoxEx("Line Number:", "", "Go to Line", "", "", "x94 w80 Number", g_hWndMain, 270)
    If (!ErrorLevel) {
        n := TabEx.GetSel()
        Sci[n].GrabFocus()

        If (Line != "") {
            Sci[n].GoToLine(Line - 1) ; 0-based index
            GoToLineEx(n, Line - 1)
        } Else {
            GoToRandomLine(n)
        }
    }
}

ToggleBookmark:
    ToggleBookmark(g_MarkerBookmark)
Return

ToggleErrormark:
    ToggleBookmark(g_MarkerError)
Return

ToggleBookmark(Marker, Line := -1) {
    Local n := TabEx.GetSel()
    If (Line == -1) { ; Current line
        Line := Sci[n].LineFromPosition(Sci[n].GetCurrentPos())
    }

    If (Sci[n].MarkerGet(Line) & (1 << Marker)) {
        Sci[n].MarkerDelete(Line, Marker)
    } Else {
        Sci[n].MarkerAdd(Line, Marker)
    }
}

MarkSelectedText() {
    Local n, SelStart, SelEnd, aSels

    n := TabEx.GetSel()

    ; SCI_SETINDICATORCURRENT(int indicator): Set the indicator that will be affected by calls to
    ; SCI_INDICATORFILLRANGE(int start, int lengthFill) and SCI_INDICATORCLEARRANGE(int start, int lengthClear).
    Sci[n].SetIndicatorCurrent(1)

    SelStart := Sci[n].GetSelectionStart()
    SelEnd := Sci[n].GetSelectionEnd()

    ; SCI_INDICATORALLONFOR: Retrieve a bitmap value representing which indicators are non-zero at a position.
    ; Unmark if marked (single selection)
    If ((Sci[n].IndicatorAllOnFor(SelStart) & 2) == 2) {
        Sci[n].IndicatorClearRange(SelStart, SelEnd - SelStart)
        Return
    }

    Sci[n].IndicSetStyle(1, g_oColors["MarkedText"].Type) ; Default: INDIC_ROUNDBOX (7)
    Sci[n].IndicSetFore(1, g_oColors["MarkedText"].Color)
    Sci[n].IndicSetAlpha(1, g_oColors["MarkedText"].Alpha)
    Sci[n].IndicSetOutlineAlpha(1, g_oColors["MarkedText"].OutlineAlpha) ; Opaque border = 255

    aSels := GetAllSelections(n)
    Loop % aSels.Length() {
        SelStart := aSels[A_Index][1]
        Sci[n].IndicatorFillRange(SelStart, aSels[A_Index][2] - SelStart)
    }

    ;Sci[n].SetSel(-1, Sci[n].GetCurrentPos())
}

ClearAllMarkers() { ; M
    Local n := TabEx.GetSel()
    Sci[n].MarkerDeleteAll(-1) ; Margin symbols
    Sci[n].SetIndicatorCurrent(1)
    Sci[n].IndicatorClearRange(0, Sci[n].GetLength()) ; Marked text
}

GoToNextMarker() {
    Local n, CurrentPos, aMarkers, Pos

    n := TabEx.GetSel()
    CurrentPos := Sci[n].GetCurrentPos()
    aMarkers := GetNearbyMarkers()

    Loop % aMarkers.Length() {
        If (aMarkers[A_Index] > CurrentPos) {
            Pos := aMarkers[A_Index]
            SetSelEx(n, Pos, Pos)
            Break
        }
    }
}

GoToPreviousMarker() {
    Local n, CurrentPos, aMarkers, Max, Index, Pos

    n := TabEx.GetSel()
    CurrentPos := Sci[n].GetCurrentPos()
    aMarkers := GetNearbyMarkers()
    Max := aMarkers.Length()

    Loop %Max% {
        Index := Max - A_Index + 1
        If (aMarkers[Index] < CurrentPos) {
            Pos := aMarkers[Index]
            SetSelEx(n, Pos, Pos, 1)
            Break
        }
    }
}

GetNearbyMarkers() {
    Local n, StartPos := 0, EndPos := 0, Max, aMarkers := [], LineStart, Prev, Next

    n := TabEx.GetSel()
    Max := Sci[n].GetLength()

    ; Marked text (indicators)
    Loop {
        ; SCI_INDICATORSTART(int indicator, position pos) → position
        StartPos := Sci[n].IndicatorStart(1, EndPos)
        EndPos := Sci[n].IndicatorEnd(1, StartPos)

        ; SCI_INDICATORALLONFOR: Retrieve a bitmap value representing which indicators are non-zero at a position.
        If ((Sci[n].IndicatorAllOnFor(StartPos) & 2) == 2) {
            aMarkers.Push(EndPos)
        }
    } Until !(EndPos != 0 && EndPos < Max)

    ; Bookmarked lines
    LineStart := Sci[n].LineFromPosition(Sci[n].GetCurrentPos())

    ; 15 (markerMask) = g_MarkerBookmark | g_MarkerBreakpoint | g_MarkerDebugStep | g_MarkerError
    Prev := GetMarkerPos(n, 15, LineStart, False) ; 15 = (2 ** 0) + (2 ** 1) + (2 ** 2) + (2 ** 3)
    If (Prev != -1) {
        aMarkers.Push(Prev)
    }

    Next := GetMarkerPos(n, 15, LineStart, True)
    If (Next != -1) {
        aMarkers.Push(Next)
    }

    SortArray(aMarkers)
    Return aMarkers
}

GetMarkerPos(n, Mask, StartLine, Next := True) {
    Local Line

    If (Next) {
        Line := Sci[n].MarkerNext(StartLine + 1, Mask)
    } Else {
        Line := Sci[n].MarkerPrevious(StartLine - 1, Mask)
    }

    Return (Line != -1) ? Sci[n].PositionFromLine(Line) : -1
}

ShowJumpList() {
    Local n, aLines, aaTemp, Line, Max, Index

    n := TabEx.GetSel()

    aLines := GetMarkedLines(n, g_MarkerMask)
    aaTemp := GetMarkedText(n)

    Loop % aaTemp.Length() {
        Line := Sci[n].LineFromPosition(aaTemp[A_Index][1])
        aLines.Push(Line)
    }

    Try {
        Menu MenuJumpList, DeleteAll
    }

    SortArray(aLines)

    Loop % Max := aLines.Length() {
        Index := Max - A_Index + 1
        MenuString := LTrim(GetLineText(aLines[Index]))
        Try {
            Menu MenuJumpList, Insert, 1&, % SubStr(MenuString, 1, 50), JumpToLine
        }
    }

    If (MenuGetHandle("MenuJumpList")) {
        g_aJumpList := aLines
        SetMenuColor("MenuJumpList", g_MenuColor)
        Menu MenuJumpList, Show
    }
}

JumpToLine(MenuString, MenuItemPos, MenuName) {
    Local n := TabEx.GetSel()
    GoToLineEx(n, g_aJumpList[MenuItemPos])
}

SortArray(ByRef Arr) {
    Local Len := Arr.Length(), n, Temp
    Loop {
        n := 0
        Loop % (Len - 1) {
            If (Arr[A_Index] > Arr[A_Index + 1]) {
                Temp := Arr[A_Index]
                Arr[A_Index] := Arr[A_Index + 1]
                Arr[A_Index + 1] := Temp
                n := A_Index
            }
        }
        Len := n
    } Until (n == 0)
}

BraceMatch(n, Pos) {
    Local Found := Sci[n].BraceMatch(Pos, 0)
    Return (Found == -1) ? Sci[n].BraceMatch(Pos - 1, 0) : Found
}

GoToMatchingBrace() { ; M
    Local n := TabEx.GetSel(), BracePos

    BracePos := BraceMatch(n, Sci[n].GetCurrentPos())
    If (BracePos != -1) {
        Sci[n].GoToPos(++BracePos)
        Sci[n].EnsureVisible(Sci[n].LineFromPosition(BracePos))
    }
}

Lowercase() { ; M
    Sci[TabEx.GetSel()].LowerCase()
}

Uppercase() { ; M
    Sci[TabEx.GetSel()].UpperCase()
}

ToTitleCase(Text) {
    StringUpper Text, Text, T
    Return Text
}

TitleCase() { ; M
    MultiSelReplace("ToTitleCase", True)
}

MultiSelReplace(Op, Select := False) {
    Local n, Max, i, SelText

    n := TabEx.GetSel()
    Sci[n].BeginUndoAction()

    Loop % Max := Sci[n].GetSelections() {
        i := Max - A_Index + 1
        SelText := GetSelectedTextN(n, i)
        If (SelText != "") {
            Text := %Op%(SelText)
            SetSelectedTextN(n, Text, i, Select)
        }
    }

    ; Remove an additional selection
    Sci[n].2671(0) ; SCI_DROPSELECTIONN

    Sci[n].EndUndoAction()
}

Dec2Hex() { ; M
    MultiSelReplace("ToHex", True)
}

Hex2Dec() { ; M
    MultiSelReplace("ToDec", True)
}

LookupConstant(ByRef Constant) {
    Local Value
    Static s_oXmlAutoCWin32

    If (!IsObject(s_oXmlAutoCWin32)) {
        If (!LoadXMLEx(s_oXmlAutoCWin32, A_ScriptDir . "\Include\Windows.xml")) {
            Return ""
        }
    }

    StringUpper Constant, % Trim(Constant)
    Value := s_oXmlAutoCWin32.selectSingleNode("//item[@const='" . Constant . "']").getAttribute("value")
    Return Value != "" ? ToHex(Value) : ""
}

ReplaceConstant() { ; M
    Local Constant, Value, Output, n := TabEx.GetSel()

    Constant := GetSelectedText(n)

    Value := LookupConstant(Constant)
    If (Constant ~= "\d+" || Value == "") {
        Run % A_ScriptDir . "\Tools\Constantine\Constantine.ahk /find " . StrReplace(Constant, "0X", "0x")
        Return
    }

    If (InStr(A_ThisMenuItem, "Declare")) {
        SetSelectedText(n, Constant . " := " . Value)

    } Else If (InStr(A_ThisMenuItem, "SendMessage")) {
        Output := "SendMessage " . Value . ", wParam, lParam,, ahk_id %hWnd% `; " . Constant
        SetSelectedText(n, Output)

    } Else If (InStr(A_ThisMenuItem, "OnMessage")) {
        Output := "OnMessage(" . Value . ", ""On" . Constant . """)" . CRLF . CRLF
               .  "On" . Constant . "(wParam, lParam, msg, hWnd) {" . CRLF . CRLF . "}" . CRLF
        SetSelectedText(n, Output)
    }
}

ToggleComment() {
    Local n, Pos, SelStart, SelEnd, LineStartPos, SelText, Lines, Count, Indentation

    n := TabEx.GetSel()
    Pos := Sci[n].GetCurrentPos()

    SelStart := Sci[n].GetSelectionStart()
    SelEnd := Sci[n].GetSelectionEnd()
    LineStartPos := Sci[n].PositionFromLine(Sci[n].LineFromPosition(SelStart))
    If (SelStart == SelEnd) {
        SelEnd := Sci[n].GetLineEndPosition(Sci[n].LineFromPosition(SelEnd))
    }

    Sci[n].SetSel(LineStartPos, SelEnd)
    SelText := GetSelectedText(n)

    Lines := ""
    Count := 0
    Loop Parse, SelText, `n, `r
    {
        ; Uncomment
        If (RegExMatch(A_LoopField, "^\s*\;")) {
            Lines .= RegExReplace(A_LoopField, "\;\s?", "", "", 1) . CRLF
            Count--

        } Else If (A_LoopField == "") {
            Lines .= CRLF

        ; Comment
        } Else {
            RegExMatch(A_LoopField, "^\s+", Indentation)
            Lines .= Indentation . ";" . StrReplace(A_LoopField, Indentation, "",, 1) . CRLF
            Count++
        }
    }

    Lines := RegExReplace(Lines, "`r`n$", "", "", 1)
    SetSelectedText(n, Lines)
    Sci[n].GoToPos(Pos + Count)
}

ZoomIn() {
    Sci[TabEx.GetSel()].ZoomIn()
}

ZoomOut() {
    Sci[TabEx.GetSel()].ZoomOut()
}

ResetZoom() {
    Sci[TabEx.GetSel()].SetZoom(0)
}

ChangeEditorFont() { ; M
    ; Flags: CF_SCREENFONTS | CF_INITTOLOGFONTSTRUCT | CF_NOSCRIPTSEL | CF_NOSIMULATIONS
    If (ChooseFont(g_FontName, g_FontSize, "", "0x000000", 0x801041, g_hWndMain)) {
        Loop % Sci.Length() {
            Sci[A_Index].SetZoom(0) ; Reset zoom
            Sci[A_Index].MarginLen := 0
            Sci[A_Index].StyleSetFont(STYLE_DEFAULT, "" . g_FontName, 1)
            Sci[A_Index].StyleSetSize(STYLE_DEFAULT, g_FontSize)
            ApplyTheme(A_Index, Sci[A_Index].Type)
        }
    }
}

ToggleLineNumbers() { ; M
    g_LineNumbers := !g_LineNumbers

    Loop % Sci.Length() {
        SetLineNumberWidth(A_Index)
    }

    TB_CheckButton(2140, g_LineNumbers)
}

ToggleSymbolMargin() { ; M
    g_SymbolMargin := !g_SymbolMargin

    ShowSymbolMargin(g_SymbolMargin)

    TB_CheckButton(2141, g_SymbolMargin)
}

ShowSymbolMargin(bShow) {
    Loop % Sci.Length() {
        Sci[A_Index].SetMarginWidthN(g_MarginSymbols, bShow ? 16 : 0)
    }
}

ToggleDivider() { ; M
    g_Divider := !g_Divider
    ShowDivider(g_Divider)
}

ShowDivider(bShow) {
    Local W := g_oColors["Divider"].Width
    Loop % Sci.Length() {
        If (bShow) {
            Sci[A_Index].SetMarginWidthN(g_MarginDivider, W)
            Sci[A_Index].SetMarginLeft(g_MarginDivider, 3) ; Left padding
        } Else {
            Sci[A_Index].SetMarginWidthN(g_MarginDivider, 0)
            Sci[A_Index].SetMarginLeft(g_MarginDivider, 2)
        }
    }
}

ToggleCodeFolding() { ; M
    g_CodeFolding := !g_CodeFolding

    If (g_CodeFolding) {
        Loop % Sci.Length() {
            If (Sci[A_Index].GetLexer() > 1) {
                SetCodeFolding(A_Index)
            }
        }
    } Else {
        Loop % Sci.Length() {
            Sci[A_Index].SetMarginWidthN(g_MarginFolding, 0)
        }
    }

    TB_CheckButton(2150, g_CodeFolding)
}

ToggleFold() { ; M
    Local n := TabEx.GetSel()
    Sci[n].ToggleFold(Sci[n].LineFromPosition(Sci[n].GetCurrentPos()))
}

CollapseFolds() { ; M
    ToggleFoldAll(TabEx.GetSel(), 0) ; SC_FOLDACTION_CONTRACT
}

ExpandFolds() { ; M
    ToggleFoldAll(TabEx.GetSel(), 1) ; SC_FOLDACTION_EXPAND
}

ToggleFoldAll(n, Flag) {
    Sci[n].FoldAll(Flag)
    Sci[n].VerticalCentreCaret()
}

ToggleFoldingLines() { ; M
    g_FoldingLines := g_FoldingLines ? 0 : 16

    Loop % Sci.Length() {
        Sci[A_Index].SetFoldFlags(g_FoldingLines)
    }
}

ToggleWordWrap() { ; M
    Local n := TabEx.GetSel()

    g_WordWrap := !Sci[n].GetWrapMode()
    Sci[n].SetWrapMode(g_WordWrap)

    TB_CheckButton(2160, g_WordWrap)
}

; Show spaces, tabs and line breaks
ToggleAllVisible() { ; M
    SendMessage 0x40A, 2190, 0,, ahk_id %g_hToolbar% ; TB_ISBUTTONCHECKED
    g_ShowWhiteSpaces := g_ShowCRLF := !ErrorLevel

    ShowWhiteSpaces(g_ShowWhiteSpaces, g_ShowCRLF)

    TB_CheckButton(2190, g_ShowCRLF)
    Try {
        Menu MenuView, % g_ShowWhiteSpaces ? "Check" : "Uncheck", &Show White Spaces
        Menu MenuView, % g_ShowCRLF ? "Check" : "Uncheck", Show Line Endings
    }
}

ToggleWSVisible() { ; M
    g_ShowWhiteSpaces := !g_ShowWhiteSpaces

    ShowWhiteSpaces(g_ShowWhiteSpaces, g_ShowCRLF)

    TB_CheckButton(2190, g_ShowWhiteSpaces & g_ShowCRLF)
    ToggleMenuItem("MenuView", "&Show White Spaces")
}

ShowWhiteSpaces(bShow, bEOL := False) {
    Loop % Sci.Length() {
        Sci[A_Index].SetWhiteSpaceSize(bShow ? 2 : 0)
        Sci[A_Index].SetWhiteSpaceFore(1, g_oColors["WhiteSpace"].FC)
        Sci[A_Index].SetWhiteSpaceBack(1, g_oColors["WhiteSpace"].BC)
        Sci[A_Index].SetViewWS(bShow)
        Sci[A_Index].SetViewEOL(bEOL)
    }
}

ToggleCRLFVisible() { ; M
    g_ShowCRLF := !g_ShowCRLF

    ShowWhiteSpaces(g_ShowWhiteSpaces, g_ShowCRLF)

    TB_CheckButton(2190, g_ShowCRLF & g_ShowWhiteSpaces)
    ToggleMenuItem("MenuView", "Show Line Endings")
}

ToggleSyntaxHighlighting() {
    g_SyntaxHighlighting := !g_SyntaxHighlighting

    If (g_SyntaxHighlighting) {
        Loop % Sci.Length() {
            ApplyTheme(A_Index, Sci[A_Index].Type)
        }
    } Else {
        Loop % Sci.Length() {
            DisableSyntaxHighlighting(A_Index)
        }
    }

    TB_CheckButton(2180, g_SyntaxHighlighting)
}

DisableSyntaxHighlighting(n) {
    Sci[n].StyleClearAll()
    Sci[n].StyleSetFore(STYLE_LINENUMBER, g_oColors["NumbersMargin"].FC)
    Sci[n].StyleSetBack(STYLE_LINENUMBER, g_oColors["NumbersMargin"].BC)
}

ToggleHighlightActiveLine() {
    g_HighlightActiveLine := !g_HighlightActiveLine

    Loop % Sci.Length() {
        Sci[A_Index].SetCaretLineVisible(g_HighlightActiveLine)
    }
}

ToggleHighlights() {
    Local n := TabEx.GetSel()
    g_Highlights := !g_Highlights

    If (g_Highlights) {
        Highlight(n, Sci[n].GetCurrentPos(), g_HITMode, g_HITFlags, g_HITLimit, g_ChkHITStartPos)
    } Else {
        Sci[n].SetIndicatorCurrent(2)
        Sci[n].IndicatorClearRange(0, Sci[n].GetLength())
    }
}

; Load autocomplete data
LoadAutoComplete(Type) {
    Local Keys, Key, Name, BaseName, oXML, List := ""

    BaseName := g_oLexTypes[Type].Name
    If (BaseName == "") {
        Return 0
    }

    oXML := LoadXML(g_AutoCDir . "\" . BaseName . ".ac")
    If (!IsObject(oXML)) {
        Return 0
    }

    Keys := oXML.selectNodes("/AutoComplete/language[@id=""" . Type . """]/key")
    For Key in Keys {
        List .= Key.getAttribute("name") . "|"
    }

    g_oAutoC[Type] := {}
    g_oAutoC[Type].List := List
    g_oAutoC[Type].oXML := oXML
    g_oAutoC[Type].bLoaded := True

    Return (List != "")
}

LoadUserList(XmlFile) {
    Local oXml, Keys, Key

    oXml := LoadXML(g_AutoCDir . "\" . XmlFile)
    If (!IsObject(oXml)) {
        Return
    }

    Keys := oXml.selectNodes("/UserDictionary/key")
    For Key in Keys {
        g_UserWords .= Key.getAttribute("word") . "|"
    }
}

CreateAutoCList(TypeList, Filter := "") {
    Local List, aList, Item, Len := StrLen(Filter), Output := ""

    Sort g_TypedWords, UCD|

    List := TypeList . g_TypedWords . g_UserWords

    aList := StrSplit(List, "|")

    Loop % aList.Length() {
        Item := aList[A_index]
        If (StrLen(Item) >= g_AutoCMinWordLen && SubStr(Item, 1, Len) = Filter) {
            Output .= Item . "|"
        }
    }

    Sort Output, UCD|

    Return RTrim(Output, "|")
}

; Show autocomplete list
ShowAutoCList(n, MinLength := 3) {
    Local CurPos, WordStartPos, LengthEntered, PrevChar, Filter, AutoCList

    CurPos := Sci[n].GetCurrentPos()
    WordStartPos := Sci[n].WordStartPosition(CurPos, True) ; True = onlyWordCharacters
    LengthEntered := CurPos - WordStartPos
    If (LengthEntered < MinLength || Sci[n].AutoCActive()) {
        Return 0
    }

    PrevChar := Sci[n].GetCharAt(WordStartPos - 1)
    If (Chr(PrevChar) ~= g_WordPrefix) {
        --WordStartPos
        --CurPos
        ++LengthEntered
    }

    Filter := GetTextRange(n, WordStartPos, CurPos)
    AutoCList := CreateAutoCList(g_oAutoC[Sci[n].Type].List, Filter)

    If (AutoCList != "") {
        Sci[n].AutoCShow(LengthEntered, "" . AutoCList, 1)
    }
}

GetCalltip(Keyword, Overload := True) {
    Local n, oNode, LineText, Params, Calltip, Separator, List, Pos, Type

    n := TabEx.GetSel()
    Type := Sci[n].Type

    List := g_oAutoC[Type].List
    Pos := InStr(List, Keyword)
    If (!Pos) {
        Return
    }
    keyword := SubStr(List, Pos, StrLen(Keyword)) ; Correct keyword case

    oXML := g_oAutoC[Type].oXML
    oNode := oXML.selectSingleNode("//key[@name=""" . Keyword . """]")

    If (Type == "AHK" && (Keyword == "Hotkey" || Keyword == "Progress")) {
        LineText := GetCurrentLine()
        If (RegExMatch(LineText, "i)\s*Gui")) {
            Return
        }
    }

    Params := oNode.selectNodes("params")
    g_CalltipParams := []
    Loop % Params.length {
        Calltip := Params.item(A_Index - 1).text
        Separator := (SubStr(Calltip, 1, 1) != "(") ? " " : ""
        g_CalltipParams.Push(Keyword . Separator . Calltip)
    }

    If (Params.item(0).text != "") {
        Return (Overload && Params.length > 1) ? Chr(2) . g_CalltipParams[1] : g_CalltipParams[1]
    }
}

ShowCalltip(n, Calltip, StartPos) {
    If (CallTip != "") {
        Sci[n].CalltipShow(StartPos, CallTip, 1)
        g_CalltipParamsIndex := 1
    }
}

InsertCalltip() {
    Local n := TabEx.GetSel(), Pos, PrevChar, EndPos, Word, Calltip, NextChar

    If (Sci[n].AutoCActive()) {
        Sci[n].AutoCComplete()
    }

    Pos := Sci[n].GetCurrentPos()

    PrevChar := Chr(Sci[n].GetCharAt(Pos - 1))
    If (PrevChar == " " || PrevChar == ",") {
        Pos--
    }

    EndPos := GetCurrentWord(Word, Pos)[2]
    GetCalltip(Word, False)
    Calltip := StrReplace(g_CalltipParams[g_CalltipParamsIndex], Word,,, 1)

    NextChar := Chr(Sci[n].GetCharAt(EndPos))
    If (NextChar == " " || NextChar == ",") {
        Sci[n].DeleteRange(EndPos, 1)
    }

    Sci[n].InsertText(EndPos, Calltip, 1)
    Sci[n].WordRight()
    Sci[n].CalltipCancel()
}

NextCalltip(Previous := 0) {
    Local n, Obj

    If ((Previous && g_CalltipParamsIndex == 1)
    || (!Previous && g_CalltipParams.Length() == g_CalltipParamsIndex)) {
        Return
    }

    n := TabEx.GetSel()
    Obj := {}
    Obj.SCNCode := SCN_CALLTIPCLICK
    Obj.Position := Previous ? 1 : 2

    Sci[n].Notify(0, 0, 0, 0, Obj)
}

ToggleAutoComplete() {
    g_AutoComplete := !g_AutoComplete

    If (g_AutoComplete) {
        Loop % Sci.Length() {
            SetAutoComplete(A_Index)
        }
    }

    TB_CheckButton(2185, g_AutoComplete)
}

ToggleTypedWords() {
    g_AutoCTypedWords := !g_AutoCTypedWords
    g_TypedWords := ""
}

ToggleCalltips() {
    g_Calltip := !g_Calltip
    g_CalltipTyping := g_CalltipAutoC := g_CalltipHover := g_Calltip
    TB_CheckButton(2186, g_Calltip)
}

ToggleAutoBrackets() {
    g_AutoBrackets := !g_AutoBrackets
    TB_CheckButton(2181, g_AutoBrackets)
}

ShowIndentationDialog:
    Gui IndentDlg: New, LabelIndentDlg hWndhIndentDlg -MinimizeBox OwnerMain
    SetWindowIcon(hIndentDlg, IconLib, -37)
    Gui Font, s9, Segoe UI
    Gui Color, White
    Gui Add, Text, x16 y16 w95 h23 +0x200, Indentation size:
    Gui Add, Edit, vg_TabSize x112 y17 w50 h21 Number
    Gui Add, UpDown, x167 y18 w17 h21, %g_TabSize%
    Gui Add, CheckBox, vg_IndentWithSpaces x16 y48 w181 h23 Checked%g_IndentWithSpaces%, Indent with spaces
    Gui Add, CheckBox, vg_AutoIndent x16 y80 w181 h23 Checked%g_AutoIndent%, Automatic indentation
    Gui Add, Text, x-1 y126 w337 h49 -Background +Border
    Gui Add, Button, gSetIndentationSettings x150 y138 w84 h24 +Default, &OK
    Gui Add, Button, gIndentDlgClose x241 y138 w84 h24, &Cancel
    Gui Show, w334 h174, Indentation Settings
Return

IndentDlgClose() {
    IndentDlgEscape:
    Gui IndentDlg: Destroy
    Return
}

SetIndentationSettings() {
    Gui IndentDlg: Submit

    Loop % Sci.Length() {
        Sci[A_Index].SetTabWidth(g_TabSize)
        Sci[A_Index].SetUseTabs(!g_IndentWithSpaces)
    }

    SetIndent() ; For generated code
}

SetIndent() {
    Indent := g_IndentWithSpaces ? Format("{1: " . g_TabSize . "}", "") : "`t"
}

ToggleRememberSession() {
    g_RememberSession := !g_RememberSession
    g_LoadLastSession := g_RememberSession
}

ToggleAskToSaveOnExit() {
    g_AskToSaveOnExit := !g_AskToSaveOnExit
}

GoToRandomLine(n) {
    Local RN, Max := Sci[n].GetLineCount()
    Random RN, 1, %Max%
    Loop %Max% {
        --RN
        If (GetLineText(RN) != CRLF) {
            GoToLineEx(n, RN)
            Break
        }
    }
}

GetLineText(Line) { ; 0-based
    Local n, LineLen, LineText
    Line := Line > 0 ? Line : 0
    n := TabEx.GetSel()
    LineLen := Sci[n].LineLength(Line)
    VarSetCapacity(LineText, LineLen, 0)
    Sci[n].GetLine(Line, &LineText)
    Return StrGet(&LineText,, "UTF-8")
}

GoToLineEx(n, Line) { ; 0-based
    Local Pos := Sci[n].PositionFromLine(Line)
    SetSelEx(n, Pos, Pos)
}

SetSelEx(n, StartPos, EndPos, Upward := 0) {
    Local Line := Sci[n].LineFromPosition(StartPos), LastVisibleLine

    Sci[n].EnsureVisible(Line) ; Expand hidden lines (contracted folds)

    If (Upward) {
        If (Line < Sci[n].GetFirstVisibleLine()) {
            Sci[n].GoToPos(StartPos)
            Sci[n].VerticalCentreCaret()
        }
    } Else {
        LastVisibleLine := Sci[n].GetFirstVisibleLine() + Sci[n].LinesOnScreen()
        If (Line > LastVisibleLine) {
            Sci[n].GoToPos(StartPos)
            Sci[n].VerticalCentreCaret()
        }
    }

    Sci[n].SetYCaretPolicy(CARET_SLOP|CARET_STRICT|CARET_EVEN, 5)
    Sci[n].SetSel(StartPos, EndPos)
    Sci[n].SetYCaretPolicy(CARET_EVEN, 0)
}

GetSelectionPos(n, ByRef StartPos, ByRef EndPos, Index := 1) { ; 1-based
    If (Index == 0) {
        Index := Sci[n].GetSelections()
    }

    Index--
    StartPos := Sci[n].GetSelectionNStart(Index)
    EndPos := Sci[n].GetSelectionNEnd(Index)

    Return !Sci[n].GetSelectionEmpty()
}

GetAllSelections(n, SkipEmpty := True) {
    Local aaSels := [], i := 1

    Loop % Sci[n].GetSelections() {
        GetSelectionPos(n, StartPos, EndPos, A_Index)
        If (SkipEmpty && StartPos == EndPos) {
            Continue
        }

        aaSels[i++] := [StartPos, EndPos]
    }

    Return aaSels
}

GetPreviousTab() {
    Local f := False, c := 0, i := 1, lat

    Loop % Sci.Length() {
        lat := Sci[A_Index].LastAccessTime

        If (f) {
            If (lat >= c) {
                c := lat
                i := A_Index
            } ; No else
        } Else {
            c := lat
            f := True
        }
    }

    Return i
}

ApplyThemeToTabN(n, ThemeName, ThemeNameEx := "") {
    Local oXML, Type

    If (LoadTheme(g_ThemeFile, ThemeName)) {
        If (ThemeNameEx == "" && LoadXMLEx(oXML, g_ThemeFile)) {
            ThemeNameEx := oXML.selectSingleNode("/themes/theme[@name='" . ThemeName . "']").getAttribute("specifics")
        }

        Type := Sci[n].Type
        g_oColors[Type].Loaded := False
        LoadLexerData(Type, ThemeNameEx)
        ApplyTheme(n, Type)
        ApplyFoldMarginColors(n)
    }
}

PreviewTheme(hCtl) {
    Local ThemeName
    GuiControlGet ThemeName,, %hCtl%
    ApplyThemeToTabN(TabEx.GetSel(), ThemeName)
}

ChooseThemeDialog() {
    Local oXML, oNodes, oNode, Name, ThemeNames := "", ThemeName, Type

    If (!LoadXMLEx(oXML, g_ThemeFile)) {
        Return 0
    }

    oNodes := oXML.selectNodes("/themes/theme")
    For oNode in oNodes {
        Name := oNode.getAttribute("name")
        ThemeNames .= Name . "|" . (Name == g_ThemeName ? "|" : "")
    }

    ThemeName := InputBoxEx("Theme", "Syntax highlighting color scheme", "Choose Theme", ThemeNames
    , "DDL", "Sort",, 500, "", IconLib, -40, "+MinimizeBox +AlwaysOnTop", "PreviewTheme")
    If (ErrorLevel) {
        If (ThemeName != g_ThemeName) {
            ApplyThemeToTabN(TabEx.GetSel(), g_ThemeName)
        }
        Return
    }

    If (LoadTheme(g_ThemeFile, g_ThemeName := ThemeName)) {
        g_ThemeNameEx := oXML.selectSingleNode("/themes/theme[@name='" . ThemeName . "']").getAttribute("specifics")

        Loop % Sci.Length() {
            Type := Sci[A_Index].Type
            ;g_oColors[Type].Loaded := False
            UnloadStyles()
            LoadLexerData(Type, g_ThemeNameEx)
            ApplyTheme(A_Index, Type)
            ApplyFoldMarginColors(A_Index)
        }
    }
}

; Global styles
LoadTheme(ThemeFile, ThemeName) {
    Local oXML, Node

    If (!LoadXMLEx(oXML, ThemeFile)) {
        Return 0
    }

    Node := oXML.selectSingleNode("/themes/theme[@name='" . ThemeName . "']")

    g_oColors["Default"] := {}
    g_oColors["Default"].FC := GetThemeColor(Node, "default", "fc")
    g_oColors["Default"].BC := GetThemeColor(Node, "default", "bc")

    If (g_oColors["Default"].FC == g_oColors["Default"].BC) {
        g_ThemeNameEx := "Default"
        Return 0 ; LoadTheme will be called again with "Shenanigans" as theme.
    }

    g_oColors["Caret"] := {}
    g_oColors["Caret"].FC := GetThemeColor(Node, "caret", "fc")

    g_oColors["Selection"] := {}
    g_oColors["Selection"].FC := GetThemeColor(Node, "selection", "fc")
    g_oColors["Selection"].BC := GetThemeColor(Node, "selection", "bc")
    g_oColors["Selection"].Alpha := GetThemeValue(Node, "selection", "a")

    g_oColors["NumbersMargin"] := {}
    g_oColors["NumbersMargin"].FC := GetThemeColor(Node, "numbersmargin", "fc")
    g_oColors["NumbersMargin"].BC := GetThemeColor(Node, "numbersmargin", "bc")

    g_oColors["SymbolMargin"] := {}
    g_oColors["SymbolMargin"].BC := GetThemeColor(Node, "symbolmargin", "bc")

    g_oColors["Divider"] := {}
    g_oColors["Divider"].BC := GetThemeColor(Node, "divider", "bc")
    g_oColors["Divider"].Width := GetThemeValue(Node, "divider", "w")

    g_oColors["FoldMargin"] := {}
    g_oColors["FoldMargin"].DLC := GetThemeColor(Node, "foldmargin", "dlc") ; Drawing lines
    g_oColors["FoldMargin"].BBC := GetThemeColor(Node, "foldmargin", "bbc") ; Button background
    g_oColors["FoldMargin"].MBC := GetThemeColor(Node, "foldmargin", "mbc") ; Margin background

    g_oColors["ActiveLine"] := {}
    g_oColors["ActiveLine"].BC := GetThemeColor(Node, "activeline", "bc")

    g_oColors["BraceMatch"] := {}
    g_oColors["BraceMatch"].FC := GetThemeColor(Node, "bracematch", "fc")
    g_oColors["BraceMatch"].Bold := GetThemeValue(Node, "bracematch", "b")
    g_oColors["BraceMatch"].Italic := GetThemeValue(Node, "bracematch", "i")

    g_oColors["MarkedText"] := {}
    g_oColors["MarkedText"].Type := GetThemeValue(Node, "markers", "t")
    g_oColors["MarkedText"].Color := GetThemeColor(Node, "markers", "c")
    g_oColors["MarkedText"].Alpha := GetThemeValue(Node, "markers", "a")
    g_oColors["MarkedText"].OutlineAlpha := GetThemeValue(Node, "markers", "oa")

    g_oColors["IdenticalText"] := {}
    g_oColors["IdenticalText"].Type := GetThemeValue(Node, "highlights", "t")
    g_oColors["IdenticalText"].Color := GetThemeColor(Node, "highlights", "c")
    g_oColors["IdenticalText"].Alpha := GetThemeValue(Node, "highlights", "a")
    g_oColors["IdenticalText"].OutlineAlpha := GetThemeValue(Node, "highlights", "oa")

    g_oColors["Calltip"] := {}
    g_oColors["Calltip"].FC := GetThemeColor(Node, "calltip", "fc")
    g_oColors["Calltip"].BC := GetThemeColor(Node, "calltip", "bc")

    g_oColors["IndentGuide"] := {}
    g_oColors["IndentGuide"].FC := GetThemeColor(Node, "indentguide", "fc")
    g_oColors["IndentGuide"].BC := GetThemeColor(Node, "indentguide", "bc")

    g_oColors["WhiteSpace"] := {}
    g_oColors["WhiteSpace"].FC := GetThemeColor(Node, "whitespace", "fc")
    g_oColors["WhiteSpace"].BC := GetThemeColor(Node, "whitespace", "bc")

    Return 1
}

GetThemeColor(BaseNode, Node, Attrib) {
    Local Value := BaseNode.selectSingleNode(Node).getAttribute(Attrib)
    Return Value ? CvtClr(Value) : Value
}

GetThemeValue(BaseNode, Node, Attrib) {
    Return BaseNode.selectSingleNode(Node).getAttribute(Attrib)
}

; Load specific language styles, keywords and properties
LoadLexerData(Type, ThemeNameEx := "Default") {
    Local BaseName, ThemeFile, oXML, oStyles, oStyle, oKWGroups, oKWGroup, nGroup, oProps, oProp, Name, Value

    BaseName := GetNameByLexType(Type)
    If (g_oColors[Type].Loaded || BaseName == "") {
        Return 0
    }

    ThemeFile := A_ScriptDir . "\Themes\Specifics\" . BaseName . ".xml"
    If (!IsObject(oXML := LoadXML(ThemeFile))) {
        Return 0
    }

    ; Styles
    oStyles := oXML.selectNodes("/scheme/theme[@name='" . ThemeNameEx . "']/style")
    If (oStyles.length()) {
        g_oColors[Type].Values := []

        For oStyle in oStyles {
            LoadThemeStyles(Type, oStyle)
        }
    }

    g_oColors[Type].Loaded := True

    ; Keywords
    oKWGroups := oXML.selectNodes("/scheme/keywords/language[@id='" . Type . "']/group")
    If (oKWGroups.length()) {
        g_oKeywords[Type] := {}
        For oKWGroup in oKWGroups {
            nGroup := oKWGroup.getAttribute("id")
            g_oKeywords[Type][nGroup] := oKWGroup.getAttribute("keywords")
        }
    }

    ; Properties
    oProps := oXML.selectNodes("/scheme/properties/property")
    If (oProps.length()) {
        g_oProps[Type] := {}
        For oProp in oProps {
            Name := oProp.getAttribute("name")
            Value := oProp.getAttribute("value")
            g_oProps[Type][Name] := Value
        }
    }

    Return 1
}

LoadThemeStyles(Type, Node) {
    Local v, fc, bc

    v := Node.getAttribute("v")
    If (!v) {
        Return
    }

    g_oColors[Type][v] := {}
    g_oColors[Type].Values.Push(v)

    fc := Node.getAttribute("fc")
    If (fc != "") {
        fc := CvtClr(fc)
        g_oColors[Type][v].FC := fc
    }

    bc := Node.getAttribute("bc")
    If (bc != "") {
        bc := CvtClr(bc)
        g_oColors[Type][v].BC := bc
    }

    g_oColors[Type][v].Bold := Node.getAttribute("b")
    g_oColors[Type][v].Italic := Node.getAttribute("i")
    g_oColors[Type][v].Under := Node.getAttribute("u")
}

SetKeywords(n, Type) {
    If (g_oKeywords.HasKey(Type)) {
        For GrpType, Keywords in g_oKeywords[Type] {
            Sci[n].SetKeywords(GrpType, Keywords, 1)
        }
    }
}

ApplyTheme(n, Type := "") {
    Local v, fc, bc, Italic, Bold, Under, SelAlpha

    ; Default color for text and background
    Sci[n].StyleSetFore(STYLE_DEFAULT, g_oColors["Default"].FC)
    Sci[n].StyleSetBack(STYLE_DEFAULT, g_oColors["Default"].BC)
    Sci[n].StyleClearAll() ; This message sets all styles to have the same attributes as STYLE_DEFAULT.

    ; Caret
    Sci[n].SetCaretFore(g_oColors["Caret"].FC)

    ; Selection
    Sci[n].SetSelFore(1, g_oColors["Selection"].FC)
    Sci[n].SetSelBack(1, g_oColors["Selection"].BC)
    SelAlpha := g_oColors["Selection"].Alpha
    If (SelAlpha != "") {
        Sci[n].SetSelAlpha(SelAlpha)
    }

    ; Margins
    ; Line numbers
    Sci[n].StyleSetFore(33, g_oColors["NumbersMargin"].FC)
    Sci[n].StyleSetBack(33, g_oColors["NumbersMargin"].BC)
    ; Symbol margin and divider
    Sci[n].SetMarginBackN(g_MarginSymbols, g_oColors["SymbolMargin"].BC)
    Sci[n].SetMarginBackN(g_MarginDivider, g_oColors["Divider"].BC)
    Sci[n].SetMarginWidthN(g_MarginDivider, g_oColors["Divider"].Width)

    ; Active line background color
    Sci[n].SetCaretLineBack(g_oColors["ActiveLine"].BC)
    Sci[n].SetCaretLineVisible(g_HighlightActiveLine)
    Sci[n].SetCaretLineVisibleAlways(g_HighlightActiveLine)

    ; Matching braces
    Sci[n].StyleSetBack(STYLE_BRACELIGHT, g_oColors["ActiveLine"].BC)
    Sci[n].StyleSetFore(STYLE_BRACELIGHT, g_oColors["BraceMatch"].FC)
    If (g_oColors["BraceMatch"].Bold) {
        Sci[n].StyleSetBold(STYLE_BRACELIGHT, True)
    }
    If (g_oColors["BraceMatch"].Italic) {
        Sci[n].StyleSetItalic(STYLE_BRACELIGHT, True)
    }

    ; Calltips
    Sci[n].CalltipSetFore(g_oColors["Calltip"].FC)
    Sci[n].CalltipSetBack(g_oColors["Calltip"].BC)

    ; Indentation guides
    Sci[n].StyleSetFore(37, g_oColors["IndentGuide"].FC)
    Sci[n].StyleSetBack(37, g_oColors["IndentGuide"].BC)

    ; Language specifics
    Loop % (g_SyntaxHighlighting * g_oColors[Type].Values.Length()) {
        v := g_oColors[Type].Values[A_Index]

        fc := g_oColors[Type][v].FC
        If (fc != "") {
            Sci[n].StyleSetFore(v, fc)
        }

        bc := g_oColors[Type][v].BC
        If (bc != "") {
            Sci[n].StyleSetBack(v, bc)
        }

        If (Italic := g_oColors[Type][v].Italic) {
            Sci[n].StyleSetItalic(v, Italic)
        }

        If (Bold := g_oColors[Type][v].Bold) {
            Sci[n].StyleSetBold(v, Bold)
        }

        If (Under := g_oColors[Type][v].Under) {
            Sci[n].StyleSetUnderline(v, Under)
        }
    }
}

LoadSyntaxMenu(LexTypes) {
    Local aLexers := StrSplit(LexTypes, "|"), DisplayName

    Loop % aLexers.Length() {
        DisplayName := g_oLexTypes[aLexers[A_Index]].DN
        If (DisplayName != "") {
            Menu MenuLexer, Add, %DisplayName%, M_SetLexType, Radio
        }
    }

    Menu MenuLexer, Add
    AddMenu("MenuLexer", "More Lexers...", "ShowSyntaxDialog", IconLib, -54)
}

M_SetLexType() {
    SetLexType(TabEx.GetSel(), A_ThisMenuItem)
}

SetLexType(n, DisplayName) {
    Local LexType := GetLexTypeByDisplayName(DisplayName)

    If (LexType != "") {
        Sci[n].Type := LexType
        Sci_Colour(n, LexType)
        SB_UpdateFileDesc(n)

        If (!g_oAutoC[LexType].bLoaded) {
            LoadAutoComplete(LexType)
        }

        If (LexType == "INI") {
            Sci[n].Encoding := "UTF-16"
            Gui Main: Default
            SB_SetText("UTF-16 LE", g_SBP_Encoding)
        }
    } Else {
        DisableSyntaxHighlighting(n)
    }
}

LoadFileTypes() {
    Local oFileExts, oFileExt, Ext, Type, Desc, oFileTypes, Id, Name, Lexer, DN

    If (!LoadXMLEx(g_oXMLFileTypes, A_ScriptDir . "\Settings\FileTypes.xml")) {
        Return
    }

    oFileExts := g_oXMLFileTypes.selectNodes("/ftypes/extensions/ext")
    For oFileExt in oFileExts {
        Ext  := oFileExt.getAttribute("id")
        Type := oFileExt.getAttribute("type")
        Desc := oFileExt.getAttribute("desc")

        g_oFileExts[Ext] := {}
        g_oFileExts[Ext].Type := Type
        g_oFileExts[Ext].Desc := Desc
    }

    oFileTypes := g_oXMLFileTypes.selectNodes("/ftypes/types/type")
    For oFileType in oFileTypes {
        Id    := oFileType.getAttribute("id")
        Name  := oFileType.getAttribute("name")
        DN    := oFileType.getAttribute("dn")
        Lexer := oFileType.getAttribute("lexer")
        Ext   := oFileType.getAttribute("ext")

        ; Lexer subtype
        g_oLexTypes[Id] := {}
        g_oLexTypes[Id].Name := Name ; Base filename
        g_oLexTypes[Id].DN := DN
        g_oLexTypes[Id].Lexer := Lexer
        g_oLexTypes[Id].Ext := Ext

        g_oColors[Id] := {}
        ;g_oColors[Id].Lexer := Lexer
        g_oColors[Id].Loaded := False ; Set in LoadLexerData
    }
}

GetLexTypeByExt(FileExt) {
    Return g_oFileExts[FileExt].Type
}

GetLexerByLexType(Type) {
    Local Lexer := g_oLexTypes[Type].Lexer
    Return Lexer != "" ? Lexer : 1
}

GetLexerByExt(FileExt) {
    Return GetLexerByLexType(GetLexTypeByExt(FileExt))
}

GetLexTypeByDisplayName(DisplayName) {
    Local K, V
    For K, V in g_oLexTypes {
        If (DisplayName == V.DN) {
            Return K
        }
    }
    Return "TXT"
}

GetDisplayNameByLexType(Type) {
    Local DN := g_oLexTypes[Type].DN
    If (DN == "") {
        Return GetLexerByLexType(Type) < 2 ? "Text File" : ""
    }
    Return DN
}

; Get "name" (language name or document type) based on "type" (sublexer)
GetNameByLexType(Type) {
    Return g_oLexTypes[Type].Name
}

GetDefaultFileExt(Type) {
    Return g_oLexTypes[Type].Ext
}

GetSelectedTextN(nTabIndex, nSelIndex := 1) {
    Local StartPos, EndPos

    If (GetSelectionPos(nTabIndex, StartPos, EndPos, nSelIndex)) {
        Return GetTextRange(nTabIndex, StartPos, EndPos)
    }

    Return ""
}

GetFileTypeDesc(FileExt) {
    Local Desc := g_oFileExts[FileExt].Desc
    Return Desc != "" ? Desc : g_oLexTypes[GetLexTypeByExt(FileExt)].DN
}

SelectMarkedLines() { ; M
    Local n := TabEx.GetSel(), aMarkedLines, Line
    aMarkedLines := GetMarkedLines(n, g_MarkerMask)
    Loop % aMarkedLines.Length() {
        Line := aMarkedLines[A_Index]
        LineStart := Sci[n].PositionFromLine(Line)
        LineEnd := Sci[n].GetLineEndPosition(Line)
        Sci[n].AddSelection(LineStart, LineEnd) ; SCI_ADDSELECTION
    }
}

RemoveBookmark(Marker) {
    Local n := TabEx.GetSel(), Line
    Line := Sci[n].LineFromPosition(Sci[n].GetCurrentPos())
    Sci[n].MarkerDelete(Line, Marker)
}

/*
SCI_CONTRACTEDFOLDNEXT(line lineStart) → line
Search efficiently for lines that are contracted fold headers. This is useful when saving the user's folding when switching documents or saving folding with a file. The search starts at line number lineStart and continues forwards to the end of the file. lineStart is returned if it is a contracted fold header otherwise the next contracted fold header is returned. If there are no more contracted fold headers then -1 is returned.
*/
GetAllFolds(n) {
    Local aLines := [], nLine := -1

    If (Sci[n].GetAllLinesVisible()) { ; SCI_GETALLLINESVISIBLE
        Return []
    }
/*
    ; Untested
    Loop {
        nLine := Sci[n].ContractedFoldNext(0)
        If (nLine == -1) {
            Break
        }
        aLines.Push(nLine)
    }
*/
    Loop % Sci[n].GetLineCount() - 1 {
        ++nLine
        If (!Sci[n].GetFoldExpanded(nLine)) {
            aLines.Push(nLine)
            ++nLine
        }
    }

    Return aLines
}

GetActiveTabIndex() {
    Local n := TabEx.GetSel()
    Return Sci[n].FullName != "" ? n : 1
}

GetMarkedLines(n, MarkerMask) {
    Local aLines := [], nLine

    Loop % Sci[n].GetLineCount() {
        nLine := A_Index - 1
        If (Sci[n].MarkerGet(nLine) & MarkerMask) {
            aLines.Push(nLine)
        }
    }

    Return aLines
}

; Get all indicators
GetMarkedText(n, Indicator := 1) {
    Local StartPos, EndPos := 0, Max := Sci[n].GetLength(), aaMarkers := []

    Loop {
        StartPos := Sci[n].IndicatorStart(1, EndPos)
        EndPos := Sci[n].IndicatorEnd(1, StartPos)

        If ((Sci[n].IndicatorAllOnFor(StartPos) & 2) == 2) {
            aaMarkers.Push([StartPos, EndPos])
        }
    } Until !(EndPos != 0 && EndPos < Max)

    Return aaMarkers
}

AutoCloseBrackets(n, CurPos, Char) {
    Local PrevChar, NextChar, PrevChars, iIndentation, sIndentation := "", NextWord

    If Char Not in 40,91,123,34 ; Parentheses, brackets, braces, quotes
        Return

    PrevChar := Chr(Sci[n].GetCharAt(CurPos - 2))
    NextChar := Chr(Sci[n].GetCharAt(CurPos))

    GetCurrentWord(NextWord, CurPos + 1)
    If (NextWord != "" && NextWord != CRLF) {
        Return
    }

    ; Parentheses
    If (Char == 40 && NextChar != ")") {
        Sci[n].InsertText(CurPos, ")", 1)

    ; Brackets
    } Else If (Char == 91 && NextChar != "]") {
        Sci[n].InsertText(CurPos, "]", 1)

    ; Braces
    } Else If (Char == 123 && NextChar != "}") {
        PrevChars := GetTextRange(n, CurPos - 5, CurPos)
        If (RegExMatch(PrevChars, "\)\s?\r?\n?")) {
            iIndentation := Sci[n].GetLineIndentation(Sci[n].LineFromPosition(CurPos))

            If (iIndentation) {
                If (g_IndentWithSpaces) {
                    sIndentation := Format("{1: " . iIndentation . "}", "")
                } Else {
                    Loop % iIndentation // g_TabSize {
                        sIndentation .= "`t"
                    }
                }
            }

            Sci[n].InsertText(CurPos, CRLF . sIndentation . Indent . CRLF . sIndentation . "}", 1)
            Sci[n].GoToPos(CurPos + StrLen(CRLF . sIndentation . Indent))
        } Else {
            Sci[n].InsertText(CurPos, "}", 1)
        }

    ; Quotes
    } Else If (Char == 34 && NextChar != """" && (PrevChar == "" || PrevChar ~= "[\s,\(\[\=\:\n\rL]")) {
        Sci[n].InsertText(CurPos, """", 1)
    }
}

; Specific properties of Scintilla lexers
; SetLexerProperties
SetProperties(n, Type) {
    Local Name, Value
    For Name, Value in g_oProps[Type] {
        Sci[n].SetProperty(Name, Value, 1, 1)
    }
}

; Scintilla context menu
CreateSciPopupMenu() {
    AddMenu("MenuSciPopup", "New Tab", "M_NewTab", IconLib, -2)
    AddMenu("MenuSciPopup", "Close Tab", "M_CloseTab", IconLib, -17)
    Menu MenuSciPopup, Add
    AddMenu("MenuSciPopup", "Undo", "Undo", IconLib, -19)
    AddMenu("MenuSciPopup", "Redo", "Redo", IconLib, -20)
    Menu MenuSciPopup, Add
    AddMenu("MenuSciPopup", "Cut", "Cut", IconLib, -21)
    AddMenu("MenuSciPopup", "Copy", "Copy", IconLib, -22)
    AddMenu("MenuSciPopup", "Paste", "Paste", IconLib, -23)
    AddMenu("MenuSciPopup", "Delete", "Clear", IconLib, -24)
    Menu MenuSciPopup, Add
    AddMenu("MenuSciPopup", "Select All", "SelectAll", IconLib, -25)
    SetMenuColor("MenuSciPopup", g_MenuColor)
    Return 1
}

UpdateSciPopupMenu() {
    Local n, HasSel, HasLen

    n := TabEx.GetSel()
    HasSel := !Sci[n].GetSelectionEmpty()
    HasLen := Sci[n].GetLength()

    UpdateMenuItemState("MenuSciPopup", "Undo", Sci[n].CanUndo())
    UpdateMenuItemState("MenuSciPopup", "Redo", Sci[n].CanRedo())
    UpdateMenuItemState("MenuSciPopup", "Cut", HasSel)
    UpdateMenuItemState("MenuSciPopup", "Copy", HasSel)
    UpdateMenuItemState("MenuSciPopup", "Paste", Sci[n].CanPaste())
    UpdateMenuItemState("MenuSciPopup", "Delete", HasLen)
    UpdateMenuItemState("MenuSciPopup", "Select All", HasLen)
}

ShowSciPopupMenu(x := "", y := "") {
    Static MenuCreated := 0

    If (!MenuCreated) {
        MenuCreated := CreateSciPopupMenu()
    }

    UpdateSciPopupMenu()
    Menu MenuSciPopup, Show, %x%, %y%
}

AddSelection(n, StartPos, EndPos, First := False) {
    First ? Sci[n].2572(StartPos, EndPos) : Sci[n].2573(StartPos, EndPos) ; SCI_SETSELECTION : SCI_ADDSELECTION
}

ToggleMultipleSelection() { ; M
    g_MultiSel := !g_MultiSel
    Loop % Sci.Length() {
        Sci[A_Index].SetMultipleSelection(g_MultiSel)
        Sci[A_Index].SetAdditionalSelectionTyping(g_MultiSel) ; g_MultiTyping
        Sci[A_Index].SetMultipaste(g_MultiSel) ; g_MultiPaste
    }
}

ShowSyntaxDialog() {
    Global
    Local LexTypes, hWndSyntax, Key, LexType, ThemeFile, Loaded, oXML
    , Syntax, oGroup, Keywords, AutoC, AutoCFile, Checked, IconCheck

    LexTypes := g_LexTypes . "|TXT"

    Gui SyntaxDlg: New, +LabelSyntaxDlg +hWndhWndSyntax
    SetWindowIcon(hWndSyntax, IconLib, -54)
    Gui Color, White

    Gui Add, Pic, x-2 y-2 w697 h51, % "HBITMAP:" . Gradient(697, 51)
    Gui Font, s12 cWhite, Segoe UI
    Gui Add, Text, x14 y12 w673 h25 +BackgroundTrans, Syntax Type
    ResetFont()

    Gui Add, Text, x14 y56 w673 h30, Select the syntax highlighting scheme of a programming language or document type to be applied to the current document.

    Gui Add, ListView, hWndg_hLvSyntax gLvSyntaxHandler x11 y93 w673 h256 -Multi +Checked +LV0x14000 +AltSubmit
    , Name|Loaded|Syntax|Keywords|Autocomplete|Lexer|File Extension
    LV_ModifyColEx(270, 52, 50, 63, 90, "39 Integer")
    Gui Add, CheckBox, vChkDefSyntax x11 y356 w673 h23, &Set as default syntax for newly created documents

    Gui Add, Text, x-1 y386 w697 h50 -Background +Border
    Gui Add, Button, gSyntaxDlgReset x11 y399 w80 h23, &Reset
    Gui Add, Button, gSyntaxDlgSubmit vBtnSyntaxOK x434 y399 w80 h23 +Default, &OK
    Gui Add, Button, gSyntaxDlgSubmit vBtnSyntaxApply x520 y399 w80 h23, &Apply
    Gui Add, Button, gSyntaxDlgClose x606 y399 w80 h23, &Close

    IconCheck := g_NT6orLater ? " ✔" : " ●"

    GuiControl -Redraw, %g_hLvSyntax%
    For Key, LexType in g_oLexTypes {
        Syntax := Keywords := AutoC := Loaded := ""

        ThemeFile := A_ScriptDir . "\Themes\Specifics\" . LexType.Name . ".xml"
        oXML := LoadXML(ThemeFile)
        If (oXML.url != "") {
            If (g_oColors[Key].Loaded) {
                Loaded := IconCheck
            }

            Try {
                Syntax := oXML.selectNodes("/scheme/theme[1]").length() ? IconCheck : ""
                oGroup := oXML.selectSingleNode("/scheme/keywords/language[@id='" . Key . "']/group[1]")
                Keywords := (oGroup.getAttribute("keywords") != "" ? IconCheck : "")
            }
        }

        AutoCFile := g_AutoCDir . "\" . LexType.Name . ".ac"
        oXML := LoadXML(AutoCFile)
        If (oXML.url != "") {
            Try {
                AutoC := oXML.selectNodes("/AutoComplete/language[@id='" . Key . "']").length() ? IconCheck : ""
            }
        }

        Checked := RegExMatch(LexTypes, "\b" . Key . "\b") ? "Check" : ""

        LV_Add(Checked, LexType.DN, Loaded, Syntax, Keywords, AutoC, LexType.Lexer, LexType.Ext)
    }

    Gui Show, w695 h435, Available Lexers for Syntax Highlighting

    SetExplorerTheme(g_hLvSyntax)
    LV_ModifyCol(1, "Sort")
    GuiControl +Redraw, %g_hLvSyntax%
    LV_ModifyCol(7, "AutoHdr")
}

SyntaxDlgSubmit(hWnd, Event) {
    Local CtlName, OK, Row, Name, LexType, n, LexTypes

    SetListView("SyntaxDlg", g_hLvSyntax)
    Gui Submit, NoHide

    GuiControlGet, CtlName, Name, %hWnd%
    OK := (CtlName == "BtnSyntaxOK") ? 1 : 0

    Row := LV_GetNext()
    ; Change current LexType
    If (Row) {
        LV_GetText(Name, Row)
        LexType := GetLexTypeByDisplayName(Name)

        n := TabEx.GetSel()
        If (LexType != Sci[n].Type) {
            SetLexType(n, Name)
        }

        ; Default syntax type for new documents
        If (ChkDefSyntax) {
            g_DefLexType := LexType
        }
    }

    If (!OK) { ; Apply or double-click on LV item
        If (hWnd == g_hLvSyntax) {
            SyntaxDlgClose()
        }
        Return
    }

    ; Redefine Syntax menu
    LexTypes := ""
    Row := 0
    While (Row := LV_GetNext(Row, "Checked")) {
        LV_GetText(Name, Row, 1)
        LexTypes .= GetLexTypeByDisplayName(Name) . "|"
    }

    g_LexTypes := StrReplace(LexTypes, "|TXT|", "|")

    Menu MenuLexer, DeleteAll
    Menu MenuLexer, Add, Text File, M_SetLexType, Radio
    Menu MenuLexer, Add
    LoadSyntaxMenu(g_LexTypes)

    SyntaxDlgClose()
}

SyntaxDlgClose() {
    SyntaxDlgEscape:
    Gui SyntaxDlg: Destroy
    Return
}

SyntaxDlgReset() {
    Local LexTypes, aLexers, Name, LexType

    LexTypes := "TXT|AHK|AU3|BAT|C|CPP|CS|CSS|HTML|INI|JAVA|JS|JSON|MAKE|PAS|PL|PHP|PS1|PY|RB|SQL|VB|VBS|XML"
    aLexers := StrSplit(LexTypes, "|")

    LV_Modify(0, "-Check")
    Loop % LV_GetCount() {
        LV_GetText(Name, A_Index)
        LexType := GetLexTypeByDisplayName(Name)
        If (IndexOf(aLexers, LexType)) {
            LV_Modify(A_Index, "Check")
        }
    }

    g_DefLexType := "TXT"
}

UnloadStyles() {
    Local Item
    For Item in g_oLexTypes {
        g_oColors[Item].Loaded := False
        g_oColors[Item].Values := []
    }
}

OnCalltipClick(n, HitTestValue, Pos) {
    Local Arrow, WordStartPos

    ; The hit test value field is set to 1 if the click is in an up arrow, 2 if in a down arrow, and 0 if elsewhere.
    If (HitTestValue == 0) {
        InsertCalltip()
        Return
    }

    If (HitTestValue == 1) {
        g_CalltipParamsIndex--
    } Else {
        g_CalltipParamsIndex++
    }

    If ((HitTestValue == 1 && g_CalltipParamsIndex > 1) || (g_CalltipParams.Length() == g_CalltipParamsIndex)) {
        Arrow := 1 ; Up arrow
    } Else {
        Arrow := 2 ; Down arrow
    }

    WordStartPos := Sci[n].WordStartPosition(Pos - 1, True)

    Sci[n].CalltipShow(WordStartPos, Chr(Arrow) . g_CalltipParams[g_CalltipParamsIndex], 1)
}

OnMarginClick(n, Margin, Pos) {
    Local Line, Marker

    Line := Sci[n].LineFromPosition(Pos)

    If (Margin == g_MarginSymbols) {
        If (Sci[n].MarkerGet(Line) & (1 << g_MarkerError)) {
            Sci[n].MarkerDelete(Line, g_MarkerError)

        } Else {
            If (GetKeyState("Shift", "P")) {
                Marker := g_MarkerError
            } Else {
                Marker := g_DbgStatus ? g_MarkerBreakpoint : g_MarkerBookmark
            }
            ToggleBookmark(Marker, Line)
        }

    } Else If (Margin == g_MarginFolding) {
        Sci[n].ToggleFold(Line)
    }
}

AhkDebugCalltip(n, Pos) {
    Local WordPos, Word, aVars, Item, Value

    WordPos := GetCurrentWord(Word, Pos)

    aVars := [g_DbgLocalVariables, g_DbgGlobalVariables]

    Loop % aVars.Length() {
        For Each, Item in aVars[A_Index] {

            If (Item.Name == Word) {
                If (Item.Type == "Object") {
                    Value := "(Object)"

                } Else If (InStr(Item.Type, "(", 1) || Item.Type == "Undefined") {
                    Value := Item.Type

                } Else {
                    Value := Item.Value
                }

                ShowCalltip(n, Word . " = " . Value, WordPos[1])
                Return 1
            }
        }
    }

    Return 0
}

SetAutoComplete(n) {
    Sci[n].AutoCSetIgnoreCase(True)
    Sci[n].AutoCSetMaxHeight(g_AutoCMaxItems)
    Sci[n].AutoCSetOrder(1) ; SC_ORDER_PERFORMSORT
    Sci[n].AutoCSetSeparator(124) ; '|', so that items may contain spaces.
}

PreloadAutoComplete(aTypes) {
    Loop % aTypes.Length() {
        LoadAutoComplete(aTypes[A_Index])
    }
}

LvSyntaxHandler(hWnd, Event, Info, Err := "") {
    Local Row := LV_GetNext()
    If (!Row) {
        Return
    }

    If (Event == "DoubleClick") {
        SyntaxDlgSubmit(hWnd, Event)

    } Else If (Event == "RightClick") {
        AddMenu("MenuLvSyntax", "Edit File", "M_ThemeFile", IconLib, -16)
        AddMenu("MenuLvSyntax", "Reload", "M_ThemeFile", IconLib, -10)
        SetMenuColor("MenuLvSyntax", g_MenuColor)
        Menu MenuLvSyntax, Show
    }
}

M_ThemeFile(MenuItem) {
    Local DN, Type, FullPath

    SetListView("SyntaxDlg", g_hLvSyntax)
    LV_GetText(DN, LV_GetNext(), 1)

    Type := GetLexTypeByDisplayName(DN)

    If (MenuItem == "Edit File") {
        FullPath := A_ScriptDir . "\Themes\Specifics\" . GetNameByLexType(Type) . ".xml"
        If (FileExist(FullPath)) {
            OpenFileEx(FullPath)
        }

    } Else If (MenuItem == "Reload") {
        ReloadThemeFile(Type)
    }
}

ReloadThemeFile(Type) {
    g_oColors[Type].Loaded := False
    g_oColors[Type] := {}
    g_oKeywords[Type] := {}
    g_oProps[Type] := {}

    Loop % Sci.Length() {
        If (Sci[A_Index].Type == Type) {
            Sci_Colour(A_Index, Type)
        }
    }
}

Sci_Colour(n, Type) {
    Sci_Config(n, Type)
    Sci[n].4003(0, -1) ; SCI_COLOURISE
}

ToggleIndentGuides() {
    g_IndentGuides := !g_IndentGuides
    IndentView := g_IndentGuides ? 3 : 0 ; 3 = SC_IV_LOOKBOTH

    Loop % Sci.Length() {
        Sci[A_Index].SetIndentationGuides(IndentView)
    }
}

ShowUserListDialog() {
    Global

    Gui UserList: New, +LabelUserList +hWndhWndUserList -MinimizeBox +OwnerMain
    SetWindowIcon(hWndUserList, IconLib, -95)
    Gui Color, White

    Gui Add, Pic, x0 y0 w503 h48, % "HBITMAP:" . Gradient(503, 48)
    Gui Font, s12 cWhite, Segoe UI
    Gui Add, Text, x14 y12 w673 h25 +BackgroundTrans, User Dictionaries
    ResetFont()

    Gui Add, ListView, hWndhLvUserLists vLvUserLists x-1 y48 w505 h157 +LV0x14000 -Hdr, _
    SetExplorerTheme(hLvUserLists)

    Gui Add, Text, x-1 y204 w505 h48 +0x200 +Border -Background
    Gui Add, Button, gM_LoadUserList x319 y216 w84 h24 +Default, &Load
    Gui Add, Button, gUserListEscape x411 y216 w84 h24, &Close

    Gui Show, w503 h251, Load Dictionary

    Loop Files, %g_AutoCDir%\*.ud
    {
        LV_Add("", A_LoopFileName)
    }
}

UserListClose() {
    UserListEscape:
    Gui UserList: Destroy
    Return
}

M_LoadUserList() {
    SetListView("UserList", "LvUserLists")
    If (Row := LV_GetNext()) {
        LV_GetText(UserList, Row)
        LoadUserList(UserList)
    }
    UserListClose()
}

AddToRecentFilesEx(FullPath) {
    AddToRecentFiles(FullPath)

    If (g_ShellRecent) {
        DllCall("Shell32.dll\SHAddToRecentDocs", "UInt", 3, "WStr", FullPath) ; SHARD_PATHW
    }
}
