; 用高级方法获取<a>...</a>之间的内容

s:="<a>aaaaaaaaa</a> <a>bbbbbbbb</a>"

; 错误方法：贪婪的任意字符会得到多余内容
re:="<a>([\s\S]*)</a>"
RegExMatch(s, re, r)
MsgBox, % r1

; 简单方法：非贪婪的任意字符得到最少内容
re:="<a>([\s\S]*?)</a>"
RegExMatch(s, re, r)
MsgBox, % r1

; 高级方法：后面没有接</a>的任意字符
re:="<a>((?:(?!</a>)[\s\S])*)</a>"
RegExMatch(s, re, r)
MsgBox, % r1