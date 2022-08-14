;@Ahk2Exe-SetMainIcon %A_ScriptDir%\Icons\set.ico
/***********************************************************************************
Copyright:HX

Author: kzf

Date:2022-07-30

Description:设置

History:
    2022-07-30:init
*/
;开头设置
#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#SingleInstance force
#Persistent
#include <log4ahk>
#include <json>


log.is_log_open := false
run_as_admin()
;全局变量
global g_json_path := ""
global g_config := ""

;加载配置
g_json_path := A_ScriptDir . "/config/settings.json"
g_config := {}
if(!loadconfig(g_config))
{
    MsgBox,% "Load config"  g_json_path " failed! will exit!!"
    ExitApp
}

;UI
Gui, Add, Text, xm, 打开搜索框:
Gui, Add, Edit, vkey_open_search_box section x+75 w80,% g_config.key_open_search_box
Gui, Add, Text, xm, 发送文件:
Gui, Add, Edit, vkey_send xs+0 yp+0 w80,% g_config.key_send

Gui, Add, Text, xm, 编辑当前指令:
Gui, Add, Edit, vkey_edit_now xs+0 yp+0 w80,% g_config.key_edit_now

Gui, Add, Text, xm, 增加一条指令:
Gui, Add, Edit, vkey_edit_new xs+0 yp+0 w80,% g_config.key_edit_new

Gui, Add, Text, xm, 打开命令添加界面:
Gui, Add, Edit, vkey_open_editor xs+0 yp+0 w80,% g_config.key_open_editor


Gui, Add, Text, xm, hook模式快捷键:
Gui, Add, Edit, vhook_open xs+0 yp+0 w80,% g_config.hook_open

;宽度
Gui, Add, Text, xm, 搜索框宽度:
Gui, Add, Edit, vwin_w xs+0 yp+0 w80,% g_config.win_w


Gui, Add, Text, xm, 搜索框背景颜色:
Gui, Add, Edit, vwin_search_box_back_color xs+0 yp+0 w80,% g_config.win_search_box_back_color

Gui, Add, Text, xm, 搜索框字体颜色:
Gui, Add, Edit, vwin_search_box_text_color xs+0 yp+0 w80,% g_config.win_search_box_text_color


Gui, Add, Text, xm, 搜索框字体大小:
Gui, Add, Edit, vwin_search_box_font_size xs+0 yp+0 w80,% g_config.win_search_box_font_size

Gui, Add, Text, xm, 列表背景颜色:
Gui, Add, Edit, vwin_list_back_color xs+0 yp+0 w80,% g_config.win_list_back_color

Gui, Add, Text, xm, 列表字体颜色:
Gui, Add, Edit, vwin_list_text_color xs+0 yp+0 w80,% g_config.win_list_text_color

Gui, Add, Text, xm, 列表焦点背景颜色:
Gui, Add, Edit, vwin_list_focus_back_color xs+0 yp+0 w80,% g_config.win_list_focus_back_color

Gui, Add, Text, xm, 列表焦点字体颜色:
Gui, Add, Edit, vwin_list_focus_text_color xs+0 yp+0 w80,% g_config.win_list_focus_text_color

Gui, Add, Text, xm, 列表字体大小:
Gui, Add, Edit, vwin_list_font_size xs+0 yp+0 w80,% g_config.win_list_font_size

Gui, Add, Text, xm, 预览背景颜色
Gui, Add, Edit, vtooltip_back_color xs+0 yp+0 w80,% g_config.tooltip_back_color

Gui, Add, Text, xm, 预览字体颜色
Gui, Add, Edit, vtooltip_text_color xs+0 yp+0 w80,% g_config.tooltip_text_color

Gui, Add, Text, xm, 预览字体大小
Gui, Add, Edit, vtooltip_font_size xs+0 yp+0 w80,% g_config.tooltip_font_size

Gui, Add, Text, xm, 是否预览随机颜色[0/1]
Gui, Add, Edit, vtooltip_random xs+0 yp+0 w80,% g_config.tooltip_random

Gui, Add, Text, xm, 是否自动切换为英文[0/1]
Gui, Add, Edit, vauto_english xs+0 yp+0 w80,% g_config.auto_english

Gui, Add, Text, xm, 是否提示帮助信息[0/1]
Gui, Add, Edit, vtooltip_help xs+0 yp+0 w80,% g_config.tooltip_help

Gui, Add, Text, xm, python解释器路径
Gui, Add, Edit, vpython_path xs+0 yp+0 w160,% g_config.python_path

Gui, Add, Link, xm, 查询按键 <a href="https://www.autoahk.com/help/autohotkey/zh-cn/docs/Hotkeys.htm">按键列表</a>
Gui, Add, Button, xm gsetting default, 设置
Gui, Add, Button, x+10 greset, 重置

Gui Color, 0xC0C0C0
Gui, Show, autosize, setting
Gui, +AlwaysOnTop +hWndhMainWnd -DPIScale
return

GuiClose:
ExitApp
return

setting:
Gui, Submit,NoHide  ; 保存用户的输入到每个控件的关联变量中.
g_config.key_open_search_box := key_open_search_box
g_config.key_edit_now := key_edit_now
g_config.key_edit_new := key_edit_new
g_config.key_open_editor := key_open_editor
g_config.hook_open := hook_open
g_config.win_w := win_w
g_config.win_search_box_back_color := win_search_box_back_color
g_config.win_search_box_text_color := win_search_box_text_color
g_config.win_search_box_font_size := win_search_box_font_size
g_config.win_list_back_color := win_list_back_color
g_config.win_list_text_color := win_list_text_color
g_config.win_list_focus_back_color := win_list_focus_back_color
g_config.win_list_focus_text_color := win_list_focus_text_color
g_config.win_list_font_size := win_list_font_size

g_config.tooltip_back_color := tooltip_back_color
g_config.tooltip_text_color := tooltip_text_color
g_config.tooltip_font_size := tooltip_font_size
g_config.tooltip_random := tooltip_random

g_config.auto_english := auto_english
g_config.tooltip_help := tooltip_help

g_config.python_path := python_path

saveconfig(g_config)
log.info(g_config)
save_script()
return

reset:
GuiControl,, key_open_search_box , +enter
GuiControl,, key_send , ~$^enter
GuiControl,, key_edit_now, ~$^e
GuiControl,, key_edit_now, ~$^d
GuiControl,, key_open_editor , ~$!c
GuiControl,, hook_open , +Space
GuiControl,, win_w , 600

GuiControl,, win_search_box_back_color , 1d1d1d
GuiControl,, win_search_box_text_color , 999999
GuiControl,, win_search_box_font_size, 16

GuiControl,, win_list_back_color , 1d1d1d
GuiControl,, win_list_text_color , 999999
GuiControl,, win_list_focus_back_color , 0x313131
GuiControl,, win_list_focus_text_color , 0x959595
GuiControl,, win_list_font_size, 14

GuiControl,, tooltip_back_color , 1d1d1d
GuiControl,, tooltip_text_color , 999999
GuiControl,, tooltip_font_size , 15
GuiControl,, tooltip_random , 1

GuiControl,, auto_english , 1
GuiControl,, tooltip_help , 1

GuiControl,, python_path, C:\Python310\python.exe
Gosub, setting
return

;函数
run_as_admin()
{
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

save_script()
{
    if(A_IsCompiled)
        run, %A_ScriptDir%/super-command.exe
    else
        run,% A_ScriptDir "\v1\AutoHotkey.exe " A_ScriptDir "\super-command.ahk"
}