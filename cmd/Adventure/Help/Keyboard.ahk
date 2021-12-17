; A reference for the keyboard shortcuts available in Adventure and Auto-GUI.

; Script compiler directives
;@Ahk2Exe-SetMainIcon %A_ScriptDir%\..\Icons\Keyboard.ico
;@Ahk2Exe-SetCompanyName AmberSoft
;@Ahk2Exe-SetDescription Adventure Keyboard Shortcuts

#SingleInstance Force
#NoEnv
#NoTrayIcon
SetBatchLines -1
SetWorkingDir %A_ScriptDir%

IconLib := A_ScriptDir . "\..\Icons\Keyboard.icl"

Menu Tray, Icon, %IconLib%

Gui Font, s9, Segoe UI

Gui Add, Tab3, hWndhTab x8 y8 w426 h477
SendMessage 0x1329, 0, 0x00170055,, ahk_id %hTab% ; TCM_SETITEMSIZE
GuiControl,, %hTab%, Text Editor|GUI Designer|AHK Debugger

IL := IL_Create(3)
IL_Add(IL, IconLib, 2)
IL_Add(IL, IconLib, 3)
IL_Add(IL, IconLib, 4)
SendMessage 0x1303, 0, IL,, ahk_id %hTab% ; TCM_SETIMAGELIST

SetTabIcon(hTab, 1, 1)
SetTabIcon(hTab, 2, 2)
SetTabIcon(hTab, 3, 3)

SendMessage 0x132B, 0, 5 | (4 << 16),, ahk_id %hTab% ; TCM_SETPADDING

Gui Tab, 1
    Gui Add, ListView, hWndhLVEditor x18 y44 w404 h428 +LV0x14000, Action|Key
    SetExplorerTheme(hLVEditor)

    LV_Add("", "New file", "Ctrl + N")
    ;LV_Add("", "New file from template", "Ctrl + T")
    LV_Add("", "Open file", "Ctrl + O")
    LV_Add("", "Save", "Ctrl + S")
    LV_Add("", "Save as", "Ctrl + Shift + S")
    LV_Add("", "Close file", "Ctrl + W")
    LV_Add("", "Undo", "Ctrl + Z")
    LV_Add("", "Redo", "Ctrl + Y")
    LV_Add("", "Cut", "Ctrl + X")
    LV_Add("", "Copy", "Ctrl + C")
    LV_Add("", "Paste", "Ctrl + V")
    LV_Add("", "Delete", "Del")
    LV_Add("", "Select all", "Ctrl + A")
    LV_Add("", "Duplicate line", "Ctrl + Down")
    LV_Add("", "Move line up", "Ctrl + Shift + Up")
    LV_Add("", "Move line down", "Ctrl + Shift + Down")
    LV_Add("", "Toggle Autocomplete", "F12")
    LV_Add("", "Show Autocomplete list", "Ctrl + Enter")
    LV_Add("", "Show calltip", "Ctrl + Space")
    LV_Add("", "Insert parameters", "Ctrl + Insert")
    LV_Add("", "Switch overloaded calltip", "Ctrl + Shift + PgDn / PgUp")
    LV_Add("", "Insert date and time", "Ctrl + D")
    LV_Add("", "Find", "Ctrl + F")
    LV_Add("", "Find next", "F3")
    LV_Add("", "Find previous", "Shift + F3")
    LV_Add("", "Replace", "Ctrl + H")
    LV_Add("", "Find in files", "Ctrl + Shift + F")
    LV_Add("", "Go to line", "Ctrl + G")
    LV_Add("", "Mark current line", "F2")
    LV_Add("", "Mark line with error sign", "Shift + F2")
    LV_Add("", "Mark selected text", "Ctrl + M")
    LV_Add("", "Go to next mark", "Ctrl + PgDn")
    LV_Add("", "Go to previous mark", "Ctrl + PgUp")
    LV_Add("", "Ctrl + AppsKey", "Jump menu")
    LV_Add("", "Clear all marks", "Alt + M")
    LV_Add("", "Go to matching brace", "Ctrl + B")
    LV_Add("", "Convert selection to uppercase", "Ctrl + Shift + U")
    LV_Add("", "Convert selection to lowercase", "Ctrl + Shift + L")
    LV_Add("", "Convert selection to title case", "Ctrl + Shift + T")
    LV_Add("", "Decimal to hexadecimal", "Ctrl + Shift + H")
    LV_Add("", "Hexadecimal to decimal", "Ctrl + Shift + D")
    LV_Add("", "Comment/uncomment", "Ctrl + K")
    LV_Add("", "Zoom in", "Ctrl + Numpad +")
    LV_Add("", "Zoom out", "Ctrl + Numpad -")
    LV_Add("", "Reset zoom", "Ctrl + Numpad 0")
    LV_Add("", "Run with associated application", "F9")
    LV_Add("", "Open folder in file manager", "Ctrl + E")
    LV_Add("", "Open folder in command prompt", "Ctrl + P")
    LV_Add("", "New line", "Enter")
    LV_Add("", "New line (no auto-indent)", "Shift + Enter")
    LV_Add("", "Rectangular selection", "Alt + Shift + Arrow Keys")
    LV_Add("", "Context menu", "AppsKey")
    LV_Add("", "Close popups / kill selection", "Esc")
    LV_Add("", "Switch to the next tab", "Ctrl + Tab")
    LV_Add("", "Switch to the previous tab", "Ctrl + Shift + Tab")
    LV_Add("", "New file (mouse)", "Double-click the tab bar")
    LV_Add("", "Close file (mouse)", "Middle-click the tab button")
    LV_Add("", "Exit", "Alt + Q")
    LV_Add("", "Help file", "F1")
    ;LV_Add("", "", "")

    LV_ModifyCol(1, 200)
    LV_ModifyCol(2, "AutoHdr")

Gui Tab, 2
    Gui Add, ListView, hWndhLVGUIDesigner x18 y44 w404 h428 +LV0x14000, Action|Key
    SetExplorerTheme(hLVGUIDesigner)

    LV_Add("", "New AHK GUI", "Ctrl + N")
    LV_Add("", "Import GUI", "Ctrl + I")
    LV_Add("", "Save", "Ctrl + S")
    LV_Add("", "Save as", "Ctrl + Shift + S")
    LV_Add("", "Select all controls", "Ctrl + A")
    LV_Add("", "Move 1px", "Arrow keys")
    LV_Add("", "Move 8px", "Ctrl + Arrow keys")
    LV_Add("", "Resize 1px", "Shift + Arrow keys")
    LV_Add("", "Resize 8px", "Ctrl + Shift + Arrow keys")
    LV_Add("", "Delete control", "Del")
    LV_Add("", "Change text/title", "F2 or double-click")
    LV_Add("", "Properties", "F10 or middle-click")
    LV_Add("", "Show/hide preview window", "F11")
    LV_Add("", "Go to line", "Ctrl + G")
    LV_Add("", "Run with AHK 64-bit", "F9")
    LV_Add("", "Run with AHK 32-bit", "Shift + F9")
    LV_Add("", "Exit", "Alt + Q")
    LV_Add("", "AutoHotkey Help File", "F1")
    ;LV_Add("", "", "")

    LV_ModifyCol(1, 200)
    LV_ModifyCol(2, "AutoHdr")

Gui Tab, 3
    Gui Add, ListView, hWndhLVDebugger x18 y44 w404 h428 +LV0x14000, Action|Key
    SetExplorerTheme(hLVDebugger)

    LV_Add("", "Toggle breakpoint", "F4")
    LV_Add("", "Start debugging", "F5")
    LV_Add("", "Step into", "F6")
    LV_Add("", "Step over", "F7")
    LV_Add("", "Step out", "Shift + F6")
    LV_Add("", "Stop debugging", "F8")
    LV_Add("", "Break", "Pause/Break")
    LV_Add("", "Run with AHK 64-bit", "F9")
    LV_Add("", "Run with AHK 32-bit", "Shift + F9")
    LV_Add("", "Run with alternative application", "Alt + F9")
    ;LV_Add("", "Run Selected Text", "Ctrl + F9")
    ;LV_Add("", "", "")

    LV_ModifyCol(1, 200)
    LV_ModifyCol(2, "AutoHdr")

Gui Tab

Gui Add, Button, gGuiClose x346 y494 w86 h24 Default, &Close

Gui Show, w440 h528, Keyboard Shortcuts
Return

GuiEscape:
GuiClose:
    ExitApp

SetExplorerTheme(hWnd) {
    Return DllCall("UxTheme.dll\SetWindowTheme", "Ptr", hWnd, "WStr", "Explorer", "Ptr", 0)    
}

SetTabIcon(hTab, Item, IconIndex) {
    Static OffImg := (3 * 4) + (A_PtrSize - 4) + A_PtrSize + 4
    Static Size := (5 * 4) + (2 * A_PtrSize) + (A_PtrSize - 4)
    VarSetCapacity(TCITEM, Size, 0)
    NumPut(0x2, TCITEM, 0, "UInt") ; 0x2 = TCIF_IMAGE
    NumPut(IconIndex - 1, TCITEM, OffImg, "Int")
    SendMessage 0x133D, Item - 1, &TCITEM,, ahk_id %hTab% ; TCM_SETITEM
}
