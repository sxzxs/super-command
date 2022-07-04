; 超级命令
; Tested on AHK v1.1.33.02 Unicode 32/64-bit, Windows /10

; Script compiler directives
;@Ahk2Exe-SetMainIcon %A_ScriptDir%\Icons\Verifier.ico
;@Ahk2Exe-SetVersion 0.1.0

OnMessage(0x004A, "Receive_WM_COPYDATA")  ; 0x004A 为 WM_COPYDATA
OnMessage(0x100, "GuiKeyDown")
OD_LB  := "+0x0050" ; LBS_OWNERDRAWFIXED = 0x0010, LBS_HASSTRINGS = 0x0040
ODLB_SetItemHeight("s14 Normal", "MS Shell Dlg 2")
ODLB_SetHiLiteColors(0xDEDEDE, 0x000000)
OnMessage(0x002C, "ODLB_MeasureItem") ; WM_MEASUREITEM
OnMessage(0x002B, "ODLB_DrawItem") ; WM_DRAWITEM
#SingleInstance force
#include <py>
#include <btt>
#include <log4ahk>
#include <TextRender>
#Persistent
CoordMode, ToolTip, Screen
SetBatchLines -1
;管理员运行
full_command_line := DllCall("GetCommandLine", "str")
if not (A_IsAdmin or RegExMatch(full_command_line, " /restart(?!\S)"))
{
    try
    {
        if A_IsCompiled
            Run *RunAs "%A_ScriptFullPath%" /restart
        else
            Run *RunAs "%A_AhkPath%" /restart "%A_ScriptFullPath%"
    }
    ExitApp
}

help_string =
(
v1.0.0
shift+enter:  搜索命令
ctrl+c: 复制当前文本
alt+c: 编辑所有命令
ctrl+x: 编辑当前命令
)
;btt(help_string, A_ScreenWidth/2, A_ScreenHeight/2 , 1, "Style4")
;SetTimer, RemoveToolTip, -5000

py.allspell_muti("ahk")
begin := 1
total_command := 0 ;总命令个数
is_get_all_cmd := false
cmds := ""
my_xml := new xml("xml")
menue_create_pid := 0

global gui_x := A_ScreenWidth / 2 - 500
global gui_y := 100
g_curent_text := ""
g_command := ""
g_exe_name := ""
g_exe_id := ""
BackgroundColor := "3e3d45"
TextColor := "f4f4f4"
global g_text_rendor := TextRender()
g_text_rendor.Render(help_string, "t: 3seconds x:left y:top pt:2", "s:15")

if !FileExist(A_ScriptDir "\cmd\Menus\超级命令.xml")
{
    MsgBox,% A_ScriptDir "\cmd\Menus\超级命令.xml 不存在, alt + c 添加命令并保存在上面目录" 
}
fileread, xml_file_content,% "*P65001 " A_ScriptDir "\cmd\Menus\超级命令.xml"
my_xml.XML.LoadXML(xml_file_content)
cmds := xml_parse(my_xml)


Menu, Tray, Icon, %A_ScriptDir%\Icons\Verifier.ico
Menu, Tray, NoStandard
Menu, Tray, Add , Suspend, Sus
Menu, Tray, Add , Reload, Rel
Menu, Tray, Add , Exit, Exi
Menu, Tray, Default, Exit
Menu, Tray, Icon , %A_ScriptDir%\Icons\Verifier.ico,, 1
Return

Sus:
Suspend, Toggle
if (A_IsSuspended)
Menu, Tray, Icon , %A_ScriptDir%\Icons\Structor.ico
Else
Menu, Tray, Icon , %A_ScriptDir%\Icons\Verifier.ico
Return
Exi:
ExitApp
Return
Rel:
Reload
Return

~*esc::
    goto GuiEscape
return

~$^x::
if(!WinActive("ahk_id " MyGuiHwnd) || g_command == "")
    return
FileDelete,% A_ScriptDir "\cmd\tmp\tmp.ahk"
FileAppend,% g_curent_text,% A_ScriptDir "\cmd\tmp\tmp.ahk",UTF-8
g_command := StrReplace(g_command, "$")
tmp_path =
(
    "%g_command%"
) 
if(A_IsCompiled)
    run,% A_ScriptDir "\cmd\Adventure\Adventure.exe  " tmp_path " " my_pid
else
    run,% A_ScriptDir "\cmd\Adventure\Adventure.ahk  " tmp_path " " my_pid
goto GuiEscape
return

~$^c::
if(!WinActive("ahk_id " MyGuiHwnd) || g_command == "")
    return
Clipboard := g_curent_text
return

!c::
Process Exist
my_pid := ErrorLevel
if(A_IsCompiled)
    run,% A_ScriptDir "\cmd\menue_create.exe " my_pid
else
    run,% A_ScriptDir "\cmd\menue_create.ahk " my_pid
return
+Enter::
!q::
WinGet, g_exe_name, ProcessName, A
WinGet, g_exe_id, ID , A
g_command := ""
if (cmds == "")
{
    my_xml := new xml("xml")
    my_xml.XML.LoadXML(xml_file_content)
    cmds := xml_parse(my_xml)
}
SetCapsLockState,off
switchime(0)
Gui +LastFoundExist
if WinActive()
{
    if(g_curent_text != "")
        Clipboard := g_curent_text
    goto GuiEscape
}
Gui Destroy
Gui Margin, 0, 0
Gui, Font, s14, Consolas
Gui, -Caption +AlwaysOnTop -DPIScale +ToolWindow +HwndMyGuiHwnd
Gui Add, Edit, hwndEDIT x0 w500 C0x%BackgroundColor% vQuery gType
Gui Add, ListBox, hwndLIST x0 y+0 h20 w500  vCommand gSelect AltSubmit -HScroll %OD_LB%
ControlColor(EDIT, MyGuiHwnd, "0x" BackgroundColor, "0x" TextColor)
ControlColor(LIST, MyGuiHwnd, "0x" BackgroundColor, "0x" TextColor)
gosub Type
Gui Show, X%gui_x% Y%gui_y%
if(A_ThisHotkey == "!q")
{
    GuiControl,,% EDIT ,% " " g_exe_name
}
return

Type:
SetTimer Refresh, -10
return

Refresh:
GuiControlGet Query
r := cmds
if (Query != "")
{
    StringSplit q, Query, %A_Space%
    Loop % q0
        r := Filter(r, q%A_Index%, c)
}
else
{
    ;btt(,,,1)
    g_text_rendor.Render("")
}
rows := ""
row_id := []
Loop Parse, r, `n
{
    row_id[A_Index] := A_LoopField
    rows .= "|"  A_LoopField
}
GuiControl,, Command, % rows ? rows : "|"
if (Query = "")
    c := row_id.MaxIndex()
total_command := c
GuiControl, Move, Command, % "h" 33 * (total_command > 20 ? 22 : total_command)
GuiControl, % (total_command && Query != "") ? "Show" : "Hide", Command
HighlightedCommand := 1
GuiControl, Choose, Command, 1
Gui, Show, AutoSize

Select:
GuiControlGet Command
if !Command
    Command := 1
Command := row_id[Command]
TargetScriptTitle := "ahk_pid " menue_create_pid " ahk_class AutoHotkey"
StringToSend := command
result := Send_WM_COPYDATA(StringToSend, TargetScriptTitle)
preview_command(command)
if (A_GuiEvent != "DoubleClick")
{
    return
}

Confirm:
GuiControlGet Command
if !Command
    Command := 1
Command := row_id[Command]
if !GetKeyState("Shift")
{
    gosub GuiEscape
}
handle_command(Command)
return

GuiEscape:
Gui,Hide
btt()
g_text_rendor.Render("")
return

#IfWinActive, menu ahk_class AutoHotkeyGUI

+Tab::
Up::
    if(HighlightedCommand == 1)
        HighlightedCommand := total_command
    else
        HighlightedCommand--
    GuiControl, Choose, command, %HighlightedCommand%
    gosub Select
    Gui, Show		
return

Tab::
Down::
    if(HighlightedCommand == total_command)
        HighlightedCommand := 1
    else
		HighlightedCommand++
    GuiControl, Choose, command, %HighlightedCommand%
    gosub Select
    Gui, Show
return
#If

GuiActivate(wParam)
{
    if (A_Gui && wParam = 0)
    {
        SetTimer GuiEscape, -5
    }
}

GuiKeyDown(wParam, lParam)
{
    if !A_Gui
        return
    if (wParam = GetKeyVK("Enter"))
    {

        gosub Confirm
        return 0
    }
    if (wParam = GetKeyVK(key := "Down")
     || wParam = GetKeyVK(key := "Up"))
    {
        GuiControlGet focus, FocusV
        if (focus != "Command")
        {
            GuiControl Focus, Command
            if (key = "Up")
                Send {End}
            else
                Send {Home}
            return 0
        }
        return
    }
    if (wParam >= 49 && wParam <= 57 && !GetKeyState("Shift") && GetKeyState("LCtrl"))
    {
        SendMessage 0x18E,,, ListBox1
        GuiControl Choose, Command, % wParam-48 + ErrorLevel
        GuiControl Focus, Command
        gosub Select
        return 0
    }
    if (wParam = GetKeyVK(key := "PgUp")
     || wParam = GetKeyVK(key := "PgDn"))
    {
        GuiControl Focus, Command
        Send {%key%}
        return
    }
}

keyValueFind(haystack,needle)
{
    ;拼音首字母转换
    ;msgbox,% haystack
    haystack .= py.allspell_muti(haystack) py.initials_muti(haystack) 
	findSign:=1
	needleArray := StrSplit(needle, " ")
	Loop,% needleArray.MaxIndex()
	{
		if(!InStr(haystack, needleArray[A_Index], false))
		{
			findSign:=0
			break
		}	
	}
	return findSign
}
Filter(s, q, ByRef count)
{
    ;建立数组 [{“a" : "原始值", "b" : "首字母"}]
    ;匹配
    s := StrSplit(s, ["`r","`n"])
    result := ""
    result := ""
    VarSetCapacity(result,0)
    VarSetCapacity(result,4000)
    count := 0
    for k,v in s
    {
        if(keyValueFind(v, q))
        {
            result .= v "`n"
            count += 1
        }
    }
    return SubStr(result, 1, -1)
}


Class XML{
	keep:=[]
	__Get(x=""){
		return this.XML.xml
	}__New(param*){
		;temp.preserveWhiteSpace:=1
		root:=param.1,file:=param.2,file:=file?file:root ".xml",temp:=ComObjCreate("MSXML2.DOMDocument")
		this.xml:=temp,this.file:=file,XML.keep[root]:=this
		temp.SetProperty("SelectionLanguage","XPath")
		if(FileExist(file)){
			FileRead,info,%file%
			if(info=""){
				this.xml:=this.CreateElement(temp,root)
				FileDelete,%file%
			}else
				temp.LoadXML(info),this.xml:=temp
		}else
			this.xml:=this.CreateElement(temp,root)
	}Add(XPath,att:="",text:="",dup:=0){
		p:="/",add:=(next:=this.SSN("//" XPath))?1:0,last:=SubStr(XPath,InStr(XPath,"/",0,0)+1)
		if(!next.xml){
			next:=this.SSN("//*")
			for a,b in StrSplit(XPath,"/")
				p.="/" b,next:=(x:=this.SSN(p))?x:next.AppendChild(this.XML.CreateElement(b))
		}if(dup&&add)
			next:=next.ParentNode.AppendChild(this.XML.CreateElement(last))
		for a,b in att
			next.SetAttribute(a,b)
		if(text!="")
			next.text:=text
		return next
	}CreateElement(doc,root){
		return doc.AppendChild(this.XML.CreateElement(root)).ParentNode
	}EA(XPath,att:=""){
		list:=[]
		if(att)
			return XPath.NodeName?SSN(XPath,"@" att).text:this.SSN(XPath "/@" att).text
		nodes:=XPath.NodeName?XPath.SelectNodes("@*"):nodes:=this.SN(XPath "/@*")
		while(nn:=nodes.item[A_Index-1])
			list[nn.NodeName]:=nn.text
		return list
	}Find(info*){
		static last:=[]
		doc:=info.1.NodeName?info.1:this.xml
		if(info.1.NodeName)
			node:=info.2,find:=info.3,return:=info.4!=""?"SelectNodes":"SelectSingleNode",search:=info.4
		else
			node:=info.1,find:=info.2,return:=info.3!=""?"SelectNodes":"SelectSingleNode",search:=info.3
		if(InStr(info.2,"descendant"))
			last.1:=info.1,last.2:=info.2,last.3:=info.3,last.4:=info.4
		if(InStr(find,"'"))
			return doc[return](node "[.=concat('" RegExReplace(find,"'","'," Chr(34) "'" Chr(34) ",'") "')]/.." (search?"/" search:""))
		else
			return doc[return](node "[.='" find "']/.." (search?"/" search:""))
	}Get(XPath,Default){
		text:=this.SSN(XPath).text
		return text?text:Default
	}ReCreate(XPath,new){
		rem:=this.SSN(XPath),rem.ParentNode.RemoveChild(rem),new:=this.Add(new)
		return new
	}Save(x*){
		if(x.1=1)
			this.Transform()
		if(this.XML.SelectSingleNode("*").xml="")
			return m("Errors happened while trying to save " this.file ". Reverting to old version of the XML")
		filename:=this.file?this.file:x.1.1,ff:=FileOpen(filename,0),text:=ff.Read(ff.length),ff.Close()
		if(!this[])
			return m("Error saving the " this.file " XML.  Please get in touch with maestrith if this happens often")
		if(text!=this[])
			file:=FileOpen(filename,"rw"),file.Seek(0),file.Write(this[]),file.Length(file.Position)
	}SSN(XPath){
		return this.XML.SelectSingleNode(XPath)
	}SN(XPath){
		return this.XML.SelectNodes(XPath)
	}Transform(){
		static
		if(!IsObject(xsl))
			xsl:=ComObjCreate("MSXML2.DOMDocument"),xsl.loadXML("<xsl:stylesheet version=""1.0"" xmlns:xsl=""http://www.w3.org/1999/XSL/Transform""><xsl:output method=""xml"" indent=""yes"" encoding=""UTF-8""/><xsl:template match=""@*|node()""><xsl:copy>`n<xsl:apply-templates select=""@*|node()""/><xsl:for-each select=""@*""><xsl:text></xsl:text></xsl:for-each></xsl:copy>`n</xsl:template>`n</xsl:stylesheet>"),style:=null
		this.XML.TransformNodeToObject(xsl,this.xml)
	}Under(under,node,att:="",text:="",list:=""){
		new:=under.AppendChild(this.XML.CreateElement(node)),new.text:=text
		for a,b in att
			new.SetAttribute(a,b)
		for a,b in StrSplit(list,",")
			new.SetAttribute(b,att[b])
		return new
	}
}SSN(node,XPath){
	return node.SelectSingleNode(XPath)
}SN(node,XPath){
	return node.SelectNodes(XPath)
}m(x*){
	active:=WinActive("A")
	ControlGetFocus,Focus,A
	ControlGet,hwnd,hwnd,,%Focus%,ahk_id%active%
	static list:={btn:{oc:1,ari:2,ync:3,yn:4,rc:5,ctc:6},ico:{"x":16,"?":32,"!":48,"i":64}},msg:=[],msgbox
	list.title:="XML Class",list.def:=0,list.time:=0,value:=0,msgbox:=1,txt:=""
	for a,b in x
		obj:=StrSplit(b,":"),(vv:=List[obj.1,obj.2])?(value+=vv):(list[obj.1]!="")?(List[obj.1]:=obj.2):txt.=b "`n"
	msg:={option:value+262144+(list.def?(list.def-1)*256:0),title:list.title,time:list.time,txt:txt}
	Sleep,120
	MsgBox,% msg.option,% msg.title,% msg.txt,% msg.time
	msgbox:=0
	for a,b in {OK:value?"OK":"",Yes:"YES",No:"NO",Cancel:"CANCEL",Retry:"RETRY"}
		IfMsgBox,%a%
	{
		WinActivate,ahk_id%active%
		ControlFocus,%Focus%,ahk_id%active%
		return b
	}
}

preview_command(command)
{
    command := StrReplace(command, "$")
    CoordMode, ToolTip, Screen
    global my_xml, menue_create_pid, log, gui_x, gui_y, g_curent_text, g_command
    word_array := StrSplit(command, " >")
    pattern := ""
    for k,v in word_array
    {
        pattern .= "/*[@name='" v "']"
    }
    pattern := "//Menu" . pattern
    first_child_name := SSN(my_xml.SSN(pattern), "Item/@name").text
    if(first_child_name != "")
    {
        return
    }
    UnityPath:= my_xml.SSN(pattern).text
    g_command := command
    g_curent_text := UnityPath
    GuiControlGet, out, Pos, Query
    if(!WinExist("超级命令添加工具"))
    {
        ;btt(UnityPath, gui_x + outW, gui_y + 150,,"Style2", {Transparent : 200})
        ;btt(UnityPath, gui_x + outW, A_ScreenHeight/2,,"Style2", {Transparent : 200})
        g_text_rendor.Render(UnityPath, "x:left y:top", "s:15 j:left")
    }
}

handle_command(command)
{
    global my_xml, menue_create_pid, log
    command := StrReplace(command, "$")
    word_array := StrSplit(command, " >")
    pattern := ""
    for k,v in word_array
    {
        pattern .= "/*[@name='" v "']"
    }
    pattern := "//Menu" . pattern
    first_child_name := SSN(my_xml.SSN(pattern), "Item/@name").text
    if(first_child_name != "")
    {
        return
    }
    UnityPath:= my_xml.SSN(pattern).text

    if(SubStr(UnityPath, 1, 3) == ";v2")
        ExecScript(UnityPath, "",A_ScriptDir "\v2\AutoHotkey.exe")
    else
        ExecScript(UnityPath, "",A_ScriptDir "\AutoHotkey.exe")
}

xml_parse(xml)
{
	All:=xml.SN("//Menu/descendant::*")
    Script := ""
	while(aa:=All.Item[A_Index-1],ea:=XML.EA(aa))
    {
        c := aa
        first_child_name := SSN(c, "Item/@name").text
        if(first_child_name != "")
            Continue
        ParentName := ""
        loop
        {
		    p := c.ParentNode
            c_parent_name := SSN(p,"@name").text
            if(c_parent_name == "")
                break
            else
                ParentName := c_parent_name "$" " >" parentname
            c := p
        }
        Script .= ParentName  ea.Name "$" "`r`n"
    }
    return script
}

switchime(ime := "A")
{
	if (ime = 1){
		DllCall("SendMessage", UInt, WinActive("A"), UInt, 80, UInt, 1, UInt, DllCall("LoadKeyboardLayout", Str,"00000804", UInt, 1))
	}else if (ime = 0)
	{
		DllCall("SendMessage", UInt, WinActive("A"), UInt, 80, UInt, 1, UInt, DllCall("LoadKeyboardLayout", Str,, UInt, 1))
	}else if (ime = "A")
	{
		Send, #{Space}
	}
}

ExecScript(Script, Params := "", AhkPath := "") {
    Local Name, Pipe, Call, Shell, Exec

    Name := "AHK_CQT_" . A_TickCount
    Pipe := []

    Loop 2 {
        Pipe[A_Index] := DllCall("CreateNamedPipe"
        , "Str", "\\.\pipe\" . Name
        , "UInt", 2, "UInt", 0
        , "UInt", 255, "UInt", 0
        , "UInt", 0, "UPtr", 0
        , "UPtr", 0, "UPtr")
    }

    If (!FileExist(AhkPath)) {
        AhkPath := A_AhkPath
    }

    Call = "%AhkPath%" /CP65001 "\\.\pipe\%Name%"
    Shell := ComObjCreate("WScript.Shell")
    Exec := Shell.Exec(Call . " " . Params)
    Exec.StdIn.Write("hh")
    Exec.StdIn.Close()
    DllCall("ConnectNamedPipe", "UPtr", Pipe[1], "UPtr", 0)
    DllCall("CloseHandle", "UPtr", Pipe[1])
    DllCall("ConnectNamedPipe", "UPtr", Pipe[2], "UPtr", 0)
    FileOpen(Pipe[2], "h", "UTF-8").Write(Script)
    DllCall("CloseHandle", "UPtr", Pipe[2])

    Return Exec
}

RemoveToolTip:
;btt(,,,1)
g_text_rendor.Render("")
return

Receive_WM_COPYDATA(wParam, lParam)
{
    global
    StringAddress := NumGet(lParam + 2*A_PtrSize)  ; 获取 CopyDataStruct 的 lpData 成员.
    CopyOfData := StrGet(StringAddress)  ; 从结构中复制字符串.
    menue_create_pid := CopyOfData
    ; 比起 MsgBox, 应该用 ToolTip 显示, 这样我们可以及时返回:
    ;ToolTip %A_ScriptName%`nReceived the following string:`n%CopyOfData%
    return true  ; 返回 1(true) 是回复此消息的传统方式.
}
Send_WM_COPYDATA(ByRef StringToSend, ByRef TargetScriptTitle)  ; 在这种情况中使用 ByRef 能节约一些内存.
; 此函数发送指定的字符串到指定的窗口然后返回收到的回复.
; 如果目标窗口处理了消息则回复为 1, 而消息被忽略了则为 0.
{
    VarSetCapacity(CopyDataStruct, 3*A_PtrSize, 0)  ; 分配结构的内存区域.
    ; 首先设置结构的 cbData 成员为字符串的大小, 包括它的零终止符:
    SizeInBytes := (StrLen(StringToSend) + 1) * (A_IsUnicode ? 2 : 1)
    NumPut(SizeInBytes, CopyDataStruct, A_PtrSize)  ; 操作系统要求这个需要完成.
    NumPut(&StringToSend, CopyDataStruct, 2*A_PtrSize)  ; 设置 lpData 为到字符串自身的指针.
    Prev_DetectHiddenWindows := A_DetectHiddenWindows
    Prev_TitleMatchMode := A_TitleMatchMode
    DetectHiddenWindows On
    SetTitleMatchMode 2
    TimeOutTime := 4000  ; 可选的. 等待 receiver.ahk 响应的毫秒数. 默认是 5000
    ; 必须使用发送 SendMessage 而不是投递 PostMessage.
    SendMessage, 0x004A, 0, &CopyDataStruct,, %TargetScriptTitle%  ; 0x004A 为 WM_COPYDAT
    DetectHiddenWindows %Prev_DetectHiddenWindows%  ; 恢复调用者原来的设置.
    SetTitleMatchMode %Prev_TitleMatchMode%         ; 同样.
    return ErrorLevel  ; 返回 SendMessage 的回复给我们的调用者.
}

GetCaretPos(Byacc:=1)
{
	Static init
    If (A_CaretX=""){
		Caretx:=Carety:=CaretH:=CaretW:=0
		If (Byacc){
			If (!init)
				init:=DllCall("LoadLibrary","Str","oleacc","Ptr")
			VarSetCapacity(IID,16), idObject:=OBJID_CARET:=0xFFFFFFF8
			, NumPut(idObject==0xFFFFFFF0?0x0000000000020400:0x11CF3C3D618736E0, IID, "Int64")
			, NumPut(idObject==0xFFFFFFF0?0x46000000000000C0:0x719B3800AA000C81, IID, 8, "Int64")
			If (DllCall("oleacc\AccessibleObjectFromWindow", "Ptr",Hwnd:=WinExist("A"), "UInt",idObject, "Ptr",&IID, "Ptr*",pacc)=0){
				Acc:=ComObject(9,pacc,1), ObjAddRef(pacc)
				Try Acc.accLocation(ComObj(0x4003,&x:=0), ComObj(0x4003,&y:=0), ComObj(0x4003,&w:=0), ComObj(0x4003,&h:=0), ChildId:=0)
				, CaretX:=NumGet(x,0,"int"), CaretY:=NumGet(y,0,"int"), CaretH:=NumGet(h,0,"int")
			}
		}
		If (Caretx=0&&Carety=0){
			MouseGetPos, x, y
            ;x := 0, y := 0
			Return {x:x,y:y,h:30,t:"Mouse",Hwnd:Hwnd}
		} Else
        	Return {x:Caretx,y:Carety,h:Max(Careth,30),t:"Acc",Hwnd:Hwnd}
    } Else
        Return {x:A_CaretX,y:A_CaretY,h:30,t:"Caret",Hwnd:Hwnd}
}

; AHK 1.1+
; ======================================================================================================================
; Function:          Auxiliary object to color controls on WM_CTLCOLOR... notifications.
;                    Supported controls are: Checkbox, ComboBox, DropDownList, Edit, ListBox, Radio, Text.
;                    Checkboxes and Radios accept only background colors due to design.
; Namespace:         CtlColors
; Tested with:       1.1.25.02
; Tested on:         Win 10 (x64)
; Change log:        1.0.04.00/2017-10-30/just me  -  added transparent background (BkColor = "Trans").
;                    1.0.03.00/2015-07-06/just me  -  fixed Change() to run properly for ComboBoxes.
;                    1.0.02.00/2014-06-07/just me  -  fixed __New() to run properly with compiled scripts.
;                    1.0.01.00/2014-02-15/just me  -  changed class initialization.
;                    1.0.00.00/2014-02-14/just me  -  initial release.
; ======================================================================================================================
; This software is provided 'as-is', without any express or implied warranty.
; In no event will the authors be held liable for any damages arising from the use of this software.
; ======================================================================================================================
Class CtlColors {
   ; ===================================================================================================================
   ; Class variables
   ; ===================================================================================================================
   ; Registered Controls
   Static Attached := {}
   ; OnMessage Handlers
   Static HandledMessages := {Edit: 0, ListBox: 0, Static: 0}
   ; Message Handler Function
   Static MessageHandler := "CtlColors_OnMessage"
   ; Windows Messages
   Static WM_CTLCOLOR := {Edit: 0x0133, ListBox: 0x134, Static: 0x0138}
   ; HTML Colors (BGR)
   Static HTML := {AQUA: 0xFFFF00, BLACK: 0x000000, BLUE: 0xFF0000, FUCHSIA: 0xFF00FF, GRAY: 0x808080, GREEN: 0x008000
                 , LIME: 0x00FF00, MAROON: 0x000080, NAVY: 0x800000, OLIVE: 0x008080, PURPLE: 0x800080, RED: 0x0000FF
                 , SILVER: 0xC0C0C0, TEAL: 0x808000, WHITE: 0xFFFFFF, YELLOW: 0x00FFFF}
   ; Transparent Brush
   Static NullBrush := DllCall("GetStockObject", "Int", 5, "UPtr")
   ; System Colors
   Static SYSCOLORS := {Edit: "", ListBox: "", Static: ""}
   ; Error message in case of errors
   Static ErrorMsg := ""
   ; Class initialization
   Static InitClass := CtlColors.ClassInit()
   ; ===================================================================================================================
   ; Constructor / Destructor
   ; ===================================================================================================================
   __New() { ; You must not instantiate this class!
      If (This.InitClass == "!DONE!") { ; external call after class initialization
         This["!Access_Denied!"] := True
         Return False
      }
   }
   ; ----------------------------------------------------------------------------------------------------------------
   __Delete() {
      If This["!Access_Denied!"]
         Return
      This.Free() ; free GDI resources
   }
   ; ===================================================================================================================
   ; ClassInit       Internal creation of a new instance to ensure that __Delete() will be called.
   ; ===================================================================================================================
   ClassInit() {
      CtlColors := New CtlColors
      Return "!DONE!"
   }
   ; ===================================================================================================================
   ; CheckBkColor    Internal check for parameter BkColor.
   ; ===================================================================================================================
   CheckBkColor(ByRef BkColor, Class) {
      This.ErrorMsg := ""
      If (BkColor != "") && !This.HTML.HasKey(BkColor) && !RegExMatch(BkColor, "^[[:xdigit:]]{6}$") {
         This.ErrorMsg := "Invalid parameter BkColor: " . BkColor
         Return False
      }
      BkColor := BkColor = "" ? This.SYSCOLORS[Class]
              :  This.HTML.HasKey(BkColor) ? This.HTML[BkColor]
              :  "0x" . SubStr(BkColor, 5, 2) . SubStr(BkColor, 3, 2) . SubStr(BkColor, 1, 2)
      Return True
   }
   ; ===================================================================================================================
   ; CheckTxColor    Internal check for parameter TxColor.
   ; ===================================================================================================================
   CheckTxColor(ByRef TxColor) {
      This.ErrorMsg := ""
      If (TxColor != "") && !This.HTML.HasKey(TxColor) && !RegExMatch(TxColor, "i)^[[:xdigit:]]{6}$") {
         This.ErrorMsg := "Invalid parameter TextColor: " . TxColor
         Return False
      }
      TxColor := TxColor = "" ? ""
              :  This.HTML.HasKey(TxColor) ? This.HTML[TxColor]
              :  "0x" . SubStr(TxColor, 5, 2) . SubStr(TxColor, 3, 2) . SubStr(TxColor, 1, 2)
      Return True
   }
   ; ===================================================================================================================
   ; Attach          Registers a control for coloring.
   ; Parameters:     HWND        - HWND of the GUI control                                   
   ;                 BkColor     - HTML color name, 6-digit hexadecimal RGB value, or "" for default color
   ;                 ----------- Optional 
   ;                 TxColor     - HTML color name, 6-digit hexadecimal RGB value, or "" for default color
   ; Return values:  On success  - True
   ;                 On failure  - False, CtlColors.ErrorMsg contains additional informations
   ; ===================================================================================================================
   Attach(HWND, BkColor, TxColor := "") {
      ; Names of supported classes
      Static ClassNames := {Button: "", ComboBox: "", Edit: "", ListBox: "", Static: ""}
      ; Button styles
      Static BS_CHECKBOX := 0x2, BS_RADIOBUTTON := 0x8
      ; Editstyles
      Static ES_READONLY := 0x800
      ; Default class background colors
      Static COLOR_3DFACE := 15, COLOR_WINDOW := 5
      ; Initialize default background colors on first call -------------------------------------------------------------
      If (This.SYSCOLORS.Edit = "") {
         This.SYSCOLORS.Static := DllCall("User32.dll\GetSysColor", "Int", COLOR_3DFACE, "UInt")
         This.SYSCOLORS.Edit := DllCall("User32.dll\GetSysColor", "Int", COLOR_WINDOW, "UInt")
         This.SYSCOLORS.ListBox := This.SYSCOLORS.Edit
      }
      This.ErrorMsg := ""
      ; Check colors ---------------------------------------------------------------------------------------------------
      If (BkColor = "") && (TxColor = "") {
         This.ErrorMsg := "Both parameters BkColor and TxColor are empty!"
         Return False
      }
      ; Check HWND -----------------------------------------------------------------------------------------------------
      If !(CtrlHwnd := HWND + 0) || !DllCall("User32.dll\IsWindow", "UPtr", HWND, "UInt") {
         This.ErrorMsg := "Invalid parameter HWND: " . HWND
         Return False
      }
      If This.Attached.HasKey(HWND) {
         This.ErrorMsg := "Control " . HWND . " is already registered!"
         Return False
      }
      Hwnds := [CtrlHwnd]
      ; Check control's class ------------------------------------------------------------------------------------------
      Classes := ""
      WinGetClass, CtrlClass, ahk_id %CtrlHwnd%
      This.ErrorMsg := "Unsupported control class: " . CtrlClass
      If !ClassNames.HasKey(CtrlClass)
         Return False
      ControlGet, CtrlStyle, Style, , , ahk_id %CtrlHwnd%
      If (CtrlClass = "Edit")
         Classes := ["Edit", "Static"]
      Else If (CtrlClass = "Button") {
         IF (CtrlStyle & BS_RADIOBUTTON) || (CtrlStyle & BS_CHECKBOX)
            Classes := ["Static"]
         Else
            Return False
      }
      Else If (CtrlClass = "ComboBox") {
         VarSetCapacity(CBBI, 40 + (A_PtrSize * 3), 0)
         NumPut(40 + (A_PtrSize * 3), CBBI, 0, "UInt")
         DllCall("User32.dll\GetComboBoxInfo", "Ptr", CtrlHwnd, "Ptr", &CBBI)
         Hwnds.Insert(NumGet(CBBI, 40 + (A_PtrSize * 2, "UPtr")) + 0)
         Hwnds.Insert(Numget(CBBI, 40 + A_PtrSize, "UPtr") + 0)
         Classes := ["Edit", "Static", "ListBox"]
      }
      If !IsObject(Classes)
         Classes := [CtrlClass]
      ; Check background color -----------------------------------------------------------------------------------------
      If (BkColor <> "Trans")
         If !This.CheckBkColor(BkColor, Classes[1])
            Return False
      ; Check text color -----------------------------------------------------------------------------------------------
      If !This.CheckTxColor(TxColor)
         Return False
      ; Activate message handling on the first call for a class --------------------------------------------------------
      For I, V In Classes {
         If (This.HandledMessages[V] = 0)
            OnMessage(This.WM_CTLCOLOR[V], This.MessageHandler)
         This.HandledMessages[V] += 1
      }
      ; Store values for HWND ------------------------------------------------------------------------------------------
      If (BkColor = "Trans")
         Brush := This.NullBrush
      Else
         Brush := DllCall("Gdi32.dll\CreateSolidBrush", "UInt", BkColor, "UPtr")
      For I, V In Hwnds
         This.Attached[V] := {Brush: Brush, TxColor: TxColor, BkColor: BkColor, Classes: Classes, Hwnds: Hwnds}
      ; Redraw control -------------------------------------------------------------------------------------------------
      DllCall("User32.dll\InvalidateRect", "Ptr", HWND, "Ptr", 0, "Int", 1)
      This.ErrorMsg := ""
      Return True
   }
   ; ===================================================================================================================
   ; Change          Change control colors.
   ; Parameters:     HWND        - HWND of the GUI control
   ;                 BkColor     - HTML color name, 6-digit hexadecimal RGB value, or "" for default color
   ;                 ----------- Optional 
   ;                 TxColor     - HTML color name, 6-digit hexadecimal RGB value, or "" for default color
   ; Return values:  On success  - True
   ;                 On failure  - False, CtlColors.ErrorMsg contains additional informations
   ; Remarks:        If the control isn't registered yet, Add() is called instead internally.
   ; ===================================================================================================================
   Change(HWND, BkColor, TxColor := "") {
      ; Check HWND -----------------------------------------------------------------------------------------------------
      This.ErrorMsg := ""
      HWND += 0
      If !This.Attached.HasKey(HWND)
         Return This.Attach(HWND, BkColor, TxColor)
      CTL := This.Attached[HWND]
      ; Check BkColor --------------------------------------------------------------------------------------------------
      If (BkColor <> "Trans")
         If !This.CheckBkColor(BkColor, CTL.Classes[1])
            Return False
      ; Check TxColor ------------------------------------------------------------------------------------------------
      If !This.CheckTxColor(TxColor)
         Return False
      ; Store Colors ---------------------------------------------------------------------------------------------------
      If (BkColor <> CTL.BkColor) {
         If (CTL.Brush) {
            If (Ctl.Brush <> This.NullBrush)
               DllCall("Gdi32.dll\DeleteObject", "Prt", CTL.Brush)
            This.Attached[HWND].Brush := 0
         }
         If (BkColor = "Trans")
            Brush := This.NullBrush
         Else
            Brush := DllCall("Gdi32.dll\CreateSolidBrush", "UInt", BkColor, "UPtr")
         For I, V In CTL.Hwnds {
            This.Attached[V].Brush := Brush
            This.Attached[V].BkColor := BkColor
         }
      }
      For I, V In Ctl.Hwnds
         This.Attached[V].TxColor := TxColor
      This.ErrorMsg := ""
      DllCall("User32.dll\InvalidateRect", "Ptr", HWND, "Ptr", 0, "Int", 1)
      Return True
   }
   ; ===================================================================================================================
   ; Detach          Stop control coloring.
   ; Parameters:     HWND        - HWND of the GUI control
   ; Return values:  On success  - True
   ;                 On failure  - False, CtlColors.ErrorMsg contains additional informations
   ; ===================================================================================================================
   Detach(HWND) {
      This.ErrorMsg := ""
      HWND += 0
      If This.Attached.HasKey(HWND) {
         CTL := This.Attached[HWND].Clone()
         If (CTL.Brush) && (CTL.Brush <> This.NullBrush)
            DllCall("Gdi32.dll\DeleteObject", "Prt", CTL.Brush)
         For I, V In CTL.Classes {
            If This.HandledMessages[V] > 0 {
               This.HandledMessages[V] -= 1
               If This.HandledMessages[V] = 0
                  OnMessage(This.WM_CTLCOLOR[V], "")
         }  }
         For I, V In CTL.Hwnds
            This.Attached.Remove(V, "")
         DllCall("User32.dll\InvalidateRect", "Ptr", HWND, "Ptr", 0, "Int", 1)
         CTL := ""
         Return True
      }
      This.ErrorMsg := "Control " . HWND . " is not registered!"
      Return False
   }
   ; ===================================================================================================================
   ; Free            Stop coloring for all controls and free resources.
   ; Return values:  Always True.
   ; ===================================================================================================================
   Free() {
      For K, V In This.Attached
         If (V.Brush) && (V.Brush <> This.NullBrush)
            DllCall("Gdi32.dll\DeleteObject", "Ptr", V.Brush)
      For K, V In This.HandledMessages
         If (V > 0) {
            OnMessage(This.WM_CTLCOLOR[K], "")
            This.HandledMessages[K] := 0
         }
      This.Attached := {}
      Return True
   }
   ; ===================================================================================================================
   ; IsAttached      Check if the control is registered for coloring.
   ; Parameters:     HWND        - HWND of the GUI control
   ; Return values:  On success  - True
   ;                 On failure  - False
   ; ===================================================================================================================
   IsAttached(HWND) {
      Return This.Attached.HasKey(HWND)
   }
}
; ======================================================================================================================
; CtlColors_OnMessage
; This function handles CTLCOLOR messages. There's no reason to call it manually!
; ======================================================================================================================
CtlColors_OnMessage(HDC, HWND) {
   Critical
   If CtlColors.IsAttached(HWND) {
      CTL := CtlColors.Attached[HWND]
      If (CTL.TxColor != "")
         DllCall("Gdi32.dll\SetTextColor", "Ptr", HDC, "UInt", CTL.TxColor)
      If (CTL.BkColor = "Trans")
         DllCall("Gdi32.dll\SetBkMode", "Ptr", HDC, "UInt", 1) ; TRANSPARENT = 1
      Else
         DllCall("Gdi32.dll\SetBkColor", "Ptr", HDC, "UInt", CTL.BkColor)
      Return CTL.Brush
   }
}
; http://www.autohotkey.com/board/topic/104539-controlcol-set-background-and-text-color-gui-controls/

ControlColor(Control, Window, bc := "", tc := "", Redraw := True) {
    Local a := {}
    a["c"]  := Control
    a["g"]  := Window
    a["bc"] := (bc == "") ? "" : (((bc & 255) << 16) + (((bc >> 8) & 255) << 8) + (bc >> 16))
    a["tc"] := (tc == "") ? "" : (((tc & 255) << 16) + (((tc >> 8) & 255) << 8) + (tc >> 16))

    CC_WindowProc("Set", a, "", "")

    If (Redraw) {
        WinSet Redraw,, ahk_id %Control%
    }
}

CC_WindowProc(hWnd, uMsg, wParam, lParam) {
    Local tc, bc, a
    Static Win := {}
    ; Critical

    If uMsg Between 0x132 And 0x138 ; WM_CTLCOLOR(MSGBOX|EDIT|LISTBOX|BTN|DLG|SCROLLBAR|STATIC)
    If (Win[hWnd].HasKey(lParam)) {
        If (tc := Win[hWnd, lParam, "tc"]) {
            DllCall("gdi32.dll\SetTextColor", "Ptr", wParam, "UInt", tc)
        }

        If (bc := Win[hWnd, lParam, "bc"]) {
            DllCall("gdi32.dll\SetBkColor",   "Ptr", wParam, "UInt", bc)
        }

        Return Win[hWnd, lParam, "Brush"] ; Return the HBRUSH to notify the OS that we altered the HDC.
    }

    If (hWnd == "Set") {
        a := uMsg
        Win[a.g, a.c] := a

        If ((Win[a.g, a.c, "tc"] == "") && (Win[a.g, a.c, "bc"] == "")) {
            Win[a.g].Remove(a.c, "")            
        }

        If (!Win[a.g, "WindowProcOld"]) {
            Win[a.g,"WindowProcOld"] := DllCall("SetWindowLong" . (A_PtrSize == 8 ? "Ptr" : "")
            , "Ptr", a.g, "Int", -4, "Ptr", RegisterCallback("CC_WindowProc", "", 4), "UPtr")
        }

        If (Win[a.g, a.c, "bc"] != "") {
            Win[a.g, a.c, "Brush"] := DllCall("gdi32.dll\CreateSolidBrush", "UInt", a.bc, "UPtr")
        }

        Return
    }

    Return DllCall("CallWindowProc", "Ptr", Win[hWnd, "WindowProcOld"], "Ptr", hWnd, "UInt", uMsg, "Ptr", wParam, "Ptr", lParam, "Ptr")
}
; ======================================================================================================================
ODLB_DrawItem(wParam, lParam, Msg, Hwnd) {
   ; lParam / DRAWITEMSTRUCT offsets
   Static offItem := 8, offAction := offItem + 4, offState := offAction + 4, offHWND := offState + A_PtrSize
        , offDC := offHWND + A_PtrSize, offRECT := offDC + A_PtrSize, offData := offRECT + 16
   ; Owner Draw Type
   Static ODT := {2: "LISTBOX", 3: "COMBOBOX"}
   ; Owner Draw Action
   Static ODA_DRAWENTIRE := 0x0001, ODA_SELECT := 0x0002, ODA_FOCUS := 0x0004
   ; Owner Draw State
   Static ODS_SELECTED := 0x0001, ODS_FOCUS := 0x0010
   ; Draw text format flags
   Static DT_Flags := 0x24 ; DT_SINGLELINE = 0x20, DT_VCENTER = 0x04
   ; -------------------------------------------------------------------------------------------------------------------
   Critical ; may help in case of drawing issues
   If (Numget(lParam + 0, 0, "UInt") <> 2) ; ODT_LISTBOX
      Return
   HWND := NumGet(lParam + offHWND, 0, "UPtr")
   Item := NumGet(lParam + offItem, 0, "Int")
   Action := NumGet(lParam + offAction, 0, "UInt")
   State := NumGet(lParam + offState, 0, "UInt")
   HDC := NumGet(lParam + offDC, 0, "UPtr")
   RECT := lParam + offRECT
   If (Action = ODA_FOCUS)
      Return True
   BgC := CtrlBgC := DllCall("Gdi32.dll\GetBkColor", "Ptr", HDC, "UInt")
   TxC := CtrlTxC := DllCall("Gdi32.dll\GetTextColor", "Ptr", HDC, "UInt")
   If (State & ODS_SELECTED) {
      C := ODLB_SetHiLiteColors("!GET!")
      BgC := C.HC, TxC := C.TC
   }
   Brush := DllCall("Gdi32.dll\CreateSolidBrush", "UInt", BgC, "UPtr")
   DllCall("User32.dll\FillRect", "Ptr", HDC, "Ptr", RECT, "Ptr", Brush)
   DllCall("Gdi32.dll\DeleteObject", "Ptr", Brush)
   NumPut(NumGet(RECT + 0, 0, "Int") + 2, RECT + 0, 0, "Int")
   SendMessage, 0x018A, % Item, 0, , ahk_id %HWND% ; LB_GETTEXTLEN
   VarSetCapacity(Txt, ErrorLevel << !!A_IsUnicode, 0)
   SendMessage, 0x0189, % Item, % &Txt, , ahk_id %HWND% ; LB_GETTEXT
   VarSetCapacity(Txt, -1)
   DllCall("Gdi32.dll\SetBkMode", "Ptr", HDC, "Int", 1) ; TRANSPARENT
   DllCall("Gdi32.dll\SetTextColor", "Ptr", HDC, "UInt", TxC)
   DllCall("User32.dll\DrawText", "Ptr", HDC, "Ptr", &Txt, "Int", -1, "Ptr", RECT, "UInt", 0x24)
   NumPut(NumGet(RECT + 0, 0, "Int") - 2, RECT + 0, 0, "Int")
   DllCall("Gdi32.dll\SetTextColor", "Ptr", HDC, "UInt", CtrlTxC)
   Return True
}
; ======================================================================================================================
ODLB_MeasureItem(wParam, lParam, Msg, Hwnd) {
   ; lParam -> MEASUREITEMSTRUCT offsets
   Static offHeight := 16
   ; -------------------------------------------------------------------------------------------------------------------
   NumPut(ODLB_SetItemHeight("!GET!"), lParam + 0, offHeight, "Int")
   Return True
}
; ======================================================================================================================
ODLB_SetItemHeight(FontOptions := "", FontName := "") {
   Static ItemHeight := 0
   If (FontOptions <> "!GET!") {
      Gui, ODLB_SetItemHeight:Font, %FontOptions%, %FontName%
      Gui, ODLB_SetItemHeight:Add, Text, 0x200 hwndHTX, Dummy
      VarSetCapacity(RECT, 16, 0)
      DllCall("User32.dll\GetClientRect", "Ptr", HTX, "Ptr", &RECT)
      Gui, ODLB_SetItemHeight:Destroy
      ItemHeight := NumGet(RECT, 12, "Int")
   }
   Return ItemHeight
}
; ======================================================================================================================
ODLB_SetHiLiteColors(HiLite := "", Text := "") {
   Static HC := DllCall("User32.dll\GetSysColor", "Int", 13, "UInt") ; COLOR_HIGHLIGHT
   Static TC := DllCall("User32.dll\GetSysColor", "Int", 14, "UInt") ; COLOR_HIGHLIGHTTEXT
   If (HiLite <> "!GET!") {
      If (HiLite = "")
         HC := DllCall("User32.dll\GetSysColor", "Int", 13, "UInt")
      Else
         HC := ((HiLite >> 16) & 0xFF) | (HiLite & 0x00FF00) | ((HiLite & 0xFF) << 16)
      If (Text = "")
         TC := DllCall("User32.dll\GetSysColor", "Int", 14, "UInt")
      Else
         TC := ((Text >> 16) & 0xFF) | (Text & 0x00FF00) | ((Text & 0xFF) << 16)
   }
   Return {HC: HC, TC: TC}
}
tip(ttext := "") 
{
    If (ttext > "") 
    {
        Gui, Tip:New, +ToolWindow -Caption +AlwaysOnTop
        Gui, Margin, 1, 1
        Gui, Add, Edit, w300 r30 ReadOnly, %ttext%
        Gui, Show, NoActivate
    } 
    Else 
        Gui, Tip:Destroy
}

TipGuiEscape:
Gui, Tip:Destroy
Return