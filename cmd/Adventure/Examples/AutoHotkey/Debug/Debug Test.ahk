; AHK Debugger Test Script

#SingleInstance Force
#NoEnv
SetWorkingDir %A_ScriptDir%
SetBatchLines -1

; File object
oFile := FileOpen(A_ScriptFullPath, "r")
Line := RTrim(oFile.ReadLine(), "`r`n")
oFile.Close()
MsgBox % Line

; Object instance, executable information
oExe := New ExeInfo(A_AhkPath)
oExe.ShowInfo()

File := A_WinDir . "\System32\rstrui.exe"
Storage(123, oExe)
Storage(123).ExeFile := FileExist(File) ? File : A_Comspec
oExe.ShowInfo()

; Motherboard information
If (GetMoboInfo(Manufacturer, Product)) {
    MsgBox 0x40, Motherboard Information, % "Manufacturer: " . Manufacturer . "`nProduct: " . Product
}

; Hex number parts
Number := 0x12345678
GetWordPortions(Number, HiWord, LoWord, HiByte, LoByte)
MsgBox 0x40, Number portions,
(LTrim
    Number: `t%Number%
    HiWord: `t%HiWord%
    LoWord: `t%LoWord%
    HiByte: `t%HiByte%
    LoByte: `t%LoByte%
)

; Array manipulation
aColors := ["red", "green", "blue"]
PrintArray(aColors, "MsgBox", True)
OutputDebug % IndexOf(aColors, "green")

aValues := [3, 5, 2, 9, 7, 1, 4, 6, 8]

SortArray(aValues)
PrintArray(aValues, "")

PrintArray(ReverseArray(aValues), "")

Return ; End of the auto-execute section.

GetWordPortions(Num, ByRef HiWord, ByRef LoWord, ByRef HIBYTE, ByRef LOBYTE) {
	SetFormat Integer, H
    HiWord := Num >> 16 ; 0x1234
    LoWord := Num & 0XFFFF ; 0x5678
    HIBYTE := (Num >> 8) & 0xFF ; 0x56
    LOBYTE := Num & 0xFF ; 0x78
    SetFormat Integer, D
}

IndexOf(aArray, Value) {
    Loop % aArray.Length() {
        If (aArray[A_Index] = Value) {
            Return A_Index
        }
    }
    Return False
}

ReverseArray(aArray) {
    Local aTemp := [], Max := aArray.Length(), Index

    Loop % Max {
        Index := Max - A_Index + 1
        aTemp[A_Index] := aArray[Index]
    }

    Return aTemp
}

SortArray(ByRef aArray) {
    Local Len := aArray.Length(), n, TempVar
    Loop {
        n := 0
        Loop % (Len - 1) {
            If (aArray[A_Index] > aArray[A_Index + 1]) {
                TempVar := aArray[A_Index]
                aArray[A_Index] := aArray[A_Index + 1]
                aArray[A_Index + 1] := TempVar
                n := A_Index
            }
        }
        Len := n
    } Until (n == 0)
}

PrintArray(aArray, Type := "MsgBox", ShowIndexes := False) {
    Local sItems := "", Index, Item

    For Index, Item in aArray {
        If (ShowIndexes) {
            sItems .= Index . ": " . Item . "`n"
        } Else {
            Item := (Item + 0 == "") ? """" . Item . """" : Item
            sItems .= Item . ", "
        }
    }

    If (!ShowIndexes) {
        sItems := "[" . RTrim(sItems, ", ") . "]"
    }

    If (Type == "MsgBox") {
        MsgBox % sItems
    } Else {
        OutputDebug % sItems
    }
}

Class ExeInfo {
    ExeFile := ""

    __New(ExeFile := "") {
        this.ExeFile := ExeFile
    }

    GetBinaryType() {
        Local BinType
        Static BinTypes := {6: "64-bit Windows-based application"
        , 0: "32-bit Windows-based application"
        , 1: "MS-DOS based application"}

        DllCall("Kernel32.dll\GetBinaryTypeW", "WStr", this.ExeFile, "Ptr*", BinType)
        BinType := BinTypes[BinType]
        Return BinType != "" ? BinType : "Unknown application type"
    }

    IsElevationRequired() {
        Local hModule, IsElevationRequired

        hModule := DllCall("GetModuleHandle", "Str", "shell32.dll", "Ptr")
        IsElevationRequired := DllCall("GetProcAddress", "Ptr", hModule, "UInt", 865, "Ptr")
        If (!hModule || !IsElevationRequired) {
            Return -1
        }

        Return DllCall(IsElevationRequired, "WStr", this.ExeFile)
    }

    ShowInfo() {
        Local BinType, Elevation
        BinType := this.GetBinaryType()
        Elevation := this.IsElevationRequired()

        MsgBox % 0, Executable info
        , % "Executable file: " . this.ExeFile
        . "`nBinary type: " . BinType
        . "`nElevation required? " . (Elevation ? "Yes" : "No")
    }
}

Storage(ID, t := "") {
    Static
    var := %ID%
    t ? %ID% := t : 0
    Return var
}

GetMoboInfo(ByRef Product, ByRef Manufacturer, ByRef Error := "") {
    Local cmd, WshExec, Output, Match, Match1, Match2

    cmd := "wmic baseboard get Product,Manufacturer /format:list"

    WshExec := ComObjCreate("WScript.Shell").Exec(cmd)

    If (Error := WshExec.StdErr.ReadAll()) {
        Return 0
    }

    Output := WshExec.StdOut.ReadAll()
    If (RegExMatch(Output, "Manufacturer=(.*)\s*Product=(.*)", Match)) {
        Product := Match2
        Manufacturer := Match1
    }

    Return 1
}
