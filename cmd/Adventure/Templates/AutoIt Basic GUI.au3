#include <GUIConstantsEx.au3>

Local $hGUI = GUICreate("Title", 800, 400)
GUISetState(@SW_SHOW, $hGUI)

Local $iMsg = 0
While 1
    $iMsg = GUIGetMsg()
    Switch $iMsg
        Case $GUI_EVENT_CLOSE
            ExitLoop
    EndSwitch
WEnd

GUIDelete($hGUI)
