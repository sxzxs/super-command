; Win32 Error Messages Lookup and Listing Tool

;@Ahk2Exe-Bin Unicode 32*
;@Ahk2Exe-SetMainIcon %A_ScriptDir%\..\..\Icons\ErrorView.ico
;@Ahk2Exe-AddResource %A_ScriptDir%\..\..\Icons\Search.ico, 300
;@Ahk2Exe-SetCompanyName AmberSoft
;@Ahk2Exe-SetDescription Win32 Error Messages Tool
;@Ahk2Exe-SetVersion 1.0.4

#SingleInstance Off
#NoEnv
#NoTrayIcon
SetWorkingDir %A_ScriptDir%
SetBatchLines -1
FileEncoding UTF-8

Global g_Version := "1.0.4"
     , g_MaxIndex := 18000
     , g_Total
     , g_aItems
     , g_hLV
     , g_hEdtSearch
     , g_hTxtCount
     , g_hEdtHidden
     , g_oVoice
     , g_MainIcon := A_ScriptDir . "\..\..\Icons\ErrorView.ico"

; Command line parameter for the redefinition of the maximum index
If (InStr(A_Args[1], "/max=")) {
    g_MaxIndex := StrSplit(A_Args[1], "=")[2]
}

SetMainIcon(g_MainIcon)
Gui Main: New, +LabelOn +Resize
Gui Color, 0xF1F5FB
Gui Font, s9, Segoe UI

; Main menu
Menu MenuFile, Add, &Save`tCtrl+S, SaveList
Menu MenuFile, Add
Menu MenuFile, Add, E&xit`tAlt+Q, OnClose
Menu MenuEdit, Add, &Copy`tCtrl+C, Copy
Menu MenuEdit, Add
Menu MenuEdit, Add, Select &All`tCtrl+A, SelectAll
Menu MenuMsg,  Add, Show in a Message Box`tEnter, ShowMsgBox
Menu MenuMsg,  Add
Menu MenuMsg,  Add, Speak`tCtrl+Space, Speak
If (A_PtrSize == 8) {
    Menu MenuMsg, Disable, Speak`tCtrl+Space
}
Menu MenuView, Add, Random &Balloon`tF2, RandomBalloon
Menu MenuView, Add
Menu MenuView, Add, &Reload`tF5, Reload
Menu MenuHelp, Add, &Online Reference`tF1, OnlineRef
Menu MenuHelp, Add
Menu MenuHelp, Add, &About, ShowAbout

Menu MenuBar, Add, &File,    :MenuFile
Menu MenuBar, Add, &Edit,    :MenuEdit
Menu MenuBar, Add, &Message, :MenuMsg
Menu MenuBar, Add, &View,    :MenuView
Menu MenuBar, Add, &Help,    :MenuHelp
Gui Menu, MenuBar
Menu MenuBar, Color, White

; Errors list
Gui Add, ListView, hWndg_hLV vLV gLvHandler x-1 y-1 w866 h448 +LV0x14000 +AltSubmit, ID|Message
LV_ModifyCol(1, "48 Integer")
LV_ModifyCol(2, 618)
DllCall("UxTheme.dll\SetWindowTheme", "Ptr", g_hLV, "WStr", "Explorer", "Ptr", 0)

Gui Add, Edit, hWndg_hEdtHidden x20 y20 w0 h0 -0x10000

; Search field
If (A_IsCompiled) {
    Gui Add, Picture, hWndhPic x207 y1 w16 h16 Icon-300, %A_ScriptName%
} Else {
    Gui Add, Picture, hWndhPic x207 y1 w16 h16, % A_ScriptDir . "\..\..\Icons\Search.ico"
}
Gui Add, Edit, hWndg_hEdtSearch vFilter gSearch x9 y457 w230 h23 +0x2000000 ; WS_CLIPCHILDREN
DllCall("SendMessage", "Ptr", g_hEdtSearch, "UInt", 0x1501, "Ptr", 1, "WStr", "Enter search here")
DllCall("SetParent", "Ptr", hPic, "Ptr", g_hEdtSearch)
WinSet Style, -0x40000000, ahk_id %hPic% ; -WS_CHILD
GuiControl Focus, %g_hEdtSearch%

Gui Add, Text, hWndg_hTxtCount x731 y457 w120 h23 +0x202, Loading Messages...

Gui Show, w864 h489, ErrorView - System Error Messages

LoadErrorMessages()

Menu ContextMenu, Add, Message Box, ShowMsgBox
Menu ContextMenu, Default, Message Box
Menu ContextMenu, Add
Menu ContextMenu, Add, &Copy`tCtrl+C, Copy
Menu ContextMenu, Add
Menu ContextMenu, Add, Select &All`tCtrl+A, SelectAll

Menu ContextMenu, Color, White

g_oVoice := ComObjCreate("SAPI.SpVoice")

Return ; End of the auto-execute section.

OnEscape() {
    Global Filter
    Gui Main: Default
    Gui Submit, NoHide

    If (g_oVoice.Status.RunningState == 2) { ; SRSEIsSpeaking
        g_oVoice.Speak(" ", 3) ; SVSFlagsAsync | SVSFPurgeBeforeSpeak
        Return
    }

    If (Filter != "") {
        GuiControl,, Filter
        Search()
    } Else {
        OnClose()
    }
}

OnClose() {
    ExitApp    
}

OnSize() {
    If (A_EventInfo == 1) {
        Return
    }

    AutoXYWH("wh", g_hLV)
    AutoXYWH("y",  g_hEdtSearch)
    AutoXYWH("xy", g_hTxtCount)

    LV_ModifyCol(2, A_GuiWidth - DPIScale(70))
}

DPIScale(x) {
    Return (x * A_ScreenDPI) // 96
}

Reload() {
    LV_Delete()
    LoadErrorMessages()
}

LoadErrorMessages() {
    Local i, Message

    g_Total := 0
    g_aItems := []

    Loop %g_MaxIndex% {
        i := A_Index - 1

        Message := GetErrorMessage(i)

        If (Message != "") {
            LV_Add("", i, Message)
            g_aItems.Push([i, Message])
        }
    }

    g_Total := g_aItems.Length()
    GuiControl,, %g_hTxtCount%, %g_Total% Items
}

GetErrorMessage(ErrorCode, LanguageId := 0) {
    Static FuncName := "FormatMessage" . (A_IsUnicode ? "W" : "A")
    Static FormatMessage := 0, hMod, Encoding := A_IsUnicode ? "UTF-16" : "CP0"

    Local Size, ErrorBuf, ErrorMsg

    If (!FormatMessage) {
        hMod := DllCall("GetModuleHandle", "Str", "Kernel32.dll", "Ptr")
        FormatMessage := DllCall("GetProcAddress", "Ptr", hMod, "AStr", FuncName, "Ptr")
    }

    Size := DllCall(FormatMessage
        ; FORMAT_MESSAGE_ALLOCATE_BUFFER | FORMAT_MESSAGE_FROM_SYSTEM | FORMAT_MESSAGE_IGNORE_INSERTS
        , "UInt", 0x1300
        , "Ptr",  0
        , "UInt", ErrorCode + 0
        , "UInt", LanguageId ; English: 0x409
        , "Ptr*", ErrorBuf
        , "UInt", 0
        , "Ptr",  0)

    If (!Size) {
        Return ""
    }

    ErrorMsg := StrGet(ErrorBuf, Size, Encoding)
    DllCall("Kernel32.dll\LocalFree", "Ptr", ErrorBuf)

    Return ErrorMsg
}

ShowMsgBox() {
    Local Row, ErrorCode, ErrorMsg

    Gui Main: Default
    Row := LV_GetNext()
    If (!Row) {
        Return
    }

    LV_GetText(ErrorCode, Row)
    LV_GetText(ErrorMsg, Row, 2)

    Gui Main: +OwnDialogs
    MsgBox 0, Error %ErrorCode%, %ErrorMsg%
}

LvHandler(hLV, Event, Info, ErrLevel := "") {
    If (Event == "RightClick" || Event == "K" && Info == 93) { ; AppsKey
        Menu ContextMenu, Show
        Return
    }

    If (Event == "DoubleClick") {
        ShowMsgBox()
        Return
    }
}

Search:
    Gui Submit, NoHide
    Search(Filter)
Return

Search(Filter := "") {
    Global

    If Filter is Integer
    {
        LV_Delete()
        Loop % g_aItems.Length() {
            If (g_aItems[A_Index][1] == Filter) {
                LV_Add("", g_aItems[A_Index][1], g_aItems[A_Index][2])
                GuiControl,, %g_hTxtCount%, 1 Item
                Break
            }
        }

        If (!LV_GetCount()) {
            ErrorMsg := GetErrorMessage(Filter + 0)
            If (ErrorMsg != "") {
                GuiControl,, %g_hTxtCount%
                Gui Main: +OwnDialogs
                MsgBox 0, Error %Filter%, %ErrorMsg%
            } Else {
                GuiControl,, %g_hTxtCount%, Not found
            }
        }

        Return
    }

    GuiControl -Redraw, %g_hLV%
    LV_Delete()

    g_Total := 0
    Loop % g_aItems.Length() {
        If (InStr(g_aItems[A_Index][1], Filter) || InStr(g_aItems[A_Index][2], Filter)) {
            LV_Add("", g_aItems[A_Index][1], g_aItems[A_Index][2])
            g_Total++
        }
    }

    GuiControl +Redraw, %g_hLV%
    LV_ModifyCol(1, 48)
    WinGetPos,,, GuiWidth
    LV_ModifyCol(2, GuiWidth - 84)

    GuiControl,, %g_hTxtCount%, % (g_Total == 0) ? "Not Found" : (g_Total == 1) ? "1 Item" : g_Total . " Items"
}

SaveList() {
    Local Output := "", ID, Message, oFile

    Gui Main: +OwnDialogs
    FileSelectFile SelectedFile, S16, Win32 Error Messages.txt, Save
    If (ErrorLevel) {
        Return
    }

    Loop % LV_GetCount() {
        LV_GetText(ID, A_Index)
        LV_GetText(Message, A_Index, 2)
        Output .= ID . "`t" . Message . "`r`n"
    }

    oFile := FileOpen(SelectedFile, "w", "UTF-8")
    oFile.Write(Output)
    oFile.Close()
}

GetFocus() {
    Return DllCall("GetFocus", "Ptr")
}

SelectAll() {
    Gui Main: Default

    hCtlFocus := GetFocus()
    GuiControlGet SearchText,, %g_hEdtSearch%

    If (hCtlFocus == g_hEdtSearch && SearchText != "") {
        ;Send ^A
        SendMessage 0xB1, 0, -1,, ahk_id %g_hEdtSearch% ; EM_SETSEL
    } Else {
        GuiControl Focus, %g_hLV%
        LV_Modify(0, "Select")
    }
}

Copy() {
    Local hCtlFocus, SearchText, Row := 0, Output := "", ID, Message

    Gui Main: Default

    hCtlFocus := GetFocus()
    GuiControlGet SearchText,, %g_hEdtSearch%

    If (hCtlFocus == g_hEdtSearch && SearchText != "") {
        Clipboard := SearchText

    } Else {
        ;ControlGet Selection, List, Selected, SysListView321 ; Truncates long messages
        While (Row := LV_GetNext(Row)) {
            LV_GetText(ID, Row)
            LV_GetText(Message, Row, 2)

            Output .= ID . "`t" . Message . "`n"
        }

        Clipboard := RTrim(Output, "`n")
    }
}

RandomBalloon() {
    Local Number, ErrorCode, ErrorMsg

    If (LV_GetCount() != g_aItems.Length()) {
        Search()
    }

    Random Number, 0, %g_Total%
    LV_GetText(ErrorCode, Number)
    LV_GetText(ErrorMsg, Number, 2)
    GuiControl -Redraw, %g_hLV%
    LV_Modify(g_Total, "Vis")
    LV_Modify(Number, "Vis Select")
    GuiControl +Redraw, %g_hLV%
    Edit_ShowBalloonTip(g_hEdtHidden, "Error " . ErrorCode, ErrorMsg, Number)
}

Edit_ShowBalloonTip(hEdit, Title, Text, Icon := 0) {
    NumPut(VarSetCapacity(EDITBALLOONTIP, 4 * A_PtrSize, 0), EDITBALLOONTIP)
    NumPut(A_IsUnicode ? &Title : UTF16(Title, T), EDITBALLOONTIP, A_PtrSize, "Ptr")
    NumPut(A_IsUnicode ? &Text : UTF16(Text, M), EDITBALLOONTIP, A_PtrSize * 2, "Ptr")
    NumPut(Icon, EDITBALLOONTIP, A_PtrSize * 3, "UInt")
    SendMessage 0x1503, 0, &EDITBALLOONTIP,, ahk_id %hEdit% ; EM_SHOWBALLOONTIP
    Return ErrorLevel
}

UTF16(String, ByRef Var) {
    VarSetCapacity(Var, StrPut(String, "UTF-16") * 2, 0)
    StrPut(String, &Var, "UTF-16")
    Return &Var
}

Speak() {
    Local hCtlFocus, FirstVis, Row, ErrorMsg

    If (A_PtrSize == 8) {
        Return
    }

    hCtlFocus := GetFocus()
    If (hCtlFocus != g_hEdtSearch) {
        SendMessage 0x1027, 0, 0,, ahk_id %g_hLV% ; LVM_GETTOPINDEX, index of the topmost visible item
        FirstVis := ErrorLevel != "FAIL" ? ErrorLevel : 1
        Row := LV_GetNext(FirstVis)
        If (!Row) {
            Return
        }

        LV_GetText(ErrorMsg, Row, 2)
        g_oVoice.Speak(ErrorMsg, 1) ; SVSFlagsAsync
    }
}

OnlineRef() {
    Try {
        Run https://docs.microsoft.com/en-us/windows/win32/debug/system-error-codes
    }
}

ShowAbout() {
    Gui Main: +Disabled
    Gui About: New, -SysMenu +OwnerMain
    Gui Color, White
    Gui Add, Picture, x15 y16 w32 h32, % A_IsCompiled ? A_ScriptName : g_MainIcon
    Gui Font, s12 c0x003399, Segoe UI
    Gui Add, Text, x56 y11 w120 h23 +0x200, ErrorView
    Gui Font, s9 cDefault, Segoe UI
    Gui Add, Text, x56 y34 w280 h18 +0x200, System Error Messages Lookup/Listing Tool v%g_Version%
    Gui Add, Text, x1 y72 w391 h48 -Background
    Gui Add, Button, gAboutGuiClose x299 y85 w80 h23 +Default, &OK
    Gui Font
    Gui Show, w392 h120, About
}

AboutGuiClose() {
    AboutGuiEscape:
    Gui Main: -Disabled
    Gui About: Destroy
    Return
}

SetMainIcon(IconRes, IconIndex := 1) {
    Try {
        Menu Tray, Icon, % A_IsCompiled ? A_ScriptName : IconRes, %IconIndex%
    }
}

#Include %A_ScriptDir%\..\..\Lib\AutoXYWH.ahk
