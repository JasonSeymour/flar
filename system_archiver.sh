#!/usr/bin/bash

HOST=`uname -n`
DATESTAMP=`date "+%Y%m%d"`
ARCHIVE_BASE=/flars/
EXCLUDES=${HOST}.excludes

[ ! -d ${ARCHIVE_BASE}/${HOST} ] && mkdir -p ${ARCHIVE_BASE}/${HOST}

[ ! -f ${ARCHIVE_BASE}/${HOST}/${EXCLUDES} ] && printf "/oracle\n/sapdb\n/sapmnt\n/usr/sap\n" > ${ARCHIVE_BASE}/${HOST}/${EXCLUDES}

FSTYPE=$(df -n / | awk '{print $3}')

case $FSTYPE in
	ufs) printf "Root filesystem is ufs\n"
	     eval "flarcreate -R / -X ${ARCHIVE_BASE}/${HOST}/${EXCLUDES} -L cpio -n ${HOST} ${ARCHIVE_BASE}/${HOST}/${HOST}.${DATESTAMP}.flar"
	     printf "FLAR created\n"
	     ;;
esac

