; A script to set Adventure as default AHK editor.

#SingleInstance Force
#NoEnv
#NoTrayIcon
SetWorkingDir %A_ScriptDir%
SetBatchLines -1

CommandLine := DllCall("GetCommandLine", "Str")
If (A_IsAdmin && RegExMatch(CommandLine, " /(exe|ahk)(?!\S)", Match)) {
    Assoc(Match1)
    ExitApp
}

If (DllCall("Kernel32.dll\GetVersion", "UChar") < 6) {
    MsgBox 0x10,, This script requires Windows Vista or higher.
    ExitApp
}

Instruction := "Default AutoHotkey Script Editor"
Content := "Choose whether you want to associate AutoHotkey scripts with the script source or the compiled version of Adventure."
Title := "Default Editor"
MainIcon := 0xFFFB ; UAC shield

RadioButtons := []
RadioButtons.Push([201, "Compiled version"])
RadioButtons.Push([202, "AutoHotkey script"])
cRadioButtons := RadioButtons.Length()

VarSetCapacity(pRadioButtons, 4 * cRadioButtons + A_PtrSize * cRadioButtons, 0)
Loop %cRadioButtons% {
    iButtonID := RadioButtons[A_Index][1]
    iButtonText := &(r%A_Index% := RadioButtons[A_Index][2])
    NumPut(iButtonID,   pRadioButtons, (4 + A_PtrSize) * (A_Index - 1), "Int")
    NumPut(iButtonText, pRadioButtons, (4 + A_PtrSize) * A_Index - A_PtrSize, "Ptr")
}

; TASKDIALOGCONFIG structure
x64 := A_PtrSize == 8
NumPut(VarSetCapacity(TDC, x64 ? 160 : 96, 0), TDC, 0, "UInt") ; cbSize
NumPut(DllCall("GetDesktopWindow", "Ptr"), TDC, 4, "Ptr") ; hwndParent
NumPut(Flags, TDC, x64 ? 20 : 12, "Int") ; dwFlags
NumPut(0x9, TDC, x64 ? 24 : 16, "Int") ; dwCommonButtons (TDCBF_OK_BUTTON | TDCBF_CANCEL_BUTTON)
NumPut(&Title, TDC, x64 ? 28 : 20, "Ptr") ; pszWindowTitle
NumPut(MainIcon, TDC, x64 ? 36 : 24, "Ptr") ; pszMainIcon
NumPut(&Instruction, TDC, x64 ? 44 : 28, "Ptr") ; pszMainInstruction
NumPut(&Content, TDC, x64 ? 52 : 32, "Ptr") ; pszContent
NumPut(cRadioButtons, TDC, x64 ? 76 : 48, "UInt") ; cRadioButtons
NumPut(&pRadioButtons, TDC, x64 ? 80 : 52, "Ptr") ; pRadioButtons
NumPut(&ExpandedText, TDC, x64 ? 100 : 64, "Ptr") ; pszExpandedInformation
NumPut(Callback, TDC, (x64) ? 140 : 84) ; pfCallback
NumPut(260, TDC, x64 ? 156 : 92, "UInt") ; cxWidth

DllCall("Comctl32.dll\TaskDialogIndirect", "Ptr", &TDC
    , "Int*", Button := 0
    , "Int*", Radio := 0
    , "Int*", Checked := 0)

If (Button == 1) { ; OK
    CmdParam := Radio == 201 ? "exe" : "ahk"

    Run *RunAs "%A_AhkPath%" /restart "%A_ScriptFullPath%" /%CmdParam%
}

Return ; End of the auto-execute section.

GetErrorMessage(ErrorCode, LanguageId := 0) {
    Local Size, ErrorBuf, ErrorMsg

    Size := DllCall("Kernel32.dll\FormatMessageW"
        ; FORMAT_MESSAGE_ALLOCATE_BUFFER | FORMAT_MESSAGE_FROM_SYSTEM | FORMAT_MESSAGE_IGNORE_INSERTS
        , "UInt", 0x1300
        , "Ptr",  0
        , "UInt", ErrorCode + 0
        , "UInt", LanguageId
        , "Ptr*", ErrorBuf
        , "UInt", 0
        , "Ptr",  0)

    If (!Size) {
        Return ""
    }

    ErrorMsg := StrGet(ErrorBuf, Size, "UTF-16")
    DllCall("Kernel32.dll\LocalFree", "Ptr", ErrorBuf)

    Return ErrorMsg
}

Assoc(Type) {
    Local
    SplitPath A_ScriptDir,, ParentDir

    If (Type == "ahk") {
        AssocPath := """" . A_AhkPath . """ """ . ParentDir . "\Adventure.ahk"""
    } Else { ; exe
        AssocPath := ParentDir . "\Adventure.exe"
    }

    RegWrite REG_SZ, HKCR\AutoHotkeyScript\Shell\Edit\Command,, %AssocPath% "`%1"
    If (ErrorLevel) {
        MsgBox 0x10, Error %A_LastError%, % GetErrorMessage(A_LastError + 0)
    } Else {
        MsgBox 0x40, Default Editor, The operation completed successfully.`n`nSelect "Edit Script" in the context menu of an AutoHotkey script file to open it with Adventure.
    }
}
