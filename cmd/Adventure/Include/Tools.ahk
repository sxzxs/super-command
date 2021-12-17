ShowToolsDialog(SelectedItem := "") {
    Global
    Local Index := 1, Each, oTool, ILIndex, hGrad

    Gui ToolsDlg: New, +LabelToolsDlg +hWndg_hWndTools
    SetWindowIcon(g_hWndTools, IconLib, -58)
    Gui Color, White

    Gui Add, Pic, x-2 y-2 w722 h51, % "HBITMAP:" . Gradient(722, 51)
    Gui Add, Picture, x680 y9 w32 h32 +BackgroundTrans +Icon-58, %IconLib%
    Gui Font, s12 cWhite, Segoe UI
    Gui Add, Text, x12 y12 w300 h23 +0x200 +BackgroundTrans, Tools Manager
    ResetFont()
    Gui Add, Text, x0 y49 w724 0x10 ; Separator

    Gui Add, ListView, hWndg_hLvTools gTools_LvHandler x8 y56 w227 h308 -Hdr -Multi +LV0x14000 +AltSubmit +0x40, Tools
    SetExplorerTheme(g_hLvTools)
    LV_SetImageList(g_oTools.ImageList, 1)
    Gui Add, Button, gTools_AddItem x6 y370 w84 h24 +Default, &New...
    Gui Add, Button, gTools_RemoveItem x95 y370 w84 h24, &Remove
    Gui Add, Button, hWndhBtnToolUp gTools_MoveItemUp x184 y370 w24 h24
    GuiButtonIcon(hBtnToolUp, IconLib, -59, "L2 T1")
    Gui Add, Button, hWndhBtnToolDown gTools_MoveItemDown x212 y370 w24 h24
    GuiButtonIcon(hBtnToolDown, IconLib, -60, "L2 T1")

    Gui Add, Text, x251 y58 w88 h23 +0x200, Display &Name:
    Gui Add, Edit, vEdtToolTitle gTools_UpdateTitle x251 y84 w450 h22 Disabled

    Gui Add, Text, x251 y114 w88 h23 +0x200, &File:
    Gui Add, Edit, vEdtToolFile x251 y140 w362 h22 Disabled
    Gui Add, Button, vBtnToolFile gTools_SelectFile x618 y138 w84 h24 Disabled, Browse...

    Gui Add, Text, x251 y170 w88 h23 +0x200, &Parameters:
    Gui Add, Edit, vEdtToolParams x251 y196 w362 h22 Disabled
    Gui Add, Button, hWndhBtnToolParams vBtnToolParams gTools_ShowPlaceholdersMenu x618 y194 w84 h24 Disabled, Choose

    Gui Add, Text, x251 y226 w88 h23 +0x200, &Working Dir:
    Gui Add, Edit, vEdtToolWorkingDir x251 y252 w362 h22 Disabled
    Gui Add, Button, vBtnToolWorkingDir gTools_SelectWorkingDir x618 y250 w84 h24 Disabled, Browse...

    Gui Add, Text, x251 y282 w88 h23 +0x200, &Icon:
    Gui Add, Edit, vEdtToolIcon x251 y308 w314 h22 Disabled
    Gui Add, Edit, vEdtToolIconIndex x566 y308 w47 h22 Disabled, 1
    Gui Add, Button, vBtnToolIcon gTools_ChooseIcon x618 y306 w84 h24 Disabled, Browse...

    Gui Add, Text, x251 y338 w88 h23 +0x200, &Description
    Gui Add, Edit, vEdtToolDesc x251 y364 w450 h22 Disabled

    Gui Add, Text, x-1 y400 w723 h48 +Border -Background
    Gui Add, Button, gToolsDlgOK x445 y412 w84 h24, &OK
    Gui Add, Button, gToolsDlgApply x536 y412 w84 h24, &Apply
    Gui Add, Button, gToolsDlgClose x627 y412 w84 h24, &Close

    Repaint(g_hWndTools)
    Gui Show, w720 h447, Configure Tools

    If (!g_oTools.Items.Length()) {
        Return
    }

    For Each, oTool in g_oTools.Items {
        ILIndex := IL_Add(g_oTools.ImageList, Tools_GetIconPath(oTool.Icon), oTool.IconIndex)
        LV_Add("Icon" . ILIndex, oTool.Title)

        If (SelectedItem != "" && oTool.Title == SelectedItem) {
            Index := A_Index
        }
    }

    LV_ModifyCol(1, "AutoHdr")
    LV_Modify(Index, "Select")

    Tools_LoadInfo()
}

ToolsDlgEscape:
ToolsDlgClose:
    Gui ToolsDlg: Destroy
Return

Tools_Enable(Action := "Enable") {
    GuiControl % Action, EdtToolTitle
    GuiControl % Action, EdtToolFile
    GuiControl % Action, BtnToolFile
    GuiControl % Action, EdtToolParams
    GuiControl % Action, BtnToolParams
    GuiControl % Action, EdtToolWorkingDir
    GuiControl % Action, BtnToolWorkingDir
    GuiControl % Action, EdtToolIcon
    GuiControl % Action, EdtToolIconIndex
    GuiControl % Action, BtnToolIcon
    GuiControl % Action, EdtToolDesc
}

Tools_Clear() {
    GuiControl,, EdtToolTitle
    GuiControl,, EdtToolFile
    GuiControl,, EdtToolParams
    GuiControl,, EdtToolWorkingDir
    GuiControl,, EdtToolIcon
    GuiControl,, EdtToolIconIndex
    GuiControl,, EdtToolDesc
}

Tools_AddItem() {
    SetListView("ToolsDlg", g_hLvTools)
    g_oTools.CurrentRow := LV_Add("Icon 0", "")
    LV_Modify(g_oTools.CurrentRow, "Select")

    Tools_Enable()
    Tools_Clear()
    Tools_SelectFile()

    LV_ModifyCol(1, "AutoHdr")
    SendMessage 0x115, 7, 0,, ahk_id %g_hLvTools% ; WM_VSCROLL, SB_BOTTOM
}

Tools_RemoveItem() {
    Local Row, Title

    If (Tools_GetRow(Row)) {
        Title := g_oTools.Items[Row].Title
        g_oTools.Items.RemoveAt(Row)

        If (Title != "") {
            Try {
                Menu MenuTools, Delete, %Title%
            }
        }

        SetListView("ToolsDlg", g_hLvTools)
        LV_Delete(Row)
        Tools_Clear()
        LV_ModifyCol(1, "AutoHdr")
        g_oTools.CurrentRow := 0

        If (!LV_GetCount()) {
            Tools_Enable("Disable")
        }

        Tools_SaveSettings()
    }
}

Tools_MoveItemUp:
Tools_MoveItemDown:
    Tools_MoveItem(A_ThisLabel == "Tools_MoveItemUp" ? 0 : 1)
Return

Tools_MoveItem(Down := True) {
    Local Index
    SetListView("ToolsDlg", g_hLvTools)

    Index := LV_GetNext()
    If (Index == 0 || (Down ? Index == LV_GetCount() : Index == 1)) {
        Return
    }

    If (Down) {
        Tools_SwapItems(g_hLvTools, Index, Index + 1, +1)
    } Else {
        Tools_SwapItems(g_hLvTools, Index, Index - 1, -1)
    }
}

Tools_SwapItems(hLV, CurIndex, NewIndex, Increment) {
    Local ToolItem, IconIndex1, IconIndex2

    ToolItem := g_oTools.Items.RemoveAt(CurIndex)
    g_oTools.Items.InsertAt(NewIndex, ToolItem)
    g_oTools.CurrentRow += Increment

    IconIndex1 := LV_GetItemIcon(hLV, CurIndex)
    IconIndex2 := LV_GetItemIcon(hLV, NewIndex)

    LV_Modify(CurIndex, "Icon" . IconIndex2, g_oTools.Items[CurIndex].Title)
    LV_Modify(NewIndex, "Icon" . IconIndex1, g_oTools.Items[NewIndex].Title)

    GuiControl Focus, %hLV%
    LV_Modify(NewIndex, "Select")
}

Tools_SelectFile() {
    Local SelectedFile, FileExt, NameNoExt, ILIndex, Row

    Gui ToolsDlg: +OwnDialogs
    FileSelectFile SelectedFile, 3,, Select File
    If (ErrorLevel) {
        Return
    }

    SplitPath SelectedFile,,, FileExt, NameNoExt

    GuiControl, ToolsDlg:, EdtToolFile, %SelectedFile%

    Gui ToolsDlg: Submit, NoHide

    Row := LV_GetNext()

    If (EdtToolTitle == "" && g_oTools.IsTitleAvailable(NameNoExt)) {
        GuiControl, ToolsDlg:, EdtToolTitle, %NameNoExt%
        ;g_oTools.Items[Row].Title := NameNoExt
    }

    If (FileExt = "EXE" && EdtToolIcon == "") {
        GuiControl, ToolsDlg:, EdtToolIcon, %SelectedFile%
        If (ILIndex := IL_Add(g_oTools.ImageList, SelectedFile, 1)) {
            LV_Modify(Row, "Icon" . ILIndex)
        }
    }
}

Tools_ChooseIcon() {
    Local Row, FileExt, ToolIcon, ILIndex

    If (!Tools_GetRow(Row)) {
        Return
    }

    Gui ToolsDlg: Submit, NoHide

    SplitPath EdtToolFile,,, FileExt
    If (FileExist(EdtToolIcon)) {
        ToolIcon := EdtToolIcon
    } Else {
        ToolIcon := (FileExt = "EXE") ? EdtToolFile : "shell32.dll"
    }

    If (ChooseIcon(ToolIcon, EdtToolIconIndex, g_hWndTools)) {
        Gui ToolsDlg: Default
        GuiControl,, EdtToolIcon, %ToolIcon%
        GuiControl,, EdtToolIconIndex, %EdtToolIconIndex%
        If (ILIndex := IL_Add(g_oTools.ImageList, ToolIcon, EdtToolIconIndex)) {
            LV_Modify(Row, "Icon" . ILIndex)
        }
    }
}

ToolsDlgOK:
ToolsDlgApply:
    Tools_Submit(A_ThisLabel == "ToolsDlgOK" ? 0 : 1)
Return

Tools_Submit(NoHide := True) {
    Global
    Local Row, Icon, ILIndex, SameTitle

    Gui ToolsDlg: Submit, NoHide

    If (Tools_GetRow(Row)) {
        g_oTools.SetItem(Row
        , EdtToolTitle, EdtToolFile, EdtToolParams, EdtToolWorkingDir, EdtToolIcon, EdtToolIconIndex, EdtToolDesc)
    }

    SameTitle := g_oTools.Validate()
    If (SameTitle != "") {
        ErrorMsgBox("More than one tool has the title """ . SameTitle . """.", g_hWndTools)
        Return
    }

    Loop % GetMenuItemCount(MenuGetHandle("MenuTools")) {
        Try {
            Menu MenuTools, Delete, 2& ; Initial position (separator)
        }
    }

    ; Rebuild menu
    Loop % g_oTools.Items.Length() {
        If (A_Index == 1) {
            Menu MenuTools, Add
        }

        If (g_oTools.Items[A_Index].Title == "" || g_oTools.Items[A_Index].File == "") {
            Continue
        }

        Icon := Tools_GetIconPath(g_oTools.Items[A_Index].Icon)
        Try {
            AddMenu("MenuTools", g_oTools.Items[A_Index].Title, "RunTool", Icon, g_oTools.Items[A_Index].IconIndex)
        }
    }

    Tools_SaveSettings()

    If (NoHide) {
        If (Row) {
            ILIndex := IL_Add(g_oTools.ImageList
            , Tools_GetIconPath(g_oTools.Items[Row].Icon), g_oTools.Items[Row].IconIndex)

            LV_Modify(Row, "Icon" . ILIndex)
        }
    } Else {
        Gui ToolsDlg: Destroy
    }
}

Tools_LvHandler() {
    Global
    If ((A_GuiEvent == "Normal" || A_GuiEvent == "K")) {
        If (!LV_GetNext()) {
            Tools_Enable("Disable")
            Return
        }

        If (g_oTools.CurrentRow) {
            Gui ToolsDlg: Submit, NoHide
            g_oTools.SetItem(g_oTools.CurrentRow, EdtToolTitle, EdtToolFile, EdtToolParams
            , EdtToolWorkingDir, EdtToolIcon, EdtToolIconIndex, EdtToolDesc)
        }

        Tools_LoadInfo()
        Tools_Enable()
    }
}

Tools_LoadInfo() {
    Local Row
    If (!Tools_GetRow(Row)) {
        Return
    }

    Tools_Enable()
    GuiControl,, EdtToolTitle, % g_oTools.Items[Row].Title
    GuiControl,, EdtToolFile, % g_oTools.Items[Row].File
    GuiControl,, EdtToolParams, % g_oTools.Items[Row].Params
    GuiControl,, EdtToolWorkingDir, % g_oTools.Items[Row].WorkingDir
    GuiControl,, EdtToolIcon, % g_oTools.Items[Row].Icon
    GuiControl,, EdtToolIconIndex, % g_oTools.Items[Row].IconIndex
    GuiControl,, EdtToolDesc, % g_oTools.Items[Row].Desc
    g_oTools.CurrentRow := Row
}

Tools_UpdateTitle() {
    Local Row
    If (!Tools_GetRow(Row)) {
        Return
    }

    Gui ToolsDlg: Submit, NoHide
    LV_Modify(Row,, EdtToolTitle)
    ;g_oTools.Items[Row].Title := EdtToolTitle
}

Tools_SelectWorkingDir() {
    Local ToolFile, StartPath, SelectedFolder
    GuiControlGet ToolFile, ToolsDlg:, EdtToolFile
    SplitPath ToolFile,, StartPath
    Gui ToolsDlg: +OwnDialogs
    FileSelectFolder SelectedFolder, *%StartPath%,, Select Folder
    If (!ErrorLevel) {
        GuiControl, ToolsDlg:, EdtToolWorkingDir, %SelectedFolder%
    }
}

Tools_GetIconPath(IconPath) {
    If (InStr(IconPath, "{:IC")) {
        IconPath := StrReplace(IconPath, "{:ICONSDIR:}", A_ScriptDir . "\Icons")
    }

    Return IconPath
}

Tools_ShowPlaceholdersMenu(hWndBtn) {
    Local hMenu, wi, x, y

    Menu Placeholders, Add, "{:FULLPATH:}", Tools_InsertPlaceholder
    Menu Placeholders, Add, "{:FILENAME:}", Tools_InsertPlaceholder
    Menu Placeholders, Add, "{:FILEDIR:}", Tools_InsertPlaceholder
    Menu Placeholders, Add, "{:FILEEXT:}", Tools_InsertPlaceholder
    Menu Placeholders, Add, "{:PROGDIR:}", Tools_InsertPlaceholder
    Menu Placeholders, Add, "{:SELTEXT:}", Tools_InsertPlaceholder
    Menu Placeholders, Add, "{:SCIHWND:}", Tools_InsertPlaceholder

    hMenu := MenuGetHandle("Placeholders")
    wi := GetWindowInfo(hWndBtn)
    x := wi.ClientX + wi.ClientW
    y := wi.ClientY + wi.ClientH
    DllCall("TrackPopupMenu", "Ptr", hMenu, "UInt", 0x8, "Int", x, "Int", y, "Int", 0, "Ptr", g_hWndTools, "Ptr", 0)
}

Tools_InsertPlaceholder() {
    Local hWnd
    GuiControlGet hWnd, ToolsDlg: Hwnd, EdtToolParams
    Control EditPaste, %A_ThisMenuItem%,, ahk_id %hWnd%
}

Class ToolsManager {
    Items := []
    XmlFile := ""
    CurrentRow := 0

    __New(ILSize := 100) {
        this.ImageList := IL_Create(ILSize)
    }

    SetItem(Index, Title, File, Params, WorkingDir, Icon, IconIndex, Desc) {
        this.Items[Index] := {}
        this.Items[Index].Title := Title
        this.Items[Index].File := File
        this.Items[Index].Params := Params
        this.Items[Index].WorkingDir := WorkingDir
        this.Items[Index].Icon := Icon
        this.Items[Index].IconIndex := IconIndex
        this.Items[Index].Desc := Desc
    }

    GetItem(ToolTitle) {
        Local Each, Item
        For Each, Item in this.Items {
            If (Item.Title == ToolTitle) {
                Return Item
            }
        }
    }

    IsTitleAvailable(ToolTitle) {
        Local Each, Item
        For Each, Item in this.Items {
            If (Item.Title == ToolTitle) {
                Return False
            }
        }
        Return True
    }

    Validate() {
        Local i1, i2, Item1, Item2

        For i1, Item1 in this.Items {
            For i2, Item2 in this.Items {
                If (i2 == i1) {
                    Continue
                }

                If (Item1.Title == Item2.Title) {
                    Return Item1.Title
                }
            }
        }

        Return ""
    }

    Save(XmlFile) {
        Local oXML, oRootNode, Each, Item, oToolNode, oNode, OutXML

        oXML := LoadXMLData("<?xml version=""1.0""?><tools></tools>")
        oRootNode := oXML.documentElement

        For Each, Item in this.Items {
            If (Item.Title == "" || Item.File == "") {
                Continue
            }

            oToolNode := oXML.createElement("tool")
            oNode := oRootNode.appendChild(oToolNode)
            oNode.setAttribute("title", Item.Title)
            oNode.setAttribute("file", Item.File)
            oNode.setAttribute("params", Item.Params)
            oNode.setAttribute("workingdir", Item.WorkingDir)
            oNode.setAttribute("icon", Item.Icon)
            oNode.setAttribute("iconindex", Item.IconIndex)
            oNode.setAttribute("desc", Item.Desc)
        }

        ; Indent
        OutXML := StrReplace(oXML.xml, "<tool ", "`r`n`t<tool ")
        OutXML := StrReplace(OutXML, "</tools", "`r`n</tools")

        Return % WriteFile(XmlFile, OutXML, "UTF-8") > -1
    }

    Reload(XmlFile) {
        this.Items := []
        this.CurrentRow := 0
        Return this.Load(XmlFile)
    }

    Load(XmlFile) {
        Local oXML, oTool, oTools, Title, File, Params, WorkingDir, Icon, IconIndex, Desc

        oXML := LoadXML(XmlFile)
        If (!IsObject(oXML)) {
            Return 0
        }

        this.XmlFile := XmlFile

        oTools := oXML.selectNodes("/tools/tool")

        For oTool in oTools {
            Title      := oTool.getAttribute("title")
            File       := oTool.getAttribute("file")
            Params     := oTool.getAttribute("params")
            WorkingDir := oTool.getAttribute("workingdir")
            Icon       := oTool.getAttribute("icon")
            IconIndex  := oTool.getAttribute("iconindex")
            Desc       := oTool.getAttribute("desc")
            If (IconIndex == "") {
                IconIndex := 1
            }

            this.SetItem(A_Index, Title, File, Params, WorkingDir, Icon, IconIndex, Desc)
        }

        Return oTools.length()
    }
}

Tools_GetRow(ByRef Row) {
    SetListView("ToolsDlg", g_hLvTools)
    Return Row := LV_GetNext()
}

Tools_SaveSettings() {
    Return g_oTools.Save(g_ToolsFile)
}
