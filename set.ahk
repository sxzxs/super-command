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
Gui, Add, Edit, vkey_open_search_box x+55 w80,% g_config.key_open_search_box
Gui, Add, Text, xm, 发送文件:
Gui, Add, Edit, vkey_send x+65 w80,% g_config.key_send

Gui, Add, Text, xm, 编辑当前指令:
Gui, Add, Edit, vkey_edit_now x+40 w80,% g_config.key_edit_now

Gui, Add, Text, xm, 打开命令添加界面:
Gui, Add, Edit, vkey_open_editor x+15 w80,% g_config.key_open_editor
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
g_config.key_open_editor := key_open_editor
saveconfig(g_config)
log.info(g_config)
save_script()
return

reset:
GuiControl,, key_open_search_box , +enter
GuiControl,, key_send , ~$^enter
GuiControl,, key_edit_now, ~$^x
GuiControl,, key_open_editor , ~$!c
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
        run, %A_ScriptDir%/menu.exe
    else
        run, %A_ScriptDir%/menu.ahk
}