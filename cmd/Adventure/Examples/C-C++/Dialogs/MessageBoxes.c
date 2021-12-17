#define UNICODE
#define WIN32_LEAN_AND_MEAN
#include <windows.h>
#include <commctrl.h>
#include <tchar.h>

#pragma comment(lib, "user32")
#pragma comment(lib, "comctl32")

#pragma comment(linker,"\"/manifestdependency:type='win32' \
name='Microsoft.Windows.Common-Controls' version='6.0.0.0' \
processorArchitecture='*' publicKeyToken='6595b64144ccf1df' language='*'\"")

typedef int (*MESSAGEBOXTIMEOUT)(HWND, LPCTSTR, LPCTSTR, UINT, WORD, DWORD);

int APIENTRY _tWinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance, LPSTR lpCmdLine, int nCmdShow) {
    HMODULE hMod, hLib;
    MSGBOXPARAMS lpmbp;
    MESSAGEBOXTIMEOUT MessageBoxTimeout;
    int nButtonPressed = 0;

    // MessageBox
    MessageBox(0, TEXT("A simple message box."), TEXT("MessageBox"), MB_OK | MB_ICONINFORMATION);

    // MessageBoxTimeout
    hMod = GetModuleHandle(TEXT("user32.dll"));
    if (hMod != NULL) {
        MessageBoxTimeout = (MESSAGEBOXTIMEOUT) GetProcAddress(hMod, "MessageBoxTimeoutW");
        if (MessageBoxTimeout != NULL) {
            MessageBoxTimeout(0
            , TEXT("This message box will close automatically after 3 seconds.")
            , TEXT("MessageBoxTimeout")
            , MB_OK | MB_ICONWARNING, 0
            , 3000);
        }
    }

    // MessageBoxIndirect
    hLib = LoadLibraryEx(TEXT("imageres.dll"), 0, LOAD_LIBRARY_AS_DATAFILE); // Icon resource
    lpmbp.cbSize = sizeof (MSGBOXPARAMS);
    lpmbp.hwndOwner = NULL;
    lpmbp.hInstance = hLib;
    lpmbp.lpszText = TEXT("Message box with custom icon.");
    lpmbp.lpszCaption = TEXT("MessageBoxIndirect");
    lpmbp.dwStyle = MB_USERICON;
    lpmbp.lpszIcon = MAKEINTRESOURCE(114);

    MessageBoxIndirect(&lpmbp);

    FreeLibrary(hLib);

    // TaskDialog
    if (TaskDialog(GetDesktopWindow(), NULL, TEXT("Task Dialog"), TEXT("Main Instruction"), TEXT("Content")
    , TDCBF_OK_BUTTON | TDCBF_CANCEL_BUTTON, MAKEINTRESOURCE(144), &nButtonPressed) == S_OK) {
        OutputDebugString(nButtonPressed == IDOK ? TEXT("OK button pressed.") : TEXT("Cancel pressed."));
    }

    return 0;
}
