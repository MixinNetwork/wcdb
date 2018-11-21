//
//  sqlite_backup.c
//  WCDB.swift
//
//  Created by tangjun on 2018/11/21.
//  Copyright © 2018年 sanhuazhang. All rights reserved.
//

#include "sqlite_backup.h"

int backupDb(
             sqlite3 *pDb,               /* Database to back up */
             const char *zFilename,      /* Name of file to back up to */
             void(*xProgress)(int, int)  /* Progress function to invoke */
){
    int rc;                     /* Function return code */
    sqlite3 *pFile;             /* Database connection opened on zFilename */
    sqlite3_backup *pBackup;    /* Backup handle used to copy data */

    /* Open the database file identified by zFilename. */
    rc = sqlite3_open(zFilename, &pFile);
    if( rc==SQLITE_OK ){

        /* Open the sqlite3_backup object used to accomplish the transfer */
        pBackup = sqlite3_backup_init(pFile, "main", pDb, "main");
        if( pBackup ){

            /* Each iteration of this loop copies 5 database pages from database
             ** pDb to the backup database. If the return value of backup_step()
             ** indicates that there are still further pages to copy, sleep for
             ** 250 ms before repeating. */
            do {
                rc = sqlite3_backup_step(pBackup, 50);
                xProgress(
                          sqlite3_backup_remaining(pBackup),
                          sqlite3_backup_pagecount(pBackup)
                          );
                if( rc==SQLITE_OK || rc==SQLITE_BUSY || rc==SQLITE_LOCKED ){
                    sqlite3_sleep(100);
                }
            } while( rc==SQLITE_OK || rc==SQLITE_BUSY || rc==SQLITE_LOCKED );

            /* Release resources allocated by backup_init(). */
            (void)sqlite3_backup_finish(pBackup);
        }
        rc = sqlite3_errcode(pFile);
    }

    /* Close the database connection opened on database file zFilename
     ** and return the result of this function. */
    (void)sqlite3_close(pFile);
    return rc;
}
