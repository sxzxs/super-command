class cmd
{
    static DLL_USE_MAP := {"cpp2ahk.dll" : {"run_cmd" : 0}, "is_load" : 0}
    static is_dll_load := false
    static _ := this.log4ahk_load_all_dll_path()
    log4ahk_load_all_dll_path()
    {
        local
        SplitPath,A_LineFile,,dir
        path := ""
        lib_path := dir
        if(A_IsCompiled)
        {
            path := A_PtrSize == 4 ? A_ScriptDir . "\lib\dll_32\" : A_ScriptDir . "\lib\dll_64\"
            lib_path := A_ScriptDir . "\lib"
        }
        else
        {
            path := (A_PtrSize == 4) ? dir . "\dll_32\" : dir . "\dll_64\"
        }
        dllcall("SetDllDirectory", "Str", path)
        for k,v in this.DLL_USE_MAP
        {
            for k1, v1 in v 
            {
                this.DLL_USE_MAP[k][k1] := DllCall("GetProcAddress", "Ptr", DllCall("LoadLibrary", "Str", k, "Ptr"), "AStr", k1, "Ptr")
            }
        }
        this.is_dll_load := true
    }
    run(cmd_line, cp := "CP0")
    {
        if(this.is_dll_load == false)
        {
            this.log4ahk_load_all_dll_path()
        }
        out_str := ""
        VarSetCapacity(out_str,0)
        VarSetCapacity(out_str,4000)

        cmd_StrPutVar(cmd_line, buf, "CP0")
        rtn := DllCall(this.DLL_USE_MAP["cpp2ahk.dll"]["run_cmd"],"Str", buf, "Str", out_str,"Cdecl Int")
        rtn := StrGet(&out_str, 4000, cp)
        return rtn
    }
}
;is_use_pip := true 使用管道时，lib库不能放到c盘
gnuwin32(cmd_line,is_use_pip := true, cp := "CP0")
{
    SplitPath,A_LineFile,,dir
    path := ""
    if(A_IsCompiled)
    {
        path := A_ScriptDir . "\lib\dll_32\bin\"
    }
    else
    {
        path := dir . "\dll_32\bin\"
    }
    cmd_line := path . cmd_line
    if(is_use_pip)
    {
        rtn := cmd.run(cmd_line, cp)
    }
    else
    {
        rtn := RunCmd(cmd_line,, "UTF-8")
    }
    return rtn
}
RunCmd(CmdLine, WorkingDir:="", Cp:="CP0") { ; Thanks Sean!  SKAN on D34E @ tiny.cc/runcmd 
  Local P8 := (A_PtrSize=8),  pWorkingDir := (WorkingDir ? &WorkingDir : 0)                                                
  Local SI, PI,  hPipeR:=0, hPipeW:=0, Buff, sOutput:="",  ExitCode:=0,  hProcess, hThread
                   
  DllCall("CreatePipe", "PtrP",hPipeR, "PtrP",hPipeW, "Ptr",0, "UInt",0)
, DllCall("SetHandleInformation", "Ptr",hPipeW, "UInt",1, "UInt",1)
    
  VarSetCapacity(SI, P8? 104:68,0),      NumPut(P8? 104:68, SI)
, NumPut(0x100, SI,  P8? 60:44,"UInt"),  NumPut(hPipeW, SI, P8? 88:60)
, NumPut(hPipeW, SI, P8? 96:64)   

, VarSetCapacity(PI, P8? 24:16)               

  If not DllCall("CreateProcess", "Ptr",0, "Str",CmdLine, "Ptr",0, "UInt",0, "UInt",True
              , "UInt",0x08000000 | DllCall("GetPriorityClass", "Ptr",-1,"UInt"), "UInt",0
              , "Ptr",pWorkingDir, "Ptr",&SI, "Ptr",&PI )  
     Return Format( "{1:}", "" 
          , DllCall("CloseHandle", "Ptr",hPipeW)
          , DllCall("CloseHandle", "Ptr",hPipeR)
          , ErrorLevel := -1 )
  DllCall( "CloseHandle", "Ptr",hPipeW)

, VarSetCapacity(Buff, 4096, 0), nSz:=0   
  While DllCall("ReadFile",  "Ptr",hPipeR, "Ptr",&Buff, "UInt",4094, "PtrP",nSz, "UInt",0)
    sOutput .= StrGet(&Buff, nSz, Cp)

  hProcess := NumGet(PI, 0),  hThread := NumGet(PI,4)
, DllCall("GetExitCodeProcess", "Ptr",hProcess, "PtrP",ExitCode)
, DllCall("CloseHandle", "Ptr",hProcess),    DllCall("CloseHandle", "Ptr",hThread)
, DllCall("CloseHandle", "Ptr",hPipeR),      ErrorLevel := ExitCode  
Return sOutput  
}

cmd_StrPutVar(string, ByRef var, encoding)
{
    ; 确定容量.
    VarSetCapacity( var, StrPut(string, encoding)
        ; StrPut 返回字符数, 但 VarSetCapacity 需要字节数.
        * ((encoding="utf-16"||encoding="cp1200") ? 2 : 1) )
    ; 复制或转换字符串.
    return StrPut(string, &var, encoding)
}