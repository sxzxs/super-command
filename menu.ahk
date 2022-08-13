; 超级命令
; Tested on AHK v1.1.33.02 Unicode 32/64-bit, Windows /10
; Script compiler directives
;@Ahk2Exe-SetMainIcon %A_ScriptDir%\Icons\Verifier.ico
;@Ahk2Exe-SetVersion 0.1.0

; Script options
#SingleInstance Off  
instance_one()
#NoEnv
#MaxMem 640
#KeyHistory 0
#Persistent
SetBatchLines -1
DetectHiddenWindows On
SetWinDelay -1
SetControlDelay -1
SetWorkingDir %A_ScriptDir%
FileEncoding UTF-8
CoordMode, ToolTip, Screen
CoordMode, Caret , Screen
ListLines Off

;管理员运行
RunAsAdmin()

#include <py>
#include <btt>
#include <log4ahk>
#include <TextRender>
#include <json>
#include <utility>

OnMessage(0x201, "WM_LBUTTONDOWN")
OnMessage(0x004A, "Receive_WM_COPYDATA")  ; 0x004A 为 WM_COPYDATA
OnMessage(0x100, "GuiKeyDown")
OnMessage(0x002C, "ODLB_MeasureItem") ; WM_MEASUREITEM
OnMessage(0x002B, "ODLB_DrawItem") ; WM_DRAWITEM

log.is_log_open := false

;加载配置
global g_json_path := A_ScriptDir . "/config/settings.json"
global g_config := {}
if(!loadconfig(g_config))
{
    MsgBox,% "Load config"  g_json_path " failed! will exit!!"
    ExitApp
}

;https://www.autohotkey.com/boards/viewtopic.php?t=3938
OD_LB  := "+0x0050" ; LBS_OWNERDRAWFIXED = 0x0010, LBS_HASSTRINGS = 0x0040
ODLB_SetItemHeight("s" g_config.win_list_font_size " Normal", "MS Shell Dlg 2")
ODLB_SetHiLiteColors(g_config.win_list_focus_back_color  , g_config.win_list_focus_text_color)

h1 := g_config.key_open_search_box,
h2 := g_config.key_send
h3 := g_config.key_open_search_box,
h4 := g_config.key_open_editor
h5 := g_config.key_edit_now
help_string =
(
v2.0
打开当前搜索框 [%h1%]
发送命令到窗口 [%h2%]
复制当前文本 [%h3%]
执行命令 [enter]
编辑所有命令 [%h4%]
编辑当前命令 [%h5%]
取消 [esc]
复制当前文本 [Ctrl c]
)
convert_key2str(help_string)
py.allspell_muti("ahk")
begin := 1
total_command := 0 ;总命令个数
is_get_all_cmd := false
my_xml := new xml("xml")
menue_create_pid := 0

g_curent_text := ""
g_command := ""
g_exe_name := ""
g_exe_id := ""
BackgroundColor := "1d1d1d"
TextColor := "999999"
global cmds := ""
global g_text_rendor := TextRender()
global g_text_rendor_clip := TextRender()
global g_hook_rendor := TextRender()
global g_hook_rendor_list := TextRender()
global g_hook_strings := ""
global g_hook_array := []
global g_hook_real_index := 1
global g_hook_list_strings := ""
global g_hook_command := ""
global g_hook_mode := false
global g_should_reload := false
global g_my_menu_map := {"增加一条命令: " convert_key2str(g_config.key_edit_new) : "edit_new"
                            , "编辑当前命令: " convert_key2str(g_config.key_edit_now) : "edit_now"
                            , "编辑全部命令: " convert_key2str(g_config.key_open_editor) : "open_editor"
                            , "发送到窗口: " convert_key2str(g_config.key_send) : "label_send_command"
                            , "复制结果: " convert_key2str(g_config.key_open_search_box) : "label_menu_copy_data"
                            , "设置" : "open_set"}
g_text_rendor.Render(help_string, "t: 5seconds x:left y:top pt:2", "s:15 j:left ")

if !FileExist(A_ScriptDir "\cmd\Menus\超级命令.xml")
{
    MsgBox,% A_ScriptDir "\cmd\Menus\超级命令.xml 不存在, alt + c 添加命令并保存在上面目录" 
}
fileread, xml_file_content,% "*P65001 " A_ScriptDir "\cmd\Menus\超级命令.xml"
my_xml.XML.LoadXML(xml_file_content)
cmds := xml_parse(my_xml)

;注册热键
Hotkey,% g_config.key_open_search_box , main_label
Hotkey,% g_config.key_send , label_send_command
Hotkey,% g_config.key_open_editor , open_editor
Hotkey,% g_config.key_edit_now , edit_now
Hotkey,% g_config.key_edit_new , edit_new
Hotkey,% g_config.hook_open , hook_open_label

Menu, Tray, Icon, %A_ScriptDir%\Icons\Verifier.ico
Menu, Tray, NoStandard
Menu, Tray, add, 帮助,  open_github
Menu, Tray, add, 设置,  open_set
Menu, Tray, add,% "打开搜索框: " convert_key2str(g_config.key_open_search_box),  main_label
Menu, Tray, add,% "添加命令: " convert_key2str(g_config.key_open_editor),  open_set
Menu, Tray, Add , Exit, Exi
Menu, Tray, Default, Exit
Menu, Tray, Icon , %A_ScriptDir%\Icons\Verifier.ico,, 1


; 添加一些菜单项来创建弹出菜单.
for k,v in g_my_menu_map
    Menu, Mymenu, add,% k,  MenuHandler
return  ; 脚本的自动运行段结束.

MenuHandler:
if(!WinActive("ahk_id " MyGuiHwnd))
    return
log.info(A_ThisMenu, A_ThisMenuItem)
for k,v in g_my_menu_map
{
    if(A_ThisMenuItem == k)
        Gosub,% v
}
return

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


~RButton::
~MButton::
if(!WinActive("ahk_id " MyGuiHwnd))
    return
Menu, MyMenu, Show
return

~*esc::
    goto GuiEscape
return

copy_command_to_editor:
    if(!WinActive("ahk_id " MyGuiHwnd) || g_command == "")
        return
    pos := InStr(g_command, ">", CaseSensitive := false, StartingPos := 0, Occurrence := 1)
    command := SubStr(g_command, 1, pos)
    command := StrReplace(command, "$")
    GuiControl,, Query ,% command
    SendInput, {end}
    gui,Submit, Nohide
return
edit_new:
    if(!WinActive("ahk_id " MyGuiHwnd))
        return
    if(g_command == "")
    {
        msgbox, 请先在编辑框添加路径和短语, 提示: ctrl+c可复制已有路径
        return
    }
    
    FileDelete,% A_ScriptDir "\cmd\tmp\tmp.ahk"
    FileAppend,% "",% A_ScriptDir "\cmd\tmp\tmp.ahk",UTF-8
    GuiControlGet, Query

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

    tmp_path =
    (
        "%command%"
    ) 
    if(A_IsCompiled)
        run,% A_ScriptDir "\cmd\Adventure\Adventure.exe  " tmp_path " " my_pid
    else
        run,% A_ScriptDir "\v1\AutoHotkey.exe " A_ScriptDir "\cmd\Adventure\Adventure.ahk  " tmp_path " " my_pid
    goto GuiEscape
return
edit_now:
    if(!WinActive("ahk_id " MyGuiHwnd))
        return
    if(g_command == "")
    {
        msgbox, 请输入命令的路径和短语, 提示: Ctrl+C 复制已有命令路径到编辑框
        return
    }
    
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
        run,% A_ScriptDir "\v1\AutoHotkey.exe " A_ScriptDir "\cmd\Adventure\Adventure.ahk  " tmp_path " " my_pid
    goto GuiEscape
return

~$^c::
    if(!WinActive("ahk_id " MyGuiHwnd) || g_command == "")
        return
    Clipboard := g_curent_text
    g_text_rendor_clip.Render("Saved text to clipboard.", "t:1250 c:#F9E486 y:75vh r:10%")
    gosub copy_command_to_editor
    return

    open_editor:
    Process Exist
    my_pid := ErrorLevel
    if(A_IsCompiled)
        run,% A_ScriptDir "\cmd\menue_create.exe " my_pid
    else
        run,% A_ScriptDir "\v1\AutoHotkey.exe " A_ScriptDir "\cmd\menue_create.ahk " my_pid
return

label_delete:
    if(!WinActive("ahk_id " MyGuiHwnd) || g_command == "")
        return

    GuiControlGet Command
    if !Command
        return
    Command := row_id[Command]
    command := StrReplace(command, "$")
    word_array := StrSplit(command, " >")
    pattern := ""
    for k,v in word_array
        pattern .= "/*[@name='" v "']"
    pattern := "//Menu" . pattern
    node := my_xml.SSN(pattern)
	if(!Next:=Node.NextSibling?Node.NextSibling:Node.PreviousSibling)
		Next:=Node.ParentNode
	Next.SetAttribute("last",1)
    Node.ParentNode.RemoveChild(Node)
    my_xml.save(1)
    Populate()
return

Populate(SetLast:=0){
	All:=MenuXML.SN("//Menu/descendant::*")
	if(Last:=MenuXML.SSN("//*[@last]"))
		TV_Modify(SSN(Last,"@tv").text,"Select Vis Focus"),Last.RemoveAttribute("last")
	All:=MenuXML.SN("//*[@expand]")
	while(aa:=All.Item[A_Index-1],ea:=XML.EA(aa))
		TV_Modify(ea.tv,"Expand"),aa.RemoveAttribute("expand")
	GuiControl,1:+Redraw,SysTreeView321
}


hook_open_label:
    g_hook_strings := ""
    g_hook_list_strings := ""
    g_hook_mode := true

    global SacHook := InputHook("E", "{Esc}")
    SacHook.OnChar := Func("SacChar")
    SacHook.OnKeyDown := Func("SacKeyDown")
    SacHook.OnEnd := Func("SacEnd")
    SacHook.KeyOpt("{Backspace}", "N")
    SacHook.Start()
    update_btt()
return

!q::
label_menu_copy_data:
main_label:
    x := g_config.win_x + g_config.win_w + 12
    y := g_config.win_y + 12
    if(g_config.tooltip_help)
    {
        if(g_config.tooltip_random == 1)
            g_text_rendor.Render(help_string, "x:" x " y:" y " color:Random", "s:" g_config.tooltip_font_size " j:left ")
        else
            g_text_rendor.Render(help_string, "x:" x " y:" y " color:" g_config.tooltip_back_color, "s:" g_config.tooltip_font_size " j:left " "c:" g_config.tooltip_text_color)
    }

    WinGet, g_exe_name, ProcessName, A
    WinGet, g_exe_id, ID , A
    g_command := ""
    if (cmds == "")
    {
        my_xml := new xml("xml")
        my_xml.XML.LoadXML(xml_file_content)
        cmds := xml_parse(my_xml)
    }
    if(g_config.auto_english)
    {
        SetCapsLockState,off
        switchime(0)
    }

    Gui +LastFoundExist
    if WinActive()
    {
        log.info(A_ThisHotkey)
        log.info(g_curent_text)
        if(g_curent_text != "" && (A_ThisHotkey == g_config.key_open_search_box || A_ThisLabel == "label_menu_copy_data"))
        {
            Clipboard := g_curent_text
            g_text_rendor_clip.Render("Saved text to clipboard.", "t:1250 c:#F9E486 y:75vh r:10%")
        }
        goto GuiEscape
    }
    Gui Destroy
    Gui Margin, 0, 0
    Gui, Color,% g_config.win_search_box_back_color,% win_search_box_back_color
    win_search_box_font_size := g_config.win_search_box_font_size
    Gui, Font, s%win_search_box_font_size% Q5, Consolas
    Gui, -0x400000 +Border ;WS_DLGFRAME WS_BORDER(细边框)  caption(标题栏和粗边框) = WS_DLGFRAME+WS_BORDER  一定要有WS_BORDER否则没法双缓冲
    Gui, +AlwaysOnTop -DPIScale +ToolWindow +HwndMyGuiHwnd  +E0x02000000 +E0x00080000 ;+E0x02000000 +E0x00080000 双缓冲
    w := g_config.win_w
    Gui Add, Edit, hwndEDIT x0 y10 w%w%  vQuery gType -E0x200
    SetEditCueBanner(EDIT, "🔍 右键菜单 🙇⌨🛐📜▪例➡🅱󠁁🇩  🚀🚀🚀🚀🚀")
    win_list_font_size := g_config.win_list_font_size
    Gui, Font, s%win_list_font_size%, Consolas
    Gui Add, ListBox, hwndLIST x0 y+0 h20 w%w%  vCommand gSelect AltSubmit -HScroll %OD_LB% -E0x200
    ControlColor(EDIT, MyGuiHwnd, "0x" g_config.win_search_box_back_color, "0x" g_config.win_search_box_text_color)
    ControlColor(LIST, MyGuiHwnd, "0x" g_config.win_list_back_color, "0x" g_config.win_list_text_color)

    win_x := g_config.win_x
    win_y := g_config.win_y
    Gui Show, X%win_x% Y%win_y%
    GuiControl, % "Hide", Command
    Gui, Show, AutoSize

    if(A_ThisHotkey == "!q")
        GuiControl,,% EDIT ,% " " g_exe_name
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
        g_text_rendor.clear()
        g_text_rendor.FreeMemory()
    }
    rows := ""
    row_id := []
    real_index := 1
    Loop Parse, r, `n
    {
        if(A_LoopField != "")
        {
            row_id[real_index] := A_LoopField
            rows .= "|"  real_index " "  A_LoopField
            real_index++
        }
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
        return

Confirm:
    GuiControlGet Command
    if !Command
        Command := 1
    Command := row_id[Command]
    if !GetKeyState("Shift")
        gosub GuiEscape
    handle_command(Command)
return

label_send_command:
    log.info("send command")
    Gui +LastFoundExist
    if !WinActive()
        return
    GuiControlGet Command
    if !Command
        Command := 1
    Command := row_id[Command]
    gosub GuiEscape
    send_command(Command)
return

GuiEscape:
    Gui,Hide
    g_text_rendor.Clear("")
    g_text_rendor.FreeMemory()
    g_text_rendor.DestroyWindow()
    g_text_rendor := ""
    global g_text_rendor := TextRender()

    g_hook_rendor_list.Clear("")
    g_hook_rendor_list.FreeMemory()
    g_hook_rendor_list.DestroyWindow()
    g_hook_rendor_list := ""
    global g_hook_rendor_list := TextRender()

    g_hook_rendor.Clear("")
    g_hook_rendor.FreeMemory()
    g_hook_rendor.DestroyWindow()
    g_hook_rendor := ""
    global g_hook_rendor := TextRender()
    Process Exist
    my_pid := ErrorLevel
    Try
    {
        ;RunWait, %A_ScriptDir%/lib/empty.exe %my_pid%,,Hide
    }
    if(g_should_reload)
       Reload
return

#if g_hook_mode

+tab::
    up::
    tab_choose("-")
return

tab::
down::
    tab_choose()
return
#If

#IfWinActive, menu ahk_class AutoHotkeyGUI

^Backspace::
    Send ^+{Left}{Backspace}
return

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
        SetTimer GuiEscape, -5
}

GuiKeyDown(wParam, lParam)
{
    if !A_Gui
        return
    log.info(A_ThisHotkey)
    if (wParam = GetKeyVK("Enter") && !GetKeyState("LCtrl"))
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
    if (wParam = GetKeyVK(key := "PgUp") || wParam = GetKeyVK(key := "PgDn"))
    {
        GuiControl Focus, Command
        Send {%key%}
        return
    }
}

keyValueFind(haystack,needle)
{
    ;拼音首字母转换
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
    VarSetCapacity(result, 0)
    VarSetCapacity(result, 90000)
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

preview_command(command)
{
    static preview_number := 0
    preview_number++
    if(preview_number == 1000)
        g_should_reload := true

    ;g_text_rendor.clear()
    ;g_text_rendor.FreeMemory()
    ;g_hook_rendor.clear()
    ;g_hook_rendor.FreeMemory()

    command := StrReplace(command, "$")
    CoordMode, ToolTip, Screen
    global my_xml, menue_create_pid, log, gui_x, gui_y, g_curent_text, g_command
    word_array := StrSplit(command, " >")
    pattern := ""
    for k,v in word_array
        pattern .= "/*[@name='" v "']"
    pattern := "//Menu" . pattern
    first_child_name := SSN(my_xml.SSN(pattern), "Item/@name").text
    if(first_child_name != "")
        return
    UnityPath:= my_xml.SSN(pattern).text
    g_command := command
    g_curent_text := UnityPath
    GuiControlGet, out, Pos, Query
    if(!WinExist("超级命令添加工具") && UnityPath != "")
    {
        x := g_config.win_x + g_config.win_w + 12
        y := g_config.win_y + 12
        if(g_hook_mode)
        {
            g_hook_rendor.Render(UnityPath, " x:" g_hook_rendor_list.x2 + 10 " y:" g_hook_rendor_list.y + 11  " color:" g_config.tooltip_back_color
                                    , "s:" g_config.tooltip_font_size " j:left")
        }
            
        else
        {
            if(g_config.tooltip_random == 1)
                g_text_rendor.Render(UnityPath, "x:" x " y:" y " color:Random", "s:" g_config.tooltip_font_size " j:left ")
            else
                g_text_rendor.Render(UnityPath, "x:" x " y:" y " color:" g_config.tooltip_back_color, "s:" g_config.tooltip_font_size " j:left " "c:" g_config.tooltip_text_color)
        }
    }
    if(UnityPath == "")
    {
        g_text_rendor.Clear("")
        g_text_rendor.FreeMemory()
        g_hook_rendor.Clear("")
        g_hook_rendor.FreeMemory()
    }
}

send_command(command)
{
    global my_xml, menue_create_pid, log
    command := StrReplace(command, "$")
    word_array := StrSplit(command, " >")
    pattern := ""
    for k,v in word_array
        pattern .= "/*[@name='" v "']"
    pattern := "//Menu" . pattern
    first_child_name := SSN(my_xml.SSN(pattern), "Item/@name").text
    if(first_child_name != "")
        return
    UnityPath:= my_xml.SSN(pattern).text

    old_str := Clipboard
    clipboard := "" ; 清空剪贴板
    Clipboard := UnityPath
    ClipWait, 2
    if ErrorLevel
    {
        Clipboard := old_str
        return
    }
    SendInput, {RShift Down}{Insert}{RShift Up}
    ;sleep,500
    ;Clipboard := old_str
}

handle_command(command)
{
    global my_xml, menue_create_pid, log
    command := StrReplace(command, "$")
    word_array := StrSplit(command, " >")
    pattern := ""
    for k,v in word_array
        pattern .= "/*[@name='" v "']"
    pattern := "//Menu" . pattern
    first_child_name := SSN(my_xml.SSN(pattern), "Item/@name").text
    if(first_child_name != "")
        return
    UnityPath:= my_xml.SSN(pattern).text

    if(SubStr(UnityPath, 1, 3) == ";v2")
        ExecScript(UnityPath, A_ScriptDir, A_ScriptDir "\v2\AutoHotkey.exe")
    else if(SubStr(UnityPath, 1, 3) == "#py")
        execute_python(UnityPath)
    else if(SubStr(UnityPath, 1, 5) == "::bat")
        execute_bat(UnityPath)
    else
        ExecScript(UnityPath, A_ScriptDir, A_ScriptDir "\v1\AutoHotkey.exe")
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
	if (ime = 1)
		DllCall("SendMessage", UInt, WinActive("A"), UInt, 80, UInt, 1, UInt, DllCall("LoadKeyboardLayout", Str,"00000804", UInt, 1))
	else if (ime = 0)
		DllCall("SendMessage", UInt, WinActive("A"), UInt, 80, UInt, 1, UInt, DllCall("LoadKeyboardLayout", Str,, UInt, 1))
	else if (ime = "A")
		Send, #{Space}
}
execute_bat(script)
{    
    global g_curent_text,g_config
    FileDelete,% A_ScriptDir "\cmd\tmp\tmp.bat"
    FileAppend,% script,% A_ScriptDir "\cmd\tmp\tmp.bat",UTF-8
    Run,% A_ScriptDir "\cmd\tmp\tmp.bat"
}
execute_python(script)
{
    global g_curent_text,g_config
    FileDelete,% A_ScriptDir "\cmd\tmp\tmp.py"
    FileAppend,% script,% A_ScriptDir "\cmd\tmp\tmp.py",UTF-8
    Run,% ComSpec " /k "  g_config.python_path " " A_ScriptDir "\cmd\tmp\tmp.py"
}


RemoveToolTip:
    g_text_rendor.clear()
    g_text_rendor.FreeMemory()
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


loadconfig(ByRef config)
{
    Global g_json_path
    config := ""
    FileRead, OutputVar,% g_json_path
    config := json_toobj(outputvar)
    log.info(config)
    if(config == "")
        return false
    return true
}

saveconfig(config)
{
    global g_json_path
    str := json_fromobj(config)
    FileDelete, % g_json_path
    FileAppend,% str,% g_json_path
}

WM_LBUTTONDOWN(wParam, lParam, msg, hwnd) 
{
    global MyGuiHwnd, g_config
	PostMessage, 0xA1, 2 ; WM_NCLBUTTONDOWN
	KeyWait, LButton, U
    WinGetPos, X, Y, W, H, ahk_id %MyGuiHwnd%
    if(x != "" && y != "" && W != "")
    {
        g_config.win_x := X
        g_config.win_y := Y
        g_config.win_w := W
        saveconfig(g_config)
    }
}


SacChar(ih, char)  ; 当一个字符被添加到 SacHook.Input 时调用.
{
    if(GetKeyVK(char) == 13)
    {
        send_command(g_hook_command)
        SacEnd()
        return
    }
    if(char != A_tab)
        g_hook_strings .= char
    if(GetKeyVK(char) == 9)
        log.info("tab")
    else
        hook_mode_quck_search()
    log.info(char, GetKeyVK(char))
    log.info(g_hook_strings)
}

SacKeyDown(ih, vk, sc)
{
    if (vk = 8) ; 退格键
        g_hook_strings := SubStr(g_hook_strings, 1 , -1)
    log.info(g_hook_strings)
    SacChar(ih, "")
}
SacEnd()
{
    g_hook_rendor.Clear("")
    g_hook_rendor.FreeMemory()
    g_hook_rendor := ""
    g_hook_rendor := TextRender()

    g_hook_rendor_list.clear()
    g_hook_rendor_list.FreeMemory()
    g_hook_rendor_list := ""
    g_hook_rendor_list := TextRender()

    g_hook_mode := false
	SacHook.stop()
}

hook_mode_quck_search()
{
    log.info(g_hook_strings)
    StringSplit q, g_hook_strings, %A_Space%
    log.info(q0)
    r := cmds
    Loop % q0
        r := Filter(r, q%A_Index%, c)
    log.info(r)
    g_hook_list_strings := ""
    g_hook_array := []
    g_hook_real_index := 1
    real_index := 1
    Loop Parse, r, `n
    {
        if(A_LoopField != "")
        {
            g_hook_array[real_index] := A_LoopField
            if(real_index == 1)
                g_hook_list_strings := real_index " " A_LoopField
            else
                g_hook_list_strings .= "`r`n"  real_index " "  A_LoopField
            real_index++
        }
    }
    log.info(g_hook_list_strings)
    update_btt()
}
update_btt()
{
    g_hook_rendor_list.crear()
    g_hook_rendor_list.FreeMemory()

    CoordMode, ToolTip, Screen
    tmp_str := ""
    Loop, parse, g_hook_list_strings, `n, `r  ; 在 `r 之前指定 `n, 这样可以同时支持对 Windows 和 Unix 文件的解析.
    {
        s := A_LoopField
        if(A_Index == g_hook_real_index)
            s := "[✓]" A_LoopField
        tmp_str .= s "`n"
    }
    g_hook_command := g_hook_array[g_hook_real_index]
    log.info(g_hook_command, A_CaretX, A_CaretY)
    ps := GetCaretPos()
    pre_h := (g_config.win_search_box_font_size + 11) * g_hook_array.Length() + 100
    if(pre_h + ps.y > A_ScreenHeight)
    {
        ps.y := A_ScreenHeight - pre_h
        ps.y := ps.y < 0 ? 0 : ps.y
    }
    show_string := g_hook_strings "`n" tmp_str
    if(g_hook_strings == "")
        show_string := "⌨"  show_string
    g_hook_rendor_list.Render(show_string
                                , "x:" ps.x + 30 " y:" ps.y + 40 " color:" g_config.win_search_box_back_color
                                ,"s:" g_config.win_search_box_font_size + 5 " j:left " "c:" g_config.win_search_box_text_color "  b:true")

    log.err(g_hook_rendor_list.y, g_hook_rendor_list.y2, g_hook_rendor_list.h)
    log.err(g_hook_array.Length())
    log.err(g_config.win_search_box_font_size + 5)
    log.err((g_config.win_search_box_font_size + 11) * g_hook_array.Length() + 52)
    preview_command(g_hook_command)
    if(tmp_str == "")
    {
        g_hook_rendor.render("")
        g_hook_rendor.FreeMemory()
    }
}

tab_choose(opt := "")
{
    log.info(g_hook_array.Length())
    if(opt == "-") 
        g_hook_real_index--
    else
        g_hook_real_index++
    if(g_hook_real_index > g_hook_array.Length())
        g_hook_real_index := 1
    if(g_hook_real_index == 0)
        g_hook_real_index := g_hook_array.Length()
    update_btt()
}

open_set:
    if(A_IsCompiled)
        run,% A_ScriptDir "\set.exe"
    else
        run,% A_ScriptDir "\set.exe"
return

open_github:
run,https://github.com/kazhafeizhale/super-command
return


convert_key2str(byref help_string)
{
    help_string := StrReplace(help_string, "+", "Shift ")
    help_string := StrReplace(help_string, "^", "Ctrl ")
    help_string := StrReplace(help_string, "!", "Alt ")
    help_string := StrReplace(help_string, "#", "Win ")
    help_string := StrReplace(help_string, "~$")
    return help_string
}