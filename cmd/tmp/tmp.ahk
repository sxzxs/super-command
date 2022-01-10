text = 
(%
UpdateText(hTooltip, TextArray) {
   static TTM_UPDATETIPTEXT := A_IsUnicode ? 0x439 : 0x40C
   text := TextArray.Pop()
   VarSetCapacity(TOOLINFO, sz := 24 + A_PtrSize*6, 0)
   NumPut(sz, TOOLINFO)
   NumPut(&text, TOOLINFO, 24 + A_PtrSize*3)
   SendMessage, TTM_UPDATETIPTEXT,, &TOOLINFO,, ahk_id %hTooltip%
   if (TextArray[1] = "")
      SetTimer,, Delete
)
#NoEnv
OnMessage(0x201, "WM_LBUTTONDOWN")

Global tClass:="SysShadow,Alternate Owner,tooltips_class32,DummyDWMListenerWindow,EdgeUiInputTopWndClass,ApplicationFrameWindow,TaskManagerWindow,Qt5QWindowIcon,Windows.UI.Core.CoreWindow,WorkerW,Progman,Internet Explorer_Hidden,Shell_TrayWnd" ; HH Parent

WinGetActiveTitle, aWin
ToolTip,% text, 0, 0
return

WM_LBUTTONDOWN(wParam, lParam, msg, hwnd) {
	PostMessage, 0xA1, 2 ; WM_NCLBUTTONDOWN
	KeyWait, LButton, U
	Loop { ; adapted from https://autohotkey.com/board/topic/32171-how-to-get-the-id-of-the-next-or-previous-window-in-z-order/
        ; GetWindow() returns a decimal value, so we have to convert it to hex
        ; GetWindow() processes even hidden windows, so we move down the z oder until the next visible window is found
        hwnd := Format("0x{:x}", DllCall("GetWindow", UPtr,hwnd, UInt,2) ) ; 2 = GW_HWNDNEXT
        if DllCall("IsWindowVisible", UPtr,hwnd) {
            WinGet, Ex, ExStyle, ahk_id %hwnd%
            ;if ( IsWindowCloaked(hwnd) || Ex & (0x8 | 0x80 | 0x8000000) ) ;WS_EX_TOPMOST, WS_EX_TOOLWINDOW, WS_EX_NOACTIVATE
            if (IsWindowCloaked(hwnd) || Ex & 0x8000088) ;WS_EX_TOPMOST, WS_EX_TOOLWINDOW, WS_EX_NOACTIVATE
		Continue
            WinGetClass, cClass, ahk_id %hwnd%
            if InStr(tClass, cClass, 1) ; if cClass in %tClass%
                Continue
            else break
        }
    }   WinActivate, ahk_id %hwnd%
}

IsWindowCloaked(hwnd) {
    return DllCall("dwmapi\DwmGetWindowAttribute", "ptr",hwnd, "int",14, "int*",cloaked, "int",4) >= 0
        && cloaked
}

Esc::exitapp