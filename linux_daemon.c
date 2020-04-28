
#include <stdio.h>
#include <stdbool.h>
#include <stdint.h>
#include <stdlib.h>
#include <stdarg.h>
#include <string.h>

#include <unistd.h>

#include <syslog.h>

#include <sys/types.h>
#include <sys/stat.h>

#include "app_interface.h"

static bool foreground = false;


void fatal(char *fmt, ...)
{
    char buf[128];
    va_list ap;

    va_start(ap, fmt);
    vsnprintf(buf, sizeof(buf), fmt, ap);
    va_end(ap);

    fprintf(stderr, "%s\n", buf);

    fflush(stderr);

    exit(EXIT_FAILURE);
}


static void init_opts(int argc, char * argv[])
{
    int opt;

    while((opt = getopt(argc, argv, "g")) != -1)
    {
        switch(opt)
        {
            case 'g':
                foreground = 1;
                break;
        }
    }
}


int main(int argc, char **argv)
{
    FILE *f = NULL;
    int fn = 0;
    int app_ret = EXIT_SUCCESS;

    init_opts(argc, argv);

    if(!foreground) {

        pid_t pid;

        /* Fork off the parent process */

        pid = fork();

        if (pid < 0) { exit(EXIT_FAILURE); }

        /* If we got a good PID, then we can exit the parent process. */

        if (pid > 0) { exit(EXIT_SUCCESS); }

        /* Change the file mode mask */

        umask(0);

        /* Open any logs here */

        /* NONE */

        /*  Create a new SID for the child process */

        if (setsid() < 0) fatal("setsid failed (%m)");

        /* Change the current working directory */

        if ((chdir("/")) < 0) fatal("chdir failed (%m)");

        /* Close out the standard file descriptors */
        setbuf (stdout,NULL);

        f = popen("logger", "w");
        if(!f) { exit(EXIT_FAILURE); }

        fn = fileno(f);
        dup2(fn, STDOUT_FILENO);
        dup2(fn, STDERR_FILENO);

        // fclose(stdin);
        // fclose(stdout);
    }

    app_ret = app_main(argc, argv);

    if(!foreground)
    {
        pclose(f);
    }

    return app_ret;
}
