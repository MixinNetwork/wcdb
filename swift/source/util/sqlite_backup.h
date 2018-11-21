#ifndef sqlite_backup_h
#define sqlite_backup_h

#ifdef __cplusplus
extern "C" {
#endif

#include <stdlib.h>
#import <sqlcipher/sqlite3.h>

/*
 ** Perform an online backup of database pDb to the database file named
 ** by zFilename. This function copies 5 database pages from pDb to
 ** zFilename, then unlocks pDb and sleeps for 250 ms, then repeats the
 ** process until the entire database is backed up.
 **
 ** The third argument passed to this function must be a pointer to a progress
 ** function. After each set of 5 pages is backed up, the progress function
 ** is invoked with two integer parameters: the number of pages left to
 ** copy, and the total number of pages in the source file. This information
 ** may be used, for example, to update a GUI progress bar.
 **
 ** While this function is running, another thread may use the database pDb, or
 ** another process may access the underlying database file via a separate
 ** connection.
 **
 ** If the backup process is successfully completed, SQLITE_OK is returned.
 ** Otherwise, if an error occurs, an SQLite error code is returned.
 */
int backupDb(
             sqlite3 *pDb,               /* Database to back up */
             const char *zFilename,      /* Name of file to back up to */
             void(*xProgress)(int, int)  /* Progress function to invoke */
);

#endif /* sqlite_backup_h */
