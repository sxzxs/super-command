OnMessage(0x100, "GuiKeyDown")
OnMessage(0x6, "GuiActivate")
#include <py>
#Persistent
#SingleInstance force

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
SetBatchLines -1
help_string =
(
alt+c:  编辑命令
alt+q:  搜索命令
alt+x:  menu菜单命令
)
;msgbox,% help_string
py.allspell_muti("ahk")
begin := 1
total_command := 0 ;总命令个数
is_get_all_cmd := false
cmds := ""
my_xml := new xml("xml")
if !FileExist(A_ScriptDir "\cmd\Menus\超级命令.xml")
{
    MsgBox,% A_ScriptDir "\cmd\Menus\超级命令.xml 不存在,\cmd\menue_create.ahk 创建并保持在上面目录" 
}
fileread, xml_file_content,% A_ScriptDir "\cmd\Menus\超级命令.xml"
my_xml.XML.LoadXML(xml_file_content)

#include %A_ScriptDir%\cmd\menufunc.ahk
init()
{
    global
    Gui Destroy
    Gui, +HwndMyGuiHwnd
    Menu, MyMenuBar, Add, $, :Menu
    Gui, Menu, MyMenuBar,
    if(!is_get_all_cmd)
    {
        cmds := MenuGetAll(MyGuiHwnd)
    }
}
!q::
SetCapsLockState,off
switchime(0)
Gui +LastFoundExist
if WinActive()
{
    goto GuiEscape
}
Gui Destroy
Gui, +HwndMyGuiHwnd
Menu, MyMenuBar, Add, $, :Menu
Gui, Menu, MyMenuBar,
Gui, Color,,0x000000
Gui Font, s11
Gui Margin, 0, 0
Gui, Font, s10 cLime, Consolas
Gui Add, Edit, x0 w500 vQuery gType
Gui Add, ListBox, x0 y+2 h20 w500  vCommand gSelect AltSubmit +Background0x000000 -HScroll
Gui, -Caption +AlwaysOnTop
if(!is_get_all_cmd)
{
    cmds := MenuGetAll(MyGuiHwnd)
}
gosub Type
DllCall("SetMenu", "Ptr", MyGuiHwnd, "Ptr", 0)
with:=A_ScreenWidth/2
height:=A_ScreenHeight/2
Gui Show, x%with% y%height%
GuiControl Focus, Query
return

MenuHandler:
msgbox,ok
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
        r := Filter_new(r, q%A_Index%, c)
}
rows := ""
row_id := []
Loop Parse, r, `n
{
    RegExMatch(A_LoopField, "(\d+)`t(.*)", m)
    row_id[A_Index] := m1
    rows .= "|"  m2
}
GuiControl,, Command, % rows ? rows : "|"
if (Query = "")
    c := row_id.MaxIndex()
total_command := c
GuiControl, Move, Command, % "h" 4 + 15 * (total_command > 4 ? 10 : total_command + 2)
GuiControl, % (total_command && Query != "") ? "Show" : "Hide", Command
Gui, Show, AutoSize

Select:
GuiControlGet Command
if !Command
    Command := 1
Command := row_id[Command]
SB_SetText("Total " c " results`t`tID: " Command)
if (A_GuiEvent != "DoubleClick")
{
    return
}

Confirm:
if !GetKeyState("Shift")
{
    gosub GuiEscape
}
;DllCall("SendNotifyMessage", "ptr", MyGuiHwnd, "uint", 0x111, "ptr", Command, "ptr", 0)
cmd2array(Command)
return

GuiEscape:
Gui,Hide
;cmds := r := ""
return

GuiSize:
;GuiControl Move, Query, % "w" A_GuiWidth-20
;GuiControl Move, Command, % "w" A_GuiWidth-20
return

GuiActivate(wParam)
{
    if (A_Gui && wParam = 0)
        SetTimer GuiEscape, -5
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
Filter_new(s, q, ByRef count)
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

Filter(s, q, ByRef count)
{
    ;转换_拼音首字母,或者 建立数组 [{“a" : "", "b" :""}]
    ;匹配，删除
    if (q = "")
    {
        StringReplace s, s, `n, `n, UseErrorLevel
        count := ErrorLevel
        return s
    }
    i := 1
    match := ""
    result := ""
    count := 0
    while i := RegExMatch(s, "`ami)^.*\Q" q "\E.*$", match, i + StrLen(match))
    {
        result .= match "`n"
        count += 1
    }
    return SubStr(result, 1, -1)
}

MenuGetAll(hwnd)
{
    if !menu := DllCall("GetMenu", "ptr", hwnd, "ptr")
        return ""    
    MenuGetAll_sub(menu, "", cmds)
    return cmds
}

MenuGetAll_sub(menu, prefix, ByRef cmds)
{
    Loop % DllCall("GetMenuItemCount", "ptr", menu)
    {
        VarSetCapacity(itemString, 2000)
        if !DllCall("GetMenuString", "ptr", menu, "int", A_Index-1, "str", itemString, "int", 1000, "uint", 0x400)
            continue
        StringReplace itemString, itemString, &
        itemID := DllCall("GetMenuItemID", "ptr", menu, "int", A_Index-1)
        if (itemID = -1)
        if subMenu := DllCall("GetSubMenu", "ptr", menu, "int", A_Index-1, "ptr")
        {
            MenuGetAll_sub(subMenu, prefix itemString " > ", cmds)
            continue
        }
        cmds .= itemID "`t" prefix RegExReplace(itemString, "`t.*") "`n"
    }
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

DynaRun(Script,Wait:=true,name:="Untitled"){
	static exec,started,filename
	if(!IsObject(v.Running))
		v.Running:=[]
	filename:=name,MainWin.Size(),exec.Terminate()
	if(Script~="i)m(.*)\{"=0)
		Script.="`n" "m(x*){`nfor a,b in x`nlist.=b Chr(10)`nMsgBox,,AHK Studio,% list`n}"
	if(Script~="i)t(.*)\{"=0)
		Script.="`n" "t(x*){`nfor a,b in x`nlist.=b Chr(10)`nToolTip,% list`n}"
	;shell:=ComObjCreate("WScript.Shell"),exec:=shell.Exec("AutoHotkey.exe /ErrorStdOut *"),exec.StdIn.Write(Script),exec.StdIn.Close(),started:=A_Now
	shell:=ComObjCreate("WScript.Shell"),exec:=shell.Exec("AutoHotkey.exe /ErrorStdOut *"),exec.StdIn.Write(Script),exec.StdIn.Close(),started:=A_Now
	v.Running[Name]:=exec
	return
}
!x::
init()
Menu,Menu,Show
return

!c::
;Menu,Menu,Show
run,% A_ScriptDir "\cmd\menue_create.ahk"
return
Function(Item,Index,Menu)
{
    MenuID := DllCall( "GetMenuItemID", "ptr", Menu_GetMenuByName(Menu), "int", Index-1 )
    cmd2array(MenuID)
}

cmd2array(command)
{
    global cmds,my_xml
    pattern = 
    (
Om`a)%command%.*?>(.*)$
    )
    word_array := []
    if(RegExMatch(cmds, pattern, SubPat))
    {
        newstr := StrReplace(subpat.Value(1), A_Space)
        word_array := StrSplit(newstr, ">")
        ;xx := my_xml.SSN("//Menu/*[@name='网站文件夹']/*[@name='百度_75WWJ2OTZ']").text
    }
    pattern := ""
    for k,v in word_array
    {
        pattern .= "/*[@name='" v "']"
    }
    pattern := "//Menu" . pattern

    UnityPath:=my_xml.SSN(pattern).text
    DynaRun(UnityPath)
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

; ======================================================================================================================
; GetMenuByName   Retrieves a handle to the menu specified by its name.
; Return values:  If the function succeeds, the return value is a handle to the menu.
;                 Otherwise, the return value is zero (False).
; Remarks:        Based on MI.ahk by Lexikos -> http://www.autohotkey.com/board/topic/20253-menu-icons-v2/
; ======================================================================================================================
Menu_GetMenuByName(MenuName) {
   Static HMENU := 0
   If !(HMENU) {
      Menu, %A_ThisFunc%Menu, Add
      Menu, %A_ThisFunc%Menu, DeleteAll
      Gui, %A_ThisFunc%GUI:+HwndHGUI
      Gui, %A_ThisFunc%GUI:Menu, %A_ThisFunc%Menu
      HMENU := Menu_GetMenu(HGUI)
      Gui, %A_ThisFunc%GUI:Menu
      Gui, %A_ThisFunc%GUI:Destroy
   }
   If !(HMENU)
      Return 0
   Menu, %A_ThisFunc%Menu, Add, :%MenuName%
   HSUBM := Menu_GetSubMenu(HMENU, 1)
   Menu, %A_ThisFunc%Menu, Delete, :%MenuName%
   Return HSUBM
}
Menu_GetMenu(HWND) {
   ; http://msdn.microsoft.com/en-us/library/ms647640(v=vs.85).aspx
   Return DllCall("User32.dll\GetMenu", "Ptr", HWND, "Ptr")
}
Menu_GetSubMenu(HMENU, ItemPos) {
   ; http://msdn.microsoft.com/en-us/library/ms647984(v=vs.85).aspx
   Return DllCall("User32.dll\GetSubMenu", "Ptr", HMENU, "Int", ItemPos - 1, "Ptr")
}