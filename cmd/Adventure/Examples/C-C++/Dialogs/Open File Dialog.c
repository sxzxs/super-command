#define UNICODE
#define WIN32_LEAN_AND_MEAN

#include <windows.h>
#include <commdlg.h>
#include <tchar.h>

#pragma comment(lib, "user32")
#pragma comment(lib, "comdlg32")

#pragma comment(linker,"\"/manifestdependency:type='win32' \
name='Microsoft.Windows.Common-Controls' version='6.0.0.0' \
processorArchitecture='*' publicKeyToken='6595b64144ccf1df' language='*'\"")

int APIENTRY _tWinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance, LPSTR lpCmdLine, int nCmdShow)
{
    TCHAR file_buf[65535];
    BOOL result;

    OPENFILENAME ofn = {0};
    ofn.lStructSize = sizeof(OPENFILENAME);
    ofn.lpstrTitle = TEXT("Select file");
    ofn.lpstrFilter = TEXT("All Files (*.*)\0*.*\0Text Documents (*.txt)\0*.txt\0");
    ofn.lpstrFile = file_buf;
    ofn.nMaxFile = sizeof(file_buf) - 1;
    ofn.lpstrInitialDir = NULL;
    ofn.Flags = OFN_HIDEREADONLY | OFN_EXPLORER;
    result = GetOpenFileName(&ofn);

    if (result) {
        MessageBox(0, file_buf, TEXT("Selected file"), MB_OK | MB_ICONINFORMATION);
    }
    
    return 0;
}
