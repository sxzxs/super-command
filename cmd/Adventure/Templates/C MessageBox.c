#define UNICODE
#define WIN32_LEAN_AND_MEAN
#include <windows.h>
#include <tchar.h>

#pragma comment(lib, "user32")

#pragma comment(linker,"\"/manifestdependency:type='win32' \
name='Microsoft.Windows.Common-Controls' version='6.0.0.0' \
processorArchitecture='*' publicKeyToken='6595b64144ccf1df' language='*'\"")

int APIENTRY _tWinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance, LPSTR lpCmdLine, int nCmdShow) {

    MessageBox(0, TEXT("Message"), TEXT("Title"), MB_OK | MB_ICONINFORMATION);

    return 0;
}
