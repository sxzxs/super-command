#include <stdio.h>
#include <time.h>

int main() {
    FILE *pFile;
    time_t now;
    struct tm *ts;
    char buf[100];

    // Get the current time
    now = time(NULL);
    ts = localtime(&now);

    // Format the string
    strftime(buf, sizeof(buf), "%A %Y-%m-%d %H:%M:%S\n", ts);

    // Open the file to append data
    pFile = fopen("LogTime.txt", "a");

    if (pFile != NULL) {
        fputs(buf, pFile);
        fclose(pFile);
    }

    return 0;
}
