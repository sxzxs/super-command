; Sort Panel - A front-end for the Sort command.

; Script compiler directives
;@Ahk2Exe-SetMainIcon %A_ScriptDir%\..\..\Icons\Sort Panel.ico
;@Ahk2Exe-SetCompanyName AmberSoft
;@Ahk2Exe-SetDescription Text Sorting Tool
;@Ahk2Exe-SetVersion 1.0.0

#SingleInstance Force
#NoEnv
#NoTrayIcon
SetWorkingDir %A_ScriptDir%
SetBatchLines -1

Global g_AppName := "Sort Panel"
, g_Version := "1.0.0"
, g_hWndMain
, GuiW := 985
, GuiH := 508
, g_hGradBG
, g_hGradOptions
, g_hGrpInput, g_hGradInput, g_hTxtInput, g_hEdtInput
, g_hGrpOutput, g_hGradOutput, g_hTxtOutput, g_hEdtOutput
, g_hGrpBtns, g_hBtnSort, g_hBtnClear, g_hBtnCopy, g_hBtnCmp, g_hBtnSave, g_hBtnClose
, g_CharToken := Chr(0xC600)
, g_AhkHelpFile := A_ScriptDir . "\..\..\Help\AutoHotkey.chm"

; Icon from FatCow's "Farm-Fresh Web Icons": sort_columns.png
MainIcon := A_ScriptDir . "\..\..\Icons\Sort Panel.ico"
SetMainIcon(MainIcon)

Gui Main: New, +LabelOn +hWndg_hWndMain +Resize +MinSize950X386
Gui Color, White ; Background color for checkboxes

; Window background
Gui Add, Pic, hWndg_hGradBG x0 y0 w%GuiW% h%GuiH%, % "HBITMAP:" . Gradient([0xD8F3FF, 0xFFFFFF], GuiW, GuiH)

; Options
Gui Add, Text, x7 y7 w253 h325 +Border +0x6 ; SS_WHITERECT
Gui Add, Pic, hWndg_hGradOptions x9 y9 w250 h23, % "HBITMAP:" . Gradient([0xDDDDBB, 0x000000], 250, 23)
SetFont("Segoe UI", "s9 Bold cWhite")
Gui Add, Text, hWndhTxtOptions x9 y9 w250 h23 +0x200 +E0x200 +BackgroundTrans, % " Options"
SetFont("Segoe UI", "s9")
Gui Add, Text, x18 y39 w120 h23 +0x200, Delimiter:
Gui Add, ComboBox, vCbxDelim x141 y40 w100, $CRLF||$SPACE|$TAB|$CHAR
Gui Add, Text, x18 y73 w120 h23 +0x200, Start at position:
Gui Add, Edit, vEdtStartPos x141 y73 w100 h21 +Number
Gui Add, UpDown, +Range1-2147483647 +0x80, 1 ; UDS_NOTHOUSANDS
Gui Add, CheckBox, vChkCaseSensitive x17 y106 w220 h23, Case sensitive
Gui Add, CheckBox, vChkUserLocale x17 y138 w220 h23, User's locale case insensitive
Gui Add, CheckBox, vChkNumericSort x17 y170 w220 h23, Numeric sort
Gui Add, CheckBox, vChkReverseOrder x17 y202 w220 h23, Reverse order
Gui Add, CheckBox, vChkRandomOrder x17 y234 w220 h23, Random order
Gui Add, CheckBox, vChkRemoveDuplicates x17 y266 w220 h23, Remove duplicates
Gui Add, CheckBox, vChkFilenameOnly x17 y298 w220 h23, Filename sorting (ignore file path)

; Input
Gui Add, Pic, hWndg_hGradInput x268 y8 w350 h23, % "HBITMAP:" . Gradient([0x3FBBE3, 0x000000], 350, 23)
SetFont("Segoe UI", "s9 Bold cWhite")
Gui Add, Text, hWndg_hTxtInput x268 y8 w350 h23 +0x200 +E0x200 +BackgroundTrans, % " Input"
SetFont("Lucida Console", "s10")
Gui Add, Edit, hWndg_hEdtInput vEdtInput x269 y31 w348 h422 +Multi -E0x200
Gui Add, GroupBox, hWndg_hGrpInput x267 y1 w352 h455 -Theme

; Output
Gui Add, Pic, hWndg_hGradOutput x628 y8 w350 h23, % "HBITMAP:" . Gradient([0x92CC47, 0x000000], 350, 23)
SetFont("Segoe UI", "s9 Bold cWhite")
Gui Add, Text, hWndg_hTxtOutput x627 y8 w350 h23 +0x200 +E0x200 +BackgroundTrans, % " Output"
SetFont("Lucida Console", "s10")
Gui Add, Edit, hWndg_hEdtOutput vEdtOutput x628 y31 w348 h422 +Multi -E0x200
Gui Add, GroupBox, hWndg_hGrpOutput x626 y1 w352 h455 -Theme
ResetFont()

; Action buttons
Gui Add, Text,   hWndg_hGrpBtns x-1 y464 w987 h45 +Border -Background
Gui Add, Button, hWndg_hBtnSort gPerformSort x268 y475 w80 h23 +Default, SORT
Gui Add, Button, hWndg_hBtnClear gClearInput x354 y475 w80 h23, Clear
Gui Add, Button, hWndg_hBtnCopy gCopyOutput x628 y475 w80 h23, COPY
Gui Add, Button, hWndg_hBtnCmp gCompareInOut x712 y475 w80 h23, Compare
Gui Add, Button, hWndg_hBtnSave gSaveOutput x796 y475 w80 h23, Save
Gui Add, Button, hWndg_hBtnClose gOnClose x880 y475 w80 h23, Close

Gui Show, w%GuiW% h%GuiH%, %g_AppName%
GuiControl Focus, %g_hEdtInput%

; Additional message handling
OnMessage(0x100, "OnWM_KEYDOWN")
OnMessage(0x112, "OnWM_SYSCOMMAND")
OnMessage(0x232, "OnWM_EXITSIZEMOVE")

Return ; End of the auto-execute section.

OnClose() {
    OnEscape:
    ExitApp
    Return
}

OnDropFiles(hWnd, aFiles, hCtl, X, Y) {
    Local
    For Each, File in aFiles {
        oFile := FileOpen(File, "r")
        If (IsObject(oFile)) {
            Text := oFile.Read()
            oFile.Close()
            GuiControl,, EdtInput, %Text%
            Break
        }
    }
}

PerformSort() {
    Global
    Local Options, InOut

    Gui Main: Default
    Gui Submit, NoHide

    ConvertDelim(CbxDelim)

    Options := ""
    SetOption(Options, CbxDelim != "", "D" . CbxDelim)      ; Delimiter
    SetOption(Options, EdtStartPos != 1, "P" . EdtStartPos) ; Position n
    SetOption(Options, ChkCaseSensitive, "C")               ; Case sensitive
    SetOption(Options, ChkUserLocale, "CL")                 ; User's locale case insensitive
    SetOption(Options, ChkNumericSort, "N")                 ; Numeric sort
    SetOption(Options, ChkReverseOrder, "R")                ; Reverse order
    SetOption(Options, ChkRandomOrder, "Random")            ; Random order
    SetOption(Options, ChkRemoveDuplicates, "U")            ; Remove duplicates
    SetOption(Options, ChkFilenameOnly, "\")                ; Filename sorting (ignore file path)

    InOut := EdtInput

    If (CbxDelim != g_CharToken) {
        Sort InOut, %Options%
        ;ErrorLevel is changed by the Sort command only when the U option is in effect.
        If (ChkRemoveDuplicates) {
            ChangeTitle(ErrorLevel)
        }

    } Else {
        If (InStr(InOut, g_CharToken)) {
            Gui Main: +OwnDialogs
            MsgBox 0x10, Error, The character "%g_CharToken%" cannot be part of the input text.
            Return
        }

        InOut := RegExReplace(InOut, "(.)", "$1" . g_CharToken)
        Sort InOut, %Options%
        If (ChkRemoveDuplicates) {
            ChangeTitle(ErrorLevel)
        }

        InOut := StrReplace(InOut, g_CharToken)
    }

    GuiControl,, EdtOutput, %InOut%
}

ConvertDelim(ByRef Delim) {
    If (Delim == "$CRLF") {
        Delim := ""
    } Else If (Delim == "$SPACE") {
        Delim := " "
    } Else If (Delim == "$TAB") {
        Delim := "`t"
    } Else If (Delim == "$CHAR") {
        Delim := g_CharToken
    }
}

ChangeTitle(ErrLvl) {
    WinSetTitle ahk_id %g_hWndMain%,, % GetDuplicateCountMessage(ErrLvl)
    SetTimer ResetTitleBar, 5000
}

CopyOutput() {
    Global
    Gui Main: Default
    Gui Submit, NoHide

    If (EdtOutput != "") {
        Clipboard := EdtOutput
        InfoMsgBox("Output copied to the clipboard.", g_AppName)
    }
}

CompareInOut() {
    Global
    Local Title := "Input-Output Comparisson"

    Gui Main: Default
    Gui Submit, NoHide

    If (Trim(EdtInput) != Trim(EdtOutput)) {
        InfoMsgBox("Input and output data are NOT EQUAL.", Title)
    } Else {
        InfoMsgBox("Nothing changed. Input and output data are EQUAL.", Title)
    }
}

InfoMsgBox(Message, Title) {
    Gui Main: +OwnDialogs
    MsgBox 0x40, %Title%, %Message%
}

ClearInput() {
    Global
    GuiControl,, EdtInput
    GuiControl Focus, EdtInput
}

SaveOutput() {
    Local
    Filename := "Sort Panel Output - " . A_Now . ".txt"

    Gui Main: +OwnDialogs
    FileSelectFile SelectedFile, S16, %Filename%, Save
    If (ErrorLevel) {
        Return
    }

    oFile := FileOpen(SelectedFile, "w `n", "UTF-8")
    If (IsObject(oFile)) {
        OutputText := GetOutputText()
        oFile.Write(OutputText)
        oFile.Close()
    }
}

SetFont(FontName, FontOptions) {
    Gui Font
    Gui Font, %FontOptions%, %FontName%
}

ResetFont() {
    Gui Font
    Gui Font, s9, Segoe UI
}

SetOption(ByRef Var, Condition, AppendString := "") {
    Var .= Condition ? AppendString . " " : ""
}

Gradient(aColors, Width, Height) {
    Return CreateGradient(DPIScale(Width), DPIScale(Height), 1, aColors)
}

DPIScale(x) {
    Return (x * A_ScreenDPI) // 96
}

SetMainIcon(IconRes, IconIndex := 1) {
    Try {
        Menu Tray, Icon, % A_IsCompiled ? A_ScriptName : IconRes, %IconIndex%
    }
}

OnSize() {
    AutoXYWH("w0.5 h*", g_hGrpInput)
    AutoXYWH("w0.5",  g_hGradInput)
    AutoXYWH("w0.5",  g_hTxtInput)
    AutoXYWH("w0.5 h", g_hEdtInput)

    AutoXYWH("x0.5 w0.5 h*", g_hGrpOutput)
    AutoXYWH("x0.5 w0.5", g_hGradOutput)
    AutoXYWH("x0.5 w0.5", g_hTxtOutput)
    AutoXYWH("x0.5 w0.5 h", g_hEdtOutput)

    AutoXYWH("wh", g_hGradBG)

    AutoXYWH("yw*", g_hGrpBtns)

    AutoXYWH("y", g_hBtnSort)
    AutoXYWH("y", g_hBtnClear)

    AutoXYWH("x0.5 y", g_hBtnCopy)
    AutoXYWH("x0.5 y", g_hBtnCmp)
    AutoXYWH("x0.5 y", g_hBtnSave)
    AutoXYWH("x0.5 y", g_hBtnClose)
}

OnWM_EXITSIZEMOVE(wParam, lParam, msg, hWnd) {
    WinSet Redraw,, ahk_id %g_hWndMain%
}

OnWM_SYSCOMMAND(wParam, lParam, msg, hWnd) {
    Static SC_MAXIMIZE := 0xF030, SC_RESTORE := 0xF120
    If (wParam == SC_MAXIMIZE || wParam == SC_RESTORE) {
        WinSet Redraw,, ahk_id %g_hWndMain%
    }
}

OnWM_KEYDOWN(wParam, lParam, msg, hWnd) {
    If (wParam == 0x70) { ; F1
        Try {
            If (GetKeyState("Shift", "P")) {
                Run https://www.autohotkey.com/docs/commands/Sort.htm
            } Else {
                Run HH mk:@MSITStore:%g_AhkHelpFile%::/docs/commands/Sort.htm
            }
        }
    } Else If (wParam >= 0x71 && wParam <= 0x73) {
        AddSampleData(SubStr(Format("{:X}", wParam), 0, 1))
    }
}

AddSampleData(Index := 1) {
    Local aText := []

    aText[1] :=
    (LTrim
	"3,000
	3000
	3.000
	1
	1.0
	0.5
	.5
	Übermensch
	Universal
	understandable
	#include
	C:\Windows\notepad.exe
	C:\Windows\System32\calc.exe
	32
	0x20"
    )

    aText[2] := ""
    aText[3] := ""

    GuiControl,, EdtInput, % aText[Index]
}

GetInputText() {
    Global
    Gui Main: Submit, NoHide
    Return %EdtInput%
}

GetOutputText() {
    Global
    Gui Main: Submit, NoHide
    Return %EdtOutput%
}

GetDuplicateCountMessage(nItems) {
    If (nItems != 0) {
        Msg := nItems . " duplicate item" . (nItems > 1 ? "s" : "") . " removed."

    } Else If (nItems == 0) {
        Msg := "No duplicate items."
    }

    Return g_AppName . " - " . Msg
}

ResetTitleBar() {
    WinSetTitle ahk_id %g_hWndMain%,, %g_AppName%
    SetTimer,, Off
}

#Include %A_ScriptDir%\..\..\Lib\AutoXYWH.ahk
#Include %A_ScriptDir%\..\..\Lib\CreateGradient.ahk
