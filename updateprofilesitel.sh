#!/bin/bash
#Author: Maynard Louis Prepotente
#Date: October 3, 2019
#Splunk to Liquibase Update Account Profile
#Testing

set -v
#exec 3>&1 4>&2
trap 'exec 2>&4 1>&3' 0 1 2 3

#set parameters
user=$1
profile="/apps/splunk/var/run/splunk/csv/${user}.csv"
#remove quotes on csv file
sed -i 's/\"//g' $profile
#set variables
uname=`cat $profile | tail -n1 | awk -F',' '{ print $1}'`
action=`cat $profile | tail -n1 | awk -F',' '{ print $2}'`
ticket=`cat $profile | tail -n1 | awk -F',' '{ print $3}'`
min=`cat $profile | tail -n1 | awk -F',' '{ print $4}'`
lname=`cat $profile | tail -n1 | awk -F',' '{ print $5}'`
fname=`cat $profile | tail -n1 | awk -F',' '{ print $6}'`
oldMin=`cat $profile | tail -n1 | awk -F',' '{ print $7}'` 
newMin=`cat $profile | tail -n1 | awk -F',' '{ print $8}'` 
kycId=`cat $profile | tail -n1 | awk -F',' '{ print $9}'`
file=`cat $profile | tail -n1 | awk -F',' '{ print $10}'`
srcMin=`cat $profile | tail -n1 | awk -F',' '{ print $11}'`
RRN=`cat $profile | tail -n1 | awk -F',' '{ print $12}'`
updateProfile=`cat $profile | tail -n1 | awk -F',' '{ print $13}'`
updateFName=`cat $profile | tail -n1 | awk -F',' '{ print $14}'`
updateMName=`cat $profile | tail -n1 | awk -F',' '{ print $15}'` 
updateLName=`cat $profile | tail -n1 | awk -F',' '{ print $16}'` 
updateAddressName=`cat $profile | tail -n1 | awk -F',' '{ print $17}'` 
updateAddressValue=`cat $profile | tail -n1 | awk -F',' '{ print $18}'` 
updateAddressType=`cat $profile | tail -n1 | awk -F',' '{ print $19}'` 
updateBirthday=`cat $profile | tail -n1 | awk -F',' '{ print $20}'`
updateEAddress=`cat $profile | tail -n1 | awk -F',' '{ print $21}'`
lq_path="/home/splunk_user/uploads"
lq_file="$lq_path/$file"

#Declare variables
TS=$(date +"%Y-%m-%d")
updateprofile="/apps/splunk/etc/apps/csg/bin/scripts/updateprofile.exp"
dump_path="/apps/splunk/etc/apps/csg/bin/scripts/uploads"
debugFile="/apps/splunk/etc/apps/csg/bin/scripts/logs/updateprofile.debug.$TS"
logFile="/apps/splunk/etc/apps/csg/bin/scripts/logs/updateprofile.${ticket}.log"
scriptDIR="/apps/splunk/etc/apps/csg/bin/scripts"
lookupDIR="/apps/splunk/etc/apps/csg/lookups"
resultfile="/apps/splunk/etc/apps/csg/lookups/updateprofile_${uname}_result.csv"

if [ ! -f "$profile" ] || [ -z "$ticket" ]; then
	exit;
fi

exec 1>> $debugFile 2>&1

updateaccount() {
        rm  $lookupDIR/updateprofile_${uname}_result.csv
        cd /apps/splunk/etc/apps/csg/bin/scripts/
        ./updateprofile.exp "$uname" "$count" "$ticket" "$min" "$lname" "$fname" "$oldMin" "$newMin" "$kycId" "$lq_file" "$srcMin" "$RRN" "$updateFName" "$updateMName" "$updateLName" "$updateAddressName" "$updateAddressValue" "$updateAddressType" "$updateBirthday" "$updateEAddress" "$updateProfile" "$logFile" 
}

cleanfile() {
 dos2unix $dump_path/$file
}
uploadfile() {
 echo $dump_path/$file
 scp $dump_path/$file splunk_user@172.18.106.177:/home/splunk_user/uploads/.
}


case $updateProfile in 
     tab_update_name)
     updateProfile=1
     ;;
     tab_update_address)
     updateProfile=2
     ;;
     tab_update_birthday)
     updateProfile=3
     ;;
     tab_update_eaddress)
     updateProfile=4
     ;;	
     *)
     updateProfile=0
     ;;
esac

echo $TS $logFile

case $action in 

	block_and_create_new_virtual_account)
	count=1
	;;
	cancel_account)
	count=2
	;;
	min_reassignment)
	count=3
	;;
	update_profile)
	count=4
	;;
	fix_plus_account_already_exist)
	count=5
	;;
	bulk_permanent_blocking)
	count=6
	;;
	fix_overridden_accounts)
	count=7
	;;
	lift_dedup_account)
	count=8
	;;
	lift_closed_account)
	count=9
	;;
	downgrade_kyc1)
	count=10
	;;
	lift_blacklisted_account)
	count=11
	;;
	suspend_accounts)
	count=12
	;;
	lift_suspended_accounts)
	count=13
	;;
	rema_claim_transaction_update)
	count=14
	;;
	bulk_blocking_accounts_cms)
	count=15
	;;
	batch_cms_suspension)
	count=16
	;;
	check_cms_status)
	count=17
	;;
esac

case $count in 
	1|2|3|4|5|10|14)
	updateaccount 
	;;
	6|7|8|9|11|12|13)
	cleanfile
	uploadfile	
	updateaccount
	;;
	15)
	cleanfile
	rm $lookupDIR/updateprofile_${uname}_result.csv
	sh -x ${scriptDIR}/.cms_fraud.sh $file | tee $logFile
        rm $dump_path/*sql
	;;
	16)
	cleanfile
	rm $lookupDIR/updateprofile_${uname}_result.csv
	sh -x ${scriptDIR}/.cms_abusive.sh $file | tee $logFile
        rm $dump_path/*sql
	;;
	17)
	cleanfile
	rm $lookupDIR/updateprofile_${uname}_result.csv
	rm $lookupDIR/updateprofile_${uname}_cmsresult.csv
        cd ${scriptDIR}
        sh -x .check_cms_status.sh $dump_path $file | tee $lookupDIR/updateprofile_${uname}_cmsresult.csv
	;;

esac

echo "Transaction completed at $TS"
sh ${scriptDIR}/.audit_logger.sh $profile
