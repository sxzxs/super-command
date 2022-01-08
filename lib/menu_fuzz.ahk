; 超级命令
; Tested on AHK v1.1.33.02 Unicode 32/64-bit, Windows /10

; Script compiler directives
;@Ahk2Exe-SetMainIcon %A_ScriptDir%\Icons\Verifier.ico
;@Ahk2Exe-SetVersion 0.1.0

OnMessage(0x004A, "Receive_WM_COPYDATA")  ; 0x004A 为 WM_COPYDATA
OnMessage(0x100, "GuiKeyDown")
#SingleInstance force
#include <py>
#include <btt>
#include <log4ahk>
#Persistent

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
ctrl+c: 复制当前文本
alt+c: 编辑所有命令
ctrl+x: 编辑当前命令
shift+enter:  搜索命令
)

btt(help_string,,,1,"Style4")
SetTimer, RemoveToolTip, -3000

py.allspell_muti("ahk")
begin := 1
total_command := 0 ;总命令个数
is_get_all_cmd := false
cmds := ""
my_xml := new xml("xml")
menue_create_pid := 0
gui_x := 200
gui_y := 0
g_curent_text := ""
g_command := ""

if !FileExist(A_ScriptDir "\cmd\Menus\超级命令.xml")
{
    MsgBox,% A_ScriptDir "\cmd\Menus\超级命令.xml 不存在, alt + c 添加命令并保存在上面目录" 
}
fileread, xml_file_content,% "*P65001 " A_ScriptDir "\cmd\Menus\超级命令.xml"
my_xml.XML.LoadXML(xml_file_content)
cmds := xml_parse(my_xml)


log.info(cmds)

handle_add_pinyin(ByRef cmds, "bd")

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
    goto GuiEscape
}
Gui Destroy
Gui, +HwndMyGuiHwnd
Gui, Color,,0x000000
Gui Font, s11
Gui Margin, 0, 0
Gui, Font, s10 cLime, Consolas
Gui Add, Edit, x0 w500 vQuery gType
Gui Add, ListBox, x0 y+2 h20 w500  vCommand gSelect AltSubmit +Background0x000000 -HScroll
Gui, -Caption +AlwaysOnTop -DPIScale
gosub Type
Gui Show, X200 Y0
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
GuiControl, Move, Command, % "h" 4 + 15 * (total_command > 4 ? 10 : total_command + 2)
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
    ;Clipboard := UnityPath
    g_command := command
    g_curent_text := UnityPath
    GuiControlGet, out, Pos, Query
    if(!WinExist("超级命令添加工具"))
        btt(UnityPath, gui_x + outW, gui_y,,"Style2")
}

handle_command(command)
{
    global my_xml, menue_create_pid, log
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


    ExecScript(UnityPath)
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
                ParentName := c_parent_name " >" parentname
            c := p
        }
        Script .= ParentName  ea.Name "`r`n"
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
btt(,,,1)
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
;{ Sift
; Fanatic Guru
; 2015 04 30
; Version 1.00
;
; LIBRARY to sift through a string or array and return items that match sift criteria.
;
; ===================================================================================================================================================
;
; Functions:
; 
; ===================================================================================================================================================
; Sift_Regex(Haystack, Needle, Options, Delimiter)
;
;   Parameters:
;   1) {Haystack}	String or array of information to search, ByRef for efficiency but Haystack is not changed by function
;
;   2) {Needle}		String providing search text or criteria, ByRef for efficiency but Needle is not changed by function
;
;	3) {Options}
;			IN		Needle anywhere IN Haystack item (Default = IN)
;			LEFT	Needle is to LEFT or beginning of Haystack item
;			RIGHT	Needle is to RIGHT or end of Haystack item
;			EXACT	Needle is an EXACT match to Haystack item
;			REGEX	Needle is an REGEX expression to check against Haystack item
;			OC		Needle is ORDERED CHARACTERS to be searched for even non-consecutively but in the given order in Haystack item 
;			OW		Needle is ORDERED WORDS to be searched for even non-consecutively but in the given order in Haystack item
;			UC		Needle is UNORDERED CHARACTERS to be search for even non-consecutively and in any order in Haystack item
;			UW		Needle is UNORDERED WORDS to be search for even non-consecutively and in any order in Haystack item
;
;			If an Option is all lower case then the search will be case insensitive
;
;	4)  {Delimiter}	Single character Delimiter of each item in a Haystack string (Default = `n)
;
;	Returns: 
;		If Haystack is string then a string is returned of found Haystack items delimited by the Delimiter
; 		If Haystack is an array then an array is returned of found Haystack items
;
; 	Note:
;		Sift_Regex searchs are all RegExMatch seaches with Needles crafted based on the options chosen
;
; ===================================================================================================================================================
; Sift_Ngram(Haystack, Needle, Delta, Haystack_Matrix, Ngram Size, Format)
;
;	Parameters:
;	1) {Haystack}		String or array of information to search, ByRef for efficiency but Haystack is not changed by function
;
;   2) {Needle}			String providing search text or criteria, ByRef for efficiency but Needle is not changed by function
;
;	3) {Delta}			(Default = .7) Fuzzy match coefficient, 1 is a prefect match, 0 is no match at all, only results above the Delta are returned
;
;	4) {Haystack_Matrix} (Default = false)	
;			An object containing the preprocessing of the Haystack for Ngrams content
;			If a non-object is passed the Haystack is processed for Ngram content and the results are returned by ByRef
;			If an object is passed then that is used as the processed Ngram content of Haystack
;			If multiply calls to the function are made with no change to the Haystack then a previous processing of Haystack for Ngram content 
;				can be passed back to the function to avoid reprocessing the same Haystack again in order to increase efficiency.
;
;	5) {Ngram Size}		(Default = 3) The length of Ngram used.  Generally Ngrams made of 3 letters called a Trigram is good
;
;	6) {Format}			(Default = S`n)
;			S				Return Object with results Sorted
;			U				Return Object with results Unsorted
;			S%%%			Return Sorted string delimited by characters after S
;			U%%%			Return Unsorted string delimited by characters after U
;								Sorted results are by best match first
;
;	Returns:
;		A string or array depending on Format parameter.
;		If string then it is delimited based on Format parameter.
;		If array then an array of object is returned where each element is of the structure: {Object}.Delta and {Object}.Data
;			Example Code to access object returned:
;				for key, element in Sift_Ngram(Data, QueryText, NgramLimit, Data_Ngram_Matrix, NgramSize)
;						Display .= element.delta "`t" element.data "`n"
;
;	Dependencies: Sift_Ngram_Get, Sift_Ngram_Compare, Sift_Ngram_Matrix, Sift_SortResults
;		These are helper functions that are generally not called directly.  Although Sift_Ngram_Matrix could be useful to call directly to preprocess a large static Haystack
;
; 	Note:
;		The string "dog house" would produce these Trigrams: dog|og |g h| ho|hou|ous|use
;		Sift_Ngram breaks the needle and each item of the Haystack up into Ngrams.
;		Then all the Needle Ngrams are looked for in the Haystack items Ngrams resulting in a percentage of Needle Ngrams found
;
; ===================================================================================================================================================
;
Sift_Regex(ByRef Haystack, ByRef Needle, Options := "IN", Delimit := "`n")
{
	Sifted := {}
	if (Options = "IN")		
		Needle_Temp := "\Q" Needle "\E"
	else if (Options = "LEFT")
		Needle_Temp := "^\Q" Needle "\E"
	else if (Options = "RIGHT")
		Needle_Temp := "\Q" Needle "\E$"
	else if (Options = "EXACT")		
		Needle_Temp := "^\Q" Needle "\E$"
	else if (Options = "REGEX")
		Needle_Temp := Needle
	else if (Options = "OC")
		Needle_Temp := RegExReplace(Needle,"(.)","\Q$1\E.*")
	else if (Options = "OW")
		Needle_Temp := RegExReplace(Needle,"( )","\Q$1\E.*")
	else if (Options = "UW")
		Loop, Parse, Needle, " "
			Needle_Temp .= "(?=.*\Q" A_LoopField "\E)"
	else if (Options = "UC")
		Loop, Parse, Needle
			Needle_Temp .= "(?=.*\Q" A_LoopField "\E)"

	if Options is lower
		Needle_Temp := "i)" Needle_Temp
	
	if IsObject(Haystack)
	{
		for key, Hay in Haystack
			if RegExMatch(Hay, Needle_Temp)
				Sifted.Insert(Hay)
	}
	else
	{
		Loop, Parse, Haystack, %Delimit%
			if RegExMatch(A_LoopField, Needle_Temp)
				Sifted .= A_LoopField Delimit
		Sifted := SubStr(Sifted,1,-1)
	}
	return Sifted
}

Sift_Ngram(ByRef Haystack, ByRef Needle, Delta := .7, ByRef Haystack_Matrix := false, n := 3, Format := "S`n" )
{
	if !IsObject(Haystack_Matrix)
		Haystack_Matrix := Sift_Ngram_Matrix(Haystack, n)
	Needle_Ngram := Sift_Ngram_Get(Needle, n)
	if IsObject(Haystack)
	{
		Search_Results := {}
		for key, Hay_Ngram in Haystack_Matrix
		{
			Result := Sift_Ngram_Compare(Hay_Ngram, Needle_Ngram)
			if !(Result < Delta)
				Search_Results[key,"Delta"] := Result, Search_Results[key,"Data"] := Haystack[key]
		}
	}
	else
	{
		Search_Results := {}
		Loop, Parse, Haystack, `n, `r
		{
			Result := Sift_Ngram_Compare(Haystack_Matrix[A_Index], Needle_Ngram)
			if !(Result < Delta)
				Search_Results[A_Index,"Delta"] := Result, Search_Results[A_Index,"Data"] := A_LoopField
		}
	}
	if (Format ~= "i)^S")
		Sift_SortResults(Search_Results)
	if RegExMatch(Format, "i)^(S|U)(.+)$", Match)
	{
		for key, element in Search_Results
			String_Results .= element.data Match2
		return SubStr(String_Results,1,-StrLen(Match2))
	}
	else
		return Search_Results
}

Sift_Ngram_Get(ByRef String, n := 3)
{
	Pos := 1, Grams := {}
	Loop, % (1 + StrLen(String) - n)
		gram := SubStr(String, A_Index, n), Grams[gram] ? Grams[gram] ++ : Grams[gram] := 1
	return Grams
} 

Sift_Ngram_Compare(ByRef Hay, ByRef Needle)
{
	for gram, Needle_Count in Needle
	{
		Needle_Total += Needle_Count
		Match += (Hay[gram] > Needle_Count ? Needle_Count : Hay[gram])
	}
	return Match / Needle_Total
}

Sift_Ngram_Matrix(ByRef Data, n := 3)
{
	if IsObject(Data)
	{
		Matrix := {}
		for key, string in Data
			Matrix.Insert(Sift_Ngram_Get(string, n))
	}
	else
	{
		Matrix := {}
		Loop, Parse, Data, `n
			Matrix.Insert(Sift_Ngram_Get(A_LoopField, n))
	}
	return Matrix
}

Sift_SortResults(ByRef Data)
{
	Data_Temp := {}
	for key, element in Data
		Data_Temp[element.Delta SubStr("0000000000" key, -9)] := element
	Data := {}
	for key, element in Data_Temp
		Data.InsertAt(1,element)
	return
}

handle_add_pinyin(ByRef cmds, Needle, Delta := 1, Haystack_Matrix := false, n := 1, Format := "S`n" )
{
    cmd_array := StrSplit(cmds, ["`r`n"])
    for k,v in cmd_array
    {
        cmd_array[k] .= ";" py.allspell_muti(v) ";" py.initials_muti(v) 
    }
    rtn := Sift_Ngram(cmd_array, Needle, Delta, Haystack_Matrix, n, Format)
    rtn := RegExReplace(rtn, "m`a);.*")
    log.info(rtn)
}