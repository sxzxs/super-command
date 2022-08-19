;by ahker, 2397633100@qq.com
;https://gitee.com/kazhafeizhale/imgui4ahk
;https://github.com/thedemons/imgui-autoit
;dx修复工具
;https://pan.baidu.com/s/1cvOX239c03QIxh8EGFfqfQ?pwd=5tsw 
;32位编译器：
;char      short      int      long      float      double      指针
;1            2        4         4       4              8         4
;64位编译器：
;char      short      int      long      float      double      指针
;1            2         4        8        4             8         8
IMGUI := _ImGui_Load_dll()
__imgui_created := False
ImDrawList_ptr := 0, ImDraw_offset_x := 0, ImDraw_offset_y := 0

FLT_MAX         				          :=  3.402823466e+38

ImGuiWindowFlags_None                   :=  0
ImGuiWindowFlags_NoTitleBar             := 1<<0
ImGuiWindowFlags_NoResize               := 1<<1
ImGuiWindowFlags_NoMove                 := 1<<2
ImGuiWindowFlags_NoScrollbar            := 1<<3
ImGuiWindowFlags_NoScrollWithMouse      := 1<<4
ImGuiWindowFlags_NoCollapse             := 1<<5
ImGuiWindowFlags_AlwaysAutoResize       := 1<<6
ImGuiWindowFlags_NoBackground           := 1<<7
ImGuiWindowFlags_NoSavedSettings        := 1<<8
ImGuiWindowFlags_NoMouseInputs          := 1<<9
ImGuiWindowFlags_MenuBar                := 1<<10
ImGuiWindowFlags_HorizontalScrollbar    := 1<<11
ImGuiWindowFlags_NoFocusOnAppearing     := 1<<12
ImGuiWindowFlags_NoBringToFrontOnFocus  := 1<<13
ImGuiWindowFlags_AlwaysVerticalScrollbar:= 1<<14
ImGuiWindowFlags_AlwaysHorizontalScrollbar:= 1<<15
ImGuiWindowFlags_AlwaysUseWindowPadding := 1<<16
ImGuiWindowFlags_NoNavInputs            := 1<<18
ImGuiWindowFlags_NoNavFocus             := 1<<19
ImGuiWindowFlags_UnsavedDocument        := 1<<20
ImGuiWindowFlags_NoDocking              := 1<<21
ImGuiWindowFlags_NoNav                  :=  ImGuiWindowFlags_NoNavInputs |  ImGuiWindowFlags_NoNavFocus
ImGuiWindowFlags_NoDecoration           :=  ImGuiWindowFlags_NoTitleBar| ImGuiWindowFlags_NoResize | ImGuiWindowFlags_NoScrollbar |  ImGuiWindowFlags_NoCollapse
ImGuiWindowFlags_NoInputs               :=  ImGuiWindowFlags_NoMouseInputs | ImGuiWindowFlags_NoNavInputs |  ImGuiWindowFlags_NoNavFocus
ImGuiWindowFlags_NavFlattened           := 1<<23
ImGuiWindowFlags_ChildWindow            := 1<<24
ImGuiWindowFlags_Tooltip                := 1<<25
ImGuiWindowFlags_Popup                  := 1<<26
ImGuiWindowFlags_Modal                  := 1<<27
ImGuiWindowFlags_ChildMenu              := 1<<28
ImGuiWindowFlags_DockNodeHost           := 1<<29

ImGuiInputTextFlags_None                := 0
ImGuiInputTextFlags_CharsDecimal        := 1<< 0
ImGuiInputTextFlags_CharsHexadecimal    := 1<<1
ImGuiInputTextFlags_CharsUppercase      := 1<<2
ImGuiInputTextFlags_CharsNoBlank        := 1<<3
ImGuiInputTextFlags_AutoSelectAll       := 1<<4
ImGuiInputTextFlags_EnterReturnsTrue    := 1<<5
ImGuiInputTextFlags_CallbackCompletion  := 1<<6
ImGuiInputTextFlags_CallbackHistory     := 1<<7
ImGuiInputTextFlags_CallbackAlways      := 1<<8
ImGuiInputTextFlags_CallbackCharFilter  := 1<<9
ImGuiInputTextFlags_AllowTabInput       := 1<<10
ImGuiInputTextFlags_CtrlEnterForNewLine := 1<<11
ImGuiInputTextFlags_NoHorizontalScroll  := 1<<12
ImGuiInputTextFlags_AlwaysOverwrite    := 1<<13
ImGuiInputTextFlags_ReadOnly            := 1<<14
ImGuiInputTextFlags_Password            := 1<<15
ImGuiInputTextFlags_NoUndoRedo          := 1<<16
ImGuiInputTextFlags_CharsScientific     := 1<<17
ImGuiInputTextFlags_CallbackResize      := 1<<18
ImGuiInputTextFlags_CallbackEdit        := 1<<19   ; Callback on any edit (note that InputText() already returns true on edit, the callback is useful mainly to manipulate the underlying buffer while focus is active)
ImGuiInputTextFlags_AlwaysInsertMode    := ImGuiInputTextFlags_AlwaysOverwrite   ; [renamed in 1.82] name was not matching behavior

ImGuiTreeNodeFlags_None                 :=  0
ImGuiTreeNodeFlags_Selected             := 1<<0
ImGuiTreeNodeFlags_Framed               := 1<<1
ImGuiTreeNodeFlags_AllowItemOverlap     := 1<<2
ImGuiTreeNodeFlags_NoTreePushOnOpen     := 1<<3
ImGuiTreeNodeFlags_NoAutoOpenOnLog      := 1<<4
ImGuiTreeNodeFlags_DefaultOpen          := 1<<5
ImGuiTreeNodeFlags_OpenOnDoubleClick    := 1<<6
ImGuiTreeNodeFlags_OpenOnArrow          := 1<<7
ImGuiTreeNodeFlags_Leaf                 := 1<<8
ImGuiTreeNodeFlags_Bullet               := 1<<9
ImGuiTreeNodeFlags_FramePadding         := 1<<10
ImGuiTreeNodeFlags_SpanAvailWidth       := 1<<11
ImGuiTreeNodeFlags_SpanFullWidth        := 1<<12
ImGuiTreeNodeFlags_NavLeftJumpsBackHere := 1<<13
ImGuiTreeNodeFlags_CollapsingHeader     := ImGuiTreeNodeFlags_Framed | ImGuiTreeNodeFlags_NoTreePushOnOpen |  ImGuiTreeNodeFlags_NoAutoOpenOnLog

ImGuiPopupFlags_None                    :=  0
ImGuiPopupFlags_MouseButtonLeft         :=  0
ImGuiPopupFlags_MouseButtonRight        :=  1
ImGuiPopupFlags_MouseButtonMiddle       :=  2
ImGuiPopupFlags_MouseButtonMask_        :=  0x1F
ImGuiPopupFlags_MouseButtonDefault_     :=  1
ImGuiPopupFlags_NoOpenOverExistingPopup := 1<<5
ImGuiPopupFlags_NoOpenOverItems         := 1<<6
ImGuiPopupFlags_AnyPopupId              := 1<<7
ImGuiPopupFlags_AnyPopupLevel           := 1<<8
ImGuiPopupFlags_AnyPopup                := ImGuiPopupFlags_AnyPopupId |  ImGuiPopupFlags_AnyPopupLevel

ImGuiSelectableFlags_None               :=  0
ImGuiSelectableFlags_DontClosePopups    := 1<<0
ImGuiSelectableFlags_SpanAllColumns     := 1<<1
ImGuiSelectableFlags_AllowDoubleClick   := 1<<2
ImGuiSelectableFlags_Disabled           := 1<<3
ImGuiSelectableFlags_AllowItemOverlap   := 1<<4

ImGuiComboFlags_None                    :=  0
ImGuiComboFlags_PopupAlignLeft          := 1<<0
ImGuiComboFlags_HeightSmall             := 1<<1
ImGuiComboFlags_HeightRegular           := 1<<2
ImGuiComboFlags_HeightLarge             := 1<<3
ImGuiComboFlags_HeightLargest           := 1<<4
ImGuiComboFlags_NoArrowButton           := 1<<5
ImGuiComboFlags_NoPreview               := 1<<6
ImGuiComboFlags_HeightMask_             := ImGuiComboFlags_HeightSmall | ImGuiComboFlags_HeightRegular | ImGuiComboFlags_HeightLarge |  ImGuiComboFlags_HeightLargest

ImGuiTabBarFlags_None                           :=  0
ImGuiTabBarFlags_Reorderable                    := 1<<0
ImGuiTabBarFlags_AutoSelectNewTabs              := 1<<1
ImGuiTabBarFlags_TabListPopupButton             := 1<<2
ImGuiTabBarFlags_NoCloseWithMiddleMouseButton   := 1<<3
ImGuiTabBarFlags_NoTabListScrollingButtons      := 1<<4
ImGuiTabBarFlags_NoTooltip                      := 1<<5
ImGuiTabBarFlags_FittingPolicyResizeDown        := 1<<6
ImGuiTabBarFlags_FittingPolicyScroll            := 1<<7
ImGuiTabBarFlags_FittingPolicyMask_             := ImGuiTabBarFlags_FittingPolicyResizeDown |  ImGuiTabBarFlags_FittingPolicyScroll
ImGuiTabBarFlags_FittingPolicyDefault_          := ImGuiTabBarFlags_FittingPolicyResizeDown

ImGuiTabItemFlags_None                          := 0
ImGuiTabItemFlags_UnsavedDocument               := 1 << 0   ; Display a dot next to the title + tab is selected when clicking the X + closure is not assumed (will wait for user to stop submitting the tab). Otherwise closure is assumed when pressing the X, so if you keep submitting the tab may reappear at end of tab bar.
ImGuiTabItemFlags_SetSelected                   := 1 << 1   ; Trigger flag to programmatically make the tab selected when calling BeginTabItem()
ImGuiTabItemFlags_NoCloseWithMiddleMouseButton  := 1 << 2   ; Disable behavior of closing tabs (that are submitted with p_open != NULL) with middle mouse button. You can still repro this behavior on user's side with if (IsItemHovered() && IsMouseClicked(2)) *p_open = false.
ImGuiTabItemFlags_NoPushId                      := 1 << 3   ; Don't call PushID(tab->ID)/PopID() on BeginTabItem()/EndTabItem()
ImGuiTabItemFlags_NoTooltip                     := 1 << 4   ; Disable tooltip for the given tab
ImGuiTabItemFlags_NoReorder                     := 1 << 5   ; Disable reordering this tab or having another tab cross over this tab
ImGuiTabItemFlags_Leading                       := 1 << 6   ; Enforce the tab position to the left of the tab bar (after the tab list popup button)
ImGuiTabItemFlags_Trailing                      := 1 << 7   ; Enforce the tab position to the right of the tab bar (before the scrolling buttons)


ImGuiFocusedFlags_None                          := 0
ImGuiFocusedFlags_ChildWindows                  := 1 << 0   ; Return true if any children of the window is focused
ImGuiFocusedFlags_RootWindow                    := 1 << 1   ; Test from root window (top most parent of the current hierarchy)
ImGuiFocusedFlags_AnyWindow                     := 1 << 2   ; Return true if any window is focused. Important: If you are trying to tell how to dispatch your low-level inputs, do NOT use this. Use 'io.WantCaptureMouse' instead! Please read the FAQ!
ImGuiFocusedFlags_NoPopupHierarchy              := 1 << 3   ; Do not consider popup hierarchy (do not treat popup emitter as parent of popup) (when used with _ChildWindows or _RootWindow)
ImGuiFocusedFlags_DockHierarchy                 := 1 << 4   ; Consider docking hierarchy (treat dockspace host as parent of docked window) (when used with _ChildWindows or _RootWindow)
ImGuiFocusedFlags_RootAndChildWindows           := ImGuiFocusedFlags_RootWindow | ImGuiFocusedFlags_ChildWindows



ImGuiHoveredFlags_None                          := 0        ; Return true if directly over the item/window, not obstructed by another window, not obstructed by an active popup or modal blocking inputs under them.
ImGuiHoveredFlags_ChildWindows                  := 1 << 0   ; IsWindowHovered() only: Return true if any children of the window is hovered
ImGuiHoveredFlags_RootWindow                    := 1 << 1   ; IsWindowHovered() only: Test from root window (top most parent of the current hierarchy)
ImGuiHoveredFlags_AnyWindow                     := 1 << 2   ; IsWindowHovered() only: Return true if any window is hovered
ImGuiHoveredFlags_NoPopupHierarchy              := 1 << 3   ; IsWindowHovered() only: Do not consider popup hierarchy (do not treat popup emitter as parent of popup) (when used with _ChildWindows or _RootWindow)
ImGuiHoveredFlags_DockHierarchy                 := 1 << 4   ; IsWindowHovered() only: Consider docking hierarchy (treat dockspace host as parent of docked window) (when used with _ChildWindows or _RootWindow)
ImGuiHoveredFlags_AllowWhenBlockedByPopup       := 1 << 5   ; Return true even if a popup window is normally blocking access to this item/window
;ImGuiHoveredFlags_AllowWhenBlockedByModal     := 1 << 6,   ; Return true even if a modal popup window is normally blocking access to this item/window. FIXME-TODO: Unavailable yet.
ImGuiHoveredFlags_AllowWhenBlockedByActiveItem  := 1 << 7   ; Return true even if an active item is blocking access to this item/window. Useful for Drag and Drop patterns.
ImGuiHoveredFlags_AllowWhenOverlapped           := 1 << 8   ; IsItemHovered() only: Return true even if the position is obstructed or overlapped by another window
ImGuiHoveredFlags_AllowWhenDisabled             := 1 << 9   ; IsItemHovered() only: Return true even if the item is disabled
ImGuiHoveredFlags_NoNavOverride                 := 1 << 10  ; Disable using gamepad/keyboard navigation state when active, always query mouse.
ImGuiHoveredFlags_RectOnly                      := ImGuiHoveredFlags_AllowWhenBlockedByPopup | ImGuiHoveredFlags_AllowWhenBlockedByActiveItem | ImGuiHoveredFlags_AllowWhenOverlapped,
ImGuiHoveredFlags_RootAndChildWindows           := ImGuiHoveredFlags_RootWindow | ImGuiHoveredFlags_ChildWindows



ImGuiDockNodeFlags_None                         :=  0
ImGuiDockNodeFlags_KeepAliveOnly                := 1<<0
ImGuiDockNodeFlags_NoDockingInCentralNode       := 1<<2
ImGuiDockNodeFlags_PassthruCentralNode          := 1<<3
ImGuiDockNodeFlags_NoSplit                      := 1<<4
ImGuiDockNodeFlags_NoResize                     := 1<<5
ImGuiDockNodeFlags_AutoHideTabBar               := 1<<6

ImGuiDragDropFlags_None                         :=  0
ImGuiDragDropFlags_SourceNoPreviewTooltip       := 1<<0
ImGuiDragDropFlags_SourceNoDisableHover         := 1<<1
ImGuiDragDropFlags_SourceNoHoldToOpenOthers     := 1<<2
ImGuiDragDropFlags_SourceAllowNullID            := 1<<3
ImGuiDragDropFlags_SourceExtern                 := 1<<4
ImGuiDragDropFlags_SourceAutoExpirePayload      := 1<<5
ImGuiDragDropFlags_AcceptBeforeDelivery         := 1<<10
ImGuiDragDropFlags_AcceptNoDrawDefaultRect      := 1<<11
ImGuiDragDropFlags_AcceptNoPreviewTooltip       := 1<<12
ImGuiDragDropFlags_AcceptPeekOnly               := ImGuiDragDropFlags_AcceptBeforeDelivery |  ImGuiDragDropFlags_AcceptNoDrawDefaultRect

ImGuiDataType_S8 := 0
ImGuiDataType_U8 := 1
ImGuiDataType_S16 := 2
ImGuiDataType_U16 := 3
ImGuiDataType_S32 := 4
ImGuiDataType_U32 := 5
ImGuiDataType_S64 := 6
ImGuiDataType_U64 := 7
ImGuiDataType_Float := 8
ImGuiDataType_Double := 9
ImGuiDataType_COUNT := 10

ImGuiDir_None    :=  -1
ImGuiDir_Left    :=  0
ImGuiDir_Right   :=  1
ImGuiDir_Up      :=  2
ImGuiDir_Down    :=  3


ImGuiKey_None := 0,
;Todo

ImGuiNavInput_Activate := 0
ImGuiNavInput_Cancel := 1
ImGuiNavInput_Input := 2
ImGuiNavInput_Menu := 3
ImGuiNavInput_DpadLeft := 4
ImGuiNavInput_DpadRight := 5
ImGuiNavInput_DpadUp := 6
ImGuiNavInput_DpadDown := 7
ImGuiNavInput_LStickLeft := 8
ImGuiNavInput_LStickRight := 9
ImGuiNavInput_LStickUp := 10
ImGuiNavInput_LStickDown := 11
ImGuiNavInput_FocusPrev := 12
ImGuiNavInput_FocusNext := 13
ImGuiNavInput_TweakSlow := 14
ImGuiNavInput_TweakFast := 15

ImGuiNavInput_KeyLeft_ := 16
ImGuiNavInput_KeyRight_ := 17
ImGuiNavInput_KeyUp_ := 18
ImGuiNavInput_KeyDown_ := 19
ImGuiNavInput_COUNT := 20


ImGuiConfigFlags_None                   :=  0
ImGuiConfigFlags_NavEnableKeyboard      := 1<<0
ImGuiConfigFlags_NavEnableGamepad       := 1<<1
ImGuiConfigFlags_NavEnableSetMousePos   := 1<<2
ImGuiConfigFlags_NavNoCaptureKeyboard   := 1<<3
ImGuiConfigFlags_NoMouse                := 1<<4
ImGuiConfigFlags_NoMouseCursorChange    := 1<<5
ImGuiConfigFlags_DockingEnable          := 1<<6

ImGuiConfigFlags_ViewportsEnable        := 1<<10
ImGuiConfigFlags_DpiEnableScaleViewports:= 1<<14
ImGuiConfigFlags_DpiEnableScaleFonts    := 1<<15
ImGuiConfigFlags_IsSRGB                 := 1<<20
ImGuiConfigFlags_IsTouchScreen          := 1<<21

ImGuiBackendFlags_None                  :=  0
ImGuiBackendFlags_HasGamepad            := 1<<0
ImGuiBackendFlags_HasMouseCursors       := 1<<1
ImGuiBackendFlags_HasSetMousePos        := 1<<2
ImGuiBackendFlags_RendererHasVtxOffset  := 1<<3
ImGuiBackendFlags_PlatformHasViewports  := 1<<10
ImGuiBackendFlags_HasMouseHoveredViewport:= 1<<11
ImGuiBackendFlags_RendererHasViewports  := 1<<12

ImGuiCol_Text := 0
ImGuiCol_TextDisabled := 1
ImGuiCol_WindowBg := 2
ImGuiCol_ChildBg := 3
ImGuiCol_PopupBg := 4
ImGuiCol_Border := 5
ImGuiCol_BorderShadow := 6
ImGuiCol_FrameBg := 7
ImGuiCol_FrameBgHovered := 8
ImGuiCol_FrameBgActive := 9
ImGuiCol_TitleBg := 10
ImGuiCol_TitleBgActive := 11
ImGuiCol_TitleBgCollapsed := 12
ImGuiCol_MenuBarBg := 13
ImGuiCol_ScrollbarBg := 14
ImGuiCol_ScrollbarGrab := 15
ImGuiCol_ScrollbarGrabHovered := 16
ImGuiCol_ScrollbarGrabActive := 17
ImGuiCol_CheckMark := 18
ImGuiCol_SliderGrab := 19
ImGuiCol_SliderGrabActive := 20
ImGuiCol_Button := 21
ImGuiCol_ButtonHovered := 22
ImGuiCol_ButtonActive := 23
ImGuiCol_Header := 24
ImGuiCol_HeaderHovered := 25
ImGuiCol_HeaderActive := 26
ImGuiCol_Separator := 27
ImGuiCol_SeparatorHovered := 28
ImGuiCol_SeparatorActive := 29
ImGuiCol_ResizeGrip := 30
ImGuiCol_ResizeGripHovered := 31
ImGuiCol_ResizeGripActive := 32
ImGuiCol_Tab := 33
ImGuiCol_TabHovered := 34
ImGuiCol_TabActive := 35
ImGuiCol_TabUnfocused := 36
ImGuiCol_TabUnfocusedActive := 37
ImGuiCol_DockingPreview := 38
ImGuiCol_DockingEmptyBg := 39
ImGuiCol_PlotLines := 40
ImGuiCol_PlotLinesHovered := 41
ImGuiCol_PlotHistogram := 42
ImGuiCol_PlotHistogramHovered := 43
ImGuiCol_TableHeaderBg := 44         ; Table header background
ImGuiCol_TableBorderStrong := 45     ; Table outer and header borders (prefer using Alpha=1.0 here)
ImGuiCol_TableBorderLight := 46     ; Table inner borders (prefer using Alpha=1.0 here)
ImGuiCol_TableRowBg := 47            ; Table row background (even rows)
ImGuiCol_TableRowBgAlt := 48         ; Table row background (odd rows)
ImGuiCol_TextSelectedBg := 49
ImGuiCol_DragDropTarget := 50
ImGuiCol_NavHighlight := 51          ; Gamepad/keyboard: current highlighted item
ImGuiCol_NavWindowingHighlight := 52 ; Highlight window when using CTRL+TAB
ImGuiCol_NavWindowingDimBg := 53     ; Darken/colorize entire screen behind the CTRL+TAB window list, when active
ImGuiCol_ModalWindowDimBg := 54      ; Darken/colorize entire screen behind a modal window, when one is active


ImGuiStyleVar_Alpha := 0               ; float     Alpha
ImGuiStyleVar_DisabledAlpha := 1       ; float     DisabledAlpha
ImGuiStyleVar_WindowPadding := 2       ; ImVec2    WindowPadding
ImGuiStyleVar_WindowRounding := 3      ; float     WindowRounding
ImGuiStyleVar_WindowBorderSize := 4    ; float     WindowBorderSize
ImGuiStyleVar_WindowMinSize := 5       ; ImVec2    WindowMinSize
ImGuiStyleVar_WindowTitleAlign := 6    ; ImVec2    WindowTitleAlign
ImGuiStyleVar_ChildRounding := 7       ; float     ChildRounding
ImGuiStyleVar_ChildBorderSize := 8     ; float     ChildBorderSize
ImGuiStyleVar_PopupRounding := 9       ; float     PopupRounding
ImGuiStyleVar_PopupBorderSize := 10     ; float     PopupBorderSize
ImGuiStyleVar_FramePadding := 11        ; ImVec2    FramePadding
ImGuiStyleVar_FrameRounding := 12       ; float     FrameRounding
ImGuiStyleVar_FrameBorderSize := 13     ; float     FrameBorderSize
ImGuiStyleVar_ItemSpacing := 14         ; ImVec2    ItemSpacing
ImGuiStyleVar_ItemInnerSpacing := 15    ; ImVec2    ItemInnerSpacing
ImGuiStyleVar_IndentSpacing := 16       ; float     IndentSpacing
ImGuiStyleVar_CellPadding := 17         ; ImVec2    CellPadding
ImGuiStyleVar_ScrollbarSize := 18       ; float     ScrollbarSize
ImGuiStyleVar_ScrollbarRounding := 19   ; float     ScrollbarRounding
ImGuiStyleVar_GrabMinSize := 20         ; float     GrabMinSize
ImGuiStyleVar_GrabRounding := 21        ; float     GrabRounding
ImGuiStyleVar_TabRounding := 22         ; float     TabRounding
ImGuiStyleVar_ButtonTextAlign := 23     ; ImVec2    ButtonTextAlign
ImGuiStyleVar_SelectableTextAlign := 24 ; ImVec2    SelectableTextAlign
ImGuiStyleVar_COUNT := 25

ImGuiColorEditFlags_None            :=  0
ImGuiColorEditFlags_NoAlpha         := 1<<1
ImGuiColorEditFlags_NoPicker        := 1<<2
ImGuiColorEditFlags_NoOptions       := 1<<3
ImGuiColorEditFlags_NoSmallPreview  := 1<<4
ImGuiColorEditFlags_NoInputs        := 1<<5
ImGuiColorEditFlags_NoTooltip       := 1<<6
ImGuiColorEditFlags_NoLabel         := 1<<7
ImGuiColorEditFlags_NoSidePreview   := 1<<8
ImGuiColorEditFlags_NoDragDrop      := 1<<9
ImGuiColorEditFlags_NoBorder        := 1<<10
ImGuiColorEditFlags_AlphaBar        := 1<<16
ImGuiColorEditFlags_AlphaPreview    := 1<<17
ImGuiColorEditFlags_AlphaPreviewHalf:= 1<<18
ImGuiColorEditFlags_HDR             := 1<<19
ImGuiColorEditFlags_DisplayRGB      := 1<<20
ImGuiColorEditFlags_DisplayHSV      := 1<<21
ImGuiColorEditFlags_DisplayHex      := 1<<22
ImGuiColorEditFlags_Uint8           := 1<<23
ImGuiColorEditFlags_Float           := 1<<24
ImGuiColorEditFlags_PickerHueBar    := 1<<25
ImGuiColorEditFlags_PickerHueWheel  := 1<<26
ImGuiColorEditFlags_InputRGB        := 1<<27
ImGuiColorEditFlags_InputHSV        := 1<<28

ImGuiColorEditFlags__OptionsDefault := ImGuiColorEditFlags_Uint8 | ImGuiColorEditFlags_DisplayRGB | ImGuiColorEditFlags_InputRGB |  ImGuiColorEditFlags_PickerHueBar
ImGuiColorEditFlags__DisplayMask    := ImGuiColorEditFlags_DisplayRGB | ImGuiColorEditFlags_DisplayHSV |  ImGuiColorEditFlags_DisplayHex
ImGuiColorEditFlags__DataTypeMask   := ImGuiColorEditFlags_Uint8 |  ImGuiColorEditFlags_Float
ImGuiColorEditFlags__PickerMask     := ImGuiColorEditFlags_PickerHueWheel |  ImGuiColorEditFlags_PickerHueBar
ImGuiColorEditFlags__InputMask      := ImGuiColorEditFlags_InputRGB |  ImGuiColorEditFlags_InputHSV

ImGuiMouseButton_Left :=  0
ImGuiMouseButton_Right :=  1
ImGuiMouseButton_Middle :=  2
ImGuiMouseButton_COUNT :=  5

ImGuiMouseCursor_None :=  -1
ImGuiMouseCursor_Arrow :=  0
ImGuiMouseCursor_TextInput := 1
ImGuiMouseCursor_ResizeAll := 2
ImGuiMouseCursor_ResizeNS := 3
ImGuiMouseCursor_ResizeEW := 4
ImGuiMouseCursor_ResizeNESW := 5
ImGuiMouseCursor_ResizeNWSE := 6
ImGuiMouseCursor_Hand := 7
ImGuiMouseCursor_NotAllowed := 8


ImGuiCond_None          :=  0
ImGuiCond_Always        := 1<<0
ImGuiCond_Once          := 1<<1
ImGuiCond_FirstUseEver  := 1<<2
ImGuiCond_Appearing     := 1<<3


ImDrawCornerFlags_None      :=  0
ImDrawCornerFlags_TopLeft   := 16
ImDrawCornerFlags_TopRight  := 32
ImDrawCornerFlags_BotLeft   := 64
ImDrawCornerFlags_BotRight  := 128
ImDrawCornerFlags_All := 240
ImDrawCornerFlags_Top       := ImDrawCornerFlags_TopLeft |  ImDrawCornerFlags_TopRight
ImDrawCornerFlags_Bot       := ImDrawCornerFlags_BotLeft |  ImDrawCornerFlags_BotRight
ImDrawCornerFlags_Left      := ImDrawCornerFlags_TopLeft |  ImDrawCornerFlags_BotLeft
ImDrawCornerFlags_Right     := ImDrawCornerFlags_TopRight |  ImDrawCornerFlags_BotRight

ImDrawListFlags_None             :=  0
ImDrawListFlags_AntiAliasedLines := 1<<0
ImDrawListFlags_AntiAliasedLinesUseTex  := 1 << 1  ; Enable anti-aliased lines/borders using textures when possible. Require backend to render with bilinear filtering (NOT point/nearest filtering).
ImDrawListFlags_AntiAliasedFill  := 1<<2
ImDrawListFlags_AllowVtxOffset   := 1<<3

_ImGui_Load_dll()
{
    SplitPath(A_LineFile,,&dir)
    path := ""
    if(A_IsCompiled)
    {
        path := A_PtrSize == 4 ? (A_ScriptDir . "/lib/dll_32/") : (A_ScriptDir . "/lib/dll_64/")
    }
    else
    {
        path := A_PtrSize == 4 ? (dir . "/dll_32/") : (dir . "/dll_64/")
    }
    dllcall("SetDllDirectory", "Str", path)
    hModule := DllCall("LoadLibrary", "Str", "imgui.dll", "Ptr")
    return hModule
}

_ImGui_EnableViewports(enable := True)
{
    DllCall("imgui\EnableViewports","Int", enable)
}

_ImGui_EnableDocking(enable := True)
{
	io := _ImGui_GetIO()
    ConfigFlags := NumGet(io , 0, "Int")
    set := enable ? (ConfigFlags | ImGuiConfigFlags_DockingEnable ) : (ConfigFlags ^ ImGuiConfigFlags_DockingEnable )
    NumPut("Int", set, io)
}
_ImGui_SetWindowTitleAlign(x := 0.5, y := 0.5)
{
    imstyle := _ImGui_GetStyle()
    NumPut("float", x, "float", y, imstyle, 28)
}

;GUI_API const ImWchar*    GetGlyphRangesDefault();                // Basic Latin, Extended Latin
;GUI_API const ImWchar*    GetGlyphRangesKorean();                 // Default + Korean characters
;GUI_API const ImWchar*    GetGlyphRangesJapanese();               // Default + Hiragana, Katakana, Half-Width, Selection of 1946 Ideographs
;GUI_API const ImWchar*    GetGlyphRangesChineseFull();            // Default + Half-Width + Japanese Hiragana/Katakana + full set of about 21000 CJK Unified Ideographs
;GUI_API const ImWchar*    GetGlyphRangesChineseSimplifiedCommon();// Default + Half-Width + Japanese Hiragana/Katakana + set of 2500 CJK Unified Ideographs for common simplified Chinese
;GUI_API const ImWchar*    GetGlyphRangesCyrillic();               // Default + about 400 Cyrillic characters
;GUI_API const ImWchar*    GetGlyphRangesThai();                   // Default + Thai characters
;GUI_API const ImWchar*    GetGlyphRangesVietnamese();             // Default + Vietnamese characters
/**
* 创建窗口
* @param src 图像
* @param w h x y 窗口大小和坐标
* @param style 
* @param exstyle
* @font_path 字体路径
*	- "c://xxx.ttf"
*   - 内存加载
*		- from_memory_ali
*		- from_memory_simhei
* @font_size 字体大小
* @font_range 字体的范围
*	- GetGlyphRangesDefault
*	- GetGlyphRangesKorean
*	- GetGlyphRangesJapanese
*	- GetGlyphRangesChineseFull
*	- GetGlyphRangesChineseSimplifiedCommon
*	- GetGlyphRangesCyrillic
*	- GetGlyphRangesThai
*	- GetGlyphRangesVietnamese
* @range_charBuf 从配置文件中读取的字体范围, 配合_Imgui_load_font_range 使用
*/
_ImGui_GUICreate(title, w, h, x := -1, y := -1, style := 0, ex_style := 0, font_path := "c:/windows/fonts/simhei.ttf", font_size := 20, font_range := "GetGlyphRangesChineseFull", range_charBuf := 0)
{
    global __imgui_created
    if(__imgui_created)
        return False
	result := DllCall("imgui\GUICreate", "wstr", title, "int", w, "int", h, "int", x, "int", y, "wstr", font_path, "float", font_size, "wstr", font_range, "ptr", range_charBuf)
    if(style != 0)
        DllCall("SetWindowLong", "Ptr", result, "Int", -16 ,"Int", style)
    if(ex_style != 0)
        DllCall("SetWindowLong", "Ptr", result, "Int", -20, "Int", ex_style)
	__imgui_created := True
    return result
}
_ImGui_PeekMsg()
{
	result := DllCall("imgui\PeekMsg")
    return result
}

; ####======================================================================================================
; ####\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
; ####======================================================================================================
; ####\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

;Main
_ImGui_GetIO()
{
	result := DllCall("imgui\GetIO", "Cdecl Ptr")
	return result
}

_ImGui_GetStyle()
{
    result := Dllcall("imgui\GetStyle", "Cdecl Ptr")
	return Imgui_style(result)	
}
_ImGui_BeginFrame()
{
   DllCall("imgui\BeginFrame", "Cdecl")
}
_ImGui_EndFrame()
{
   DllCall("imgui\EndFrame", "UInt", 0x004488, "Cdecl")
}
;Style
_ImGui_StyleColorsLight()
{
	DllCall("imgui\StyleColorsLight")
}

_ImGui_StyleColorsDark()
{
	DllCall("imgui\StyleColorsDark")
}
_ImGui_StyleColorsClassic()
{
	DllCall("imgui\StyleColorsClassic")
}

;window
_ImGui_Begin(title, close_btn := 0, flags := 0)
{
	is_open := 1
	if(close_btn)
    	DllCall("imgui\Begin", "WStr", title, "int *", &is_open, "Int", flags, "Cdecl")
	else
    	DllCall("imgui\Begin", "WStr", title, "int *", 0, "Int", flags, "Cdecl")
	return is_open
}
_ImGui_End()
{
   DllCall("imgui\End", "Cdecl")
}

; // Child Windows
;flags := ImGuiWindowFlags_None
 _ImGui_BeginChild(text, w := 0, h := 0, border := False, flags := 0)
 {

	result := Dllcall("imgui\BeginChild", "wstr", text, "float", w, "float", h, "int", border, "int", flags)
	Return result
}
_ImGui_EndChild()
{
	Dllcall("imgui\EndChild")
}


_ImGui_IsWindowAppearing()
{
    result := Dllcall("imgui\IsWindowAppearing")
    Return result
}

_ImGui_IsWindowCollapsed()
{
	result := Dllcall("imgui\IsWindowCollapsed")
	Return result
}

;flags := ImGuiFocusedFlags_None
_ImGui_IsWindowFocused(flags := 0)
{
	result := Dllcall("imgui\IsWindowFocused", "int", flags)
	Return result[0]
}
_ImGui_IsWindowHovered(flags := 0)
{
	result := Dllcall("imgui\IsWindowHovered", "int", flags)
	Return result[0]
}

_ImGui_GetWindowDrawList()
{
	result := Dllcall("imgui\GetWindowDrawList")
	Return result
}

_ImGui_GetOverlayDrawList()
{
	result := Dllcall("imgui\GetOverlayDrawList")
	Return result
}
_ImGui_GetBackgroundDrawList()
{
	result := Dllcall("imgui\GetBackgroundDrawList")
	Return result
}
_ImGui_GetForegroundDrawList()
{
	result := Dllcall("imgui\GetForegroundDrawList")
	Return result
}
_ImGui_GetWindowDpiScale()
{
	result := Dllcall("imgui\GetWindowDpiScale")
	Return result
}

_ImGui_GetWindowViewport()
{
	result := Dllcall("imgui\GetWindowViewport")
	return result
}

_ImGui_GetWindowPos()
{
	Return ___ImGui_RecvImVec2("none:cdecl", "GetWindowPos")
}

_ImGui_GetWindowSize()
{
	Return ___ImGui_RecvImVec2("none:cdecl", "GetWindowSize")
}

_ImGui_GetWindowWidth()
{
	result := Dllcall("imgui\GetWindowWidth")
	Return result
}

_ImGui_GetWindowHeight()
{
	result := Dllcall("imgui\GetWindowHeight")
	Return result
}
;cond := ImGuiCond_None
_ImGui_SetNextWindowPos(x, y, cond := 0, pivot_x := 0, pivot_y := 0)
{
	Dllcall("imgui\SetNextWindowPos", "float", x, "float", y, "int", cond, "float", pivot_x, "float", pivot_y)
}
_ImGui_SetNextWindowSize(x, y, cond := 0)
{
	Dllcall("imgui\SetNextWindowSize", "float", x, "float", y, "int", cond)
}
_ImGui_SetNextWindowSizeConstraints(size_min_x, size_min_y, size_max_x, size_max_y)
{
	Dllcall("imgui\SetNextWindowSizeConstraints", "float", size_min_x, "float", size_min_y, "float", size_max_x, "float", size_max_y)
}

_ImGui_SetNextWindowContentSize(size_x, size_y)
{
	Dllcall("imgui\SetNextWindowContentSize", "float", size_x, "float", size_y)
}
_ImGui_SetNextWindowCollapsed(collapsed, cond := 0)
{
	Dllcall("imgui\SetNextWindowCollapsed", "int", collapsed, "int", cond)
}
_ImGui_SetNextWindowFocus()
{
	Dllcall("imgui\SetNextWindowFocus")
}
_ImGui_SetNextWindowBgAlpha(alpha)
{
	Dllcall("imgui\SetNextWindowBgAlpha", "float", alpha)
}
_ImGui_SetNextWindowViewport(id)
{
	Dllcall("imgui\SetNextWindowViewport", "int", id)
}
_ImGui_SetWindowPos(pos_x, pos_y, cond:=0)
{
	Dllcall("imgui\SetWindowPosition", "float", pos_x, "float", pos_y, "int", cond)
}
_ImGui_SetWindowSize(size_x, size_y, cond:=0)
{
	Dllcall("imgui\SetWindowSize", "float", size_x, "float", size_y, "int", cond)
}

_ImGui_SetWindowCollapsed(collapsed, cond := 0)
{
	Dllcall("imgui\SetWindowCollapsed", "int", collapsed, "int", cond)
}

_ImGui_SetWindowFocus()
{
	Dllcall("imgui\SetWindowFocus")
}

_ImGui_SetWindowFontScale(scale)
{
	Dllcall("imgui\SetWindowFontScale", "float", scale)
}
_ImGui_SetWindowPosByName(name, pos_x, pos_y, cond := 0)
{
	Dllcall("imgui\SetWindowPosByName", "wstr", name, "float", pos_x, "float", pos_y, "int", cond)
}

_ImGui_SetWindowSizeByName(name, size_x, size_y, cond := 0)
{
	Dllcall("imgui\SetWindowSizeByName", "wstr", name, "float", size_x, "float", size_y, "int", cond)
}

_ImGui_SetWindowCollapsedByName(name, collapsed, cond := 0)
{
	result := Dllcall("imgui\SetWindowCollapsedByName", "wstr", name, "int", collapsed, "int", cond)
	Return result
}
_ImGui_SetWindowFocusByName(name)
{
	Dllcall("imgui\SetWindowFocus", "wstr", name)
}

___ImGui_RecvImVec2(return_type, func_name)
{
	struct_x := buffer("4", 0)
	struct_y := buffer("4", 0)
	result := DllCall("imgui\" func_name, "ptr", struct_x, "ptr", struct_y)
    ret := [NumGet(struct_x, 0, "float"), NumGet(struct_y, 0, "float")]
	Return ret
}

_ImGui_GetContentRegionMax()
{
	Return ___ImGui_RecvImVec2("none:cdecl", "GetContentRegionMax")
}
_ImGui_GetContentRegionAvail()
{
	Return ___ImGui_RecvImVec2("none:cdecl", "GetContentRegionAvail")
}
_ImGui_GetWindowContentRegionMin()
{
	Return ___ImGui_RecvImVec2("none:cdecl", "GetWindowContentRegionMin")
}
_ImGui_GetWindowContentRegionMax()
{
	Return ___ImGui_RecvImVec2("none:cdecl", "GetWindowContentRegionMax")
}
_ImGui_GetItemRectMin()
{
	Return ___ImGui_RecvImVec2("none:cdecl", "GetItemRectMin")
}
_ImGui_GetItemRectMax()
{
	Return ___ImGui_RecvImVec2("none:cdecl", "GetItemRectMax")
}
_ImGui_GetItemRectSize()
{
	Return ___ImGui_RecvImVec2("none:cdecl", "GetItemRectSize")
}
_ImGui_GetMousePos()
{
	Return ___ImGui_RecvImVec2("none:cdecl", "GetMousePos")
}
_ImGui_GetMousePosOnOpeningCurrentPopup()
{
	Return ___ImGui_RecvImVec2("none:cdecl", "GetMousePosOnOpeningCurrentPopup")
}
;button := ImGuiMouseButton_Left
_ImGui_GetMouseDragDelta(button := 0, lock_threshold := -1)
{
    struct_x := buffer(4, 0)
    struct_y := buffer(4, 0)
	result := Dllcall("imgui\GetMouseDragDelta", "int", button, "float", lock_threshold, "ptr", struct_x,"ptr", struct_y)
    ret := [NumGet(struct_x, 0, "float"), NumGet(struct_y, 4, "float")]
	Return ret
}

_ImGui_GetWindowContentRegionWidth()
{
	result := Dllcall("imgui\GetWindowContentRegionWidth")
	Return result
}
_ImGui_GetScrollX()
{
	result := Dllcall("imgui\GetScrollX")
	Return result
}
_ImGui_GetScrollY()
{
	result := Dllcall("imgui\GetScrollY")
	Return result
}
_ImGui_GetScrollMaxX()
{
	result := Dllcall("imgui\GetScrollMaxX")
	Return result
}
_ImGui_GetScrollMaxY()
{
	result := Dllcall("imgui\GetScrollMaxY")
	Return result
}
_ImGui_SetScrollX(scroll_x)
{
	Dllcall("imgui\SetScrollX", "float", scroll_x)
}
_ImGui_SetScrollY(scroll_y)
{
	Dllcall("imgui\SetScrollY", "float", scroll_y)
}
_ImGui_SetScrollHereX(center_x_ratio := 0.5)
{
	Dllcall("imgui\SetScrollHereX", "float", center_x_ratio)
}
_ImGui_SetScrollHereY(center_y_ratio := 0.5)
{
	Dllcall("imgui\SetScrollHereY", "float", center_y_ratio)
}
_ImGui_SetScrollFromPosX(local_x, center_x_ratio := 0.5)
{
	Dllcall("imgui\SetScrollFromPosX", "float", local_x, "float", center_x_ratio)
}
_ImGui_SetScrollFromPosY(local_y, center_y_ratio := 0.5)
{
	Dllcall("imgui\SetScrollFromPosY", "float", local_y, "float", center_y_ratio)
}
_ImGui_PushFont(font)
{
	Dllcall("imgui\PushFont", "ptr", font)
}
_ImGui_PopFont()
{
	Dllcall("imgui\PopFont")
}
_ImGui_PushStyleColor(idx, col)
{
	Dllcall("imgui\PushStyleColor", "int", idx, "uint", col)
}
_ImGui_PopStyleColor(count := 1)
{
	Dllcall("imgui\PopStyleColor", "int", count)
}
_ImGui_PushStyleVar(idx, val)
{
	Dllcall("imgui\PushStyleVar", "int", idx, "float", val)
}
_ImGui_PushStyleVarPos(idx, val_x, val_y)
{
	Dllcall("imgui\PushStyleVarPos", "int", idx, "float", val_x, "float", val_y)
}
_ImGui_PopStyleVar(count := 1)
{
	Dllcall("imgui\PopStyleVar", "int", count)
}
_ImGui_GetFont()
{
	result := Dllcall("imgui\GetFont")
	Return result
}
_ImGui_GetFontSize()
{
	result := Dllcall("imgui\GetFontSize")
	Return result
}
_ImGui_GetFontTexUvWhitePixel()
{
	Return ___ImGui_RecvImVec2("none:cdecl", "GetFontTexUvWhitePixel")
}


_ImGui_GetColorU32(idx, alpha_mul := 1)
{
	result := Dllcall("imgui\GetColorU32", "int", idx, "float", alpha_mul)
	Return result
}
_ImGui_PushItemWidth(item_width)
{
	Dllcall("imgui\PushItemWidth", "float", item_width)
}
_ImGui_PopItemWidth()
{
	Dllcall("imgui\PopItemWidth")
}
_ImGui_SetNextItemWidth(item_width)
{
	Dllcall("imgui\SetNextItemWidth", "float", item_width)
}
_ImGui_CalcItemWidth()
{
	result := Dllcall("imgui\CalcItemWidth")
	Return result
}
_ImGui_PushTextWrapPos(wrap_pos_x := 0)
{
	Dllcall("imgui\PushTextWrapPos", "float", wrap_pos_x)
}
_ImGui_PopTextWrapPos()
{
	Dllcall("imgui\PopTextWrapPos")
}
_ImGui_PushAllowKeyboardFocus(allow_keyboard_focus)
{
	Dllcall("imgui\PushAllowKeyboardFocus", "int", allow_keyboard_focus)
}
_ImGui_PopAllowKeyboardFocus()
{
	Dllcall("imgui\PopAllowKeyboardFocus")
}
_ImGui_PushButtonRepeat(repeat)
{
	Dllcall("imgui\PushButtonRepeat", "int", repeat)
}
_ImGui_PopButtonRepeat()
{
	Dllcall("imgui\PopButtonRepeat")
}
_ImGui_Separator()
{
	Dllcall("imgui\Separator")
}
_ImGui_SameLine(offset_from_start_x := 0, spacing_w := -1)
{
	Dllcall("imgui\SameLine", "float", offset_from_start_x, "float", spacing_w)
}
_ImGui_NewLine()
{
	Dllcall("imgui\NewLine")
}
_ImGui_Spacing()
{
	Dllcall("imgui\Spacing")
}
_ImGui_Dummy(size_x, size_y)
{
	Dllcall("imgui\Dummy", "float", size_x, "float", size_y)
}
_ImGui_Indent(indent_w := 0)
{
	Dllcall("imgui\Indent", "float", indent_w)
}
_ImGui_Unindent(indent_w := 0)
{
	Dllcall("imgui\Unindent", "float", indent_w)
}
_ImGui_BeginGroup()
{
	Dllcall("imgui\BeginGroup")
}
_ImGui_EndGroup()
{
	Dllcall("imgui\EndGroup")
}
_ImGui_GetCursorPos()
{
	Return ___ImGui_RecvImVec2("none:cdecl", "GetCursorPosition")
}
_ImGui_SetCursorPos(local_pos_x, local_pos_y)
{
	Dllcall("imgui\SetCursorPosition", "float", local_pos_x, "float", local_pos_y)
}
_ImGui_GetCursorPosX()
{
	result := Dllcall("imgui\GetCursorPosX")
	Return result
}
_ImGui_GetCursorPosY()
{
	result := Dllcall("imgui\GetCursorPosY")
	Return result
}
_ImGui_SetCursorPosX(x)
{
	Dllcall("imgui\SetCursorPosX", "float", x)
}
_ImGui_SetCursorPosY(y)
{
	Dllcall("imgui\SetCursorPosY", "float", y)
}
_ImGui_GetCursorStartPos()
{
	Return ___ImGui_RecvImVec2("none:cdecl", "GetCursorStartPos")
}
_ImGui_GetCursorScreenPos()
{
	Return ___ImGui_RecvImVec2("none:cdecl", "GetCursorScreenPos")
}
_ImGui_SetCursorScreenPos(pos_x, pos_y)
{
	Dllcall("imgui\SetCursorScreenPos", "float", pos_x, "float", pos_y)
}
_ImGui_AlignTextToFramePadding()
{
	Dllcall("imgui\AlignTextToFramePadding")
}
_ImGui_GetTextLineHeight()
{
	result := Dllcall("imgui\GetTextLineHeight")
	Return result
}
_ImGui_GetTextLineHeightWithSpacing()
{
	result := Dllcall("imgui\GetTextLineHeightWithSpacing")
	Return result
}
_ImGui_GetFrameHeight()
{
	result := Dllcall("imgui\GetFrameHeight")
	Return result
}
_ImGui_GetFrameHeightWithSpacing()
{
	result := Dllcall("imgui\GetFrameHeightWithSpacing")
	Return result
}
_ImGui_PushID(str_id)
{
	Dllcall("imgui\PushID", "wstr", str_id)
}
_ImGui_PopID()
{
	Dllcall("imgui\PopID")
}
_ImGui_GetID(str_id)
{
	result := Dllcall("imgui\GetID", "wstr", str_id)
	Return result
}

_ImGui_Text(text)
{
	Dllcall("imgui\Text", "wstr", text)
}

_ImGui_TextColored(text, color := 0xFFFFFFFF)
{
	Dllcall("imgui\TextColored", "uint", color, "wstr", text)
}
_ImGui_TextDisabled(text)
{
	Dllcall("imgui\TextDisabled", "wstr", text)
}
_ImGui_TextWrapped(text)
{
	Dllcall("imgui\TextWrapped", "wstr", text)
}
_ImGui_LabelText(label, text)
{
	Dllcall("imgui\LabelText", "wstr", label, "wstr", text)
}

_ImGui_BulletText(text)
{
	Dllcall("imgui\BulletText", "wstr", text)
}
_ImGui_Button(text, w := 0, h := 0)
{
	return DllCall("imgui\Button", "wstr", text, "float", w, "float", h)
}

_ImGui_SmallButton(label)
{
	result := Dllcall("imgui\SmallButton", "wstr", label)
	Return result
}
_ImGui_InvisibleButton(str_id, size_x, size_y)
{
	result := Dllcall("imgui\InvisibleButton", "wstr", str_id, "float", size_x, "float", size_y)
	Return result
}
;ImGuiDir_Up
_ImGui_ArrowButton(str_id, dir := 2)
{
	result := DllCall("imgui\ArrowButton", "wstr", str_id, "int", dir)
	Return result
}
_ImGui_Image(user_texture_id, size_x, size_y, uv0_x := 0, uv0_y := 0, uv1_x := 1, uv1_y := 1, tint_col := 0xFFFFFFFF, border_col := 0)
{
	Dllcall("imgui\Image", "int", user_texture_id, "float", size_x, "float", size_y, "float", uv0_x, "float", uv0_y, "float", uv1_x, "float", uv1_y, "uint", tint_col, "uint", border_col)
}

_ImGui_ImageButton(user_texture_id, size_x, size_y, uv0_x := 0, uv0_y := 0, uv1_x := 1, uv1_y := 1, frame_padding := -1, bg_col := 0, tint_col := 0xFFFFFFFF)
{
	result := DllCall("imgui\ImageButton", "int", user_texture_id, "float", size_x, "float", size_y, "float", uv0_x, "float", uv0_y, "float", uv1_x, "float", uv1_y, "int", frame_padding, "uint", bg_col, "uint", tint_col)
    return result
}
_ImGui_CheckBox(text, &active)
{
    b_active := buffer(4, 0)
    NumPut("Int", active, b_active)
	result := DllCall("imgui\Checkbox", "wstr", text, "ptr", b_active)
    active := NumGet(b_active, 0, "Int")
    return result
}

_ImGui_CheckboxFlags(label, &flags, flags_value)
{
	struct_flags := buffer(4, 0)
    NumPut("UInt", flags, struct_flags)
	result := Dllcall("imgui\CheckboxFlags", "wstr", label, "ptr", struct_flags, "uint", flags_value)
	flags := Numget(struct_flags, 0, "uint")
	Return result
}
_ImGui_RadioButton(label, &v, v_button)
{
	struct_v := buffer(4, 0)
    NumPut("Int", v, struct_v)
	result := DllCall("imgui\RadioButton", "wstr", label, "ptr", struct_v, "int", v_button)
    v := NumGet(struct_v, 0, "Int")
    return result
}

_ImGui_ProgressBar(fraction, size_arg_x := -1, size_arg_y := 0, overlay := "")
{
	Dllcall("imgui\ProgressBar", "float", fraction, "float", size_arg_x, "float", size_arg_y, "wstr", overlay)
}
_ImGui_Bullet()
{
	Dllcall("imgui\Bullet")
}
;flags := ImGuiComboFlags_None
_ImGui_BeginCombo(label, preview_value, flags := 0)
{
	result := Dllcall("imgui\BeginCombo", "wstr", label, "wstr", preview_value, "int", flags)
	Return result
}
_ImGui_EndCombo()
{
	Dllcall("imgui\EndCombo")
}


_ImGui_SetStyleColor(index, color := 0xFFFFFFFF)
{
	Dllcall("imgui\SetStyleColor", "int", index, "uint", color)
}
;flags := ImGuiSelectableFlags_None
_ImGui_Selectable(label, selected := False, flags := 0, size_arg_x := 0, size_arg_y := 0)
{
	result := Dllcall("imgui\Selectable", "wstr", label, "int", selected, "int", flags, "float", size_arg_x, "float", size_arg_y)
	Return result
}
_ImGui_Columns(columns_count := 1, id := "", border := true)
{
	Dllcall("imgui\Columns", "int", columns_count, "wstr", id, "int", border)
}
_ImGui_NextColumn()
{
	Dllcall("imgui\NextColumn")
}
_ImGui_GetColumnIndex()
{
	result := Dllcall("imgui\GetColumnIndex")
	Return result
}
_ImGui_GetColumnWidth(column_index := -1)
{
	result := Dllcall("imgui\GetColumnWidth", "int", column_index)
	Return result
}
_ImGui_SetColumnWidth(column_index, width)
{
	Dllcall("imgui\SetColumnWidth", "int", column_index, "float", width)
}
_ImGui_GetColumnOffset(column_index := -1)
{
	result := Dllcall("imgui\GetColumnOffset", "int", column_index)
	Return result
}
_ImGui_SetColumnOffset(column_index, offset)
{
	Dllcall("imgui\SetColumnOffset", "int", column_index, "float", offset)
}
_ImGui_GetColumnsCount()
{
	result := Dllcall("imgui\GetColumnsCount")
	Return result
}
_ImGui_DragFloat(label, &v, v_speed := 1, v_min := 0, v_max := 0, format := "%3.f", power := 1)
{
    struct_v := buffer(4, 0)
    numput("float", v, struct_v)
	result := Dllcall("imgui\DragFloat", "wstr", label, "ptr", struct_v, "float", v_speed, "float", v_min, "float", v_max, "wstr", format, "float", power)
    v := numget(struct_v, 0, "float")
	Return result
}
_ImGui_DragFloat2(label, v, v_speed := 1, v_min := 0, v_max := 0, format := "%.3f", power := 1)
{
	Return ___ImGui_DragFloatN(2, label, v, v_speed, v_min, v_max, format, power)
}
_ImGui_DragFloat3(label, v, v_speed := 1, v_min := 0, v_max := 0, format := "%.3f", power := 1)
{
	Return ___ImGui_DragFloatN(3, label, v, v_speed, v_min, v_max, format, power)
}
_ImGui_DragFloat4(label, v, v_speed := 1, v_min := 0, v_max := 0, format := "%.3f", power := 1)
{
	Return ___ImGui_DragFloatN(4, label, v, v_speed, v_min, v_max, format, power)
}

___ImGui_DragFloatN(n, label, &v, v_speed, v_min, v_max, format, power)
{
    if(n < 2 || n > 4 || v.Length < n)
        return false
    struct_value := buffer(4 * n, 0)
    loop(n)
        numput("float", v[A_Index], struct_value, (a_index -1) * 4)
	result := Dllcall("imgui\DragFloatN"
		"int", n
		"wstr", label
		"ptr", struct_value
		"float", v_speed
		"float", v_min
		"float", v_max
		"wstr", format
		"float", power
	)
    loop(n)
        v[A_Index] := numget(struct_value, (a_index - 1) * 4, "float")
	Return result
}


_ImGui_DragFloatRange2(label, &v_current_min, &v_current_max, v_speed := 1, v_min := 0, v_max := 0, format := "%.3f", format_max := "", power := 1)
{
    struct_v_current_min := buffer(4, 0)
    numput("float", v_current_min, struct_v_current_min)
    struct_v_current_max := buffer(4, 0)
    numput("float", v_current_max, struct_v_current_max)
	result := Dllcall("imgui\DragFloatRange2", "wstr", label, "ptr", struct_v_current_min, "ptr", struct_v_current_max, "float", v_speed, "float", v_min, "float", v_max, "wstr", format, "wstr", format_max, "float", power)
    v_current_min := numget(struct_v_current_min, 0, "float")
    v_current_max := numget(struct_v_current_max, 0, "float")
	Return result
}

_ImGui_DragInt(label, &v, v_speed := 1, v_min := 0, v_max := 0, format := "%d")
{
    struct_v := buffer(4, 0)
    numput("int", v, struct_v)
	result := Dllcall("imgui\DragInt", "wstr", label, "ptr", struct_v, "float", v_speed, "int", v_min, "int", v_max, "wstr", format)
    v := numget(struct_v, 0, "int")
	Return result
}
 _ImGui_DragInt2(label, &v, v_speed := 1, v_min := 0, v_max := 0, format :="%d")
 {
	___ImGui_DragIntN(2, label, v, v_speed, v_min, v_max, format)
}
_ImGui_DragInt3(label, &v, v_speed := 1, v_min := 0, v_max := 0, format :="%d")
{
	___ImGui_DragIntN(3, label, v, v_speed, v_min, v_max, format)
}
_ImGui_DragInt4(label, &v, v_speed := 1, v_min := 0, v_max := 0, format :="%d")
{
	___ImGui_DragIntN(4, label, v, v_speed, v_min, v_max, format)
}
___ImGui_DragIntN(n, label, &v, v_speed, v_min, v_max, format)
{
    if(n < 2 || n > 4 || v.Length < n)
        return false
    struct_value := buffer(4 * n, 0)
    loop(n)
        numput("int", v[A_Index], struct_value, (a_index -1) * 4)
	result := Dllcall("imgui\DragIntN",
		"int", n,
		"wstr", label,
		"ptr", struct_value,
		"float", v_speed,
		"int", v_min,
		"int", v_max,
		"wstr", format
	)
    loop(n)
        v[A_Index] := numget(struct_value, (a_index - 1) * 4, "int")
	Return result
}

_ImGui_DragIntRange2(label, &v_current_min, &v_current_max, v_speed := 1, v_min := 0, v_max := 0, format := "%.3f", format_max := "")
{
    struct_v_current_min := buffer(4, 0)
    numput("int", v_current_min, struct_v_current_min)
    struct_v_current_max := buffer(4, 0)
    numput("int", v_current_max, struct_v_current_max)
	result := Dllcall("imgui\DragIntRange2", "wstr", label, "ptr", struct_v_current_min, "ptr", struct_v_current_max, "float", v_speed, "int", v_min, "int", v_max, "wstr", format, "wstr", format_max)
    v_current_min := numget(struct_v_current_min, 0, "int")
    v_current_max := numget(struct_v_current_max, 0, "int")
	Return result
}

_ImGui_SliderFloat(text, &value, v_min, v_max, format := "%.3f", power := 1)
{
    struct := buffer(4, 0)
    numput("float", value, struct)
	result := Dllcall("imgui\SliderFloat", "wstr", text, "ptr", struct, "float", v_min, "float", v_max, "wstr", format, "float", power)
    value := numget(struct, 0, "float")
	Return result
}


_ImGui_SliderFloat2(label, &v, v_min, v_max, format := "%.3f", power := 1)
{
	___ImGui_SliderFloatN(2, label, v, v_min, v_max, format, power)
}
_ImGui_SliderFloat3(label, &v, v_min, v_max, format := "%.3f", power := 1)
{
	___ImGui_SliderFloatN(3, label, v, v_min, v_max, format, power)
}
_ImGui_SliderFloat4(label, &v, v_min, v_max, format := "%.3f", power := 1)
{
	___ImGui_SliderFloatN(4, label, v, v_min, v_max, format, power)
}

___ImGui_SliderFloatN(n, label, &v, v_min, v_max, format, power)
{
    if(n < 2 || n > 4 || v.Length < n)
        return false
    struct_value := buffer(4 * n, 0)
    loop(n)
        numput("float", v[A_Index], struct_value, (a_index -1) * 4)
	result := Dllcall("imgui\SliderFloatN",
		"int", n,
		"wstr", label,
		"ptr", struct_value,
		"float", v_min,
		"float", v_max,
		"wstr", format,
		"float", power
	)
    loop(n)
        v[A_Index] := numget(struct_value, (a_index - 1) * 4, "float")
	Return result
}

_ImGui_SliderInt(label, &v, v_min, v_max, format := "%d")
{
    struct := buffer(4, 0)
    numput("int", v, struct)
	result := Dllcall("imgui\SliderInt", "wstr", label, "ptr", struct, "int", v_min, "int", v_max, "wstr", format)
    v := numget(struct, 0, "int")
	Return result
}

_ImGui_SliderInt2(label, &v, v_min, v_max, format := "%d")
{
	return ___ImGui_SliderIntN(2, label, &v, v_min, v_max, format)
}
_ImGui_SliderInt3(label, &v, v_min, v_max, format := "%d")
{
	return ___ImGui_SliderIntN(3, label, &v, v_min, v_max, format)
}
_ImGui_SliderInt4(label, &v, v_min, v_max, format := "%d")
{
	return ___ImGui_SliderIntN(4, label, &v, v_min, v_max, format)
}

___ImGui_SliderIntN(n, label, &v, v_min, v_max, format)
{
    if(n < 2 || n > 4 || v.Length < n)
        return false
    struct_value := buffer(4 * n, 0)
    loop(n)
        numput("int", v[A_Index], struct_value, (a_index -1) * 4)
	result := Dllcall("imgui\SliderIntN",
		"int", n,
		"wstr", label,
		"ptr",struct_value,
		"int", v_min,
		"int", v_max,
		"wstr", format
	)
    loop(n)
        v[A_Index] := numget(struct_value, (a_index - 1) * 4, "int")
	Return result
}

_ImGui_SliderAngle(label, &v_rad, v_degrees_min := -360, v_degrees_max := 360, format := "%.0f deg")
{
    struct_v_rad := buffer(4, 0)
    numput("float", v_rad, struct_v_rad)
	result := Dllcall("imgui\SliderAngle", "wstr", label, "ptr", struct_v_rad, "float", v_degrees_min, "float", v_degrees_max, "wstr", format)
    v_rad := numget(struct_v_rad, 0, "float")
	Return result
}
_ImGui_VSliderFloat(label, size_x, size_y, &v, v_min, v_max, format := "%.3f", power := 1)
{
    struct_v := buffer(4, 0)
    numput("float", v, struct_v)
	result := Dllcall("imgui\VSliderFloat", "wstr", label, "float", size_x, "float", size_y, "ptr", struct_v, "float", v_min, "float", v_max, "wstr", format, "float", power)
    v := numget(struct_v, 0, "float")
	Return result
}

_ImGui_VSliderInt(label, size_x, size_y, &v, v_min, v_max, format := "%d")
{
	struct_v := buffer(4, 0)
    numput("int", v, struct_v)
	result := Dllcall("imgui\VSliderInt", "wstr", label, "float", size_x, "float", size_y, "ptr", struct_v, "int", v_min, "int", v_max, "wstr", format)
    v := numget(struct_v, 0, "int")
	Return result
}
;flags := ImGuiInputTextFlags_None := 0
_ImGui_InputText(label, &buf, flags := 0, buf_size := 128000, call_back := 0)
{
	struct_buf := Buffer(buf_size, 0)
    StrPut(buf, struct_buf)
	result := Dllcall("imgui\InputText", "wstr", label, "ptr", struct_buf, "int", buf_size, "int", flags, "ptr", call_back, "ptr", 0)
    buf := StrGet(struct_buf, 10240)
	Return result
}
 
_ImGui_InputTextMultiline(label, &buf, size_x := 0, size_y := 0, flags := 0, buf_size := 128000)
{
	struct_buf := Buffer(buf_size, 0)
    StrPut(buf, struct_buf)
	result := Dllcall("imgui\InputTextMultiline", "wstr", label, "ptr", struct_buf, "int", buf_size, "float", size_x, "float", size_y, "int", flags, "ptr", 0, "ptr", 0)
    buf := StrGet(struct_buf, 10240)
	Return result
}

_ImGui_InputTextWithHint(label, hint, &buf, flags := 0, buf_size := 128000)
{
	struct_buf := Buffer(buf_size, 0)
    StrPut(buf, struct_buf)
	result := DllCall("imgui\InputTextWithHint", "wstr", label, "wstr", hint, "ptr", struct_buf, "int", buf_size, "int", flags)
    buf := StrGet(struct_buf, 10240)
}


_ImGui_InputFloat(label, &v, step := 0, step_fast := 0, format := "%.3f", flags := 0)
{
    struct_v := buffer(4, 0)
    numput("float", v, struct_v)
	result := Dllcall("imgui\InputFloat", "wstr", label, "ptr", struct_v, "float", step, "float", step_fast, "wstr", format, "int", flags)
    v := numget(struct_v, 0, "float")
	Return result
}

_ImGui_InputFloat2(label, &v, format := "%.3f", flags := 0)
{
	___ImGui_InputFloatN(2, label, v, format, flags)
}
_ImGui_InputFloat3(label, &v, format := "%.3f", flags := 0)
{
	___ImGui_InputFloatN(3, label, v, format, flags)
}
_ImGui_InputFloat4(label, &v, format := "%.3f", flags := 0)
{
	___ImGui_InputFloatN(4, label, v, format, flags)
}
___ImGui_InputFloatN(n, label, &v, format, flags)
{
    if(n < 2 || n > 4 || v.Length < n)
        return false
    struct_value := buffer(4 * n, 0)
    loop(n)
        numput("float", v[A_Index], struct_value, (a_index -1) * 4)
	result := Dllcall("imgui\InputFloatN",
		"int", n,
		"wstr", label,
		"ptr", struct_value,
		"wstr", format,
		"int", flags
	)
    loop(n)
        v[A_Index] := numget(struct_value, (a_index - 1) * 4, "float")
	Return result
}

;flags := ImGuiInputTextFlags_None := 0
_ImGui_InputInt(label, &v, step := 1, step_fast := 100, flags := 0)
{
    struct_v := buffer(4, 0)
    numput("int", v, struct_v)
	result := Dllcall("imgui\InputInt", "wstr", label, "ptr", struct_v, "int", step, "int", step_fast, "int", flags)
    v := numget(struct_v, 0, "int")
	Return result
}

_ImGui_InputInt2(label, &v, flags := 0)
{
	___ImGui_InputIntN(2, label, v, flags := 0)
}
_ImGui_InputInt3(label, &v, flags := 0)
{
	___ImGui_InputIntN(3, label, v, flags := 0)
}
_ImGui_InputInt4(label, &v, flags := 0)
{
	___ImGui_InputIntN(4, label, v, flags)
}

___ImGui_InputIntN(n, label, &v, flags)
{
    if(n < 2 || n > 4 || v.Length < n)
        return false
    struct_value := buffer(4 * n, 0)
    loop(n)
        numput("int", v[A_Index], struct_value, (a_index -1) * 4)
	result := Dllcall("imgui\InputIntN",
		"int", n,
		"wstr", label,
		"ptr", struct_value,
		"int", flags
	)
    loop(n)
        v[A_Index] := numget(struct_value, (a_index - 1) * 4, "int")
	Return result
}
_ImGui_InputDouble(label, &v, step := 0, step_fast := 0, format := "%.6f", flags := 0)
{
    struct_v := buffer(8, 0)
    numput("double", v, struct_v)
	result := Dllcall("imgui\InputDouble", "wstr", label, "ptr", struct_v, "double", step, "double", step_fast, "wstr", format, "int", flags)
    v := numget(struct_v, 0, "double")
	Return result
}
;flags := ImGuiColorEditFlags_None 0
_ImGui_ColorEdit(label, &color, flags := 0)
{
    struct_v := buffer(4, 0)
    numput("uint", color, struct_v)
	result := Dllcall("imgui\ColorEdit", "wstr", label, "ptr", struct_v, "int", flags)
    color := numget(struct_v, 0, "uint")
	Return result
}
_ImGui_ColorPicker(label, &color, flags := 0)
{
    struct_v := buffer(4, 0)
    numput("uint", color, struct_v)
	result := Dllcall("imgui\ColorPicker", "wstr", label, "ptr", struct_v, "int", flags)
    color := numget(struct_v, 0, "uint")
	Return result
}
_ImGui_TreeNode(label)
{
	result := Dllcall("imgui\TreeNode", "wstr", label)
	Return result
}
;flags := ImGuiTreeNodeFlags_None 0
_ImGui_TreeNodeEx(label, flags := 0)
{
	result := Dllcall("imgui\TreeNodeEx", "wstr", label, "int", flags)
	Return result
}
_ImGui_TreePush(str_id)
{
	Dllcall("imgui\TreePush", "wstr", str_id)
}
_ImGui_TreePop()
{
	Dllcall("imgui\TreePop")
}
_ImGui_GetTreeNodeToLabelSpacing()
{
	result := Dllcall("imgui\GetTreeNodeToLabelSpacing")
	Return result
}
_ImGui_CollapsingHeader(label, flags := 0)
{
	result := Dllcall("imgui\CollapsingHeader", "wstr", label, "int", flags)
	Return result
}
_ImGui_CollapsingHeaderEx(label, &p_open, flags := 0)
{
    struct_p_open := buffer(4, 0)
    numput("int", p_open, struct_p_open)
	result := Dllcall("imgui\CollapsingHeaderEx", "wstr", label, "ptr", struct_p_open, "int", flags)
    p_open := numget(struct_p_open, 0, "int")
	Return result
}
;cond := ImGuiCond_None 0
_ImGui_SetNextItemOpen(is_open, cond := 0)
{
	Dllcall("imgui\SetNextItemOpen", "int", is_open, "int", cond)
}
;item string 数组
; 返回包含字符串的缓冲对象.
StrBuf(str, encoding)
{
    ; 计算所需的大小并分配缓冲.
    buf := Buffer(StrPut(str, encoding))
    ; 复制或转换字符串.
    StrPut(str, buf, encoding)
    return buf
}
_ImGui_ListBox(label, &current_item, items, height_items := -1)
{
    if(Type(items) != "Array")
        return False
	items_count := items.Length

    struct_current_item := buffer(4, 0)
    numput("int", current_item, struct_current_item)

    struct_item_count := buffer(4 * (items_count + 1), 0)
    numput("int", items_count , struct_item_count)

    loop(items_count)
    {
        len := StrLen(items[a_index]) + 1
        NumPut("int", len, struct_item_count,  4 * a_index)
    }
    all_str := ""
    for k,v in items
        all_str .= v . chr(0)
    struct_item := StrBuf(all_str, "UTF-16")
    ;strcut_current_item out 当前index
    ;strcut_item 字符串数组 每个item包含的字符串
    ;strcut_item_count int 数组
    ;[0] 总个数,  [1]-[n] 每个的个数
	result := Dllcall("imgui\ListBox", "wstr", label, "ptr", struct_current_item, "ptr", struct_item, "ptr", struct_item_count, "int", height_items)
    current_item := NumGet(struct_current_item, 0, "Int")
	Return result
}

_ImGui_ListBoxHeader(label, size_arg_x := 0, size_arg_y := 0)
{
	result := Dllcall("imgui\ListBoxHeader", "wstr", label, "float", size_arg_x, "float", size_arg_y)
	Return result
}
_ImGui_ListBoxHeaderEx(label, items_count, height_in_items := -1)
{
	result := Dllcall("imgui\ListBoxHeaderEx", "wstr", label, "int", items_count, "int", height_in_items)
	Return result
}
_ImGui_ListBoxFooter()
{
	Dllcall("imgui\ListBoxFooter")
}

_ImGui_PlotLines(label, values, values_offset := 0, overlay_text := "", scale_min := 3.402823466e+38, scale_max := 3.402823466e+38, graph_size_x := 0, graph_size_y := 0, stride := 4)
{
    if(Type(values) != "Array")
        return False
	count := values.Length
	If values_offset >= count
        values_offset := Mod(values_offset, count)
    struct_values := buffer(4 * count)

    loop(count)
    {
        NumPut("float", values[a_index], struct_values, (a_index - 1) * 4)
    }
	DllCall("imgui\PlotLines", "wstr", label, "ptr", struct_values, "int",
        count, "int", values_offset, "wstr", overlay_text, "float", scale_min, "float", scale_max,
	    "float", graph_size_x, "float", graph_size_y, "int", stride)
}
;scale_min := FLT_MAX         				          :=  3.402823466e+38
;scale_max := FLT_MAX
_ImGui_PlotHistogram(label, values, values_offset := 0, overlay_text := "", scale_min := 3.402823466e+38, scale_max := 3.402823466e+38, graph_size_x := 0, graph_size_y := 0, stride := 4)
{
    if(Type(values) != "Array")
        return False
    count := values.Length
    if( values_offset >= count)
        values_offset := Mod(values_offset, count)
    struct_values := buffer(4 * count, 0)
    loop(count)
        numput("float", values[A_Index], struct_values, (a_index -1) * 4)
	Dllcall("imgui\PlotHistogram", "wstr", label, "ptr", struct_values, "int", count, "int", values_offset, "wstr", overlay_text, "float", scale_min, "float", scale_max, "float", graph_size_x, "float", graph_size_y, "int", stride)
}

_ImGui_ValueBool(prefix, b)
{
	Dllcall("imgui\ValueBool", "wstr", prefix, "int", b)
}
_ImGui_ValueInt(prefix, v)
{
	Dllcall("imgui\ValueInt", "wstr", prefix, "int", v)
}
_ImGui_ValueFloat(prefix, v, float_format := "")
{
	Dllcall("imgui\ValueFloat", "wstr", prefix, "float", v, "wstr", float_format)
}

_ImGui_BeginMenuBar()
{
	result := Dllcall("imgui\BeginMenuBar")
	Return result
}
_ImGui_EndMenuBar()
{
	Dllcall("imgui\EndMenuBar")
}
_ImGui_BeginMainMenuBar()
{
	result := Dllcall("imgui\BeginMainMenuBar")
	Return result
}
_ImGui_EndMainMenuBar()
{
	Dllcall("imgui\EndMainMenuBar")
}
_ImGui_BeginMenu(label, enabled := True)
{
	result := Dllcall("imgui\BeginMenu", "wstr", label, "int", enabled)
	Return result
}
_ImGui_EndMenu()
{
	Dllcall("imgui\EndMenu_")
}
_ImGui_MenuItem(label, shortcut := "", selected := False, enabled := True)
{
	result := Dllcall("imgui\MenuItem", "wstr", label, "wstr", shortcut, "int", selected, "int", enabled)
	Return result
}


_ImGui_MenuItemEx(label, shortcut, &p_selected, enabled := True)
{
    struct_p_selected := buffer(4, 0)
    numput("int", p_selected, struct_p_selected)
	result := Dllcall("imgui\MenuItemEx", "wstr", label, "wstr", shortcut, "ptr", struct_p_selected, "int", enabled)
    p_selected := numget(struct_p_selected, 0, "int")
	Return result
}
 
_ImGui_ShowDemoWindow()
{
	Dllcall("imgui\ShowDemoWindow")
}
_ImGui_ToolTip(text)
{
	_ImGui_BeginTooltip()
	_ImGui_Text(text)
	_ImGui_EndTooltip()
}
 _ImGui_BeginTooltip(){
	Dllcall("imgui\BeginTooltip")
}
_ImGui_EndTooltip()
{
	Dllcall("imgui\EndTooltip")
}
_ImGui_SetTooltip(text)
{
	Dllcall("imgui\SetTooltip", "wstr", text)
}
;flags := ImGuiWindowFlags_None
_ImGui_BeginPopup(str_id, flags := 0)
{
	result := Dllcall("imgui\BeginPopup", "wstr", str_id, "int", flags)
	Return result
}

_ImGui_BeginPopupModal(name, flags := 0)
{

	result := Dllcall("imgui\BeginPopupModal", "wstr", name, "ptr", 0, "int", flags)
	Return result
}

_ImGui_BeginPopupModalEx(name, &p_open, flags := 0)
{
    struct_p_open := buffer(4, 0)
    numput("int", p_open, struct_p_open)
	result := Dllcall("imgui\BeginPopupModal", "wstr", name, "ptr", struct_p_open, "int", flags)
    p_open := numget(struct_p_open, 0, "int")
	Return result
}

_ImGui_EndPopup()
{
	Dllcall("imgui\EndPopup")
}
;popup_flags := ImGuiPopupFlags_MouseButtonLeft         :=  0
_ImGui_OpenPopup(str_id, popup_flags := 0)
{
	Dllcall("imgui\OpenPopup", "wstr", str_id, "int", popup_flags)
}
_ImGui_OpenPopupContextItem(str_id := "", popup_flags := 0)
{
	result := Dllcall("imgui\OpenPopupContextItem", "wstr", str_id, "int", popup_flags)
	Return result
}
_ImGui_CloseCurrentPopup()
{
	Dllcall("imgui\CloseCurrentPopup")
}
_ImGui_BeginPopupContextItem(str_id := "", popup_flags := 0)
{
	result := Dllcall("imgui\BeginPopupContextItem", "wstr", str_id, "int", popup_flags)
	Return result
}
_ImGui_BeginPopupContextWindow(str_id := "", popup_flags := 0)
{
	result := Dllcall("imgui\BeginPopupContextWindow", "wstr", str_id, "int", popup_flags)
	Return result
}
_ImGui_BeginPopupContextVoid(str_id := "", popup_flags := 0)
{
	result := Dllcall("imgui\BeginPopupContextVoid", "wstr", str_id, "int", popup_flags)
	Return result
}
;popup_flags := ImGuiPopupFlags_None                    :=  0
_ImGui_IsPopupOpen(str_id, popup_flags := 0)
{
	result := Dllcall("imgui\IsPopupOpen", "wstr", str_id, "int", popup_flags)
	Return result
}
;flags := ImGuiTabBarFlags_None                           :=  0
 _ImGui_BeginTabBar(str_id, flags := 0){
	result := Dllcall("imgui\BeginTabBar", "wstr", str_id, "int", flags)
	Return result
}
_ImGui_EndTabBar()
{
	Dllcall("imgui\EndTabBar")
}

;flags := ImGuiTabItemFlags_None                          :=  0
_ImGui_BeginTabItemEx(label, &p_open, flags := 0)
{
    struct_p_open := buffer(4, 0)
    numput("float", p_open, struct_p_open)
	result := Dllcall("imgui\BeginTabItem", "wstr", label, "ptr", struct_p_open, "int", flags)
    p_open := numget(struct_p_open, 0, "int")
	Return result
}

_ImGui_BeginTabItem(label, flags := 0)
{
	result := Dllcall("imgui\BeginTabItem", "wstr", label, "ptr", 0, "int", flags)
	Return result
}
 
_ImGui_EndTabItem(){
	Dllcall("imgui\EndTabItem")
}
_ImGui_SetTabItemClosed(label)
{
	Dllcall("imgui\SetTabItemClosed", "wstr", label)
}
;flags := ImGuiDockNodeFlags_None                         :=  0
_ImGui_DockSpace(id, size_arg_x := 0, size_arg_y := 0, flags := 0)
{
	Dllcall("imgui\DockSpace", "int", id, "float", size_arg_x, "float", size_arg_y, "int", flags)
}
;f
_ImGui_DockSpaceOverViewport(viewport := 0, dockspace_flags := 0)
{
	result := Dllcall("imgui\DockSpaceOverViewport", "ptr", viewport, "int", dockspace_flags)
	Return result
}
;cond := ImGuiCond_None 0
_ImGui_SetNextWindowDockID(id, cond := 0)
{
	Dllcall("imgui\SetNextWindowDockID", "int", id, "int", cond)
}
_ImGui_SetNextWindowClass(window_class)
{
	Dllcall("imgui\SetNextWindowClass", "ptr", window_class)
}
_ImGui_GetWindowDockID()
{
	result := Dllcall("imgui\GetWindowDockID")
	Return result
}
_ImGui_IsWindowDocked()
{
	result := Dllcall("imgui\IsWindowDocked")
	Return result
}
;flags := ImGuiDragDropFlags_None                         :=  0
_ImGui_BeginDragDropSource(flags := 0)
{
	result := Dllcall("imgui\BeginDragDropSource", "int", flags)
	Return result
}
_ImGui_PushClipRect(clip_rect_min_x, clip_rect_min_y, clip_rect_max_x, clip_rect_max_y, intersect_with_current_clip_rect)
{
	Dllcall("imgui\PushClipRect", "float", clip_rect_min_x, "float", clip_rect_min_y, "float", clip_rect_max_x, "float", clip_rect_max_y, "int", intersect_with_current_clip_rect)
}
_ImGui_PopClipRect()
{
	Dllcall("imgui\PopClipRect")
}
_ImGui_SetItemDefaultFocus()
{
	Dllcall("imgui\SetItemDefaultFocus")
}
_ImGui_SetKeyboardFocusHere(offset := 0)
{
	Dllcall("imgui\SetKeyboardFocusHere", "int", offset)
}
;flags := ImGuiHoveredFlags_None                          :=  0
_ImGui_IsItemHovered(flags := 0)
{
	result := Dllcall("imgui\IsItemHovered", "int", flags)
	Return result
}
_ImGui_IsItemActive()
{
	result := Dllcall("imgui\IsItemActive")
	Return result
}
_ImGui_IsItemFocused()
{
	result := Dllcall("imgui\IsItemFocused")
	Return result
}
_ImGui_IsItemVisible()
{
	result := Dllcall("imgui\IsItemVisible")
	Return result
}
_ImGui_IsItemEdited()
{
	result := Dllcall("imgui\IsItemEdited")
	Return result
}
_ImGui_IsItemActivated()
{
	result := Dllcall("imgui\IsItemActivated")
	Return result
}
_ImGui_IsItemDeactivated()
{
	result := Dllcall("imgui\IsItemDeactivated")
	Return result
}
_ImGui_IsItemDeactivatedAfterEdit()
{
	result := Dllcall("imgui\IsItemDeactivatedAfterEdit")
	Return result
}
_ImGui_IsItemToggledOpen()
{
	result := Dllcall("imgui\IsItemToggledOpen")
	Return result
}
_ImGui_IsAnyItemHovered()
{
	result := Dllcall("imgui\IsAnyItemHovered")
	Return result
}
_ImGui_IsAnyItemActive()
{
	result := Dllcall("imgui\IsAnyItemActive")
	Return result
}
_ImGui_IsAnyItemFocused()
{
	result := Dllcall("imgui\IsAnyItemFocused")
	Return result
}
_ImGui_SetItemAllowOverlap()
{
	Dllcall("imgui\SetItemAllowOverlap")
}
;mouse_button := ImGuiMouseButton_Left
_ImGui_IsItemClicked(mouse_button := 0)
{
	result := Dllcall("imgui\IsItemClicked", "int", mouse_button)
	Return result
}
_ImGui_IsRectVisible(size_x, size_y)
{
	result := Dllcall("imgui\IsRectVisible", "float", size_x, "float", size_y)
	Return result
}
_ImGui_IsRectVisibleEx(rect_min_x, rect_min_y, rect_max_x, rect_max_y)
{
	result := Dllcall("imgui\IsRectVisibleEx", "float", rect_min_x, "float", rect_min_y, "float", rect_max_x, "float", rect_max_y)
	Return result
}
_ImGui_GetTime()
{
	result := Dllcall("imgui\GetTime")
	Return result
}
_ImGui_GetFrameCount()
{
	result := Dllcall("imgui\GetFrameCount")
	Return result
}
;flags := ImGuiWindowFlags_None
_ImGui_BeginChildFrame(id, size_x, size_y, extra_flags := 0)
{
	result := Dllcall("imgui\BeginChildFrame", "int", id, "float", size_x, "float", size_y, "int", extra_flags)
	Return result
}
_ImGui_EndChildFrame()
{
	Dllcall("imgui\EndChildFrame")
}
_ImGui_CalcTextSize(text, hide_text_after_double_hash := false, wrap_width := -1)
{
    struct_x := buffer(4, 0)
    struct_y := buffer(4, 0)
	result := Dllcall("imgui\CalcTextSize", "wstr", text, "int", hide_text_after_double_hash, "float", wrap_width, "ptr", struct_x, "ptr", struct_y)
    ret := [NumGet(struct_x, 0, "float"), NumGet(struct_y, 0, "float")]
	Return ret
}

_ImGui_GetKeyIndex(imgui_key)
{
	result := Dllcall("imgui\GetKeyIndex", "int", imgui_key)
	Return result
}
_ImGui_IsKeyDown(user_key_index)
{
	result := Dllcall("imgui\IsKeyDown", "int", user_key_index)
	Return result
}
_ImGui_IsKeyPressed(user_key_index, repeat := true)
{
	result := Dllcall("imgui\IsKeyPressed", "int", user_key_index, "int", repeat)
	Return result
}
_ImGui_IsKeyReleased(user_key_index)
{
	result := Dllcall("imgui\IsKeyReleased", "int", user_key_index)
	Return result
}
_ImGui_GetKeyPressedAmount(key_index, repeat_delay, repeat_rate)
{
	result := Dllcall("imgui\GetKeyPressedAmount", "int", key_index, "float", repeat_delay, "float", repeat_rate)
	Return result
}
_ImGui_CaptureKeyboardFromApp(capture)
{
	Dllcall("imgui\CaptureKeyboardFromApp", "int", capture)
}
;mouse_button := ImGuiMouseButton_Left
_ImGui_IsMouseDown(button := 0)
{
	result := Dllcall("imgui\IsMouseDown", "int", button)
	Return result
}
_ImGui_IsMouseClicked(button := 0, repeat := False)
{
	result := Dllcall("imgui\IsMouseClicked", "int", button, "int", repeat)
	Return result
}
_ImGui_IsMouseReleased(button := 0)
{
	result := Dllcall("imgui\IsMouseReleased", "int", button)
	Return result
}
_ImGui_IsMouseHoveringRect(r_min_x, r_min_y, r_max_x, r_max_y, clip := True)
{
	result := Dllcall("imgui\IsMouseHoveringRect", "float", r_min_x, "float", r_min_y, "float", r_max_x, "float", r_max_y, "int", clip)
	Return result
}
_ImGui_IsMousePosValid()
{
	result := Dllcall("imgui\IsMousePosValid")
	Return result
}
_ImGui_IsAnyMouseDown()
{
	result := Dllcall("imgui\IsAnyMouseDown")
	Return result
}
_ImGui_IsMouseDragging(button := 0, lock_threshold := -1)
{
	result := Dllcall("imgui\IsMouseDragging", "int", button, "float", lock_threshold)
	Return result
}
_ImGui_ResetMouseDragDelta(button := 0)
{
	Dllcall("imgui\ResetMouseDragDelta", "int", button)
}
_ImGui_GetMouseCursor()
{
	result := Dllcall("imgui\GetMouseCursor")
	Return result
}
;cursor_type := ImGuiMouseCursor_Arrow :=  0
_ImGui_SetMouseCursor(cursor_type := 0)
{
	Dllcall("imgui\SetMouseCursor", "int", cursor_type)
}
_ImGui_CaptureMouseFromApp(capture)
{
	Dllcall("imgui\CaptureMouseFromApp", "int", capture)
}
_ImGui_LoadIniSettingsFromDisk(ini_filename)
{
	Dllcall("imgui\LoadIniSettingsFromDisk", "wstr", ini_filename)
}
_ImGui_SaveIniSettingsToDisk(ini_filename)
{
	Dllcall("imgui\SaveIniSettingsToDisk", "wstr", ini_filename)
}
_ImGui_GetMainViewport()
{
	result := Dllcall("imgui\GetMainViewport")
	return result
}
_ImGui_UpdatePlatformWindows()
{
	Dllcall("imgui\UpdatePlatformWindows")
}
_ImGui_RenderPlatformWindowsDefault(platform_render_arg, renderer_render_arg)
{
	Dllcall("imgui\RenderPlatformWindowsDefault", "ptr", platform_render_arg, "ptr", renderer_render_arg)
}
_ImGui_DestroyPlatformWindows()
{
	Dllcall("imgui\DestroyPlatformWindows")
}


; ========================================================================================================================================== ImDraw

_ImDraw_SetOffset(x, y)
{
	global ImDraw_offset_x
	global ImDraw_offset_y
	ImDraw_offset_x := x
	ImDraw_offset_y := y
}

_ImDraw_SetDrawList(draw_list)
{
	global ImDrawList_ptr
	ImDrawList_ptr := draw_list
}
_ImDraw_GetDrawList()
{
	Return ImDrawList_ptr
}
_ImDraw_AddLine(p1_x, p1_y, p2_x, p2_y, col := 0xFFFFFFFF, thickness := 1)
{
	Dllcall("imgui\AddLine", "ptr", ImDrawList_ptr, "float", p1_x, "float", p1_y, "float", p2_x, "float", p2_y, "uint", col, "float", thickness)
}

;rounding_corners := ImDrawCornerFlags_All       :=  0xF
_ImDraw_AddRect(x, y, w, h, col := 0xFFFFFFFF, rounding := 0, rounding_corners := 0xF, thickness := 1)
{
	Dllcall("imgui\AddRect",  "ptr", ImDrawList_ptr, "float", x, "float", y, "float", x+w, "float", y+h, "uint", col, "float", rounding, "int", rounding_corners, "float", thickness)
}
;rounding_corners := ImDrawCornerFlags_All       :=  0xF
_ImDraw_AddRectFilled( x, y, w, h, col := 0xFFFFFFFF, rounding := 0, rounding_corners := 0xF)
{
	Dllcall("imgui\AddRectFilled", "ptr", ImDrawList_ptr, "float", x, "float", y, "float", x+w, "float", y+h, "uint", col, "float", rounding, "int", rounding_corners)
}
_ImDraw_AddBezierCurve(p1_x, p1_y, p2_x, p2_y, p3_x, p3_y, p4_x, p4_y, col := 0xFFFFFFFF, thickness := 1, num_segments := 30)
{
	Dllcall("imgui\AddBezierCurve", "ptr", ImDrawList_ptr, "float", p1_x, "float", p1_y, "float", p2_x, "float", p2_y, "float", p3_x, "float", p3_y, "float", p4_x, "float", p4_y, "uint", col, "float", thickness, "int", num_segments)
}
_ImDraw_AddCircle(center_x, center_y, radius, col := 0xFFFFFFFF, num_segments := 30, thickness := 1)
{
	Dllcall("imgui\AddCircle", "ptr", ImDrawList_ptr, "float", center_x, "float", center_y, "float", radius, "uint", col, "int", num_segments, "float", thickness)
}
_ImDraw_AddCircleFilled(center_x, center_y, radius, col := 0xFFFFFFFF, num_segments := 0)
{
    if(!IsSet(p))
        num_segments := radius /3 + 10
    if(ImGuiTreeNodeFlags_DefaultOpen)
	Dllcall("imgui\AddCircleFilled", "ptr", ImDrawList_ptr, "float", center_x, "float", center_y, "float", radius, "uint", col, "int", num_segments)
}


_ImDraw_AddConvexPolyFilled(points, col := 0xFFFFFFFF)
{
    if(Type(points) != "Array")
        return false

    points_count := points.Length
    struct_points := buffer(4 * points_count * 2, 0)
    loop(points_count)
    {
        NumPut("float", points[A_Index][0], 2 * 4 * A_Index)
        NumPut("float", points[A_Index][1], 2 * 4 * A_Index + 1)
    }
	Dllcall("imgui\AddConvexPolyFilled", "ptr", ImDrawList_ptr, "ptr", struct_points, "int", points_count, "uint", col)
}

_ImDraw_AddImage(user_texture_id, p_min_x, p_min_y, p_max_x, p_max_y, uv_min_x := 0, uv_min_y := 0, uv_max_x := 1, uv_max_y := 1, col := 0xFFFFFFFF)
{
	Dllcall("imgui\AddImage", "ptr", ImDrawList_ptr, "int", user_texture_id, "float", p_min_x, "float", p_min_y, "float", p_max_x, "float", p_max_y, "float", uv_min_x, "float", uv_min_y, "float", uv_max_x, "float", uv_max_y, "uint", col)
}
_ImDraw_AddImageQuad(user_texture_id, p1_x, p1_y, p2_x, p2_y, p3_x, p3_y, p4_x, p4_y, uv1_x := 0, uv1_y := 0, uv2_x := 1, uv2_y := 0, uv3_x := 1, uv3_y := 1, uv4_x := 0, uv4_y := 1, col := 0xFFFFFFFF)
{
	Dllcall("imgui\AddImageQuad", "ptr", ImDrawList_ptr, "int", user_texture_id, "float", p1_x, "float", p1_y, "float", p2_x, "float", p2_y, "float", p3_x, "float", p3_y, "float", p4_x, "float", p4_y, "float", uv1_x, "float", uv1_y, "float", uv2_x, "float", uv2_y, "float", uv3_x, "float", uv3_y, "float", uv4_x, "float", uv4_y, "uint", col)
}
;rounding_corners := ImDrawCornerFlags_All       :=  0xF
_ImDraw_AddImageRounded(user_texture_id, p_min_x, p_min_y, p_max_x, p_max_y, uv_min_x := 0, uv_min_y := 0, uv_max_x := 1, uv_max_y := 1, col := 0xFFFFFFFF, rounding := 5, rounding_corners := 0xF)
{
	Dllcall("imgui\AddImageRounded", "ptr", ImDrawList_ptr, "int", user_texture_id, "float", p_min_x, "float", p_min_y, "float", p_max_x, "float", p_max_y, "float", uv_min_x, "float", uv_min_y, "float", uv_max_x, "float", uv_max_y, "uint", col, "float", rounding, "int", rounding_corners)
}
_ImDraw_AddNgon(center_x, center_y, radius, col := 0xFFFFFFFF, num_segments := 5, thickness := 1)
{
	Dllcall("imgui\AddNgon", "ptr", ImDrawList_ptr, "float", center_x, "float", center_y, "float", radius, "uint", col, "int", num_segments, "float", thickness)
}
_ImDraw_AddNgonFilled(center_x, center_y, radius, col := 0xFFFFFFFF, num_segments := 5)
{
	Dllcall("imgui\AddNgonFilled", "ptr", ImDrawList_ptr, "float", center_x, "float", center_y, "float", radius, "uint", col, "int", num_segments)
}

_ImDraw_AddPolyline(points, col := 0xFFFFFFFF, closed := True, thickness := 1)
{
    if(Type(points) != "Array")
        return false
    points_count := points.Length
    struct_points := buffer(4 * points_count * 2, 0)
    loop(points_count)
    {
        NumPut("float", points[A_Index][0], 2 * 4 * A_Index)
        NumPut("float", points[A_Index][1], 2 * 4 * A_Index + 1)
    }
	Dllcall("imgui\AddPolyline", "ptr", ImDrawList_ptr, "ptr", struct_points, "int", points_count, "uint", col, "int", closed, "float", thickness)
}

ImDraw_AddQuad(p1_x, p1_y, p2_x, p2_y, p3_x, p3_y, p4_x, p4_y, col := 0xFFFFFFFF, thickness := 1)
{
	Dllcall("imgui\AddQuad", "ptr", ImDrawList_ptr, "float", p1_x, "float", p1_y, "float", p2_x, "float", p2_y, "float", p3_x, "float", p3_y, "float", p4_x, "float", p4_y, "uint", col, "float", thickness)
}
_ImDraw_AddQuadFilled(p1_x, p1_y, p2_x, p2_y, p3_x, p3_y, p4_x, p4_y, col := 0xFFFFFFFF)
{
	Dllcall("imgui\AddQuadFilled", "ptr", ImDrawList_ptr, "float", p1_x, "float", p1_y, "float", p2_x, "float", p2_y, "float", p3_x, "float", p3_y, "float", p4_x, "float", p4_y, "uint", col)
}
_ImDraw_AddRectFilledMultiColor(p_min_x, p_min_y, p_max_x, p_max_y, col_upr_left, col_upr_right, col_bot_right, col_bot_left)
{
	Dllcall("imgui\AddRectFilledMultiColor", "ptr", ImDrawList_ptr, "float", p_min_x, "float", p_min_y, "float", p_max_x, "float", p_max_y, "uint", col_upr_left, "uint", col_upr_right, "uint", col_bot_right, "uint", col_bot_left)
}
_ImDraw_AddText(text, font, font_size, pos_x, pos_y, col := 0xFFFFFFFF, wrap_width := 0)
{
	Dllcall("imgui\AddText", "ptr", ImDrawList_ptr, "ptr", font, "float", font_size, "float", pos_x, "float", pos_y, "uint", col, "wstr", text, "float", wrap_width)
}
_ImDraw_AddTriangle(p1_x, p1_y, p2_x, p2_y, p3_x, p3_y, col := 0xFFFFFFFF, thickness := 1)
{
	Dllcall("imgui\AddTriangle", "ptr", ImDrawList_ptr, "float", p1_x, "float", p1_y, "float", p2_x, "float", p2_y, "float", p3_x, "float", p3_y, "uint", col, "float", thickness)
}
_ImDraw_AddTriangleFilled(p1_x, p1_y, p2_x, p2_y, p3_x, p3_y, col := 0xFFFFFFFF)
{
	Dllcall("imgui\AddTriangleFilled", "ptr", ImDrawList_ptr, "float", p1_x, "float", p1_y, "float", p2_x, "float", p2_y, "float", p3_x, "float", p3_y, "uint", col)
}
_ImDraw_PathClear()
{
	Dllcall("imgui\PathClear", "ptr", ImDrawList_ptr)
}
_ImDraw_PathLineTo(pos_x, pos_y)
{
	Dllcall("imgui\PathLineTo", "ptr", ImDrawList_ptr, "float", pos_x, "float", pos_y)
}
_ImDraw_PathLineToMergeDuplicate(pos_x, pos_y)
{
	Dllcall("imgui\PathLineToMergeDuplicate", "ptr", ImDrawList_ptr, "float", pos_x, "float", pos_y)
}
_ImDraw_PathFillConvex(col)
{
	Dllcall("imgui\PathFillConvex", "ptr", ImDrawList_ptr, "uint", col)
}
_ImDraw_PathStroke(col, closed, thickness := 1)
{
	Dllcall("imgui\PathStroke", "ptr", ImDrawList_ptr, "uint", col, "boolean", closed, "float", thickness)
}
_ImDraw_PathArcTo(center_x, center_y, radius, a_min_a, a_max, num_segments := 20)
{
	Dllcall("imgui\PathArcTo", "ptr", ImDrawList_ptr, "float", center_x, "float", center_y, "float", radius, "float", a_min, "float", a_max, "int", num_segments)
}
_ImDraw_PathArcToFast(center_x, center_y, radius, a_min_of_12, a_max_of_12)
{
	Dllcall("imgui\PathArcToFast", "ptr", ImDrawList_ptr, "float", center_x, "float", center_y, "float", radius, "int", a_min_of_12, "int", a_max_of_12)
}
_ImDraw_PathBezierCurveTo(p2_x, p2_y, p3_x, p3_y, p4_x, p4_y, num_segments := 0)
{
	Dllcall("imgui\PathBezierCurveTo", "ptr", ImDrawList_ptr, "float", p2_x, "float", p2_y, "float", p3_x, "float", p3_y, "float", p4_x, "float", p4_y, "int", num_segments)
}
;rounding_corners := ImDrawCornerFlags_All       :=  0xF
_ImDraw_PathRect(rect_min_x, rect_min_y, rect_max_x, rect_max_y, rounding := 0, rounding_corners := 0xf)
{
	Dllcall("imgui\PathRect", "ptr", ImDrawList_ptr, "float", rect_min_x, "float", rect_min_y, "float", rect_max_x, "float", rect_max_y, "float", rounding, "int", rounding_corners)
}

;rounding_corners := ImDrawCornerFlags_All       :=  0xF
_ImDraw_AddImageFit(user_texture_id, pos_x, pos_y, size_x := 0, size_y := 0, crop_area := True, rounding := 0, tint_col := 0xFFFFFFFF, rounding_corners := 0xf)
{
	Dllcall("imgui\AddImageFit",
	"ptr", ImDrawList_ptr,
	"ptr", user_texture_id,
	"float", pos_x,
	"float", pos_y,
	"float", size_x,
	"float", size_y,
	"boolean", crop_area,
	"float", rounding,
	"uint", tint_col,
	"int", rounding_corners)
}
;rounding_corners := ImDrawCornerFlags_All       :=  0xF
_ImGui_ImageFit(user_texture_id, size_x := 0, size_y := 0, crop_area := True, rounding := 0, tint_col := 0xFFFFFFFF, rounding_corners := 0xF)
{
	DllCall("imgui\ImageFit",
	    "ptr", user_texture_id,
        "float", size_x,
        "float", size_y,
        "int", crop_area,
        "float", rounding,
        "uint", tint_col,
        "int", rounding_corners)
}
_ImGui_ImageFromFile(file_path)
{
	result := Dllcall("imgui\ImageFromFile", "wstr", file_path)
	Return result
}
_ImGui_ImageFromURL(url)
{
	result := Dllcall("imgui\ImageFromURL", "str", url)
	Return result
}
_ImGui_ImageGetSize(user_texture_id)
{
	if(user_texture_id == 0)
        return false
    struct_x := buffer(4, 0)
    struct_y := buffer(4, 0)
	result := Dllcall("imgui\ImageGetSize", "ptr", user_texture_id, "ptr", struct_x,"ptr", struct_y)
    ret := [NumGet(struct_x, 0, "float"), NumGet(struct_y, 0, "float")]
	Return ret
}

_Imgui_LoadFont(font_path, font_size)
{
	result := DllCall("imgui\LoadFont", "wstr", font_size, "float", font_size, "ptr")
	return result
}

_Imgui_LoadTextureFromFile(filename, &out_srv, &out_width, &out_height)
{
	result := DllCall("imgui\LoadTextureFromFile", "wstr", filename, "int *", &out_srv, "int *", &out_width, "int *", &out_height)
	return result
}

_Imgui_LoadTextureFromMemory(buf, buf_size, &out_srv, &out_width, &out_height)
{
	result := DllCall("imgui\LoadTextureFromMemory", "ptr", buf, "int", buf_size, "int *", &out_srv, "int *", &out_width, "int *", &out_height)
	return result
}

_Imgui_TextureFree(srv)
{
	return DllCall("imgui\TextureFree", "ptr", srv)
}

_Imgui_imgui_stbi__fopen(file_path, mode)
{
	return DllCall("imgui\imgui_stbi__fopen", "wstr", file_path, "wstr", mode)
}

_Imgui_imgui_stbi__start_file(&stbi__context, file_handle)
{
	DllCall("imgui\imgui_stbi__start_file", "ptr", stbi__context, "ptr", file_handle)
}

imgui_stbi__gif_load_next(&stbi__context, &out_srv, &out_width := 0, &out_height := 0, req_comp := 4)
{
	result := DllCall("imgui\imgui_stbi__gif_load_next", "ptr", stbi__context, "int *", &out_srv, "Int", req_comp, "Int *", &out_width, "Int *", &out_height)
	return result
}

_Imgui_imgui_stbi__load_gif(file_path, &out_srv_array, &length, &w, &h, &delay)
{
    struct_value := buffer(A_PtrSize * 1024 * 10, 0)
	DllCall("imgui\imgui_stbi__load_gif", "wstr", file_path, "ptr", struct_value, "int *", &length, "int *", &w, "int *", &h, "int *", &delay)
	loop(length)
		out_srv_array.Push(NumGet(struct_value, (A_Index -1) * A_PtrSize, "ptr"))
}
;EXTERN_DLL_EXPORT  bool imgui_get_custom_font_range(wchar_t* filename, int *out, int *out_length, wchar_t *buff)

_Imgui_load_font_range(file_path, &range_array, &length, &raw_data)
{
    struct_value := buffer(10000 * 4, 0)
    raw_data := buffer(10000 * 4, 0)
	DllCall("imgui\imgui_get_custom_font_range", "wstr", file_path, "ptr", struct_value, "int *", &length, "ptr", raw_data)
	loop(length)
		range_array.Push(NumGet(struct_value, (A_Index -1) * 4, "int"))
}
/*
* 从给定的字符串中获取字符的编码范围
* @string 字符串， utf-16
* @range_array 返回字符串编码数组
* @length 数字数组的长度
* @raw_data 原始字符范围字符串
*/
_Imgui_load_font_range_from_string(string, &range_array, &length, &raw_data)
{
    struct_value := buffer(10000 * 4, 0)
    raw_data := buffer(10000 * 4, 0)
	DllCall("imgui\imgui_get_custom_font_range_from_string", "wstr", string, "ptr", struct_value, "int *", &length, "ptr", raw_data)
	loop(length)
		range_array.Push(NumGet(struct_value, (A_Index -1) * 4, "int"))
}

class Imgui_style
{
	ptr := 0
	size := 0
	__New(ptr) => (this.ptr := ptr, this.size := ptr)
	Alpha
	{
		get => NumGet(this, 0, "float")
		set => NumPut("float", value, this, 0)
	}
	DisabledAlpha
	{
		get => NumGet(this, 4, "float")
		set => NumPut("float", value, this, 4)
	}
	WindowPadding
	{
		get => [NumGet(this, 8, "float"), NumGet(this, 12, "float")]
		set => [NumPut("float", value[1], this, 8), NumPut("float", value[2], this, 12)]
	}
	WindowRounding
	{
		get => NumGet(this, 16, "float")
		set => NumPut("float", value, this, 16)
	}
	WindowBorderSize
	{
		get => NumGet(this, 20, "float")
		set => NumPut("float", value, this, 20)
	}
	WindowMinSize
	{
		get => [NumGet(this, 24, "float"), NumGet(this, 28, "float")]
		set => [NumPut("float", value[1], this, 24), NumPut("float", value[2], this, 28)]
	}
	WindowTitleAlign
	{
		get => [NumGet(this, 32, "float"), NumGet(this, 36, "float")]
		set => [NumPut("float", value[1], this, 32), NumPut("float", value[2], this, 36)]
	}
	WindowMenuButtonPosition
	{
		get => NumGet(this, 40, "float")
		set => NumPut("float", value, this, 40)
	}
	ChildRounding
	{
		get => NumGet(this, 44, "float")
		set => NumPut("float", value, this, 44)
	}
	ChildBorderSize
	{
		get => NumGet(this, 48, "float")
		set => NumPut("float", value, this, 48)
	}
	PopupRounding
	{
		get => NumGet(this, 52, "float")
		set => NumPut("float", value, this, 52)
	}
	PopupBorderSize
	{
		get => NumGet(this, 56, "float")
		set => NumPut("float", value, this, 56)
	}
	FramePadding
	{
		get => [NumGet(this, 60, "float"), NumGet(this, 64, "float")]
		set => [NumPut("float", value[1], this, 60), NumPut("float", value[2], this, 64)]
	}
	FrameRounding
	{
		get => NumGet(this, 68, "float")
		set => NumPut("float", value, this, 68)
	}
	FrameBorderSize
	{
		get => NumGet(this, 72, "float")
		set => NumPut("float", value, this, 72)
	}
	ItemSpacing
	{
		get => [NumGet(this, 76, "float"), NumGet(this, 80, "float")]
		set => [NumPut("float", value[1], this, 76), NumPut("float", value[2], this, 80)]
	}
	ItemInnerSpacing
	{
		get => [NumGet(this, 84, "float"), NumGet(this, 88, "float")]
		set => [NumPut("float", value[1], this, 84), NumPut("float", value[2], this, 88)]
	}
	CellPadding
	{
		get => [NumGet(this, 92, "float"), NumGet(this, 96, "float")]
		set => [NumPut("float", value[1], this, 92), NumPut("float", value[2], this, 96)]
	}
	TouchExtraPadding
	{
		get => [NumGet(this, 100, "float"), NumGet(this, 104, "float")]
		set => [NumPut("float", value[1], this, 100), NumPut("float", value[2], this, 104)]
	}
	IndentSpacing
	{
		get => NumGet(this, 108, "float")
		set => NumPut("float", value, this, 108)
	}
	ColumnsMinSpacing
	{
		get => NumGet(this, 112, "float")
		set => NumPut("float", value, this, 112)
	}
	ScrollbarSize
	{
		get => NumGet(this, 116, "float")
		set => NumPut("float", value, this, 112)
	}
	ScrollbarRounding
	{
		get => NumGet(this, 120, "float")
		set => NumPut("float", value, this, 120)
	}
	GrabMinSize
	{
		get => NumGet(this, 124, "float")
		set => NumPut("float", value, this, 124)
	}
	GrabRounding
	{
		get => NumGet(this, 128, "float")
		set => NumPut("float", value, this, 128)
	}
	LogSliderDeadzone
	{
		get => NumGet(this, 132, "float")
		set => NumPut("float", value, this, 132)
	}
	TabRounding
	{
		get => NumGet(this, 136, "float")
		set => NumPut("float", value, this, 136)
	}
	TabBorderSize
	{
		get => NumGet(this, 140, "float")
		set => NumPut("float", value, this, 140)
	}
	TabMinWidthForCloseButton
	{
		get => NumGet(this, 144, "float")
		set => NumPut("float", value, this, 144)
	}
	ColorButtonPosition
	{
		get => NumGet(this, 148, "float")
		set => NumPut("float", value, this, 148)
	}
	ButtonTextAlign
	{
		get => [NumGet(this, 152, "float"), NumGet(this, 156, "float")]
		set => [NumPut("float", value[1], this, 152), NumPut("float", value[2], this, 156)]
	}
	SelectableTextAlign
	{
		get => [NumGet(this, 160, "float"), NumGet(this, 164, "float")]
		set => [NumPut("float", value[1], this, 160), NumPut("float", value[2], this, 164)]
	}
	DisplayWindowPadding
	{
		get => [NumGet(this, 168, "float"), NumGet(this, 172, "float")]
		set => [NumPut("float", value[1], this, 168), NumPut("float", value[2], this, 172)]
	}
	DisplaySafeAreaPadding
	{
		get => [NumGet(this, 176, "float"), NumGet(this, 180, "float")]
		set => [NumPut("float", value[1], this, 176), NumPut("float", value[2], this, 180)]
	}
	MouseCursorScale
	{
		get => NumGet(this, 184, "float")
		set => NumPut("float", value, this, 184)
	}
	AntiAliasedLines
	{
		get => NumGet(this, 188, "char")
		set => NumPut("char", value, this, 188)
	}
	AntiAliasedLinesUseTex
	{
		get => NumGet(this, 189, "char")
		set => NumPut("char", value, this, 189)
	}
	AntiAliasedFill
	{
		get => NumGet(this, 190, "char")
		set => NumPut("char", value, this, 190)
	}
	CurveTessellationTol
	{
		get => NumGet(this, 192, "char")
		set => NumPut("char", value, this, 192)
	}
	CircleTessellationMaxError
	{
		get => NumGet(this, 196, "char")
		set => NumPut("char", value, this, 196)
	}
;ImGuiCol_Text
;example
; c := Colors[ImGuiCol_Text]
; Colors[ImGuiCol_Text] := [1, 2, 3, 4]
	Colors[index]
	{
		;sc := 1.0 / 255.0
		;r := value[1] * sc, g := value[2] * sc, b := value[3] * sc, a := value[4] * sc
		get => [NumGet(this, 200 + (index - ImGuiCol_Text) * 16, "float"), 
				NumGet(this, 200 + (index - ImGuiCol_Text) * 16 + 4, "float"), 
				NumGet(this, 200 + (index - ImGuiCol_Text) * 16 + 8, "float"), 
				NumGet(this, 200 + (index - ImGuiCol_Text) * 16 + 12, "float")]
		set => [NumPut("float", value[1] * (1.0 / 255.0), this, 200 + (index - ImGuiCol_Text) * 16), 
				NumPut("float", value[2] * (1.0 / 255.0), this, 200 + (index - ImGuiCol_Text) * 16 + 4), 
				NumPut("float", value[3] * (1.0 / 255.0), this, 200 + (index - ImGuiCol_Text) * 16 + 8), 
				NumPut("float", value[4] * (1.0 / 255.0), this, 200 + (index - ImGuiCol_Text) * 16 + 12)]
	}
}

/*
class ImGuiStyle	size(1080):
1>	+---
1> 0	| Alpha
1> 4	| DisabledAlpha
1> 8	| ImVec2 WindowPadding
1>16	| WindowRounding
1>20	| WindowBorderSize
1>24	| ImVec2 WindowMinSize
1>32	| ImVec2 WindowTitleAlign
1>40	| WindowMenuButtonPosition
1>44	| ChildRounding
1>48	| ChildBorderSize
1>52	| PopupRounding
1>56	| PopupBorderSize
1>60	| ImVec2 FramePadding
1>68	| FrameRounding
1>72	| FrameBorderSize
1>76	| ImVec2 ItemSpacing
1>84	| ImVec2 ItemInnerSpacing
1>92	| ImVec2 CellPadding
1>100	| ImVec2 TouchExtraPadding
1>108	| IndentSpacing
1>112	| ColumnsMinSpacing
1>116	| ScrollbarSize
1>120	| ScrollbarRounding
1>124	| GrabMinSize
1>128	| GrabRounding
1>132	| LogSliderDeadzone
1>136	| TabRounding
1>140	| TabBorderSize
1>144	| TabMinWidthForCloseButton
1>148	| ColorButtonPosition
1>152	| ImVec2 ButtonTextAlign
1>160	| ImVec2 SelectableTextAlign
1>168	| ImVec2 DisplayWindowPadding
1>176	| ImVec2 DisplaySafeAreaPadding
1>184	| MouseCursorScale
1>188	| AntiAliasedLines
1>189	| AntiAliasedLinesUseTex
1>190	| AntiAliasedFill
1>  	| <alignment member> (size=1)
1>192	| CurveTessellationTol
1>196	| CircleTessellationMaxError
1>200	| Colors
1>	+---
*/