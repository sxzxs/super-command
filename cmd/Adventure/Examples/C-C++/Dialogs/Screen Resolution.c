#define UNICODE
#include <windows.h>
#include <tchar.h>
#include <strsafe.h>

#pragma comment(lib, "user32")

#pragma comment(linker,"\"/manifestdependency:type='win32' \
name='Microsoft.Windows.Common-Controls' version='6.0.0.0' \
processorArchitecture='*' publicKeyToken='6595b64144ccf1df' language='*'\"")

int APIENTRY _tWinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance, LPSTR lpCmdLine, int nCmdShow) {
    TCHAR pszDest[40]; 
    size_t cchDest = 40;

    TCHAR* pszTxt = TEXT("Screen resolution: ");
    LPCTSTR pszFormat = TEXT("%s %d x %d.\n");

    int cxScreen = GetSystemMetrics(SM_CXSCREEN);
    int cyScreen = GetSystemMetrics(SM_CYSCREEN);

    HRESULT hr = StringCchPrintf(pszDest, cchDest, pszFormat, pszTxt, cxScreen, cyScreen);

    MessageBox(NULL, (LPCTSTR)pszDest, TEXT("Information"), MB_ICONINFORMATION);

    return 0;
}
