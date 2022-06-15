; AutoTaskMan - AutoHotkey Scripts Manager
; Tested with AHK v1.1.33.02 Unicode 32/64-bit on Windows XP/7/10

; Credits
; -------
; tmplinshi - Basic functionality:
; https://autohotkey.com/boards/viewtopic.php?f=28&t=24222
; Lexicos - New Process Notifier:
; https://autohotkey.com/board/topic/56984-new-process-notifier/#entry358038
; Sean - Explorer Context Menu:
; https://autohotkey.com/board/topic/20376-invoking-directly-contextmenu-of-files-and-folders/

#SingleInstance Off
#NoEnv
SetBatchLines -1
SetWorkingDir %A_ScriptDir%
DetectHiddenWindows On
Menu Tray, Click, 1

Global g_AppName := "AutoTaskMan"
     , g_Version := "1.2.7"
     , g_AppData := A_AppData . "\AmberSoft\Adventure"
     , g_IniFile := GetIniFileLocation("AutoTaskMan.ini")

     , Commands := {"Reload Script": 65400
           , "Edit Script": 65401
           , "Suspend Hotkeys": 65404
           , "Pause Script": 65403
           , "Exit Script": 65405
           , "Recent Lines": 65406
           , "Variables": 65407
           , "Hotkeys": 65408
           , "Key history": 65409
           , "AHK User Manual": 65411}

     , g_hWndMain
     , g_hToolbar
     , g_hLV
     , g_hSB
     , g_ImageList
     , g_AlwaysOnTop
     , g_HideWhenMinimized
     , g_ConfirmAction
     , g_Notifications
     , g_RegEx := "(.:[^:]*\\([^\x22]+))"
     , g_ThousandSep

     , g_hWndShell := CreateShellMenuWindow()
     , g_pIContextMenu
     , g_pIContextMenu2
     , g_pIContextMenu3

     , IconLib := A_ScriptDir . "\..\..\Icons\AutoTaskMan.icl"
     , g_Tool_FiF := A_ScriptDir . "\..\Find in Files\Find in Files.ahk"
     , g_Tool_DefEdt := A_ScriptDir . "\..\Default Editor.ahk"
     , g_AhkHelpFile := A_ScriptDir . "\..\..\Help\AutoHotkey.chm"

     , g_AhkInfo := "AutoHotkey " . A_AhkVersion . " "
     . (A_IsUnicode ? "Unicode " : "ANSI ")
     . (A_PtrSize == 4 ? "32-bit" : "64-bit")

SetMainIcon(IconLib)

Gui 1: New, +hWndg_hWndMain +Resize, %g_AppName% - AutoHotkey Scripts Manager

; Main menu
AddMenu("ScriptMenu", "&Reload Script`tCtrl+R",, IconLib, -2)
Menu ScriptMenu, Add
AddMenu("ScriptMenu", "&Edit Script`tCtrl+E",, IconLib, -3)
AddMenu("ScriptMenu", "Set &Default Editor...", "SetDefaultEditor", IconLib, -17)
Menu ScriptMenu, Add
AddMenu("ScriptMenu", "&Suspend Hotkeys`tCtrl+S",, IconLib, -4)
AddMenu("ScriptMenu", "&Pause Script`tPause",, IconLib, -5)
Menu ScriptMenu, Add
AddMenu("ScriptMenu", "E&xit Script`tDel",, IconLib, -6)
Menu ScriptMenu, Add
AddMenu("ScriptMenu", "&Open Folder`tCtrl+O", "OpenFolder", IconLib, -11)
AddMenu("ScriptMenu", "&Copy Path`tCtrl+P", "CopyPath", IconLib, -12)
Menu ScriptMenu, Add
AddMenu("ScriptMenu", "Command Prompt", "CommandPromptHere", IconLib, -14)
AddMenu("ScriptMenu", "Run...", "M_RunFileDlg", IconLib, -15)
Menu ScriptMenu, Add
AddMenu("ScriptMenu", "Exit AutoTaskMan`tEsc", "GuiClose", IconLib, -13)

AddMenu("InspectMenu", "Recent &Lines`tCtrl+L",, IconLib, -7)
AddMenu("InspectMenu", "&Variables`tCtrl+V",, IconLib, -8)
AddMenu("InspectMenu", "&Hotkeys`tCtrl+H",, IconLib, -9)
AddMenu("InspectMenu", "&Key history`tCtrl+K",, IconLib, -10)

Menu EditMenu, Add, Select &All`tCtrl+A, SelectAll
Menu EditMenu, Add
Menu EditMenu, Add, &Find in Files...`tCtrl+F, FindInFiles

Menu ViewMenu, Add, &Refresh Now`tF5, ReloadList

Menu OptionsMenu, Add, Always on Top, SetAlwaysOnTop
Menu OptionsMenu, Add, Hide When Minimized, SetHideWhenMinimized
Menu OptionsMenu, Add, Confirm Reload/Exit, SetConfirmAction
Menu OptionsMenu, Add, TrayTip Notifications, SetNotifications

AddMenu("HelpMenu", "AHK User &Manual`tF1", "OpenHelpFile", "hh.exe")
Menu HelpMenu, Add
AddMenu("HelpMenu", "&About", "ShowAbout", "user32.dll", -104)

Menu MenuBar, Add, &Script,  :ScriptMenu
Menu MenuBar, Add, &Inspect, :InspectMenu
Menu MenuBar, Add, &Edit,    :EditMenu
Menu MenuBar, Add, &View,    :ViewMenu
Menu MenuBar, Add, &Options, :OptionsMenu
Menu MenuBar, Add, &Help,    :HelpMenu
Gui Menu, MenuBar
Menu, MenuBar, Color, 0xFAFAFA

; Initial position and size
IniRead X, %g_IniFile%, Window, X
IniRead Y, %g_IniFile%, Window, Y
IniRead W, %g_IniFile%, Window, Width, 734
IniRead H, %g_IniFile%, Window, Height, 441
IniRead State, %g_IniFile%, Window, State, 1

If (FileExist(g_IniFile)) {
    SetWindowPlacement(g_hWndMain, X, Y, W, H, 0)
} Else {
    Gui Show, w%W% h%H% Hide
}

Gui Font, s9, Segoe UI

Gui Add, StatusBar, hWndg_hSB
GuiControlGet SBPos, Pos, %g_hSB%

GetClientSize(g_hWndMain, WindowW, WindowH)
LVH := WindowH - 28 - SBPosH
Gui Add, ListView, hWndg_hLV vList gLvHandler x0 y30 h%LVH% w%WindowW% +LV0x14000 AltSubmit, Filename|Path|PID|State

IniRead Columns, %g_IniFile%, Window, Columns, 177|424|49|79
aCols := StrSplit(Columns, "|")
LV_ModifyCol(1, aCols[1])
LV_ModifyCol(2, aCols[2])
LV_ModifyCol(3, aCols[3] . " Integer")
LV_ModifyCol(4, aCols[4])

g_ImageList := IL_Create(10)
IL_Add(g_ImageList, A_AhkPath)
LV_SetImageList(g_ImageList)

CreateToolbar()

DllCall("ShowWindow", "Ptr", g_hWndMain, "UInt", State)

LoadOptions()

RegRead g_ThousandSep, HKEY_CURRENT_USER\Control Panel\International, sThousand

DllCall("UxTheme.dll\SetWindowTheme", "Ptr", g_hLV, "WStr", "Explorer", "Ptr", 0)

; Get WMI service object.
Global winmgmts := ComObjGet("winmgmts:")

LoadList()
UpdateStatusBar()

; Create sink objects for receiving event notifications.
ComObjConnect(CreateSink := ComObjCreate("WbemScripting.SWbemSink"), "ProcessCreate_")
ComObjConnect(DeleteSink := ComObjCreate("WbemScripting.SWbemSink"), "ProcessDelete_")

; Set event polling interval, in seconds.
Interval := 1

; Register for process creation notifications:
winmgmts.ExecNotificationQueryAsync(CreateSink
    , "SELECT * FROM __InstanceCreationEvent"
    . " WITHIN " Interval
    . " WHERE TargetInstance ISA 'Win32_Process'"
    . " AND TargetInstance.Name LIKE 'AutoHotkey%'")

; Register for process deletion notifications:
winmgmts.ExecNotificationQueryAsync(DeleteSink
    , "SELECT * FROM __InstanceDeletionEvent"
    . " WITHIN " Interval
    . " WHERE TargetInstance ISA 'Win32_Process'"
    . " AND TargetInstance.Name LIKE 'AutoHotkey%'")

Hotkey IfWinActive, ahk_id %g_hWndMain%
Hotkey ^C, CopySelectedItems

; Tray menu
Menu Tray, NoStandard
AddMenu("Tray", "Show Window", "ShowMainWindow", IconLib, -1)
Menu Tray, Default, Show Window
Menu Tray, Add
AddMenu("Tray", "Exit", "GuiClose", IconLib, -13)
Menu Tray, Tip, %g_AppName%

; Save settings on system shutdown
OnMessage(0x16, "SaveSettings") ; WM_ENDSESSION

Return ; End of the auto-execute section

ReloadList() {
    Local Row := LV_GetNext()

    LV_Delete()
    IL_Destroy(g_ImageList)
    g_ImageList := IL_Create(10)
    IL_Add(g_ImageList, A_AhkPath)
    LV_SetImageList(g_ImageList)

    LoadList()
    If (Row) {
        LV_Modify(Row, "Select Focus")
    }

    UpdateStatusBar()
}

LoadList() {
    Local StrQuery, Process

    StrQuery := "Select * from Win32_Process Where Name Like 'AutoHotkey%'"

    For Process in winmgmts.ExecQuery(StrQuery) {
        AddToList(Process)
    }
}

GuiSize() {
    If (A_EventInfo == 1) {
        If (g_HideWhenMinimized) {
            WinHide ahk_id %g_hWndMain%
        }
        Return
    }

    AutoXYWH("wh", g_hLV)
    GuiControl Move, %g_hToolbar%, w%A_GuiWidth%
}

GuiContextMenu() {
    Local Row, FullPath, WorkingDir, hMenuShell, X, Y, ItemID, Verb

    If (A_GuiControl == "List" && Row := LV_GetNext()) {
        LV_GetText(FullPath, Row, 2)
        If (!FileExist(FullPath)) {
            Return
        }

        WorkingDir := GetFileDir(FullPath)

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

GuiClose() {
    GuiEscape:
    DllCall("DestroyWindow", "Ptr", g_hWndShell)
    SaveSettings()
    ExitApp
    Return
}

GetSelectedItems() {
    Local Row := 0, aItems := []

    While (Row := LV_GetNext(Row)) {
        LV_GetText(Path, Row, 2)
        If (!FileExist(Path)) {
            Continue
        }
        LV_GetText(PID, Row, 3)
        aItems.Push({"PID": PID, "Path": Path})
    }

    Return aItems
}

MenuHandler() {
    ; Remove keyboard shortcut and ampersand from menu item string
    Local MenuItem := StrReplace(RegExReplace(A_ThisMenuItem, "\t.*"), "&")
    ExecCommand(MenuItem)
}

OpenFolder() {
    Local aItems, Item, FullPath
    aItems := GetSelectedItems()
    If (!aItem.Length()) {
        Run *open explorer.exe %A_ScriptDir%\..
        Return
    }

    For Each, Item in aItems {
        FullPath := Item.Path
        Run *open explorer.exe /select`,"%FullPath%"
    }
}

CopyPath() {
    Local Filenames := "", Items, Item

    Items := GetSelectedItems()
    For Each, Item in Items {
        Filenames .= Item.Path . "`r`n"
    }

    Clipboard := RTrim(Filenames, "`r`n")
}

CopySelectedItems() {
    Local SelectedItems
    ControlGet SelectedItems, List, Selected, SysListView321
    Clipboard := SelectedItems
}

SelectAll() {
    GuiControl Focus, %g_hLV%
    LV_Modify(0, "Select")
}

GetWindowIconByPID(PID) {
    Local WinIDs, hWnd
    WinGet WinIDs, List, ahk_class AutoHotkeyGUI ahk_PID %PID%

    Loop %WinIDs% {
        hWnd := WinIDs%A_Index%
        If (!GetOwner(hWnd)) {
            SendMessage 0x7F, 0, 0,, ahk_id %hWnd% ; WM_GETICON
            If (ErrorLevel && ErrorLevel != "FAIL") {
                Return ErrorLevel
            }
        }
    }

    Return 0
}

GetOwner(hWnd) {
    Return DllCall("GetWindow", "Ptr", hWnd, "UInt", 4, "Ptr") ; GW_OWNER
}

GetScriptState(PID, State) {
    Local hWnd, Command, hMenu, MenuState

    WinGet hWnd, ID, ahk_class AutoHotkey ahk_pid %PID%

    If (WinExist("ahk_id " . hWnd)) {
        SendMessage 0x211, 0, 0,, ahk_id %hWnd% ; WM_ENTERMENULOOP
        SendMessage 0x212, 0, 0,, ahk_id %hWnd% ; WM_EXITMENULOOP

        Command := (State == "S") ? 65404 : 65403
        hMenu := DllCall("GetMenu", "Ptr", hWnd, "Ptr")
        MenuState := DllCall("GetMenuState", "Ptr", hMenu, "UInt", Command, "UInt", 0) ; By command

        Return MenuState & 0x8 ; MF_CHECKED
    }

    Return 0
}

UpdateToolbar() {
    Local Row, PID, Suspended, Paused, State

    Row := LV_GetNext()
    LV_GetText(PID, Row, 3)
    Suspended := GetScriptState(PID, "S")
    Paused := GetScriptState(PID, "P")

    ; 0x402 = TB_CHECKBUTTON
    SendMessage 0x402, 10004, %Suspended%,, ahk_id %g_hToolbar%
    SendMessage 0x402, 10005, %Paused%,,    ahk_id %g_hToolbar%

    State := Paused ? "Paused" : "Running"
    If (Suspended) {
        State .= " with hotkeys suspended"
    }

    LV_Modify(Row, "Col4", State)
}

LvHandler() {
    If (A_GuiEvent == "C" || A_GuiEvent == "K") {
        ; C: the ListView has released mouse capture.
        ; K: the user has pressed a key while the ListView has focus.
        UpdateStatusBar()
        UpdateToolbar()
    }
}

UpdateStatusBar() {
    Row := LV_GetNext()
    If (Row) {
        ;Started:|CPU Usage:|Working Size:|Virtual Size:|32/64-bit (Image Type)
        SB_SetParts(179, 120, 150, 150)

        LV_GetText(PID, Row, 3)

        SB_SetText("CPU Usage: " . GetCPUUsage(PID), 2)

        StrQuery := "SELECT * FROM Win32_Process WHERE ProcessId=" . PID
        QueryEnum := winmgmts.ExecQuery(StrQuery)._NewEnum()
        If (QueryEnum[Process]) {
            CreationDate := Process.CreationDate
            SubStr(CreationDate, 1, InStr(CreationDate, ".") - 1)
            FormatTime CreationDate, %CreationDate% D1 T0 ; Short date and time with seconds

            WorkingSetSize := "Working Size: " . FormatBytes(Process.WorkingSetSize, g_ThousandSep)
            VirtualSize := "Virtual Size: " . FormatBytes(Process.VirtualSize, g_ThousandSep)

            SB_SetText("Started: " . CreationDate, 1)
            SB_SetText(WorkingSetSize, 3)
            SB_SetText(VirtualSize, 4)
            SB_SetText(Is32Bit(PID) ? "32-bit" : "64-bit", 5)
        }

    } Else {
        SB_SetParts(179)
        Count := LV_GetCount()
        If (Count) {
            SB_SetText("Scripts: " . Count, 1)
        }

        SB_SetText(g_AhkInfo, 2)
    }
}

/*
GetCPUUsage(PID) {
    Static Processors := 0

    If (!Processors) {
        ;Sys := winmgmts.ExecQuery("Select * from Win32_ComputerSystem")._NewEnum
        ;Processors := Sys[Sys] ? Sys.NumberOfLogicalProcessors : 1
        For Sys in winmgmts.ExecQuery("Select NumberOfLogicalProcessors from Win32_ComputerSystem") {
            Processors := Sys.NumberOfLogicalProcessors
        }
    }

    StrQuery := "SELECT PercentProcessorTime FROM Win32_PerfFormattedData_PerfProc_Process WHERE IDProcess = " . PID
    For Process in winmgmts.ExecQuery(StrQuery) {
        CPUUsage := Format("{1:0.2f}", Process.PercentProcessorTime / Processors)
    }

    Return CPUUsage := (CPUUsage) ? CPUUsage : "0.00"
}
*/

GetCPUUsage(PID) {
    Local CPUUsage := GetProcessTimes(PID)

    If (CPUUsage < 0) { ; First run
        Sleep 125
        CPUUsage := GetProcessTimes(PID)
    }
    
    Return Round(CPUUsage, 2)
}

; Thanks to whoever wrote this function
GetProcessTimes(PID) {
    Static aPIDs := []

    ; If called too frequently, will get mostly 0%, so it's better to just return the previous usage 
    If aPIDs.HasKey(PID) && A_TickCount - aPIDs[PID, "tickPrior"] < 100
        Return aPIDs[PID, "usagePrior"] 
    ; Open a handle with PROCESS_QUERY_INFORMATION access
    If !hProc := DllCall("OpenProcess", "UInt", 0x400, "Int", 0, "Ptr", PID, "Ptr")
        Return -2, aPIDs.HasKey(PID) ? aPIDs.Remove(PID, "") : "" ; Process doesn't exist anymore or don't have access to it.
         
    DllCall("GetProcessTimes", "Ptr", hProc, "Int64*", lpCreationTime, "Int64*", lpExitTime, "Int64*", lpKernelTimeProcess, "Int64*", lpUserTimeProcess)
    DllCall("CloseHandle", "Ptr", hProc)
    DllCall("GetSystemTimes", "Int64*", lpIdleTimeSystem, "Int64*", lpKernelTimeSystem, "Int64*", lpUserTimeSystem)
   
    If aPIDs.HasKey(PID) ; check if previously run
    {
        ; find the total system run time delta between the two calls
        systemKernelDelta := lpKernelTimeSystem - aPIDs[PID, "lpKernelTimeSystem"] ;lpKernelTimeSystemOld
        systemUserDelta := lpUserTimeSystem - aPIDs[PID, "lpUserTimeSystem"] ; lpUserTimeSystemOld
        ; get the total process run time delta between the two calls 
        procKernalDelta := lpKernelTimeProcess - aPIDs[PID, "lpKernelTimeProcess"] ; lpKernelTimeProcessOld
        procUserDelta := lpUserTimeProcess - aPIDs[PID, "lpUserTimeProcess"] ;lpUserTimeProcessOld
        ; sum the kernal + user time
        totalSystem :=  systemKernelDelta + systemUserDelta
        totalProcess := procKernalDelta + procUserDelta
        ; The result is simply the process delta run time as a percent of system delta run time
        result := 100 * totalProcess / totalSystem
    }
    Else result := -1

    aPIDs[PID, "lpKernelTimeSystem"] := lpKernelTimeSystem
    aPIDs[PID, "lpKernelTimeSystem"] := lpKernelTimeSystem
    aPIDs[PID, "lpUserTimeSystem"] := lpUserTimeSystem
    aPIDs[PID, "lpKernelTimeProcess"] := lpKernelTimeProcess
    aPIDs[PID, "lpUserTimeProcess"] := lpUserTimeProcess
    aPIDs[PID, "tickPrior"] := A_TickCount

    Return aPIDs[PID, "usagePrior"] := result 
}

FormatBytes(n, sThousand := ".") {
    Local Unit, a, b

    If (n > 999) {
        n /= 1024
        Unit := " K"
    } Else {
        Unit := " B"
    }

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

Is32Bit(PID) {
    hProc := DllCall("OpenProcess", "UInt", 0x400, "Int", False, "UInt", PID, "Ptr") ; PROCESS_QUERY_INFORMATION

    If (A_Is64bitOS) {
        ; Determines whether the specified process is running under WOW64.
        Try DllCall("IsWow64Process", "Ptr", hProc, "Int*", Is32Bit := True)
    } Else {
        Is32Bit := True
    }

    DllCall("CloseHandle", "Ptr", hProc)

    Return Is32Bit
}

AddMenu(MenuName, MenuItemName := "", Subroutine := "MenuHandler", Icon := "", IconIndex := 1) {
    Menu, %MenuName%, Add, %MenuItemName%, %Subroutine%

    If (Icon != "") {
        Menu, %MenuName%, Icon, %MenuItemName%, %Icon%, %IconIndex%
    }
}

ExecCommand(Command) {
    Static WM_COMMAND := 0x111

    Items := GetSelectedItems()
    If (!Items.Length()) {
        Return
    }

    If ((Command == "Reload Script" || Command == "Exit Script") && !GetKeyState("Shift", "P")) {
        If (Items.Length() > 1) {
            Filename := "the selected scripts"
        } Else {
            LV_GetText(Filename, LV_GetNext(), 1)
        }

        If (g_ConfirmAction) {
            Action := (SubStr(Command, 1, 1) == "R") ? "reload" : "exit"
            Gui +OwnDialogs
            MsgBox 0x31, %g_AppName%, % "Are you sure you want to " . Action . " " . Filename . "?"
            IfMsgBox Cancel, Return
        }
    }

    For Each, Item in Items {
        ;OutputDebug % Command . " (" Commands[Command] "), PID: " Item.PID
        PostMessage WM_COMMAND, % Commands[Command],,, % "ahk_class AutoHotkey ahk_pid" . Item.PID

        If (Command == "Suspend Hotkeys" || Command == "Pause Script") {
            UpdateToolbar()
            /*
            If (Command == "Pause Script" && Row := LV_GetNext()) {
                LV_GetText(PID, Row, 3) ; 3 is the PID column
                SB_SetText("CPU Usage: " . GetCPUUsage(PID), 2)
            }
            */
        }
    }

    If (Command == "Exit Script") {
        ReloadList()
    } Else {
        UpdateStatusBar()
    }
}

OpenHelpFile() {
    Try {
        Run %g_AhkHelpFile%
    }
}

ShowAbout() {
    OnMessage(0x44, "OnMsgBox")
    Gui +OwnDialogs
    MsgBox 0x80, About, %g_AppName% %g_Version%
    OnMessage(0x44, "")
}

OnMsgBox() {
    DetectHiddenWindows, On
    Process, Exist
    If (WinExist("ahk_class #32770 ahk_pid " . ErrorLevel)) {
        hIcon := LoadPicture(IconLib, "w32", _)
        SendMessage 0x172, 1, %hIcon%, Static1 ; STM_SETIMAGE
    }
}

IL_AddEx(hIL, IconRes, Indexes*) {
    Local Each, Index
    For Each, Index in Indexes {
        IL_Add(hIL, IconRes, Index)
    }
}

CreateToolbar() {
    Local IL, sButtons, aButtons, TBBUTTON_Size, cButtons, TBBUTTONS
    , Index := 0, iBitmap, idCommand, fsStyle, iString, Offset

    Gui, Add, Custom, ClassToolbarWindow32 hWndg_hToolbar gTbHandler 0x50009901

    IL := IL_Create(15)
    IL_AddEx(IL, IconLib, -2, -3, -16, -4, -5, -6, -7, -8, -9, -10, -11, -12, -14, -15)

    sButtons =
    (LTrim
        -
        Reload Script
        Edit Script
        -
        Find in Files
        -
        Suspend Hotkeys
        Pause Script
        -
        Exit Script
        -
        Recent Lines
        Variables
        Hotkeys
        Key History
        -
        Open Folder
        Copy Path
        -
        Command Prompt
        Run...
    )
    aButtons := StrSplit(sButtons, "`n")

    TBBUTTON_Size := A_PtrSize == 8 ? 32 : 20
    cButtons := aButtons.Length()
    VarSetCapacity(TBBUTTONS, TBBUTTON_Size * cButtons , 0)

    Loop %cButtons% {
        If (aButtons[A_Index] == "-") {
            iBitmap := 0
            idCommand := 0
            fsStyle := 1 ; BTNS_SEP
            iString := -1
        } Else {
            Index++
            iBitmap := Index - 1
            idCommand := 10000 + Index
            fsStyle := 0
            iString := &(ButtonText%Index% := aButtons[A_Index])
        }

        Offset := (A_Index - 1) * TBBUTTON_Size
        NumPut(iBitmap, TBBUTTONS, Offset, "Int") ; iBitmap
        NumPut(idCommand, TBBUTTONS, Offset + 4, "Int") ; idCommand
        NumPut(0x4, TBBUTTONS, Offset + 8, "UChar") ; fsState (TBSTATE_ENABLED)
        NumPut(fsStyle, TBBUTTONS, Offset + 9, "UChar") ; fsStyle
        NumPut(iString, TBBUTTONS, Offset + (A_PtrSize == 8 ? 24 : 16), "Ptr") ; iString
    }

    SendMessage 0x454, 0, 0x9,, ahk_id %g_hToolbar% ; TB_SETEXTENDEDSTYLE
    SendMessage 0x430, 0, %IL%,, ahk_id %g_hToolbar% ; TB_SETg_ImageList
    ;SendMessage 0x43C, 0, 0,, ahk_id %g_hToolbar% ; TB_SETMAXTEXTROWS
    SendMessage % A_IsUnicode ? 0x444 : 0x414, %cButtons%, % &TBBUTTONS,, ahk_id %g_hToolbar% ; TB_ADDBUTTONS
    SendMessage 0x421, 0, 0,, ahk_id %g_hToolbar% ; TB_AUTOSIZE
    SendMessage 0x41F, 0, 0x00180018,, ahk_id %g_hToolbar% ; TB_SETBUTTONSIZE
}

TbHandler() {
    Local Code, ButtonId, Text

    Code := NumGet(A_EventInfo + 0, A_PtrSize * 2, "Int")
    If (Code == -2) { ; NM_CLICK
        ButtonId := NumGet(A_EventInfo + (3 * A_PtrSize))

        VarSetCapacity(Text, 128)
        SendMessage % A_IsUnicode ? 0x44B : 0x42D, ButtonId, &Text,, ahk_id %g_hToolbar% ; TB_GETBUTTONTEXT

        If (Text == "Open Folder") {
            OpenFolder()

        } Else If (Text == "Copy Path") {
            CopyPath()

        } Else If (Text == "Command Prompt") {
            CommandPromptHere()

        } Else If (Text == "Run...") {
            RunFileDlg(g_hWndMain)

        } Else If (Text == "Find in Files") {
            FindInFiles()

        } Else {
            ExecCommand(Text)
        }
    }
}

; Called when a new process is detected:
ProcessCreate_OnObjectReady(obj) {
    Process := obj.TargetInstance
    AddToList(Process)

    If (g_Notifications) {
        CommandLine := StrReplace(Process.CommandLine, Process.ExecutablePath)
        RegExMatch(CommandLine, g_RegEx, m)
        FileGetVersion Ver, % Process.ExecutablePath

        TrayTip New Script Detected, % "
        (LTrim
            File name:`t"  . m2 . "
            Directory:`t"  . GetFileDir(m1) . "
            AutoHotkey:`t" . Process.Name . " v" . Ver . "
            Process ID:`t" . Process.ProcessId . "

            Command line:
            " . Process.CommandLine
        ),, 0x11
    }

    UpdateStatusBar()
}

; Called when a process terminates:
ProcessDelete_OnObjectReady(obj) {
    Process := obj.TargetInstance
    RemoveFromList(Process)

    If (g_Notifications) {
        CommandLine := StrReplace(Process.CommandLine, Process.ExecutablePath)
        RegExMatch(CommandLine, g_RegEx, m)
        FileGetVersion Ver, % Process.ExecutablePath

        TrayTip Script Terminated, % "
        (LTrim
            File name:`t"  . m2 . "
            Directory:`t"  . GetFileDir(m1) . "
            AutoHotkey:`t" . Process.Name . " v" . Ver . "
            Process ID:`t" . Process.ProcessId
        ),, 0x11
    }

    UpdateStatusBar()
}

AddToList(oProcess) {
    Local CommandLine, PID, hIcon, m, IconIndex, Suspended, Paused, State, m2, m1

    CommandLine := StrReplace(oProcess.CommandLine, oProcess.ExecutablePath)
    If (RegExMatch(CommandLine, g_RegEx, m)) {
        PID := oProcess.ProcessId

        hIcon := GetWindowIconByPID(PID)
        If (hIcon) {
            hIcon := DllCall("CopyIcon", "Ptr", hIcon, "Ptr")
            IconIndex := IL_Add(g_ImageList, "HICON: " . hIcon)
        } Else {
            IconIndex := 1
        }

        Suspended := GetScriptState(PID, "S")
        Paused := GetScriptState(PID, "P")

        State := Paused ? "Paused" : "Running"
        If (Suspended) {
            State .= " with hotkeys suspended"
        }

        LV_Add("Icon" . IconIndex, m2, m1, PID, State)
    }
}

RemoveFromList(oProcess) {
    Local PID, RowPID

    PID := oProcess.ProcessId

    Loop % LV_GetCount() {
        LV_GetText(RowPID, A_Index, 3)
        If (RowPID == PID) {
            LV_Delete(A_Index)
            Break
        }
    }
}

ShowMainWindow() {
    Local State

    WinGet State, MinMax, ahk_id %g_hWndMain%
    If (State == -1) {
        WinRestore ahk_id %g_hWndMain%
    }

    WinActivate ahk_id %g_hWndMain%
}

CommandPromptHere() {
    Local Row, FullPath, StartDir

    Row := LV_GetNext()
    If (Row) {
        LV_GetText(FullPath, Row, 2)
        SplitPath FullPath,, StartDir
    } Else {
        EnvGet StartDir, SystemDrive
    }
    FixRootDir(StartDir)

    Run %Comspec%, %StartDir%
}

M_RunFileDlg() {
    RunFileDlg(g_hWndMain)
}

RunFileDlg(hWndParent) {
    Local hModule, RunFileDlg
    hModule := DllCall("GetModuleHandle", "Str", "shell32.dll", "Ptr")
    RunFileDlg := DllCall("GetProcAddress", "Ptr", hModule, "UInt", 61, "Ptr")
    DllCall(RunFileDlg, "Ptr", hWndParent, "Ptr", 0, "Ptr", 0, "Ptr", 0, "Ptr", 0, "UInt", 0)
}

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
    Return DllCall("SetWindowPlacement", "Ptr", hWnd, "Ptr", &WINDOWPLACEMENT)
}

SaveSettings() {
    Local Pos, State, Columns

    If (!CreateIniFile()) {
        Return
    }

    ; Options
    IniWrite %g_AlwaysOnTop%, %g_IniFile%, Options, AlwaysOnTop
    IniWrite %g_HideWhenMinimized%, %g_IniFile%, Options, HideWhenMinimized
    IniWrite %g_ConfirmAction%, %g_IniFile%, Options, ConfirmAction
    IniWrite %g_Notifications%, %g_IniFile%, Options, Notifications

    ; Position and size
    Pos := GetWindowPlacement(g_hWndMain)
    IniWrite % Pos.x, %g_IniFile%, Window, X
    IniWrite % Pos.y, %g_IniFile%, Window, Y
    IniWrite % Pos.w, %g_IniFile%, Window, Width
    IniWrite % Pos.h, %g_IniFile%, Window, Height
    If (Pos.showCmd == 2) { ; Minimized
        State := (Pos.flags & 2) ? 3: 1
    } Else {
        State := Pos.showCmd
    }
    IniWrite %State%, %g_IniFile%, Window, State

    ; Columns width
    Columns := ""
    Loop % LV_GetCount("Col") {
        SendMessage 0x101D, A_Index - 1, 0,, ahk_id %g_hLV% ; LVM_GETCOLUMNWIDTH
        Columns .= ErrorLevel . "|"
    }
    Columns := SubStr(Columns, 1, -1)
    IniWrite %Columns%, %g_IniFile%, Window, Columns
}

SetAlwaysOnTop() { ; M
    Local ExStyle
    WinGet ExStyle, ExStyle, ahk_id %g_hWndMain%

    If (ExStyle & 0x8) {
        WinSet AlwaysOnTop, Off, ahk_id %g_hWndMain%
        g_AlwaysOnTop := False
        Menu OptionsMenu, Uncheck, Always on Top

    } Else {
        WinSet AlwaysOnTop, On, ahk_id %g_hWndMain%
        g_AlwaysOnTop := True
        Menu OptionsMenu, Check, Always on Top
    }
}

SetHideWhenMinimized() { ; M
    g_HideWhenMinimized := !g_HideWhenMinimized
    Menu OptionsMenu, ToggleCheck, Hide When Minimized
}

SetConfirmAction() { ; M
    g_ConfirmAction := !g_ConfirmAction
    Menu OptionsMenu, ToggleCheck, Confirm Reload/Exit
}

SetNotifications() { ; M
    g_Notifications := !g_Notifications
    Menu OptionsMenu, ToggleCheck, TrayTip Notifications
}

FindInFiles() {
    Local Row := 0, Files := "", FullPath

    While (Row := LV_GetNext(Row)) {
        LV_GetText(FullPath, Row, 2)
        Files .= FullPath . "|"
    }

    If (Files == "") {
        Loop % LV_GetCount() {
            LV_GetText(FullPath, A_Index, 2)
            Files .= FullPath . "|"
        }
    }

    If (Files != "") {
        Try {
            Run %g_Tool_FiF% /target:"%Files%" /filter:*.ahk /focus
        }
    }
}

SetDefaultEditor() { ; M
    Try {
        Run %g_Tool_DefEdt%
    }
}

LoadOptions() {
    IniRead g_AlwaysOnTop, %g_IniFile%, Options, AlwaysOnTop, 0
    IniRead g_HideWhenMinimized, %g_IniFile%, Options, HideWhenMinimized, 0
    IniRead g_ConfirmAction, %g_IniFile%, Options, ConfirmAction, 1
    IniRead g_Notifications, %g_IniFile%, Options, Notifications, 0

    If (g_AlwaysOnTop) {
        WinSet AlwaysOnTop, On, ahk_id %g_hWndMain%
        Menu OptionsMenu, Check, Always on Top
    }

    If (g_HideWhenMinimized) {
        Menu OptionsMenu, Check, Hide When Minimized
    }

    If (g_ConfirmAction) {
        Menu OptionsMenu, Check, Confirm Reload/Exit
    }

    If (g_Notifications) {
        Menu OptionsMenu, Check, TrayTip Notifications
    }
}

GetClientSize(hWnd, ByRef Width, ByRef Height) {
    Local RECT
    VarSetCapacity(RECT, 16, 0)
    DllCall("GetClientRect", "Ptr", hWnd, "Ptr", &RECT)
    Width  := NumGet(RECT, 8,  "Int")
    Height := NumGet(RECT, 12, "Int")
}

GetFileDir(FullPath) {
    Local Dir
    SplitPath FullPath,, Dir
    Return FixRootDir(Dir)
}

FixRootDir(ByRef Dir) {
    If (SubStr(Dir, 0, 1) == ":") {
        Dir := Dir . "\"
    }
    Return Dir
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
        Sections := "[Options]`n`n[Window]`n"

        FileAppend %Sections%, %g_IniFile%, UTF-16
        If (ErrorLevel) {
            FileCreateDir %g_AppData%
            g_IniFile := g_AppData . "\AutoTaskMan.ini"
            FileDelete %g_IniFile%
            FileAppend %Sections%, %g_IniFile%, UTF-16
        }
    }

    Return FileExist(g_IniFile)
}

SetMainIcon(IconRes, IconIndex := 1) {
    Try {
        Menu Tray, Icon, % A_IsCompiled ? A_ScriptName : IconRes, %IconIndex%
    }
}

GetShellContextMenu(sPath, Flags := 0, IDFirst := 1, IDLast := 0x7FFF) {
    Local pidl, IID_IShellFolder, pIShellFolder, pidlChild, IID_IContextMenu, hMenu, e

    If (DllCall("shell32.dll\SHParseDisplayName", "WStr", sPath, "Ptr", 0, "Ptr*", pidl, "UInt", 0, "UInt*", 0)) {
        Return 0
    }

    DllCall("shell32.dll\SHBindToParent", "Ptr", pidl, "Ptr", GUID4String(IID_IShellFolder, "{000214E6-0000-0000-C000-000000000046}"), "Ptr*", pIShellFolder, "Ptr*", pidlChild)

    ; IShellFolder->GetUIObjectOf
    DllCall(VTable(pIShellFolder, 10), "Ptr", pIShellFolder, "Ptr", 0, "UInt", 1, "Ptr*", pidlChild, "Ptr", GUID4String(IID_IContextMenu, "{000214E4-0000-0000-C000-000000000046}"), "Ptr", 0, "Ptr*", g_pIContextMenu)
    ObjRelease(pIShellFolder)

    DllCall("ole32.dll\CoTaskMemFree", "Ptr", pidl)

    hMenu := DllCall("CreatePopupMenu", "Ptr")

    ; IContextMenu->QueryContextMenu
    DllCall(VTable(g_pIContextMenu, 3), "Ptr", g_pIContextMenu, "Ptr", hMenu, "UInt", 0, "UInt", IDFirst, "UInt", IDLast, "UInt", Flags)
    ComObjError(0)
    g_pIContextMenu2 := ComObjQuery(g_pIContextMenu, "{000214F4-0000-0000-C000-000000000046}") ; IID_IContextMenu2
    g_pIContextMenu3 := ComObjQuery(g_pIContextMenu, "{BCFCE0A0-EC17-11D0-8D10-00A0C90F2719}") ; IID_IContextMenu3
    e := A_LastError
    ComObjError(1)
    If (e != 0) {
        DestroyShellMenu(hMenu)
        Return 0
    }

    Return hMenu
}

DestroyShellMenu(hMenu) {
    DllCall("DestroyMenu", "Ptr", hMenu)
    ReleaseIContextMenu()
}

ReleaseIContextMenu() {
    ObjRelease(g_pIContextMenu3)
    ObjRelease(g_pIContextMenu2)
    ObjRelease(g_pIContextMenu)
    g_pIContextMenu2 := g_pIContextMenu3 := 0
}

RunShellMenuCommand(pIContextMenu, Cmd, WorkingDir := "", hWnd := 0, X := 0, Y := 0, IDFirst := 1, Verb := False) {
    Local CmdName, Directory, x64 := A_PtrSize == 8

    If (Verb) {
        VarSetCapacity(CmdName, StrPut(Cmd, "UTF-16") * 2, 0)
        StrPut(Cmd, &CmdName, "UTF-16")
        Cmd := &CmdName
    } Else {
        Cmd := Cmd - IDFirst
    }

    Directory := WorkingDir != "" ? &WorkingDir : 0

    ; CMINVOKECOMMANDINFOEX
    NumPut(VarSetCapacity(CMICI, x64 ? 104 : 64, 0), CMICI, 0, "UInt") ; cbSize
    ; Mask flags: CMIC_MASK_UNICODE | CMIC_MASK_ASYNCOK | CMIC_MASK_PTINVOKE
    NumPut(0x4000 | 0x100000 | 0x20000000, CMICI, 4, "UInt") ; fMask
    NumPut(hWnd, CMICI, 8, "UPtr") ; hWnd
    NumPut(1, CMICI, x64 ? 40 : 24, "UInt") ; nShow
    NumPut(Cmd, CMICI, x64 ? 16 : 12, "UPtr") ; lpVerb
    NumPut(Cmd, CMICI, x64 ? 64 : 40, "UPtr") ; lpVerbW
    NumPut(Directory, CMICI, x64 ? 32 : 20, "Ptr") ; lpDirectory
    NumPut(Directory, CMICI, x64 ? 80 : 48, "Ptr") ; lpDirectoryW
    NumPut(X, CMICI, x64 ? 96 : 56, "Int") ; ptInvoke
    NumPut(Y, CMICI, x64 ? 100 : 60, "Int")

    Return DllCall(VTable(pIContextMenu, 4), "Ptr", pIContextMenu, "Ptr", &CMICI) ; InvokeCommand
}

CreateShellMenuWindow(ClassName := "ShellWnd", WndProc := "ShellWndProc") {
    Local hWnd, WNDCLASS

    VarSetCapacity(WNDCLASS, A_PtrSize == 8 ? 72 : 40, 0)
    NumPut(RegisterCallback(WndProc, "F"), WNDCLASS, A_PtrSize == 8 ? 8 : 4, "Ptr")
    NumPut(&ClassName, WNDCLASS, A_PtrSize == 8 ? 64 : 36, "Ptr")

    If (!DllCall("RegisterClass", "Ptr", &WNDCLASS)) {
        MsgBox 0x10, Error, Failed to register window class.
        Return 0
    }

    hWnd := DllCall("CreateWindowEx", "UInt" , 0, "Str", ClassName, "Str", "", "UInt", 0
         , "Int", 0, "Int", 0, "Int", 0, "Int", 0, "Ptr", 0, "Ptr", 0, "Ptr", 0, "Ptr", 0, "Ptr")

    If (!hWnd) {
        MsgBox 0x10, Error, Failed to create window.
        Return 0
    }

    Return hWnd
}

ShellWndProc(hWnd, uMsg, wParam, lParam) {
    Global g_pIContextMenu2, g_pIContextMenu3

    If (g_pIContextMenu3) {
        ; IContextMenu3->HandleMenuMsg2
        If !(DllCall(VTable(g_pIContextMenu3, 7), "Ptr", g_pIContextMenu3, "UInt", uMsg, "Ptr", wParam, "Ptr", lParam, "Ptr*", lResult)) {
            Return lResult
        }
    } Else If (g_IContextMenu2) {
        ; IContextMenu2->HandleMenuMsg
        If !(DllCall(VTable(g_pIContextMenu2, 6), "Ptr", g_pIContextMenu2, "UInt", uMsg, "Ptr", wParam, "Ptr", lParam)) {
            Return 0
        }
    }

    Return DllCall("DefWindowProc", "Ptr", hWnd, "UInt", uMsg, "UPtr", wParam, "Ptr", lParam, "Ptr")
}

ShowPopupMenu(hMenu, Flags, X, Y, hWnd) {
    Return DllCall("TrackPopupMenuEx", "Ptr", hMenu, "UInt", Flags, "Int", X, "Int", Y, "Ptr", hWnd, "Ptr", 0)
}

VTable(ppv, idx) {
    Return NumGet(NumGet(1 * ppv) + A_PtrSize * idx)
}

GUID4String(ByRef CLSID, String) {
    VarSetCapacity(CLSID, 16, 0)
    Return DllCall("ole32.dll\CLSIDFromString", "WStr", String, "Ptr", &CLSID) >= 0 ? &CLSID : ""
}

GetShellMenuItemVerb(pIContextMenu, ItemID, IDFirst := 1, Unicode := True) { ; GCS_VERBW
    Local Verb
    VarSetCapacity(Verb, 256, 0)

    ; IContextMenu->GetCommandString
    If (DllCall(VTable(pIContextMenu, 5), "Ptr", pIContextMenu, "UPtr", ItemID - IDFirst
    , "UInt", Unicode ? 4 : 0, "UInt", 0, "Str", Verb, "UInt", 256)) {
        Return ""
    }

    Return StrGet(&Verb, 256, Unicode ? "UTF-16" : "CP0")
}

PasteFile(Dir) {
    Local SEI

    If (!InStr(FileExist(Dir), "D", 1)) {
        Return 0
    }

    NumPut(VarSetCapacity(SEI, A_PtrSize == 8 ? 112 : 60, 0), SEI, 0, "UInt") ; SHELLEXECUTEINFO
    NumPut(0x400C, SEI, 4, "UInt") ; fMask (SEE_MASK_UNICODE | SEE_MASK_INVOKEIDLIST)
    NumPut(&Verb := "paste", SEI, A_PtrSize == 8 ? 16 : 12, "Ptr")
    NumPut(&Dir := Dir, SEI, A_PtrSize == 8 ? 24 : 16, "Ptr")
    Return DllCall("Shell32.dll\ShellExecuteExW", "Ptr", &SEI)
}

