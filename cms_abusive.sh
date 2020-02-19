#!/bin/bash
#Author: Maynard Louis E. Prepotente
#Date: November 15,2019

set -vx

pDate=`date +%Y%m`
lDate=`date '+%d/%m/%y %H:%M'`

fileDIR=/apps/splunk/etc/apps/csg/bin/scripts/uploads
logDIR=/apps/splunk/etc/apps/csg/bin/scripts/log
abusiveDIR=/home/cms_user/scripts/BLOCKING_OF_ABUSIVE_ACCOUNTS

file=$1
filedate=$(echo "$file" | cut -f 1 -d '.')


if [ ! -f $fileDIR/$file  ]
then
  echo "${lDate} File not found."
  exit 1
fi

echo "${lDate} Processing ${file}..."

   filename="insert_fraud_msisdn_${filedate}"
   echo ${filename}
   cnt=0
   filenum=1

  #script in creating insert script
  echo "${lDate} creating insert script... " | tee -a ${logFILE}

    DONE=false
    until $DONE; do
            read x || DONE=true
             ((cnt=cnt+1))
     		min=`echo ${x} | cut -c 4-`
     		echo "insert into gtt_reports values ('${min}');" >> ${fileDIR}/${filename}_${filenum}.sql
         	if [ $cnt -eq 50000 ]; then
       		filenum=`expr "$filenum" + 1`
       		cnt=0
         	fi
    done < ${fileDIR}/${file}


#Create SQL Script

echo "@${filename}_${filenum}.sql" >> ${fileDIR}/UNICARD_APPS_SPLUNK.sql
echo "@batch_acct_cancellation_blocking_of_abusive_accounts.sql" >> ${fileDIR}/UNICARD_APPS_SPLUNK.sql
echo "@Blocked_accounts_script.sql" >> ${fileDIR}/UNICARD_APPS_SPLUNK.sql
echo "exit;" >> ${fileDIR}/UNICARD_APPS_SPLUNK.sql

#Dump files to CMS
scp ${fileDIR}/${filename}_${filenum}.sql cms_user@10.133.200.66:$abusiveDIR
scp ${fileDIR}/UNICARD_APPS_SPLUNK.sql cms_user@10.133.200.66:$abusiveDIR

#Execute CMS script
ssh  cms_user@10.133.200.66 /bin/bash -x /home/cms_user/scripts/.BLOCKING_OF_ABUSIVE_ACCOUNTS_SPLUNK.sh
