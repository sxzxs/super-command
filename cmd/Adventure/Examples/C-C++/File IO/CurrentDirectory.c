#include <windows.h> 
#include <stdio.h>
#include <tchar.h>
#define BUFSIZE MAX_PATH

void _tmain(int argc, TCHAR **argv)
{
    TCHAR Buffer[BUFSIZE];
    DWORD dwRet;

    if (argc != 2) {
        _tprintf(TEXT("Usage: %s <dir>\n"), argv[0]);
        return;
    }

    dwRet = GetCurrentDirectory(BUFSIZE, Buffer);

    if (dwRet == 0) {
        printf("GetCurrentDirectory failed (%d)\n", GetLastError());
        return;
    }

    if (dwRet > BUFSIZE) {
        printf("Buffer too small; need %d characters\n", dwRet);
        return;
    }

    if (!SetCurrentDirectory(argv[1])) {
        printf("SetCurrentDirectory failed (%d)\n", GetLastError());
        return;
    }

    _tprintf(TEXT("Set current directory to %s\n"), argv[1]);

    if (!SetCurrentDirectory(Buffer)) {
        printf("SetCurrentDirectory failed (%d)\n", GetLastError());
        return;
    }

    _tprintf(TEXT("Restored previous directory (%s)\n"), Buffer);
}
