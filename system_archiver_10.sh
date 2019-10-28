#!/usr/bin/bash

HOST=`uname -n`
DATESTAMP=`date "+%Y%m%d"`
ARCHIVE_BASE=/flars/
EXCLUDES=${HOST}.excludes

HOSTVER=$(uname -r)
case $HOSTVER in
	5.10) printf "Solaris 10 system detected so proceeding to archive\n"
	      ;;
	5.11) printf "Solaris 11 system detected so aborting\n"
	      exit 1
	      ;;
esac

[ ! -d ${ARCHIVE_BASE}/${HOST} ] && mkdir -p ${ARCHIVE_BASE}/${HOST}

[ ! -f ${ARCHIVE_BASE}/${HOST}/${EXCLUDES} ] && printf "/oracle\n/sapdb\n/sapmnt\n/usr/sap\n" > ${ARCHIVE_BASE}/${HOST}/${EXCLUDES}

eval "flarcreate -R / -X ${ARCHIVE_BASE}/${HOST}/${EXCLUDES} -L cpio -n ${HOST} ${ARCHIVE_BASE}/${HOST}/${HOST}.${DATESTAMP}.flar"

if [ $? -eq 0 ]
then
	printf "Successfully created flar image file\n"
else
	printf "There was an error while creating the flar image file\n"
fi
 exit 0
