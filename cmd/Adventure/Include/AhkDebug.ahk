; https://xdebug.org/docs-dbgp.php

DebuggerInit() {
    DBGp_OnBegin("DebuggerConnected")
    DBGp_OnBreak("DebuggerBreak")
    DBGp_OnStream("DebuggerStream")
    DBGp_OnEnd("DebuggerDisconnected")

    g_DbgSocket := DBGp_StartListening("127.0.0.1", g_DebugPort)
}

DebuggerConnected(Session) {
    ;MsgBox % "Connected to " . Session.File

    ; Error stream
    Session.stderr("-c " . g_DbgCaptureStderr) ; 0 - disable, 1 - copy data, 2 - redirection

    ;Session.stdout("-c 2") ; ?

    g_DbgSession := Session
    g_DbgSession.property_set("-n A_LastError -- 0")

    g_DbgStatus := 1

    Debug_SetBreakpoints()

    Debug_UpdateGUI(True, "Connected to " . Session.File, "Connected")

    ; Step onto the first line.
    Session.step_into()
}

; DebuggerBreak is called whenever the debugger breaks, such
; as when step_into has completed or a breakpoint has been hit.
DebuggerBreak(Session, ByRef Response) {
    Local LineNo, FileURI, FullPath, n

    If (!InStr(Response, "status=""break""")) {
        Return
    }

    ; Get the current context; i.e. file and line.
    Session.stack_get("-d 0", Response)

    ; Retrieve the line number and file URI.
    RegExMatch(Response, "lineno=""\K\d+", LineNo)
    RegExMatch(Response, "filename=""\K.*?(?="")", FileURI)

    FullPath := DBGp_DecodeFileURI(FileURI)
    If (FullPath == "") {
        Return
    }

    g_DbgSession.CurrentFile := FullPath

    n := TabEx.GetSel()
    If (Sci[n].FullName != FullPath) {
        n := GoToFile(FullPath)
    }

    RemoveStepMarker()
    Sci[n].MarkerAdd(LineNo - 1, g_MarkerDebugStep)
    Sci[n].GoToLine(LineNo - 1)
    GoToLineEx(n, LineNo - 1)

    ; Variables
    Debug_GetContext()

    ; Call Stack
    Session.stack_get("", g_DbgStack := "")
    g_DbgStack := LoadXMLData(g_DbgStack)

    If (g_ReloadVarListOnBreak && IsWindow(g_hWndDbg)) {
        Debug_ReloadVariables()
        Debug_ShowCallStack()        
    }

    g_DbgStatus := 2

    Gui Debug: Default
    SB_SetText("Line " . LineNo . " of file " . FullPath)
}

DebuggerStream(Session, ByRef Packet) { ; OutputDebug was called.
    Local StdErr, Time

    If (RegExMatch(Packet, "(?<=<stream type=""stderr"">).*(?=</stream>)", StdErr)) {
        StdErr := DBGp_Base64UTF8Decode(StdErr)

        FormatTime Time, %A_Now%, HH:mm:ss

        SetListView("Debug", g_hLvErrorStream)
        LV_Add("", LV_GetCount() + 1, Time . "." . A_MSec, StdErr)
        LV_ModifyCol(3, "AutoHdr")

        SendMessage 0x115, 7, 0,, ahk_id %g_hLvErrorStream% ; WM_VSCROLL, SB_BOTTOM (autoscroll)
    }
}

DebuggerDisconnected(Session) {
    ;MsgBox % "Disconnected from " . Session.File

    g_DbgStatus := 0
    g_AttachDebugger := False

    DBGp_StopListening(g_DbgSocket)

    Debug_UpdateGUI(False, "Disconnected from " . Session.File, "Disconnected")

    Loop % g_aBreakpoints.Length() {
        g_DbgSession.breakpoint_remove("-d " . g_aBreakpoints[A_Index].ID)
    }
}

M_Debug_Start() {
    If (Sci[TabEx.GetSel()].Type != "AHK") {
        Return
    }

    Debug_ShowWindow()
    Debug_Start()
}

Debug_Start(AhkPath := "") {
    Local foDebugRun

    If (Sci[TabEx.GetSel()].Type != "AHK") {
        ErrorMsgBox("Debugging is available for AutoHotkey scripts only.", "Debug")
        Return
    }

    If (g_DbgStatus == 0) {
        If (AhkPath != "") {
            foDebugRun := Func("Debug_Run").Bind(AhkPath)
            SetTimer, %foDebugRun%, -1

        } Else {
            SetTimer, Debug_Run, -1 ; RunWait
        }
    } Else {
        Debug_Continue()
    }
}

; Start debugging
Debug_Run(AhkPath := "") {
    Local n, AhkScript, Params, WorkingDir

    n := TabEx.GetSel()

    If (Sci[n].GetModify() && !SaveFile(n)) {
        Return
    }

    AhkPath := (AhkPath == "") ? GetAhkPath() : AhkPath
    AhkScript := Sci[n].FullName
    Params := Sci[n].Parameters
    WorkingDir := GetFileDir(AhkScript)

    If (!FileExist(AhkPath) || !FileExist(AhkScript)) {
        Return
    }

    DebuggerInit()
    RemoveStepMarker()

    If (g_CaptureStdErr) {
        AhkRunGetStdErr(n, AhkPath, AhkScript, Params, WorkingDir, "/Debug=127.0.0.1:" . g_DebugPort)

    } Else {
        RunWait "%AhkPath%" /debug=127.0.0.1:%g_DebugPort% "%AhkScript%" %Params%, %WorkingDir%, UseErrorLevel
        If (ErrorLevel) {
            Debug_Error()
        }
    }
}

Debug_Error() {
    Debug_Stop()
    DBGp_StopListening(g_DbgSocket)
    Debug_UpdateGUI(g_DbgStatus := 0, "Error", "An error occurred.")
}

Debug_Continue() {
    g_DbgSession.run()
}

Debug_Pause() {
    g_DbgSession.break()
}

Debug_StepInto() {
    g_DbgSession.step_into()
}

Debug_StepOver() {
    g_DbgSession.step_over()
}

Debug_StepOut() {
    g_DbgSession.step_out()
}

Debug_Stop() {
    If (g_AttachDebugger) {
        g_DbgSession.detach()
    } Else {
        g_DbgSession.stop()
    }

    g_DbgSession.close()
}

Debug_GetContext() {
    Local XmlLocal, oXmlLocal, oLocalNodes, XmlGlobal, oXmlGlobal, oGlobalNodes

    ; Local variables
    g_DbgSession.context_get("-c 0", XmlLocal)
    oXmlLocal := LoadXMLData(XmlLocal)
    oLocalNodes := oXmlLocal.getElementsByTagName("property")
    Debug_GetVariables(oLocalNodes, g_DbgLocalVariables)

    ; Global variables
    g_DbgSession.context_get("-c 1", XmlGlobal)
    oXmlGlobal := LoadXMLData(XmlGlobal)
    oGlobalNodes := oXmlGlobal.getElementsByTagName("property")
    Debug_GetVariables(oGlobalNodes, g_DbgGlobalVariables)
}

Debug_GetVariables(oXmlNodes, ByRef aVariables) {
    Local oNode, Name, Type, Value, ClassName, Facet
    aVariables := []

    For oNode in oXmlNodes {
        Name := oNode.getAttribute("fullname")

        StringUpper Type, % oNode.getAttribute("type"), T

        Value := (Type == "Object") ? "" : DBGp_Base64UTF8Decode(oNode.text)

        ClassName := oNode.getAttribute("classname")
        If (ClassName != "" && ClassName != "Object") {
            Type := Type . " (" . ClassName . ")"
        }

        Facet := oNode.getAttribute("facet")

        aVariables.Push({"Name": Name, "Value": Value, "Type": Type, "Facet": Facet})
    }
}

Debug_ShowVariables() { ; M
    Local Pos, SearchFunc, Variables, i, Scope, Each, Item, Icon, Row

    SetListView("Debug", g_hLvVariables)
    Gui Submit, NoHide

    Pos := DllCall("GetScrollPos", "Ptr", g_hLvVariables, "Int", 1) ; SB_VERT

    SearchFunc := ChkVarRegExp ? "RegExMatch" : "InStr"

    LV_Delete()
    GuiControl -Redraw, %g_hLvVariables%

    Variables := [g_DbgLocalVariables, g_DbgGlobalVariables]
    Loop % Variables.Length() {
        i := A_Index
        Scope := i == 1 ? "Local" : "Global"
        For Each, Item in Variables[i] {
            If (!g_ShowReservedClassMembers && RegExMatch(Item.Name, "\.(base|Name|__Class|__Init)")) {
                Continue
            }

            If (!g_ShowIndexedVariables && InStr(Item.Name, "[")) {
                Continue
            }

            If (!g_ShowObjectMembers && InStr(Item.Name, ".")) {
                Continue
            }

            If ((ChkVarName && %SearchFunc%(Item.Name, EdtVarSearch))
            || (ChkVarValue && %SearchFunc%(Item.Value, EdtVarSearch))) {
                Icon := "Icon" . Debug_GetVarTypeIcon(Item.Name, Item.Type, Item.Facet)
                Row := LV_Add(Icon, Item.Name, Item.Value, Item.Type, Scope)
                LV_SetGroup(g_hLvVariables, Row, i)
            }
        }
    }

    GuiControl +Redraw, %g_hLvVariables%
    ;DllCall("SetScrollPos", "Ptr", g_hLvVariables, "Int", 1, "Int", Pos, "Int", 0)
    SendMessage 0x1014, 0, %Pos%,, ahk_id %g_hLvVariables% ; LVM_SCROLL (XP? WM_VSCROLL?)
}

Debug_ReloadVariables() {
    Debug_GetContext()
    Debug_ShowVariables()
}

Debug_GetVarTypeIcon(VarName, VarType, VarFacet) {
    If (SubStr(VarType, 9, 5) == "Class") { ; Object (Class)
        Return 7
    } Else If (InStr(VarType, "(File", 1)) { ; FileObject
        Return 6
    } Else If (InStr(VarType, "Func", 1)) { ; Func or BoundFunc
        Return 5
    } Else If (SubStr(VarType, 1, 1) == "O") { ; Object
        Return 3
    } Else If (VarName ~= "\.|\[") { ; Object member or indexed variable
        Return 4
    } Else If (VarFacet == "Builtin" || VarName ~= "i)^(Clipboard|ClipboardAll|ErrorLevel|\d+)$") {
        Return 2
    } Else {
        Return 1
    }
}

Debug_EditVar() {
    Local Row, VarName, VarValue, Context, Scope, ExStyle, NewValue, Response

    SetListView("Debug", g_hLvVariables)
    Row := LV_GetNext()
    If (!Row) {
        Return
    }

    LV_GetText(VarName, Row)
    LV_GetText(VarValue, Row, 2)

    If (g_NT6orLater) {
        Context := LV_GetGroupId(g_hLvVariables, Row) - 1 ; 0 = local, 1 = global
    } Else {
        LV_GetText(Scope, Row, 4)
        Context := (Scope == "Local") ? 0 : 1
    }

    If (VarName = "A_LastError") {
        MessageBox(g_hWndDbg, GetErrorMessage(VarValue+0), "A_LastError: " . VarValue, 0)
        Return
    }

    If (Debug_IsBuiltInVar(VarName)) {
        MessageBox(g_hWndDbg, """%VarName%"" is a READ-ONLY built-in variable.", "Modify Variable", 0x10)
        Return
    }

    WinGet ExStyle, ExStyle, ahk_id %g_hWndDbg%

    NewValue := InputBoxEx("Modify Variable", "Enter the new value for the variable """ . VarName . """:"
    , "Variables", VarValue, "", "", g_hWndDbg, "", "", IconLib, -78, ExStyle & 0x8 ? "AlwaysOnTop" : "")

    If (!ErrorLevel) {
        NewValue := DBGp_Base64UTF8Encode(NewValue)

        g_DbgSession.property_set("-c " . Context . " -n " . VarName . " -- " . NewValue, Response)

        If (RegExMatch(Response, "success=""\K\d")) {
            Debug_ReloadVariables()
            LV_Modify(Row, "Select")

        } Else {
            MessageBox(g_hWndDbg, "The value of the variable """
            . VarName . """ could not be changed.", "Debug", 16)
        }
    }
}

Debug_IsBuiltInVar(VarName) {
    Local Each, Item

    If (VarName = "Clipboard") {
        Return 0
    }

    For Each, Item in g_DbgGlobalVariables {
        If (VarName = Item.Name && Item.Facet == "Builtin") {
            Return 1
        }
    }

    Return VarName = "ClipboardAll" ? 1 : 0
}

Debug_ShowCallStack() {
    Local oFilename, oLineNo, oWhere, i, Filename, ShortName

    oFilename := g_DbgStack.selectNodes("/response/stack/@filename")
    oLineNo   := g_DbgStack.selectNodes("/response/stack/@lineno")
    oWhere    := g_DbgStack.selectNodes("/response/stack/@where")

    SetListView("Debug", g_hLvCallStack)
    LV_Delete()

    Loop % oWhere.Length() {
        i := A_Index - 1

        Filename := DBGp_DecodeFileURI(oFilename.item[i].text)
        SplitPath Filename, ShortName

        LV_Add("", ShortName, oLineNo.item[i].text, oWhere.item[i].text)
    }
    LV_ModifyCol(3, "AutoHdr")
}

ToggleBreakpoint() {
    Local n := TabEx.GetSel()
    Local Line := Sci[n].LineFromPosition(Sci[n].GetCurrentPos())

    If (Sci[n].MarkerGet(Line) & (1 << g_MarkerBreakpoint)) {
        Sci[n].MarkerDelete(Line, g_MarkerBreakpoint)
        RemoveBreakpoint(Sci[n].FullName, Line + 1)

    } Else {
        Sci[n].MarkerAdd(Line, g_MarkerBreakpoint)
        AddBreakpoint(Sci[n].FullName, Line + 1)
    }

    Debug_ListBreakpoints()
}

AddBreakpoint(File, Line) {
    Local URI, Response, ID

    If (g_DbgStatus) {
        URI := DBGp_EncodeFileURI(File)
        g_DbgSession.breakpoint_set("-t line -n " . Line . " -f " . URI, Response)

        If (RegExMatch(Response, " id=""\K\d+", ID)) {
            g_aBreakpoints.Push({"File": File, "Line": Line, "ID": ID})
        }
    }
}

RemoveBreakpoint(File, Line) {
    If (g_DbgStatus) {
        Loop % g_aBreakpoints.Length() {
            If (g_aBreakpoints[A_Index].File == File && g_aBreakpoints[A_Index].Line == Line) {
                g_DbgSession.breakpoint_remove("-d " . g_aBreakpoints[A_Index].ID)
                Break
            }
        }
    }
}

; Define breakpoint markers as real breakpoints (called from DebuggerConnected)
Debug_SetBreakpoints() {
    Local Line := 0, i

    Loop % Sci.Length() {
        i := A_Index

        If (Sci[i].FullName == "") {
            Continue
        }

        Loop {
            Line := Sci[i].MarkerNext(Line, (1 << g_MarkerBreakpoint)) + 1
            If (Line) {
                AddBreakpoint(Sci[i].FullName, Line)
            }
        } Until (!Line)
    }

    Debug_ListBreakpoints()
}

DeleteBreakpoints() {
    Loop % Sci.Length() {
        Sci[A_Index].MarkerDeleteAll(g_MarkerBreakpoint)
    }

    Loop % g_aBreakpoints.Length() {
        g_DbgSession.breakpoint_remove("-d " . g_aBreakpoints[A_Index].ID)
    }

    Debug_ListBreakpoints()
}

RemoveStepMarker() {
    Loop % Sci.Length() {
        Sci[A_Index].MarkerDeleteAll(g_MarkerDebugStep)
    }
}

Debug_ListRunningScripts() {
    Local Scripts, hWnd, Title, Filename, FilePath, FileExt, PID

    SetListView("Debug", g_hLvDbgAttach)
    LV_Delete()

    ; Get the list of running scripts (adapted from DebugVars)
    WinGet Scripts, List, ahk_class AutoHotkey
    Loop % Scripts {
        hWnd := Scripts%A_Index%
        If (hWnd == A_ScriptHwnd) {
            Continue
        }

        PostMessage 0x44, 0, 0,, ahk_id %hWnd% ; WM_COMMNOTIFY, WM_NULL
        If (ErrorLevel) { ; Likely blocked by UIPI (won't be able to attach).
            Continue
        }

        WinGetTitle Title, ahk_id %hWnd%
        Title := RegExReplace(Title, " - AutoHotkey v\S*$")
        SplitPath Title, Filename, FilePath, FileExt
        If (IsAhkFileExt(FileExt)) {
            WinGet PID, PID, ahk_id %hWnd%
            LV_Add("", Filename, FilePath, PID)
        }
    }
}

AttachDebugger() { ; M
    Local Row, Filename, Path, PID, AttachMsg, IP, FullPath

    SetListView("Debug", g_hLvDbgAttach)
    Row := LV_GetNext()
    If (Row) {
        LV_GetText(Filename, Row, 1)
        LV_GetText(Path, Row, 2)
        LV_GetText(PID, Row, 3)

        Process Exist, %PID%
        If (!ErrorLevel) {
            ErrorMsgBox("A process with PID " . PID . " no longer exists.", "Debug")
            Return
        }

        FullPath := Path . "\" . Filename

        If (g_DbgStatus) {
            If (MessageBox(g_hWndDbg, "Detach current script from debugger?", "Debugger", 0x31) == 1) { ; IDOK
                Debug_Stop()
            }

            If (FullPath == g_DbgSession.File) {
                Return
            }
        }

        DebuggerInit()

        AttachMsg := DllCall("RegisterWindowMessage", "Str", "AHK_ATTACH_DEBUGGER")
        IP := DllCall("ws2_32\inet_addr", "AStr", "127.0.0.1")
        PostMessage %AttachMsg%, %IP%, %g_DebugPort%,, ahk_pid %PID% ahk_class AutoHotkey

        GoToFile(FullPath)

        g_AttachDebugger := True
    }
}

Debug_UpdateGUI(bActive, TitleBarText, StatusBarText) {
    Gui Debug: Default
    WinSetTitle ahk_id %g_hWndDbg%,, % "Debugger - " . TitleBarText
    Debug_UpdateBug()
    SB_SetText(StatusBarText)

    If (bActive) {
        Gui Main: Default
        SB_SetText("Debugging", g_SBP_FileType)
        SB_SetIcon(IconLib, -65, g_SBP_FileType)
    } Else {
        RemoveStepMarker()
        SB_UpdateFileDesc(TabEx.GetSel())
        SendMessage 0x40F, % g_SBP_FileType - 1, 0,, ahk_id %g_hStatusBar% ; SB_SETICON
    }
}

Debug_UpdateBug() {
    GuiControl Debug:, PicBug, % A_ScriptDir . "\Icons\Bug" . (g_DbgStatus ? "Red" : "Blue") . ".png"
}

Debug_ShowWindow() {
    Local hIL1, Buttons, TbOpts, TbSize, hTbDbg, oTab, hIL2, LV_Options, Columns, hIL3, SliderOptions

    If (IsWindow(g_hWndDbg)) {
        ShowWindow(g_hWndDbg)
        Debug_ReloadVariables()
        Return
    }

    Gui Debug: New, +hWndg_hWndDbg +LabelDebug_On +MinSize176x362 +AlwaysOnTop +Resize
    SetWindowIcon(g_hWndDbg, IconLib, -65)

    ; Header
    Gui Add, Pic, vGradDbg x0 y0 w824 h48, % "HBITMAP:" . Gradient(824, 48)
    Gui Font, s12 cWhite, Segoe UI
    Gui Add, Text, x12 y12 w300 h24 +BackgroundTrans, AutoHotkey Debugger
    Gui Add, Pic, vPicBug x786 y8 w32 h32 +BackgroundTrans
    Debug_UpdateBug()
    ResetFont()

    ; Toolbar ImageList
    hIL1 := IL_Create(13)
    IL_AddEx(hIL1, IconLib, -66, -68, -69, -72, -73, -74, -75, -76, -10, -34, -16)

    Buttons = 
    (LTrim
        Run / Continue (F5),,,, 2500
        Pause,,,, 2501
        Stop (F8),,,, 2502
        -
        Step Into (F6),,,, 2503
        Step Over (F7),,,, 2504
        Step Out (Shift + F6),,,, 2505
        -
        Toggle Breakpoint (F4),,,, 2506
        Delete All Breakpoints,,,, 2507
        -
        Reload List,,,, 2508
        Clear Error Stream,,,, 2509
        -
        Modify Variable,,,, 2512
    )
    ; Toolbar
    TbOpts := "Flat List Vertical ShowText NoDivider"
    TbSize := "x8 y56 w160 h360"
    hTbDbg := Toolbar_Create("Debug_OnToolbar", Buttons, hIL1, TbOpts,, TbSize,, 0)
    SendMessage 0x43B, 0, 160,, ahk_id %hTbDbg% ; TB_SETBUTTONWIDTH

    ; Tab Control
    Gui Add, Tab3, hWndg_hTabDbg gDebug_TabHandler x180 y56 w640 h429 +AltSubmit -Wrap
    SendMessage 0x1329, 0, % DPIScale(23) << 16,, ahk_id %g_hTabDbg% ; TCM_SETITEMSIZE
    GuiControl,, %g_hTabDbg%, Variables||Call Stack|Error Stream|Breakpoints|Attach|Options

    ; Tab Icons
    oTab := New GuiTabEx(g_hTabDbg)
    hIL2 := IL_Create(5)
    IL_AddEx(hIL2, IconLib, -78, -88, -89, -77, -70, -37)
    oTab.SetImageList(hIL2)
    Loop 6 {
        oTab.SetIcon(A_Index, A_Index)
    }
    SendMessage 0x132B, 0, 5 | (3 << 16),, ahk_id %g_hTabDbg% ; TCM_SETPADDING

    LV_Options := "x186 y88 w626 h389 +LV0x14000 +0x40"

    Gui Tab, 1 ; Variables
    Columns := g_NT6orLater ? "Name|Value|Type" : "Name|Value|Type|Scope"
    Gui Add, ListView, hWndg_hLvVariables gDebug_LvHandler x186 y88 w626 h360 +LV0x14000 +0x40, %Columns%
    g_NT6orLater ? LV_ModifyColEx(200, 270, 130) : LV_ModifyColEx(200, 200, 100, 100)

    Gui Add, Edit, hWndhEdtVarSearch vEdtVarSearch gDebug_ShowVariables x186 y454 w225 h23 +0x2000000
    DllCall("SendMessage", "Ptr", hEdtVarSearch, "UInt", 0x1501, "Ptr", 0, "WStr", "Search", "Ptr")

    Gui Add, Checkbox, vChkVarName gDebug_ShowVariables x420 y454 w70 h23 +Checked, &Name
    Gui Add, Checkbox, vChkVarValue gDebug_ShowVariables x500 y454 w70 h23 +Checked, &Value
    Gui Add, Checkbox, vChkVarRegExp gDebug_ShowVariables x580 y454 h23, &RegExp

    hIL3 := IL_Create(7, 0, 0)
    ; Variable, BIV, object, object member, function object, file object, COM object
    IL_AddEx(hIL3, IconLib, -79, -80, -81, -82, -85, -83, -84)
    LV_SetImageList(hIL3, 1)

    If (g_NT6orLater) {
        LV_InsertGroup(g_hLvVariables, 1, "Local Variables")
        LV_InsertGroup(g_hLvVariables, 2, "Global Variables")
        LV_EnableGroupView(g_hLvVariables)
    }

    Gui Tab, 2 ; Call Stack
    Gui Add, ListView, hWndg_hLvCallStack %LV_Options%, File|Line|Stack Entry
    LV_ModifyColEx(140, 45, "AutoHdr")

    Gui Tab, 3 ; Error Stream
    SetFont("Consolas", "s10")
    Gui Add, ListView, hWndg_hLvErrorStream %LV_Options%, #|Time|Debug Print
    ResetFont()
    LV_ModifyColEx(36, 112, "AutoHdr")

    Gui Tab, 4 ; Breakpoints
    Gui Add, ListView, hWndg_hLvBreakpoints gDebug_LvHandler %LV_Options%, Line|File
    LV_ModifyColEx(45, "AutoHdr")

    Gui Tab, 5 ; Attach
    Gui Add, Text, x188 y88 w622 h23 +0x200
    , Attach the debugger to a running script. The script will not be terminated when the debug session ends.
    Gui Add, ListView, hWndg_hLvDbgAttach gDebug_LvHandler x186 y117 w626 h330 +LV0x14000 +0x40, File|Path|PID
    LV_ModifyColEx(174, 387, "AutoHdr Integer Left")
    Gui Add, Button, vBtnAttach gAttachDebugger x726 y452 w84 h24, &Attach

    Gui Tab, 6 ; Options
    Gui Add, Text, x190 y92 w200 h23 +0x200, IPC connection port:
    Gui Add, Edit, vEdtDbgPort x310 y92 w60 h23 +Number
    Gui Add, UpDown, +Range1024-65535 +0x80, %g_DebugPort%
    Gui Add, Text, vSepDbg x188 y123 w624 +0x10 ; Separator

    Gui Add, Checkbox, vChkDbgAOT x192 y132 w500 h23 +Checked, Keep the window always on top
    Gui Add, Checkbox, vChkDbgRld xp yp+30 wp hp +Checked, Reload variables on every step
    Gui Add, Checkbox, vChkDbgIdx xp yp+30 wp hp +Checked, Show indexed variables
    Gui Add, Checkbox, vChkDbgMbr xp yp+30 wp hp +Checked, Show object members
    Gui Add, Checkbox, vChkDbgRsv xp yp+30 wp hp, Show reserved class members
    Gui Add, Checkbox, vChkDbgODS xp yp+30 wp hp +Checked, Capture OutputDebug string
    Gui Add, Text, xp yp+50 w100 hp +0x200, Transparency:
    SliderOptions := "+Range70-255 +Center +ToolTip +AltSubmit"
    Gui Add, Slider, xp+101 yp-8 w168 h40 vSldrTransp gDebug_SetTransparency %SliderOptions%, 255

    Gui Add, Button, vBtnDbgOptReset gDebug_ResetOptions x638 y452 w84 h24, &Reset
    Gui Add, Button, vBtnDbgOptApply gDebug_ApplyOptions xp+88 yp wp hp, &Apply

    Gui Debug: Tab

    For Each, hLV in [g_hLvVariables, g_hLvCallStack, g_hLvErrorStream, g_hLvBreakpoints, g_hLvDbgAttach] {
        SetExplorerTheme(hLV)
    }

    ; Search Icon
    Gui Add, Pic, hWndhPicVarSearch x202 y1 w16 h16 Icon-87, %IconLib%
    DllCall("SetParent", "Ptr", hPicVarSearch, "Ptr", hEdtVarSearch)
    WinSet Style, -0x40000000, ahk_id %hPicVarSearch% ; -WS_CHILD

    Gui Add, StatusBar,, Ready
    SB_SetIcon(IconLib, -94)

    Gui Color, 0xF1F5FB
    Gui Show, w824 h513, Debugger - Stopped

    If (g_DbgStatus) {
        ;Debug_GetContext()
        Debug_ShowVariables()
    }

    Debug_ListBreakpoints()
}

Debug_SetTransparency() {
    GuiControlGet TranspLevel, Debug:, SldrTransp
    WinSet Transparent, %TranspLevel%, ahk_id %g_hWndDbg%
}

Debug_OnToolbar(hWnd, Event, Text, Pos, ID) {
    Local TabIndex

    If (Event != "Click") {
        Return
    }

    GuiControlGet TabIndex,, %g_hTabDbg%

    If (ID == 2500) { ; Run / Continue
        Debug_Start()

    } Else If (ID == 2501) {
        Debug_Pause()

    } Else If (ID == 2502) {
        Debug_Stop()

    } Else If (ID == 2503) {
        Debug_StepInto()

    } Else If (ID == 2504) {
        Debug_StepOver()

    } Else If (ID == 2505) {
        Debug_StepOut()

    } Else If (ID == 2506) {
        ToggleBreakpoint()

    } Else If (ID == 2507) {
        DeleteBreakpoints()

    } Else If (ID == 2508) { ; Reload List

        If (TabIndex == 1) { ; Variables
            Debug_ReloadVariables()

        } Else If (TabIndex == 2) { ; Call Stack
            Debug_ShowCallStack()

        } Else If (TabIndex == 4) { ; Breakpoints
            Debug_ListBreakpoints()

        } Else If (TabIndex == 5) { ; Attach
            Debug_ListRunningScripts()
        }

    } Else If (ID == 2509) { ; Clear Error Stream
        SetListView("Debug", g_hLvErrorStream)
        LV_Delete()

    } Else If (ID == 2512) { ; Modify Variable
        If (TabIndex == 1) {
            Debug_EditVar()
        }
    }
}

Debug_TabHandler() {
    Local TabIndex

    GuiControlGet TabIndex,, %g_hTabDbg%
    If (TabIndex == 5) {
        Debug_ListRunningScripts()
    }
}

Debug_OnSize(hWnd, EventInfo, Width, Height) {
    If (EventInfo == SIZE_MINIMIZED) {
        Return
    }

    AutoSize("wh", g_hTabDbg)
    AutoSize("wht*", g_hLvVariables, g_hLvCallStack, g_hLvErrorStream, g_hLvBreakpoints, g_hLvDbgAttach)
    AutoSize("yt*", "EdtVarSearch", "ChkVarName", "ChkVarValue", "ChkVarRegExp")
    AutoSize("xyt*", "BtnAttach", "BtnDbgOptReset", "BtnDbgOptApply")
    AutoSize("w", "GradDbg", "SepDbg")
    AutoSize("x*", "PicBug")
    Sleep 10
}

Debug_OnClose() {
    Gui Debug: Hide
}

Debug_ResetOptions() {
    Gui Debug: Default
    GuiControl,, EdtDbgPort, 9001
    GuiControl,, ChkDbgAOT, 1
    GuiControl,, ChkDbgRld, 1
    GuiControl,, ChkDbgIdx, 1
    GuiControl,, ChkDbgMbr, 1
    GuiControl,, ChkDbgRsv, 0
    GuiControl,, ChkDbgODS, 1
}

Debug_ApplyOptions() {
    Global

    Gui Debug: Default
    Gui Submit, NoHide

    If (EdtDbgPort) {
        g_DebugPort := EdtDbgPort
    }

    WinSet AlwaysOnTop, %ChkDbgAOT%, ahk_id %g_hWndDbg%

    g_ReloadVarListOnBreak := ChkDbgRld ? 1 : 0
    g_ShowIndexedVariables := ChkDbgIdx ? 1 : 0
    g_ShowObjectMembers := ChkDbgMbr ? 1 : 0
    g_ShowReservedClassMembers := ChkDbgRsv ? 1 : 0
    g_DbgCaptureStderr := ChkDbgODS ? 1 : 0
    If (g_DbgStatus) {
        g_DbgSession.stderr("-c " . g_DbgCaptureStderr)        
    }

    Debug_ReloadVariables()
}

Debug_ListBreakpoints() {
    Local i, aLines, Each, Line

    If (!IsWindow(g_hWndDbg)) {
        Return
    }

    SetListView("Debug", g_hLvBreakpoints)
    LV_Delete()

    Loop % Sci.Length() {
        i := A_Index
        aLines := GetMarkedLines(i, 1 << g_MarkerBreakpoint)

        For Each, Line in aLines {
            LV_Add("", Line + 1, Sci[i].FullName)
        }
    }
}

Debug_LvHandler(hLV, Event, Row, Error := "") {
    If (Event != "DoubleClick") {
        Return
    }

    If (hLV == g_hLvVariables) {
        Debug_EditVar()

    } Else If (hLV == g_hLvBreakpoints) {
        Debug_GoToBreakpoint()

    } Else If (hLV == g_hLvDbgAttach) {
        AttachDebugger()
    }
}

Debug_OnContextMenu(hWnd, hCtl, EventInfo) {
    If (InStr(GetClassName(hCtl), "SysList")) {
        AddMenu("Debug_LvMenu", "&Copy", "Debug_LvCopy", IconLib, -22)
        AddMenu("Debug_LvMenu", "Select &All", "Debug_LvSelectAll", IconLib, -25)
        SetMenuColor("Debug_LvMenu", g_MenuColor)
        Menu Debug_LvMenu, Show
    }
}

Debug_LvCopy() {
    Local TabIndex, Row := 0, RowText, Output := "", Value

    Gui Debug: Default
    GuiControlGet TabIndex,, %g_hTabDbg%
    Gui ListView, SysListView32%TabIndex%

    While (Row := LV_GetNext(Row)) {
        RowText := ""
        Loop % LV_GetCount("Column") {
            LV_GetText(Value, Row, A_Index)
            RowText .= Value . "`t"
        }
        Output .= RTrim(RowText, "`t") . "`n"
    }
    Clipboard := RTrim(Output, "`n")
}

Debug_LvSelectAll() {
    Local TabIndex, LV
    Gui Debug: Default
    GuiControlGet TabIndex,, %g_hTabDbg%
    LV := "SysListView32" . TabIndex
    GuiControl Focus, %LV%
    Gui ListView, %LV%
    LV_Modify(0, "Select")
}

Debug_GoToBreakpoint() {
    Local Row, Line, File, n

    SetListView("Debug", g_hLvBreakpoints)
    Row := LV_GetNext()
    If (!Row) {
        Return
    }

    LV_GetText(Line, Row, 1)
    LV_GetText(File, Row, 2)

    If (n := GoToFile(File)) {
        GoToLineEx(n, Line - 1)
    }
}

OnWM_SIZING(wParam, lParam, msg, hWnd) {
    If (hWnd == g_hWndDbg) {
        GuiControl Debug: Choose, %g_hTabDbg%, 6 ; Last tab
    }
}
