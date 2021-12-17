' FreeBASIC Win32 GUI

#include once "windows.bi"
'#include once "win/commctrl.bi"

Dim Shared hInstance As HINSTANCE
hInstance = GetModuleHandle(NULL)

'Dim iccx As INITCOMMONCONTROLSEX
'iccx.dwSize = Len(iccx)
'iccx.dwICC  = ICC_DATE_CLASSES
'InitCommonControlsEx(@iccx)

' Window procedure handler
Function WndProc(ByVal hWnd As HWND, _
                 ByVal uMsg As UINT, _
                 ByVal wParam As WPARAM, _
                 ByVal lParam As LPARAM) As Integer

    Function = 0

    Select Case (uMsg)
    Case WM_CREATE

    Case WM_KEYDOWN
        If (LoByte(wParam) = VK_ESCAPE) Then
            PostMessage(hWnd, WM_CLOSE, 0, 0)
        End If

    Case WM_DESTROY
        PostQuitMessage(0)
        Exit Function
    End Select

    Function = DefWindowProc(hWnd, uMsg, wParam, lParam)

End Function

    ' Program entry
    Dim wcls As WNDCLASSEX
    Dim hWnd As HWND
    Dim wMsg As MSG

    Dim appName As String
    appName = "FB_Win32GUI"

    With wcls
        .hInstance     = hInstance
        .lpszClassName = StrPtr(appName)
        .lpfnWndProc   = @WndProc
        .style         = CS_HREDRAW or CS_VREDRAW or CS_DBLCLKS
        .cbSize        = SizeOf(WNDCLASSEX)
        .hIcon         = LoadIcon(NULL, IDI_APPLICATION)
        .hIconSm       = LoadIcon(NULL, IDI_APPLICATION)
        .hCursor       = LoadCursor(NULL, IDC_ARROW)
        .lpszMenuName  = NULL
        .cbClsExtra    = 0
        .cbWndExtra    = 0
        .hbrBackground = Cast(HBRUSH, 5)
    End With

    If (RegisterClassEx(@wcls) = FALSE) Then
        MessageBox(NULL, "Failed to register window class!", appName, MB_ICONERROR)
        End 1
    End If

    hWnd = CreateWindowEx(0, appName, "Win32 GUI", _
                          WS_OVERLAPPEDWINDOW or WS_VISIBLE or WS_CLIPCHILDREN, _
                          CW_USEDEFAULT, CW_USEDEFAULT, 680, 480, _
                          NULL, NULL, hInstance, NULL)

    ' Messages loop
    Do Until (GetMessage(@wMsg, NULL, 0, 0) = FALSE)
        TranslateMessage(@wMsg)
        DispatchMessage(@wMsg)
    Loop

    End 0
