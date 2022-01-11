#NoEnv
Gui, Margin, 20, 20
Gui, Font, s12
Gui, Add, Edit, w200 Center hwndHED1, Edit 1
CtlColor_Edit(HED1, 0x0091FF, 0x00FF91)
Gui, Add, Edit, xm wp hp Center hwndHED2, Edit 2
CtlColor_Edit(HED2, 0x00FF91, 0xFF0091)
Gui, Add, Edit, xm wp hp Center hwndHED3, Edit 3
CtlColor_Edit(HED3, 0xFF0091, 0x0091FF)
Gui, Add, Edit, xm wp hp Center hwndHED4, Edit 4
Gui, Show, , CtlColor_Edit()
Return
; ======================================================================================================================
GuiClose:
GuiEscape:
ExitApp
; ======================================================================================================================
; WM_CTLCOLOREDIT = 0x0133 <- msdn.microsoft.com/en-us/library/windows/desktop/bb761691(v=vs.85).aspx
; An edit control that is not read-only or disabled sends the WM_CTLCOLOREDIT message to its parent window
; when the control is about to be drawn.
; ======================================================================================================================
CtlColor_Edit(Param1, Param2 := "", Param3 := "") {
   Static Init := OnMessage(0x0133, "CtlColor_Edit")
   Static DCBrush := DllCall("Gdi32.dll\GetStockObject", "UInt", 18, "UPtr") ; DC_BRUSH = 18
   Static Controls := []
   ; If Param1 contains a valid window handle, the function has been called by the user ---------------------------------
   ; Param1 = HWND, Param2 = BackgroundColor, Param3 = TextColor
   If DllCall("IsWindow", "Ptr", Param1, "UInt") {
      Controls.Delete(Param1)
      If (Param2 <> "") {
         Controls[Param1, "BkColor"] := CtlColor_BGR(Param2)
         If (Param3 <> "")
            Controls[Param1, "TxColor"] := CtlColor_BGR(Param3)
      }
   }
   ; Function has been called as message handler -----------------------------------------------------------------------
   ; Param1 (wParam) = HDC, Param2 (lParam) = HWND
   Else If (((BC := Controls[Param2, "BkColor"]) . (TC := Controls[Param2, "TxColor"])) <> "") {
      If (TC <> "")
         DllCall("SetTextColor", "Ptr", Param1, "UInt", TC)
      DllCall("SetBkColor", "Ptr", Param1, "UInt", BC)
      DllCall("SetDCBrushColor", "Ptr", Param1, "UInt", BC)
      Return DCBrush
   }
}
; ======================================================================================================================
; Color values must be passed as BGR to GDI functions, this function does the conversion from RGB
; ======================================================================================================================
CtlColor_BGR(RGB) {
   Static HTML := {AQUA: 0xFFFF00, BLACK: 0x000000, BLUE: 0xFF0000, FUCHSIA: 0xFF00FF, GRAY: 0x808080, GREEN: 0x008000
                 , LIME: 0x00FF00, MAROON: 0x000080, NAVY: 0x800000, OLIVE: 0x008080, PURPLE: 0x800080, RED: 0x0000FF
                 , SILVER: 0xC0C0C0, TEAL: 0x808000, WHITE: 0xFFFFFF, YELLOW: 0x00FFFF}
   Return (HTML.HasKey(RGB) ? HTML[RGB] : ((RGB >> 16) & 0x0000FF) + (RGB & 0x00FF00) + ((RGB & 0x0000FF) << 16))
}