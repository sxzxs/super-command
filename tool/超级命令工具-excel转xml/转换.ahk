#Include ExcelIO.ahk
#include <log>
help_string ="
(%
把 \cmd\Menus\超级命令.xml 放到当前路径，并转成 utf-8 bom编码
执行转换.ahk或者  转换.exe
会把excel中的数据添加到 xml
重新把xml放回原来的路径，重启程序生效
excel格式
第一列:  父路径   中间用 '>' 分割, 例如    网站文件夹 > 常用
第二列:  key  例如  百度
第三列:具体文本， 例如  run,www.baidu.com
)"
msgbox,% help_string
log.is_use_editor := false
log.is_enter := true
;excel load
book := ExcelIO.Load("2.xlsx"), sheet := book.getSheet("0")
lastRow := sheet.lastFilledRow()
log.info(lastrow)

;xml load
if(!FileExist(A_ScriptDir "/超级命令.xml"))
    my_xml := new XML("Menu",A_ScriptDir "/超级命令.xml")
else
{
    my_xml := new xml("xml")
    fileread, xml_file_content,*P65001	%A_ScriptDir%\超级命令.xml
    my_xml.file := A_ScriptDir "\超级命令.xml"
    if(xml_file_content == "")
    {
        msgbox, 请先创建节点,并且根节点为 Menu
        ExitApp
    }
    my_xml.XML.LoadXML(xml_file_content)
}

;convert
;读取第一列 > 第二列  第三列
;写入xml
ar := []
loop
{
    log.info(A_Index)
    p := "A" (A_Index)
    c1 := "", c2 := "", c3 := ""
    try
    {
        c1 := SHeet.__item["A" A_Index].Value
    }
    catch e
    {
        c1 := ""
    }
    try
    {
        c2 := SHeet.__item["B" A_Index].Value
    }
    catch e
    {
        c2 := ""
    }
    try
    {
        c3 := SHeet.__item["C" A_Index].Value
        log.info(c3)
        log.info(c3)
    }
    catch e
    {
        c3 := ""
    }
    if(c1 != "")
        c1 := hanlde_cell_string(c1)
    c := c1 == "" ? c2 : (c2 == "" ? c1 : c1 " >" c2)
    write2xml(c, c3)
    ar.Push(c)
    if(A_Index == lastRow)
        break
}

;处理单元格字符串
hanlde_cell_string(Query)
{
    command := ""
    ar := StrSplit(Query, ">", " `t")
    for k,v in ar
    {
        if(A_Index == 1)
            command := v
        else
            command .= " >" v
    }
    command := StrReplace(command, "$")
    return command
}

;------------------------------FUNC---------------------------------------------
FindDupe(Node,Item){
	if(SSN(Node.ParentNode,"Item[translate(@name,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')='" Format("{:L}",Item) "']")){
        return true
	}
}

write2xml(command, data)
{
    global my_xml,command_pid
    word_array := StrSplit(command, " >")
    pattern := ""
    pattern := "//Menu" . pattern
    Node := my_xml.SSN("//Menu")
    for k,v in word_array
    {
        if(!FindDupe(Node.FirstChild, v))
        {
		    my_xml.Under(Node,"Item",{name:v,last:1})
        }
        pattern .= "/*[@name='" v "']"
        Node := my_xml.SSN(pattern)
    }

    my_xml.SSN(pattern).text := data
    my_xml.save(1)
}


Class XML{
	keep:=[]
	__Get(x=""){
		return this.XML.xml
	}__New(param*){
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
		filename:=this.file?this.file:x.1.1,
        ff:=FileOpen(filename,0),
        ff.Encoding := "UTF-8"
        text:=ff.Read(ff.length),ff.Close()
		if(!this[])
			return m("Error saving the " this.file " XML.  Please get in touch with maestrith if this happens often")
		if(text!=this[])
        {
			file:=FileOpen(filename,"rw")
            file.Encoding := "UTF-8"
            file.Seek(0),file.Write(this[]),file.Length(file.Position)

        }
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