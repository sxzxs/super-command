/*
 * @description Number Theory Lib, used for high precision integer and floating point number calculation
 * @file NTLCalc.ahk
 * @author thqby
 * @date 2021/12/12
 * @version 1.0.3
*/

/*
	 * Computational mathematical expression.
	 * @param exp A mathematical expression to be evaluated, such as `4*23.2/4.1`
	 * #### `constants`
	 * - pi, e
	 *
	 * #### functions
	 * - sin, cos, tan, pow, pow2, pow3, sqrt, abs, ceil, floor, exp, ln, log
	 * - max(x1, x2, ...)
	 * - min(x1, x2, ...)
	 * - round(x, n = 0)
*/



class NTLCalc
{
	;static static_:= DllCall("LoadLibrary", "str","ntl.dll", "ptr")
	static static_ := DllCall("LoadLibrary", "str", A_LineFile "\..\" (A_PtrSize * 8) "bit\ntl.dll", "ptr")

	Call(exp) {
		switch (DllCall("ntl\Calc", "astr", exp, "ptr*", val, "cdecl")) {
			case 0: return StrGet(val, "cp0")
			case 1: throw Exception("ExpressionError")
			case 2: throw Exception("ParamCountError")
			case 3: throw Exception("TypeError")
			case 4: throw Exception("UnknowTokenError")
			case 5: throw Exception("ZeroDivisionError")
		}
    }

	; Set Debug Mode, Print the results of each step in the stdout.
	SetDebugMode(p := false) {
		DllCall("ntl\SetDebugMode", "char", p, "cdecl")
	}

	; Set output precision(number of bits).		;设置输出精度（位数）。
	SetOutputPrecision(p) {
		DllCall("ntl\SetOutputPrecision", "int", p, "cdecl")
	}

	; Set the precision(number of bits).	;设置精度（位数）。
		SetPrecision(p) {
		DllCall("ntl\SetPrecision", "int", p, "cdecl")
	}
}