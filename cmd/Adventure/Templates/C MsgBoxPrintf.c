#define UNICODE
#include <windows.h>
#include <wchar.h>

#pragma comment(lib, "user32")

#pragma comment(linker,"\"/manifestdependency:type='win32' \
name='Microsoft.Windows.Common-Controls' version='6.0.0.0' \
processorArchitecture='*' publicKeyToken='6595b64144ccf1df' language='*'\"")

int CDECL MsgBoxPrintf(wchar_t *szCaption, wchar_t *szFormat, ...)
{
    wchar_t szBuffer[1024];
    va_list pArgList;

    va_start(pArgList, szFormat);
    vswprintf(szBuffer, sizeof(szBuffer) / sizeof(wchar_t), szFormat, pArgList);
    va_end(pArgList);

    return MessageBoxW(NULL, szBuffer, szCaption, 0);
}

int APIENTRY wWinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance, LPSTR lpCmdLine, int nCmdShow)
{
    MsgBoxPrintf(L"Title", L"%d", 1);
    return 0;
}
