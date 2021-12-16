global G_MY_DLL_BUFFER_SIZE := 4000
global G_MY_DLL_USE_MAP := {"DXGICapture.dll" : {"dxgi_init":0,"dxgi_pixelgetcolor":0},"cpp2ahk.dll" : {"cpp2ahk": 0, "log_simple" : 0, "chinese_convert_pinyin_initials" : 0, "chinese_convert_pinyin_allspell" : 0}, "opencv_dll_creat.dll" : {"opencv_ImageSearch" : 0, "opencv_imagesearch_adapt" : 0}, "TXGYMailCamera.dll" : {"CameraWindow": 0}, "PrScrn.dll" : {"PrScrn": 0}}
load_all_dll_path()
load_all_dll_path()
{
    local
    global G_MY_DLL_USE_MAP, log
    SplitPath,A_LineFile,,dir
    path := ""

    if(A_IsCompiled)
    {
        if(A_PtrSize == 4)
        {
            path :=  A_ScriptDir . "/lib/dll_32/"
        }
        else
        {
            path :=  A_ScriptDir . "/lib/dll_64/"
        }
        dllcall("SetDllDirectory", "Str", path)
    }
    else
    {
        if(A_PtrSize == 4)
        {
            path := dir . "/dll_32/"
        }
        else
        {
            path := dir . "/dll_64/"
        }
        dllcall("SetDllDirectory", "Str",path )
    }
    for k,v in G_MY_DLL_USE_MAP
    {
        for k1, v1 in v 
        {
            G_MY_DLL_USE_MAP[k][k1] := DllCall("GetProcAddress", "Ptr", DllCall("LoadLibrary", "Str", k, "Ptr"), "AStr", k1, "Ptr")
        }
    }
}
;convert obj to str
to_str(str)
{
    local
    rtn := ""
    if(IsObject(str))
    {
      rtn := obj2json_local(str)
      ;删除换行空格
      rtn := StrReplace(rtn, "`r`n")
      rtn := StrReplace(rtn, " ")
    }
    else
    {
      rtn := str
    }
    return rtn
}

dxgi_pixelgetcolor(x, y)
{
	out_str := ""
	VarSetCapacity(out_str,6)

    mylib_StrPutVar(in_str, buf, "CP0")
    rtn := DllCall(G_MY_DLL_USE_MAP["DXGICapture.dll"]["dxgi_pixelgetcolor"], "Int", x, "Int", y, "Str", out_str,"Cdecl Int")
	rtn := StrGet(&out_str, 6,"UTF-8")
    return rtn
}
dxgi_init()
{
	out_str := ""
	VarSetCapacity(out_str,0)
	VarSetCapacity(out_str,4000)

    mylib_StrPutVar(in_str, buf, "CP0")
    rtn := DllCall(G_MY_DLL_USE_MAP["DXGICapture.dll"]["dxgi_init"],"Cdecl Int")
    return rtn
}

chinese_convert_pinyin_allspell(in_str)
{
	out_str := ""
	VarSetCapacity(out_str,0)
	VarSetCapacity(out_str,4000)

    mylib_StrPutVar(in_str, buf, "CP0")
    rtn := DllCall(G_MY_DLL_USE_MAP["cpp2ahk.dll"]["chinese_convert_pinyin_allspell"],"Str", buf, "Str", out_str,"Cdecl Int")
	rtn := StrGet(&out_str, 4000,"UTF-8")
    return rtn
}
chinese_convert_pinyin_initials(in_str)
{
	out_str := ""
	VarSetCapacity(out_str,0)
	VarSetCapacity(out_str,4000)

    mylib_StrPutVar(in_str, buf, "CP0")
    rtn := DllCall(G_MY_DLL_USE_MAP["cpp2ahk.dll"]["chinese_convert_pinyin_initials"],"Str", buf, "Str", out_str,"Cdecl Int")
	rtn := StrGet(&out_str, 4000,"UTF-8")
    return rtn
}

mylib_StrPutVar(string, ByRef var, encoding)
{
    ; 确定容量.
    VarSetCapacity( var, StrPut(string, encoding)
        ; StrPut 返回字符数, 但 VarSetCapacity 需要字节数.
        * ((encoding="utf-16"||encoding="cp1200") ? 2 : 1) )
    ; 复制或转换字符串.
    return StrPut(string, &var, encoding)
}


StrPutVar(string, ByRef var, encoding)
{
    ; 确定容量.
    VarSetCapacity( var, StrPut(string, encoding)
        ; StrPut 返回字符数, 但 VarSetCapacity 需要字节数.
        * ((encoding="utf-16"||encoding="cp1200") ? 2 : 1) )
    ; 复制或转换字符串.
    return StrPut(string, &var, encoding)
}

/*
;------------------------------------
;  json转码纯AHK实现 v2.0  By FeiYue
;------------------------------------
*/

json2obj_local(s)  ; Json字符串转AHK对象
{
  local
  static rep:=[ ["\\","\u005c"], ["\""",""""]
    , ["\r","`r"], ["\n","`n"], ["\t","`t"]
    , ["\/","/"], ["\b","`b"], ["\f","`f"] ]
  if !(p:=RegExMatch(s, "[\{\[]", r))
    return
  SetBatchLines, % (bch:=A_BatchLines)?"-1":"-1"
  obj:=[], stack:=[], arr:=obj, flag:=r
  , key:=(flag="{" ? "":1), keyok:=0
  While p:=RegExMatch(s, "\S", r, p+StrLen(r))
  {
    if (r="{" or r="[")       ; 如果是 左括号
    {
      arr[key]:=[], stack.Push(arr, flag)
      , arr:=arr[key], flag:=r
      , key:=(flag="{" ? "":1), keyok:=0
    }
    else if (r="}" or r="]")  ; 如果是 右括号
    {
      if !stack.MaxIndex()
        Break
      flag:=stack.Pop(), arr:=stack.Pop()
      , key:=(flag="{" ? "":arr.MaxIndex()), keyok:=0
    }
    else if (r=",")           ; 如果是 逗号
    {
      key:=(flag="{" ? "":Round(key)+1), keyok:=0
    }
    else if (r="""")          ; 如果是 双引号
    {
      if !(RegExMatch(s, """((?:\\[\s\S]|[^""\\])*)""", r, p)=p)
        Break
      if InStr(r1, "\")
      {
        For k,v in rep
          r1:=StrReplace(r1, v.1, v.2)
        While RegExMatch(r1, "\\u[0-9A-Fa-f]{4}", k)
          r1:=StrReplace(r1, k, Chr("0x" SubStr(k,3)))
      }
      if (flag="{" and keyok=0)  ; 如果是 键名
      {
        p+=StrLen(r)
        if !(RegExMatch(s, "\s*:", r, p)=p)
          Break
        key:=r1, keyok:=1
      }
      else arr[key]:=r1
    }
    else if RegExMatch(s, "[\w\+\-\.]+", r, p)=p
    {
      arr[key]:=r  ; 如果是 数字、true、false、null
    }
    else Break
  }
  SetBatchLines, %bch%
  return obj
}

obj2json_local(obj, space:="")  ; AHK对象转Json字符串
{
  local
  ; 默认不替换 "/-->\/" 与 "Unicode字符-->\uXXXX"
  static rep:=[ ["\\","\"], ["\""",""""]  ; , ["\/","/"]
    , ["\r","`r"], ["\n","`n"], ["\t","`t"]
    , ["\b","`b"], ["\f","`f"] ]
  if !IsObject(obj)
  {
    if obj is Number
      return obj
    if (obj=="true" or obj=="false" or obj=="null")
      return obj
    For k,v in rep
      obj:=StrReplace(obj, v.2, v.1)
    ; While RegExMatch(obj, "[^\x20-\x7e]", k)
    ;   obj:=StrReplace(obj, k, Format("\u{:04x}",Ord(k)))
    return """" obj """"
  }
  is_arr:=1  ; 是简单数组
  For k,v in obj
    if (k!=A_Index) and !(is_arr:=0)
      Break
  s:="", space2:=space . "    "
  For k,v in obj
    s.= "`r`n" space2 . (is_arr ? ""
      : """" Trim(%A_ThisFunc%(Trim(k)),"""") """: ")
      . %A_ThisFunc%(v,space2) . ","
  return (is_arr?"[":"{") . Trim(s,",")
       . "`r`n" space . (is_arr?"]":"}")
}
;t = 20 强制替换
SmartZip(s, o, t = 4)
{
    IfNotExist, %s%
        return, -1
    oShell := ComObjCreate("Shell.Application")
    if InStr(FileExist(o), "D") or (!FileExist(o) and (SubStr(s, -3) = ".zip"))
    {
        if !o
            o := A_ScriptDir
        else ifNotExist, %o%
                FileCreateDir, %o%
        Loop, %o%, 1
            sObjectLongName := A_LoopFileLongPath
        oObject := oShell.NameSpace(sObjectLongName)
        Loop, %s%, 1
        {
            oSource := oShell.NameSpace(A_LoopFileLongPath)
            oObject.CopyHere(oSource.Items, t)
        }
    }
}

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

mylib_opencv_pic_search(picPath,x1,y1,x2,y2,thresh, hold, ext := "")
{
	local
    global G_MY_DLL_USE_MAP
	VarSetCapacity(str,0)
	VarSetCapacity(str,2000)
    result := DllCall(G_MY_DLL_USE_MAP["opencv_dll_creat.dll"]["opencv_ImageSearch"],"AStr",picPath,"Int", x1,"Int", y1,"Int", x2,"Int", y2,"Int",thresh, "Str", str,"Cdecl Int")
	if(ErrorLevel != 0)
    {
        MsgBox, dll调用错误 %ErrorLevel%
        return 0
    }
    if(result != 0)
    {
        MsgBox, 参数错误 %result%
        return 0
    }
	rtn := StrGet(&str,2000,"CP0")
    ext["str"] := rtn
	InStr(rtn, "0_0_0", true)

	arr2 := mStringSplit(rtn)
	for key,value in arr2
	{
		if(arr2[key][1] > hold )
		{
			value[2] := value[2] + x1
			value[3] := value[3] + y1
			return value
		}
	}
	return 0
}

;	x:=ok[2]
;	y:=ok[3]
mOpencvPicSearch(picPath,x1,y1,x2,y2,thresh, hold, ext := "")
{
	local
  global G_MY_DLL_USE_MAP
	str1 := ""
	rtn := ""
	VarSetCapacity(str,0)
	VarSetCapacity(str,2000)

  result := DllCall(G_MY_DLL_USE_MAP["opencv_dll_creat.dll"]["opencv_ImageSearch"],"AStr",picPath,"Int", x1,"Int", y1,"Int", x2,"Int", y2,"Int",thresh, "Str", str,"Cdecl Int")
	if(ErrorLevel != 0)
    {
        MsgBox, dll调用错误 %ErrorLevel%
        return 0
    }
    if(result != 0)
    {
        MsgBox, 参数错误 %result%
        return 0
    }
	rtn := StrGet(&str,2000,"CP0")
    ext["str"] := rtn
	InStr(rtn, "0_0_0", true)

	arr2 := mStringSplit(rtn)
	for key,value in arr2
	{
		if(arr2[key][1] > hold )
		{
			value[2] := value[2] + x1
			value[3] := value[3] + y1
			return value
		}
	}
	return 0
}

image_search_adapt(picPath,x1,y1,x2,y2, hold, ext := "",block_size := 21, c := 7)
{
	local
  global G_MY_DLL_USE_MAP
	str1 := ""
	rtn := ""
	VarSetCapacity(str,0)
	VarSetCapacity(str,2000)

  ;msgbox,% block_size " " c
  ;result := DllCall(G_MY_DLL_USE_MAP["opencv_dll_creat.dll"]["opencv_imagesearch_adapt"],"AStr",picPath,"Int", x1,"Int", y1,"Int", x2,"Int", y2,"Int", block_size, "Int", c, "Str", str,"Cdecl Int")
  result := DllCall(G_MY_DLL_USE_MAP["opencv_dll_creat.dll"]["opencv_imagesearch_adapt"],"AStr",picPath,"Int", x1,"Int", y1,"Int", x2,"Int", y2, "Int", block_size, "Int", c, "Str", str,"Cdecl Int")
	if(ErrorLevel != 0)
    {
        MsgBox, dll调用错误 %ErrorLevel%
        return 0
    }
    if(result != 0)
    {
        MsgBox, 参数错误 %result%
        return 0
    }
	rtn := StrGet(&str,2000,"CP0")
  ext["str"] := rtn
	InStr(rtn, "0_0_0", true)

	arr2 := mStringSplit(rtn)
	for key,value in arr2
	{
		if(arr2[key][1] > hold )
		{
			value[2] := value[2] + x1
			value[3] := value[3] + y1
			return value
		}
	}
	return 0
}
mStringSplit(string)
{
  local
  inside_array := []
  this_color := []
  word_array := StrSplit(string, "|")
  Loop % word_array.MaxIndex()-1
  {
      this_color := word_array[a_index]
      inside_array[a_index]:= StrSplit(this_color, "_")
  }
  return inside_array
}

mylib_capture()
{
  local 
  global G_MY_DLL_USE_MAP
  DllCall(G_MY_DLL_USE_MAP["PrScrn.dll"]["PrScrn"])
}

mylib_run_with_32ahk()
{
    if((A_PtrSize=8&&A_IsCompiled="")||!A_IsUnicode){ ;32 bit=4  ;64 bit=8
    SplitPath,A_AhkPath,,dir
    if(!FileExist(correct:=dir "\AutoHotkeyU32.exe")){
	    MsgBox error
	    ExitApp
    }
    Run,"%correct%" "%A_ScriptName%",%A_ScriptDir%
    ExitApp
    return
    }
}

QPC() 
{
    static Freq,MulDivProc,init
    if (!init)
    {
        MulDivProc:=DllCall("GetProcAddress", "Ptr", DllCall("LoadLibrary", "Str", "Kernel32", "Ptr"), "AStr", "QueryPerformanceCounter", "Ptr")
        DllCall("QueryPerformanceFrequency", "Int64P", Freq)
        init:=1
    }
    DllCall(MulDivProc, "Int64P", Count1)
    return Count1/Freq*1000
}
sleep_ms(ms)
{
    static init,socket,MulDivProc,timeBeginPeriod,timeEndPeriod,NtSetTimerResolution
    if (!init)
    {
        MulDivProc := DllCall("GetProcAddress", "Ptr", DllCall("LoadLibrary", "Str", "Ws2_32", "Ptr"), "AStr", "select", "Ptr")
        timeBeginPeriod := DllCall("GetProcAddress", "Ptr", DllCall("LoadLibrary", "Str", "Winmm", "Ptr"), "AStr", "timeBeginPeriod", "Ptr")
        timeEndPeriod := DllCall("GetProcAddress", "Ptr", DllCall("LoadLibrary", "Str", "Winmm", "Ptr"), "AStr", "timeEndPeriod", "Ptr")
        NtSetTimerResolution := DllCall("GetProcAddress", "Ptr", DllCall("LoadLibrary", "Str", "NTDLL", "Ptr"), "AStr", "NtSetTimerResolution", "Ptr")  ;0.5ms
        VarSetCapacity(wsaData, 408)
        DllCall("Ws2_32\WSAStartup", "ushort",2|(2<<8), "Ptr", &wsaData)
        socket:=DllCall("Ws2_32\socket", "int", 2, "int", 1, "int", 0)
        init:=1
    }
    VarSetCapacity(rfds, A_PtrSize*(64+1), 0)
    NumPut(socket, rfds, A_PtrSize, "Ptr"), NumPut(1, rfds, "int")
    VarSetCapacity(Hints, 8, 0)
    NumPut(tv_sec:=0, Hints, 0, "Int")
    NumPut(tv_usec:=Round(ms*1000), Hints, 4, "Int")
    DllCall(timeBeginPeriod, "UInt", 1)
    DllCall(MulDivProc, "Int",1, "Ptr",&rfds, "Ptr",0, "Ptr",0, "Ptr",&Hints)
    DllCall(timeEndPeriod, "UInt", 1)
    ;DllCall(NtSetTimerResolution, "UInt", 5000, "UInt", 1, "UInt*", TimerResolutionActual) ;设置计时器分辨率为0.5ms
    ;DllCall(MulDivProc, "Int",1, "Ptr",&rfds, "Ptr",0, "Ptr",0, "Ptr",&Hints)
    ;DllCall(NtSetTimerResolution, "UInt", 5000, "UInt", 0, "UInt*", TimerResolutionActual) ;还原默认计时器分辨率
}

/*
------------------------------------------
  左键拖动选择屏幕范围 v1.5  By FeiYue

  说明：
      按热键“F1”开始左键拖动选择范围，
      然后点击范围确定，点其他位置取消
------------------------------------------
*/

my_lib_GetRange(ByRef x="",ByRef y="",ByRef w="",ByRef h="")
{
  Hotkey, *LButton, my_lib_LButton_Return, On
  CoordMode, Mouse
  Ptr:=A_PtrSize ? "UPtr":"UInt", int:="int"
  nW:=A_ScreenWidth, nH:=A_ScreenHeight

  ;-- 生成画布窗口和选框窗口
  Gui, Canvas:New, +AlWaysOnTop +ToolWindow -Caption
  Gui, Canvas:Add, Picture, x0 y0 w%nW% h%nH% +0xE HwndpicID
  Gui, Range:+LastFound +AlWaysOnTop -Caption +OwnerCanvas
  WinSet, Transparent, 50
  Gui, Range:Color, Yellow
  my_lib_range_create("Red","Canvas")

  ;-- 截屏到内存图像并关联到画布窗口的图片控件
  hDC:=DllCall("GetDC", Ptr,0, Ptr)
  mDC:=DllCall("CreateCompatibleDC", Ptr,hDC, Ptr)
  hBM:=DllCall("CreateCompatibleBitmap", Ptr,hDC, int,nW, int,nH, Ptr)
  oBM:=DllCall("SelectObject", Ptr,mDC, Ptr,hBM, Ptr)
  DllCall("BitBlt", Ptr,mDC, int,0, int,0, int,nW, int,nH
    , Ptr,hDC, int,0, int,0, int,0x00CC0020|0x40000000)
  SendMessage, 0x172, 0, hBM,, ahk_id %picID%
  if ( E:=ErrorLevel )
    DllCall("DeleteObject", Ptr,E)
  DllCall("SelectObject", Ptr,mDC, Ptr,oBM)
  DllCall("DeleteDC", Ptr,mDC)
  DllCall("ReleaseDC", Ptr,0, Ptr,hDC)

  ;-- 显示画布窗口，开始等待选择范围
  Gui, Canvas:Show, NA x0 y0 w%nW% h%nH%
  ok:=w:=h:=0
  ListLines, Off
  Loop {
    Sleep, 100
    MouseGetPos, x2, y2
    if GetkeyState("LButton","P")!=ok
    {
      ToolTip
      ok:=!ok, x1:=x2, y1:=y2
      if (ok and x2>x and y2>y and x2<x+w-1 and y2<y+h-1)
        Break
    }
    if (ok=0)
    {
      ToolTip, % w+h>5 ? "点击范围确定，点其他位置取消"
        : "请按下鼠标左键并拖动选择范围"
      Continue
    }
    w:=Abs(x1-x2), h:=Abs(y1-y2)
    x:=(x1+x2-w)//2, y:=(y1+y2-h)//2
    if (w+h>5)
    {
      Gui, Range:Show, NA x%x% y%y% w%w% h%h%
      my_lib_range_show(x,y,w,h)
    }
    else
    {
      Gui, Range:Hide
      my_lib_range_hide()
    }
  }
  ListLines, On
  my_lib_range_delete()
  Gui, Range:Destroy
  Gui, Canvas:Destroy

  ;-- 不需要了才清除内存图像
  DllCall("DeleteObject", Ptr,hBM)

  KeyWait, LButton
  Hotkey, *LButton, my_lib_LButton_Return, Off
  my_lib_LButton_Return:
  Return
}

my_lib_range_create(color="Red", Owner="") {
  j:=Owner ? "+Owner" Owner : "+ToolWindow"
  Loop 4 {
    i:=A_Index
    Gui,range_%i%:+AlWaysOnTop -Caption %j% +E0x08000000
    Gui,range_%i%:Color, %color%
  }
}

my_lib_range_show(x,y,w,h,r=2) {
  Loop 4 {
    i:=A_Index
    , x1:=i=3 ? x+w : x-r
    , y1:=i=4 ? y+h : y-r
    , w1:=i=1 or i=3 ? r : w+r+r
    , h1:=i=2 or i=4 ? r : h+r+r
    Gui, range_%i%:Show, NA x%x1% y%y1% w%w1% h%h1%
  }
}

my_lib_range_hide() {
  Loop 4
    Gui, range_%A_Index%:Hide
}

my_lib_range_delete() {
  Loop 4
    Gui, range_%A_Index%:Destroy
}

my_lib_MouseTip(x="", y="", w="", h="")
{
  if (x="")
  {
    VarSetCapacity(pt,16,0), DllCall("GetCursorPos","ptr",&pt)
    x:=NumGet(pt,0,"uint"), y:=NumGet(pt,4,"uint")
  }
  x:=Round(x)
  y:=Round(y)
  h:=Round(h)
  w:=Round(w)
  ;-------------------------
  Gui, _MouseTip_: +AlwaysOnTop -Caption +ToolWindow +Hwndmyid +E0x08000000
  Gui, _MouseTip_: Show, Hide w%w% h%h%
  ;-------------------------
  dhw:=A_DetectHiddenWindows
  DetectHiddenWindows, On
  d:=4, i:=w-d, j:=h-d
  s=0-0 %w%-0 %w%-%h% 0-%h% 0-0
  s=%s%  %d%-%d% %i%-%d% %i%-%j% %d%-%j% %d%-%d%
  WinSet, Region, %s%, ahk_id %myid%
  DetectHiddenWindows, %dhw%
  ;-------------------------
  Gui, _MouseTip_: Show, NA x%x% y%y%
  Loop, 4
  {
    Gui, _MouseTip_: Color, % A_Index & 1 ? "Red" : "Blue"
    Sleep, 500
  }
  Gui, _MouseTip_: Destroy
}

mylib_mt_mousetip(x := 0, y := 0, w := 10, h := 10, show_time := 999999999)
{
  return new mylib_muti_mousetip(x, y, w, h, show_time)
}
class mylib_muti_mousetip 
{
    static s_tooltip_number := 1
    static s_max_btt := 40
    __New(x := 0, y := 0, w := 10, h := 10, show_time := 999999999) 
    {
        this.timer := ObjBindMethod(this, "Tick")
        this.x := x
        this.y := y
        this.w := w
        this.h := h
        this.show_time := show_time
        this.which := this.base.s_tooltip_number
        if(this.base.s_tooltip_number == this.s_max_btt)
        {
            this.base.s_tooltip_number := 0
        }
        this.base.s_tooltip_number++
        this.Start()
    }
    __Delete()
    {
    }
    Start() 
    {
        timer := this.timer
        SetTimer % timer,% -this.show_time
        mylib_mt_MouseTip_fy(this.x, this.y, this.w, this.h, this.which)
    }
    Stop() 
    {
        gui_name := "name_" this.which
        timer := this.timer
        SetTimer % timer, delete
        Gui, %gui_name%: Destroy
        this.timer := 0
    }
    Tick() 
    {
        this.stop()
    }
}
;by feiyue
mylib_mt_MouseTip_fy(x="", y="", w="", h="", which := 1)
{
  local
  if (x="")
  {
    VarSetCapacity(pt,16,0), DllCall("GetCursorPos","ptr",&pt)
    x:=NumGet(pt,0,"uint"), y:=NumGet(pt,4,"uint")
  }
  x:=Round(x)
  y:=Round(y)
  h:=Round(h)
  w:=Round(w)
  gui_name := "name_" which
  ;-------------------------
  Gui, %gui_name%: +AlwaysOnTop -Caption +ToolWindow +Hwndmyid +E0x08000000
  Gui, %gui_name%: Show, Hide w%w% h%h%
  ;-------------------------
  dhw:=A_DetectHiddenWindows
  DetectHiddenWindows, On
  d:=4, i:=w-d, j:=h-d
  s=0-0 %w%-0 %w%-%h% 0-%h% 0-0
  s=%s%  %d%-%d% %i%-%d% %i%-%j% %d%-%j% %d%-%d%
  WinSet, Region, %s%, ahk_id %myid%
  DetectHiddenWindows, %dhw%
  ;-------------------------
  Gui, %gui_name%: Show, NA x%x% y%y%
  Gui, %gui_name%: Color,%  "Red"
}

;添加自启动
add_start()
{
    startuplnk := A_StartMenu . "\Programs\Startup\" substr(A_ScriptName, 1, -4) ".lnk"
    FileCreateShortcut, % A_ScriptFullpath, % startuplnk
}
;删除自启动
delete_start()
{
    startuplnk := A_StartMenu . "\Programs\Startup\" substr(A_ScriptName, 1, -4) ".lnk"
    if(FileExist(startuplnk))
        FileDelete, % startuplnk
}