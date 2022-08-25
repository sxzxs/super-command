#include <NTLCalc>
command := A_args[1]

;第一种调用方式
NTLCalc.SetOutputPrecision(500)
NTLCalc.SetPrecision(500)
MsgBox, % NTLCalc.Call(command)