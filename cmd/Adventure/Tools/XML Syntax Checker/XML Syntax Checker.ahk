; XML Syntax Checker 1.0.0

#SingleInstance Force
#NoEnv
SetWorkingDir %A_ScriptDir%
SetBatchLines -1

; Prompt for filename if it isn't specified on command line
If (!A_Args.Length() || !FileExist(A_Args[1])) {
    FileSelectFile XmlFile, 3,, Select XML File, XML Files (*.xml)
    If (ErrorLevel) {
        ExitApp
    }

} Else {
    XmlFile := A_Args[1]
}

If (LoadXMLEx(x, XmlFile)) {
    SplitPath XmlFile, Filename
    MsgBox 0x40, XML Syntax Checker, No error found in file "%Filename%".
}

ExitApp

LoadXMLEx(ByRef oXML, Fullpath) {
    oXML := ComObjCreate("MSXML2.DOMDocument.6.0")
    oXML.async := False

    If (!oXML.load(Fullpath)) {
        MsgBox 0x10, Error, % "Failed to load XML file."
        . "`n`nFilename: """ . Fullpath . """"
        . "`n`nError: " . Format("0x{:X}", oXML.parseError.errorCode & 0xFFFFFFFF)
        . "`n`nReason: " . oXML.parseError.reason
        Return 0
    }

    Return 1
}
