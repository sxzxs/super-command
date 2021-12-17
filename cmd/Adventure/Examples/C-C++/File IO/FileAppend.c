#include <windows.h>
#include <tchar.h>
#include <stdio.h>

int __cdecl _tmain(int argc, TCHAR *argv[])
{
    HANDLE hFile;
    char DataBuffer[] = "This is some test data to write to the file.\n";
    DWORD dwBytesToWrite = (DWORD)strlen(DataBuffer);
    DWORD dwBytesWritten;
    BOOL bError = FALSE;

    // Open the existing file, or if the file does not exist,
    // create a new file.
    hFile = CreateFile(TEXT("Log.txt"), // open Log.txt
            FILE_APPEND_DATA,           // open for writing
            0,                          // do not share
            NULL,                       // no security
            OPEN_ALWAYS,                // open or create
            FILE_ATTRIBUTE_NORMAL,      // normal file
            NULL);                      // no attr. template

    if (hFile == INVALID_HANDLE_VALUE) {
        printf("Could not open Log.txt.\n");
        return 1;
    }

    bError = WriteFile(hFile,           // open file handle
                       DataBuffer,      // start of data to write
                       dwBytesToWrite,  // number of bytes to write
                       &dwBytesWritten, // number of bytes that were written
                       NULL);           // no overlapped structure

    if (bError == FALSE || dwBytesWritten != dwBytesToWrite) {
        printf("Error saving file.\n");
        return 2;
    }

    CloseHandle(hFile);
    return 0;
}
