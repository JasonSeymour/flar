#!/usr/bin/bash

HOST=`uname -n`
DATESTAMP=`date "+%Y%m%d"`
ARCHIVE_BASE=/flars/
EXCLUDES=${HOST}.excludes

[ ! -d ${ARCHIVE_BASE}/${HOST} ] && mkdir -p ${ARCHIVE_BASE}/${HOST}

[ ! -f ${ARCHIVE_BASE}/${HOST}/${EXCLUDES} ] && printf "/oracle\n/sapdb\n/sapmnt\n/usr/sap\n" > ${ARCHIVE_BASE}/${HOST}/${EXCLUDES}

