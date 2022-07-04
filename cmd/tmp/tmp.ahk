str := "aaa123===bbb456"
re := "([ab]+)(\d+)"
For k,v in arr:=RegExMatchAll(str, re)
  msgbox % "第 " k " 个匹配的第 2 个子匹配是：" v[2]

;----------------------------------
; 简单的 RegExMatchAll  By FeiYue
;----------------------------------
; 返回值为所有找到的匹配的二级数组，没找到返回0
; 第一级是所有找到的匹配
; 第二级是每个找到的匹配的多个字符串构成的简单数组
;     数组[0]表示整个匹配的字符串
;     数组[N]表示第N个子模式匹配的字符串
;----------------------------------
RegExMatchAll(str, re)
{
  ; 给正则表达式re添加大欧选项O)
  re:=RegExMatch(re, "^[\w\s`a]*\)") ? "O" re : "O)" re
  arr:=[], pos:=1
  While pos:=RegExMatch(str, re, Match, pos)
  {
    if Match.Len(0)<1 and (pos++ or 1)
      Continue
    pos+=Match.Len(0), arr2:=[]
    Loop % Floor(Match.Count())+1
      arr2[A_Index-1]:=Match.Value(A_Index-1)
    arr.Push(arr2)
  }
  return arr.Length() ? arr : 0
}