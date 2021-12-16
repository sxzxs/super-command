#SingleInstance,Force
global Settings:=new XML("Settings"),MainWin:=new GUIKeep(1),MenuXML
if((A_PtrSize=8&&A_IsCompiled="")||!A_IsUnicode){
	SplitPath,A_AhkPath,,dir
	if(!FileExist(correct:=dir "\AutoHotkeyU32.exe")){
		m("Requires AutoHotkey 1.1 to run")
		ExitApp
	}
	Run,"%correct%" "%A_ScriptName%" "%file%",%A_ScriptDir%
	ExitApp
	return
}Main:={"&File":["&New","&Open","Ex&port","&Save","E&xit"],"A&bout":["Help","Online Manual"]},Order:=["&File","A&bout"],MenuXML:=new XML("Menu",Settings.Get("//Last/@file","Menus\Menu.XML"))
for a,b in Order
	for c,d in Main[b]
		Menu,% RegExReplace(b,"\W"),Add,%d%,MenuHandler
for a,b in Order
	Menu,Main,Add,%b%,% ":" RegExReplace(b,"\W")
Gui,Menu,Main
MainWin.Add("TreeView,w350 h300 vTV gUpdateColor AltSubmit,,wh"
		 ,"GroupBox,w240 h140 Section,New Menu:,y"
		 ,"Edit,xp+10 yp+20 w220 vItem,,y"
		 ,"Button,xs+10 yp+30 gAddMenuItem Default,&Add,y"
		 ,"Button,x+m gAddSubMenuItem,Add &Sub-Menu,y"
		 ,"Button,x+m gEdit,&Name,y"
		 ,"Radio,xs+30 yp+35 vAfter Checked gFocusItem,Insert Af&ter,y"
		 ,"Radio,vBefore gFocusItem,Insert &Before,y"
		 ,"GroupBox,xs+250 ys w100 h110 Section,Color,y"
		 ,"Progress,xs+10 ys+20 w16 h16 c0xff00ff vProgress,100,y"
		 ,"Button,xs+10 yp+20 gChangeColor,&Current,y"
		 ,"Button,gChangeRoot,&Root,y"
		 ;,"Button,xm gShowMenu,Sho&w Menu,y"
		 ,"Checkbox,xm vConfirm,Confirm Delete,y"
		 ;,"Button,gname_add_time, name增加id,y"
		 ,"Button,geditcmd,编辑命令,y"
		 ,"Button,gsave_script x+10,确定,y"
		 ,"StatusBar")
MainWin.SetText("Confirm",Settings.Get("//Confirm",1))
MainWin.Show("超级命令添加工具")
Hotkey,IfWinActive,% MainWin.ID
for a,b in {Delete:"Delete",Up:"Arrows",Down:"Arrows",Left:"Arrows",Right:"Arrows","!Up":"Move","!Down":"Move","!Left":"Move","!Right":"Move"}
	Hotkey,%a%,%b%,On
Populate(),MainWin.Focus("Item")
return
class GUIKeep{
	static Table:=[],ShowList:=[]
	__Get(x*){
		if(x.1)
			return this.Var[x.1]
		return this.Add()
	}__New(win,parent:=""){
		DetectHiddenWindows,On
		Gui,%win%:Destroy
		Gui,%win%:+hwndhwnd -DPIScale
		Gui,%win%:Margin,5,5
		Gui,%win%:Font,s10 c0xAAAAAA,Courier New
		Gui,%win%:Color,0,0
		this.All:=[],this.gui:=[],this.hwnd:=hwnd,this.con:=[],this.XML:=new XML("GUI"),this.ahkid:=this.id:="ahk_id" hwnd,this.win:=win,this.Table[win]:=this,this.var:=[],this.Radio:=[],this.Static:=[]
		for a,b in {border:A_OSVersion~="^10"?3:0,caption:DllCall("GetSystemMetrics",int,4,"int")}
			this[a]:=b
		Gui,%win%:+LabelGUIKeep.
		Gui,%win%:Default
		return this
	}Add(info*){
		static
		if(!info.1){
			var:=[]
			Gui,% this.Win ":Submit",Nohide
			for a,b in this.var{
				if(b.Type="s")
					Var[a]:=b.sc.GetUNI()
				else
					var[a]:=%a%
			}return var
		}for a,b in info{
			i:=StrSplit(b,","),newpos:=""
			if(i.1="ComboBox")
				WinGet,ControlList,ControlList,% this.ID
			if(i.1="s"){
				Pos:=RegExReplace(i.2,"OU)\s*\b(v.+)\b")
				sc:=new s(1,{Pos:Pos}),hwnd:=sc.sc
			}else
				Gui,% this.win ":Add",% i.1,% i.2 " hwndhwnd",% i.3
			if(RegExMatch(i.2,"U)\bg(.*)\b",Label))
				Label:=Label1
			if(RegExMatch(i.2,"U)\bv(.*)\b",var))
				this.var[var1]:={hwnd:HWND,type:i.1,sc:sc}
			this.con[hwnd]:=[]
			if(i.4!="")
				this.con[hwnd,"pos"]:=i.4,this.resize:=1
			if(i.5)
				this.Static.Push(hwnd)
			Name:=Var1?Var1:Label
			if(i.1="ListView"||i.1="TreeView")
				this.All[Name]:={HWND:HWND,Name:Name,Type:i.1,ID:"ahk_id" HWND}
			if(i.1="ComboBox"){
				WinGet,ControlList2,ControlList,% this.ID
				Obj:=StrSplit(ControlList2,"`n"),LeftOver:=[]
				for a,b in Obj
					LeftOver[b]:=1
				for a,b in Obj2:=StrSplit(ControlList,"`n")
					LeftOver.Delete(b)
				for a in LeftOver{
					if(!InStr(a,"ComboBox")){
						ControlGet,Married,HWND,,%a%,% this.ID
						this.XML.Add("Control",{hwnd:Married,id:"ahk_id" Married+0,name:Name,type:"Edit"},,1)
					}
				}
				
			}
			this.XML.Add("Control",{hwnd:HWND,id:"ahk_id" HWND,name:Name,type:i.1},,1)
	}}Close(a:=""){
		this:=GUIKeep.table[A_Gui]
		if(A_Gui=1)
			this.Exit()
	}ContextMenu(x*){
		if(IsFunc(Function:=A_Gui "GuiContextMenu"))
			%Function%(x*)
	}Current(XPath,Number){
		Node:=Settings.SSN(XPath)
		all:=SN(Node.ParentNode,"*")
		while(aa:=all.item[A_Index-1])
        {
            if(A_Index==Number)
            {
                aa.SetAttribute("last",1)
            }
            else 
            {
                aa.RemoveAttribute("last")
            }
        }
			;(A_Index=Number?aa.SetAttribute("last",1):aa.RemoveAttribute("last"))
	}Default(Name:=""){
		Gui,% this.Win ":Default"
		ea:=this.XML.EA("//Control[@name='" Name "']")
		if(ea.Type~="TreeView|ListView")
			Gui,% this.Win ":" ea.Type,% ea.HWND
	}DisableAll(){
		for a,b in this.All{
			GuiControl,1:+g,% b.HWND
			GuiControl,1:-Redraw,% b.HWND
		}
	}DropFiles(filelist,ctrl,x,y){
		df:="DropFiles"
		if(IsFunc(df))
			%df%(filelist,ctrl,x,y)
	}EnableAll(){
		for a,b in this.All{
			GuiControl,% this.Win ":+g" b.Name,% b.HWND
			GuiControl,% this.Win ":+Redraw",% b.HWND
		}
	}Escape(){
		KeyWait,Escape,U
		if(A_Gui!=1)
			Gui,%A_Gui%:Destroy
		else
			MainWin.Exit()
		return 
	}Exit(){
		Exit:
		Info:=MainWin[]
		if(A_Gui=1){
			Node:=GetNode(),Node.SetAttribute("last",1),MenuXML.Save(1)
			Settings.Add("Last",{file:MenuXML.File}),Settings.Add("Confirm",,MainWin[].Confirm)
			MainWin.SavePos()
			Settings.Save(1)
			ExitApp
		}else
			Gui,% this.Win ":Destroy"
		return
	}Focus(Control){
		this.Default(Control)
		ControlFocus,,% this.GetCtrlXML(Control,"id")
	}GetCtrl(Name,Value:="hwnd"){
		return this.All[Name]
	}GetCtrlXML(Name,Value:="hwnd"){
		return Info:=this.XML.SSN("//*[@name='" Name "']/@" Value).text
	}GetPos(){
		Gui,% this.win ":Show",AutoSize Hide
		WinGet,cl,ControlListHWND,% this.ahkid
		SysGet,Menu,55
		pos:=this.winpos(),ww:=pos.w,wh:=pos.h,flip:={x:"ww",y:"wh"}
		for index,hwnd in StrSplit(cl,"`n"){
			obj:=this.gui[hwnd]:=[]
			ControlGetPos,x,y,w,h,,ahk_id%hwnd%
			y-=Menu
			for c,d in StrSplit(this.con[hwnd].pos)
				d~="w|h"?(obj[d]:=%d%-w%d%):d~="x|y"?(obj[d]:=%d%-(d="y"?wh+this.Caption+this.Border:ww+this.Border))
		}
		Gui,% this.win ":+MinSize400x400"
	}Map(Location,Info:=""){
		static Map:={PopulateAccounts:["PopulateAccounts"],PopulateAllFilters:["PopulateMGList"],PopulateMGList:["PopulateMGList"]
				  ,PopulateMGListItems:["PopulateMGListItems"],PopulateMGTags:["PopulateMGTags"],PopulateMGMessages:["PopulateMGMessages"]}
		if(!Map[Location])
			return m("Working on: " Location,ExtraInfo.1,ExtraInfo.2)
		this.DisableAll()
		for a,b in Map[Location]{
			if(b.1="Fix")
				return m("Work On: " a)
			MainWin.Busy:=1,MainWin.Function:=b.1?b.1:b
			Info:=%b%(Info)
			if(Info.tv){
				TV_Modify(Info.tv,"Select Vis Focus")
			}
			while(MainWin.Busy){
				t("It's busy",A_TickCount,MainWin.Function,"Hmm.")
			}
		}this.EnableAll()
		return Info
	}SavePos(){
		if(!top:=Settings.SSN("//gui/position[@window='" this.win "']"))
			top:=Settings.Add("gui/position",{window:this.Win},,1)
		top.text:=this.WinPos().text
	}SetText(Control,Text:=""){
		if((sc:=this.Var[Control].sc).sc)
			Len:=VarSetCapacity(tt,StrPut(Text,"UTF-8")-1),StrPut(Text,&tt,Len,"UTF-8"),sc.2181(0,&tt)
		else
			GuiControl,% this.Win ":",% this.GetCtrlXML(Control),%Text%
	}Show(name){
		this.GetPos(),Pos:=this.Resize=1?"":"AutoSize",this.name:=name
		if(this.resize=1)
			Gui,% this.win ":+Resize"
		GUIKeep.ShowList.Push(this)
		SetTimer,GUIKeepShow,-100
		return
		GUIKeepShow:
		while(this:=GUIKeep.ShowList.Pop()){
			Gui,% this.win ":Show",% Settings.SSN("//gui/position[@window='" this.win "']").text " " pos,% this.name
			this.size()
			if(this.resize!=1){
				Gui,% this.win ":Show",AutoSize
			}
			WinActivate,% this.id
		}
		return
	}Size(){
		this:=GUIKeep.table[A_Gui],pos:=this.winpos()
		for a,b in this.gui
			for c,d in b
				GuiControl,% this.win ":MoveDraw",%a%,% c (c~="y|h"?pos.h:pos.w)+d
	}WinPos(HWND:=0){
		VarSetCapacity(rect,16),DllCall("GetClientRect",ptr,(HWND?HWND:this.hwnd),ptr,&rect)
		WinGetPos,x,y,,,% (HWND?"ahk_id" HWND:this.ahkid)
		w:=NumGet(rect,8,"int"),h:=NumGet(rect,12,"int"),text:=(x!=""&&y!=""&&w!=""&&h!="")?"x" x " y" y " w" w " h" h:""
		return {x:x,y:y,w:w,h:h,text:text}
	}
}
Exit(){
	Settings.Save(1)
}
save_script()
{
    MenuHandler("save", 4, "File")
    run, %A_ScriptDir%/../menu.ahk
}
editcmd()
{  
    static
	Node:=GetNode()
    first_child_name := SSN(Node, "Item/@name").text
    if(first_child_name != "")
    {
        msgbox, 当前节点有子节点不能编辑
        return
    }
    gui,2: Destroy
    Gui,2: Add, Edit, vMyEdit Hwndedit w500 h500
    gui,2: Add, Button, gsavefile, 保存
    gui,2: +hwndgui2
    GuiControl,,% edit,% Node.text
    gui,2:show, AutoSize
    return
    savefile:
        Node:=GetNode()
        Populate(1)
        gui,2: submit, NoHide
        Node.text := Myedit
        MenuHandler("save", 4, "File")
        run, %A_ScriptDir%/../menu.ahk
    return
}
MenuHandler(a,b,c){
	Item:=Clean(a)
	if(c="File"){
		if(Item="Exit"){
			MainWin.Exit()
			ExitApp
		}else if(Item="Save"){
			if(MenuXML.File="Menus\Menu.xml"){
				if(!FileExist(A_ScriptDir "\Menus"))
					FileCreateDir,%A_ScriptDir%\Menus
				FileSelectFile,FileName,S16,%A_ScriptDir%\Menus,Save,*.xml
				if(ErrorLevel)
					return
				FileName:=SubStr(FileName,-3)!=".xml"?FileName.=".xml":FileName
				MenuXML.File:=FileName,MenuXML.Save(1)
				return
			}else
				return MenuXML.Save(1)
		}else if(Item="New"){
			return MenuXML:=new XML("Menu","Menus\Menu.xml"),MenuXML.XML.LoadXML("<Menu/>"),Populate()
		}else if(Item="Open"){
			FileSelectFile,FileName,,Menus,Open a Menu,*.xml
			if(ErrorLevel||!FileExist(FileName))
				return
			xx:=new XML("Menu",FileName)
			if(!xx.SSN("//*[not(Menu) or not(Item)]"))
				return m("XML Not compatible")
			return MenuXML:=xx,Populate()
		}else if(Item="Export")
			return Export()
		else if(Item="Copy_To_Clipboard"){
			if(MenuXML.File="Menus\Menu.xml"){
				if(!FileExist(A_ScriptDir "\Menus"))
					FileCreateDir,%A_ScriptDir%\Menus
				FileSelectFile,FileName,S16,%A_ScriptDir%\Menus,Save,*.xml
				if(ErrorLevel)
					return
				FileName:=SubStr(FileName,-3)!=".xml"?FileName.=".xml":FileName
				MenuXML.File:=FileName,MenuXML.Save(1)
			}else{
				MenuXML.Save(1)
			}
			return Clipboard:=Export(1)
            ;outToFile(),
            ;changeCmdfile()
		}
	}if(c="About"){
		if(Item="Help")
			return Help()
		else if(Item="Online_Manual")
			{
                clipboard:="-" . ToBase(A_Now,36)
            }
	}
	;m("Coming Soon...")
}
ShowMenu(){
	All:=MenuXML.SN("//Menu/descendant::*")
	while(aa:=All.Item[A_Index-1],ea:=XML.EA(aa)){
		Parent:=aa.ParentNode,ParentName:=SSN(Parent,"@name").text,ParentName:=ParentName?ParentName:"Menu"
		Menu,%ParentName%,Add,% ea.Name,DeadEnd
	}while(aa:=All.Item[A_Index-1],ea:=XML.EA(aa)){
		Parent:=aa.ParentNode,ParentName:=SSN(Parent,"@name").text,ParentName:=ParentName?ParentName:"Menu"
		if(SSN(aa,"*").NodeName="Item"){
			if(Color:=SSN(aa,"Item")?ea.Color:SSN(aa.ParentNode,"@color").text){
				Menu:=SSN(aa,"Item")?ea.Name:SSN(aa.ParentName,"@name").text
				Menu:=Menu?Menu:"Menu"
				Menu,%Menu%,Color,% RGB(Color)
			}
			Menu,%ParentName%,Add,% ea.Name,% ":" ea.Name
	}}if(Color:=MenuXML.SSN("//Menu/@color").text)
		Menu,Menu,Color,% RGB(Color),Single
	Menu,Menu,Show
}
Clean(Text){
	return RegExReplace(RegExReplace(Text," ","_"),"\W")
}
Populate(SetLast:=0){
	if(SetLast)
		GetNode().SetAttribute("last",1)
	MainWin.Default("TV")
	GuiControl,1:-Redraw,SysTreeView321
	TV_Delete(),All:=MenuXML.SN("//Menu/descendant::*")
	while(aa:=All.Item[A_Index-1],ea:=XML.EA(aa))
		aa.SetAttribute("tv",TV_Add(ea.Name,SSN(aa.ParentNode,"@tv").text))
	if(Last:=MenuXML.SSN("//*[@last]"))
		TV_Modify(SSN(Last,"@tv").text,"Select Vis Focus"),Last.RemoveAttribute("last")
	All:=MenuXML.SN("//*[@expand]")
	while(aa:=All.Item[A_Index-1],ea:=XML.EA(aa))
		TV_Modify(ea.tv,"Expand"),aa.RemoveAttribute("expand")
	GuiControl,1:+Redraw,SysTreeView321
}
GetNode(){
	MainWin.Default("TV")
	return Node:=MenuXML.SSN("//*[@tv='" TV_GetSelection() "']")
}
AddMenuItem(){
    ;ToolTip, 注意命令节点名称不能相同，建议名字结尾添加当前时间(点击TIME按钮获取到剪切板)
    ;SetTimer, RemoveToolTip, -5000
	Obj:=MainWin[],Item:=Obj.Item
	if(ErrorLevel||!Item)
		return
	if(!Node:=GetNode())
		return MenuXML.Add("Menu/Item",{name:Item,last:1}),Populate(),MainWin.SetText("Item")
	FindDupe(Node,Item)
	New:=MenuXML.Add("Item",{name:Item,last:1},,1)
	if(Obj.Before)
		Node.ParentNode.InsertBefore(New,Node)
	else if(Obj.After){
		if(Next:=Node.NextSibling)
			Node.ParentNode.InsertBefore(New,Next)
		else
			Node.ParentNode.AppendChild(New)
	}MainWin.SetText("Item"),Populate()
}
AddSubMenuItem(){
    ;ToolTip, 注意命令节点名称不能相同，建议名字结尾添加当前时间(点击TIME按钮获取到剪切板)
    ;SetTimer, RemoveToolTip, -5000
	Item:=MainWin[].Item
	if(ErrorLevel||!Item)
		return
	if(!Node:=GetNode())
		return MenuXML.Add("Menu/Item",{name:Item,last:1}),Populate()
	FindDupe(Node.FirstChild,Item)
	if(MenuXML.Find(Node,"Item/@name",Item))
		return m("Menu already exists")
	New:=MenuXML.Under(Node,"Item",{name:Item,last:1}),Populate(),MainWin.SetText("Item")
}
Delete(){
	Node:=GetNode(),Confirm:=MainWin[].Confirm
	if(Confirm)
		if(m("Can not be undone, are you sure?","ico:?","btn:ync","def:2")!="Yes")
			return
	if(!Next:=Node.NextSibling?Node.NextSibling:Node.PreviousSibling)
		Next:=Node.ParentNode
	Next.SetAttribute("last",1),Node.ParentNode.RemoveChild(Node),Populate()
}
Arrows(){
	ControlGetFocus,Focus,% MainWin.ID
	if(Focus="Edit1")
		ControlSend,SysTreeView321,{%A_ThisHotkey%},% MainWin.ID
	else
		Send,{%A_ThisHotkey%}
}
Edit(){
	Node:=GetNode()
	InputBox,Item,New Menu Item Name,Enter the new name for this menu item,,,,,,,,% (Name:=SSN(Node,"@name").text)
	if(ErrorLevel||!Item||Name=Item)
		return
	FindDupe(Node,Item)
    Node.SetAttribute("name",Item)
    Populate(1)
}
name_add_time()
{
	Node := GetNode()
    id := SSN(Node,"@tv").text
    name := SSN(Node,"@name").text
    name .= "_" ToBase(A_Now,36)
    Node.SetAttribute("name",name)
    Populate(1)
    ;UnityPath:=my_xml.SSN("//*[@name='" attribute "']").text
    ;my_xml := new xml("xml")
    ;fileread, xml_file_content,% A_ScriptDir "\Menus\超级命令.xml"
    ;my_xml.XML.LoadXML(xml_file_content)
    ;attribute := "百度_75WWJ2OTZ"
    ;xx := my_xml.SSN("//*[@name='" attribute "']").text
    ;xx := my_xml.SSN("//Menu/Item[1]/Item[1]").text
    ;xx := my_xml.SSN("//Menu/*[@name='网站文件夹']/*[@name='百度_75WWJ2OTZ']").text
}
FindDupe(Node,Item){
	if(SSN(Node.ParentNode,"Item[translate(@name,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')='" Format("{:L}",Item) "']")){
		m("Menu Item Already Exists")
		Exit
	}
}
Move(){
	Node:=GetNode()
	if((Direction:=A_ThisHotkey)="!Up"){
		if(Next:=Node.PreviousSibling)
			Next.ParentNode.InsertBefore(Node,Next),Populate(1)
	}else if(Direction="!Down"){
		if(Next:=Node.NextSibling.NextSibling)
			Next.ParentNode.InsertBefore(Node,Next),Populate(1)
		else
			Node.ParentNode.AppendChild(Node),Populate(1)
	}else if(Direction="!Left"){
		if((Parent:=Node.ParentNode.ParentNode).NodeName!="#document")
			Parent.AppendChild(Node),Populate(1)
	}else if(Direction="!Right"){
		if(Under:=Node.NextSibling)
			Under.AppendChild(Node),Populate(1)
	}
}
Help(){
	m("按下 Alt+Up/Down/Left/Right 移动 menu items")
}
m(x*){
	static list:={btn:{oc:1,ari:2,ync:3,yn:4,rc:5,ctc:6},ico:{"x":16,"?":32,"!":48,"i":64}},msg:=[]
	static Title
	list.title:="Menu Maker",list.def:=0,list.time:=0,value:=0,txt:=""
	WinGetTitle,Title,A
	for a,b in x
		obj:=StrSplit(b,":"),(vv:=List[obj.1,obj.2])?(value+=vv):(list[obj.1]!="")?(List[obj.1]:=obj.2):txt.=b "`n"
	msg:={option:value+262144+(list.def?(list.def-1)*256:0),title:list.title,time:list.time,txt:txt}
	Sleep,120
	MsgBox,% msg.option,% msg.title,% msg.txt,% msg.time
	for a,b in {OK:value?"OK":"",Yes:"YES",No:"NO",Cancel:"CANCEL",Retry:"RETRY"}
		IfMsgBox,%a%
			return b
	return
}
DeadEnd(a,b,c){
	m("You Clicked: " a,"In Menu: " c)
}
ChangeColor(){
	Node:=GetNode()
	if(!SSN(Node,"Item"))
		Node:=Node.ParentNode
	Dlg_Color(Node,,MainWin.HWND),UpdateColor()
}
Dlg_Color(Node,Default:="",hwnd:="",Attribute:="color"){
	static
	Active:=DllCall("GetActiveWindow")
	Node:=Node.xml?Node:Settings.Add(Trim(Node,"/")),Default:=Default?Default:Settings.SSN("//default"),Color:=(((Color:=SSN(Node,"@" Attribute).text)!="")?Color:SSN(Default,"@" Attribute).text)
	VarSetCapacity(Custom,16*4,0),size:=VarSetCapacity(ChooseColor,9*4,0)
	for a,b in Settings.EA("//CustomColors")
		NumPut(Round(b),Custom,(A_Index-1)*4,"UInt")
	NumPut(size,ChooseColor,0,"UInt"),NumPut(hwnd,ChooseColor,4,"UPtr"),NumPut(Color,ChooseColor,3*4,"UInt"),NumPut(3,ChooseColor,5*4,"UInt"),NumPut(&Custom,ChooseColor,4*4,"UPtr")
	ret:=DllCall("comdlg32\ChooseColorW","UPtr",&ChooseColor,"UInt")
	CustomColors:=Settings.Add("CustomColors")
	Loop,16
		CustomColors.SetAttribute("Color" A_Index,NumGet(Custom,(A_Index-1)*4,"UInt"))
	if(!ret)
		Exit
	Node.SetAttribute(Attribute,(Color:=NumGet(ChooseColor,3*4,"UInt")))
	if(!Node.xml)
		m("Bottom of Dlg_Color()",Node.xml,Color)
	WinActivate,ahk_id%Active%
	return Color
}
RGB(c){
	return Format("0x{:06X}",(c&255)<<16|c&65280|c>>16)
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
	shell:=ComObjCreate("WScript.Shell"),exec:=shell.Exec("AutoHotkey.exe /ErrorStdOut *"),exec.StdIn.Write(Script),exec.StdIn.Close(),started:=A_Now
	v.Running[Name]:=exec
	return
}
Export(Return:=0){
	All:=MenuXML.SN("//Menu/descendant::*")
	while(aa:=All.Item[A_Index-1],ea:=XML.EA(aa))
		Parent:=aa.ParentNode,ParentName:=SSN(Parent,"@name").text,ParentName:=ParentName?ParentName:"Menu",Script.="Menu," ParentName ",Add," ea.Name ",Function`r`n"
	while(aa:=All.Item[A_Index-1],ea:=XML.EA(aa)){
		Parent:=aa.ParentNode,ParentName:=SSN(Parent,"@name").text,ParentName:=ParentName?ParentName:"Menu"
		if(SSN(aa,"*").NodeName="Item"){
			if(Color:=SSN(aa,"Item")?ea.Color:SSN(aa.ParentNode,"@color").text)
				Menu:=SSN(aa,"Item")?ea.Name:SSN(aa.ParentName,"@name").text,Menu:=Menu?Menu:"Menu",Script.="Menu," Menu ",Color," RGB(Color) "`r`n"
			Script.="Menu," ParentName ",Add," ea.Name ",:" ea.Name "`r`n"
	}}if(Color:=MenuXML.SSN("//Menu/@color").text)
		Script.="Menu,Menu,Color," RGB(Color) ",Single`r`n"
	Script.="Menu,Menu,Show`r`nreturn`r`nFunction(Item,Index,Menu){`r`n`tMsgBox,You Clicked: %Item% Under: %Menu%`r`n}`r`nreturn"
	if(Return)
		return Script
	FileSelectFile,FileName,S16,,Export FileName,*.ahk
	File:=FileOpen(FileName,"RW"),File.Write(Script),File.Length(File.Position),File.Close()
	Run,%FileName%
}
UpdateColor(){
	Node:=GetNode()
	Color:=SSN(Node,"Item")?SSN(Node,"@color").text:SSN(Node.ParentNode,"@color").text
	GuiControl,% "1:+c" RGB(Color),% MainWin.GetCtrlXML("Progress")
}
ChangeRoot(){
	Node:=MenuXML.SSN("//Menu"),Dlg_Color(Node,,MainWin.HWND)
}
FocusItem(){
	MainWin.Focus("Item")
}
Class XML{
	keep:=[]
	__Get(x=""){
		return this.XML.xml
	}__New(param*){
		if(!FileExist(A_ScriptDir "\lib"))
			FileCreateDir,%A_ScriptDir%\lib
		root:=param.1,file:=param.2,file:=file?file:root ".xml",temp:=ComObjCreate("MSXML2.DOMDocument"),temp.SetProperty("SelectionLanguage","XPath"),this.XML:=temp,this.file:=file,XML.keep[root]:=this
		if(Param.3)
			temp.preserveWhiteSpace:=1
		if(FileExist(file)){
			ff:=FileOpen(file,"R","UTF-8"),info:=ff.Read(ff.Length),ff.Close()
			if(info=""){
				this.XML:=this.CreateElement(temp,root)
				FileDelete,%file%
			}else
				temp.LoadXML(info),this.XML:=temp
		}else
			this.XML:=this.CreateElement(temp,root)
		SplitPath,file,,dir
		if(!FileExist(dir))
			FileCreateDir,%dir%
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
		FileName:=this.file?this.file:x.1.1,ff:=FileOpen(FileName,"R"),text:=ff.Read(ff.length),ff.Close()
		if(ff.encoding!="UTF-8")
			FileDelete,%FileName%
		if(!this[])
			return m("Error saving the " this.file " XML.  Please get in touch with maestrith if this happens often")
		if(!FileExist(FileName))
			FileAppend,% this[],%FileName%,UTF-8
		else if(text!=this[])
			file:=FileOpen(FileName,"W","UTF-8"),file.Write(this[]),file.Length(file.Position),file.Close()
	}SSN(XPath){
		return this.XML.SelectSingleNode(XPath)
	}SN(XPath){
		return this.XML.SelectNodes(XPath)
	}Transform(Loop:=1){
		static
		if(!IsObject(xsl))
			xsl:=ComObjCreate("MSXML2.DOMDocument"),xsl.loadXML("<xsl:stylesheet version=""1.0"" xmlns:xsl=""http://www.w3.org/1999/XSL/Transform""><xsl:output method=""xml"" indent=""yes"" encoding=""UTF-8""/><xsl:template match=""@*|node()""><xsl:copy>`n<xsl:apply-templates select=""@*|node()""/><xsl:for-each select=""@*""><xsl:text></xsl:text></xsl:for-each></xsl:copy>`n</xsl:template>`n</xsl:stylesheet>"),style:=null
		Loop,%Loop%
			this.XML.TransformNodeToObject(xsl,this.xml)
	}Under(under,node,att:="",text:="",list:=""){
		new:=under.AppendChild(this.XML.CreateElement(node)),new.text:=text
		for a,b in att
			new.SetAttribute(a,b)
		for a,b in StrSplit(list,",")
			new.SetAttribute(b,att[b])
		return new
	}
}
SSN(node,XPath){
	return node.SelectSingleNode(XPath)
}
SN(node,XPath){
	return node.SelectNodes(XPath)
}
t(x*){
	for a,b in x{
		if((obj:=StrSplit(b,":")).1="time"){
			SetTimer,killtip,% "-" obj.2*1000
			Continue
		}
		list.=b "`n"
	}
	Tooltip,% list
	return
	killtip:
	ToolTip
	return
}

ToBase(n,b){
    return (n < b ? "" : ToBase(n//b,b)) . ((d:=Mod(n,b)) < 10 ? d : Chr(d+55))  
}

outToFile()
{
    local filename := A_ScriptDir . "/menufunc.ahk"
    local outstring := ""
    local number := 0
    local text := Clipboard
    loop, Parse, text,`n, `r
    {
        if(InStr(A_LoopField, "Menu,Menu,Show", true))
        {
            break
        }
        outstring := outstring . A_LoopField . "`r`n"
    }
    outstring := outstring . "Return"
    FileDelete,% filename
    FileAppend, %outstring% ,% filename,UTF-8
}

changeCmdfile()
{
    local fileName := A_ScriptDir . "/menucmd.ahk"
    oldFileString := ""
    appendString := ""
    text := Clipboard
    Loop, Read,% fileName
    {
        oldFileString := oldFileString . A_LoopReadLine
    }
    loop, Parse, text,`,
    {
        if(InStr(A_LoopField,"_",True))
        {
            if(!Instr(oldFileString,A_LoopField,True))
            {
                appendString := appendString . A_LoopField . "(){`r`n}`r`n"
            }
        }
    }
    FileAppend,% "`r`n" . appendString,% filename,UTF-8
}
RemoveToolTip:
ToolTip
return