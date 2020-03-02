#!/bin/bash
#Author: Maynard Louis E. Prepotente
#Date: Nov 28, 2019

TS=$(date +"%Y-%m-%d %H:%M:%S")
fDate=$(date +"%Y-%m-%d")
logDIR="/apps/splunk/etc/apps/csg/bin/scripts/logs"
profile="$1"
updateprofile="/apps/splunk/etc/apps/csg/bin/scripts/updateprofile.exp"
dump_path="/apps/splunk/etc/apps/csg/bin/scripts/uploads"
lq_path="/home/splunk_user/uploads"
trail="/apps/splunk/etc/apps/csg/bin/scripts/logs/updateprofile_audit.log.${fDate}"

#remove quotes on csv file
sed -i 's/\"//g' $profile
#variables
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
lq_file="$lq_path/$file"
logfile="/apps/splunk/etc/apps/csg/bin/scripts/logs/updateprofile.${ticket}.log"
resultfile="/apps/splunk/etc/apps/csg/lookups/updateprofile_${uname}_result.csv"

echo "TIMESTAMP: $TS" | tee $resultfile
echo "USERNAME = $uname" | tee $resultfile
echo "TICKET = $ticket" | tee $resultfile


case $action in 
	block_and_create_new_virtual_account)
    echo "ACTION = virtual_card_replacement" | tee $resultfile
	echo "DETAILS = \"MIN: $min\"" | tee $resultfile
        x=$(cat $logfile | grep -c "DONE BLOCKING AND CREATING NEW VIRTUAL ACCOUNT.")
	if [ $x -eq 0 ]; then
    ERROR=$(cat $logfile | egrep -i "ERROR|INFO|NOTICE")
        echo "STATUS = FAILED" | tee $resultfile
        echo "$ERROR" | tee $resultfile
	else
	echo "STATUS = SUCCESSFUL" | tee $resultfile
	fi
	;;
	cancel_account)
    echo "ACTION = min_deregistration_from_account" | tee $resultfile
	echo "DETAILS = \"MIN: $min\"" | tee $resultfile
        x=$(cat $logfile | grep -c "DONE WITH ACCOUNT CANCELLATION.")
        if [ $x -eq 0 ]; then
        ERROR=$(cat $logfile | egrep -i "ERROR|INFO|NOTICE")
            echo "STATUS = FAILED" | tee $resultfile
            echo "$ERROR" | tee $resultfile
        else
        echo "STATUS = SUCCESSFUL" | tee $resultfile
        fi
        ;;
	min_reassignment)
    echo "ACTION = min_reassignment" | tee $resultfile
	echo "DETAILS = \"OLD MIN: $oldMin NEW MIN: $newMin\"" | tee $resultfile
	x=$(cat $logfile | grep -c "Successfully updated MIN in identity management service")
        if [ $x -eq 0 ]; then
        ERROR=$(cat $logfile | egrep -i "ERROR|INFO|NOTICE")
            echo "STATUS = FAILED" | tee $resultfile
            echo "$ERROR" | tee $resultfile
        else
        echo "STATUS = SUCCESSFUL" | tee $resultfile
	fi
	;;
	update_profile)
        case $updateProfile in 
	     tab_update_name)
             echo "ACTION = update_profile" | tee $resultfile
	         echo "DETAILS = \"MIN: $min FIRST NAME: $updateFName MIDDLE NAME: $updateMName LAST NAME: $updateLName\"" >> $resultfile
             x=$(cat $logfile | grep -c "Done updating the name of the user in the database.")
             if [ $x -eq 0 ]; then
             ERROR=$(cat $logfile | egrep -i "ERROR|INFO|NOTICE")
                echo "STATUS = FAILED" | tee $resultfile
                echo "$ERROR" | tee $resultfile
             else
             echo "STATUS = SUCCESSFUL" | tee $resultfile
             fi
             ;;
	     tab_update_address)
             echo "ACTION = update_profile" | tee $resultfile
	         echo "DETAILS = \"MIN: $min ADDRESS FIELD: $updateAddressName ADDRESS VALUE: $updateAddressValue TYPE: $updateAddressType\"" >> $resultfile
             x=$(cat $logfile | grep -c "DONE UPDATING ADDRESS.")
             if [ $x -eq 0 ]; then
             ERROR=$(cat $logfile | egrep -i "ERROR|INFO|NOTICE")
                echo "STATUS = FAILED" | tee $resultfile
                echo "$ERROR" | tee $resultfile
             else
             echo "STATUS = SUCCESSFUL" | tee $resultfile
             fi 
	     ;;
	     tab_update_birthday)
             echo "ACTION = update_profile" | tee $resultfile
             echo "DETAILS = \"MIN: $min NEW BIRTHDAY: $updateBirthday\"" | tee $resultfile
             x=$(cat $logfile | grep -c "Done updating birthday.")
             if [ $x -eq 0 ]; then
             ERROR=$(cat $logfile | egrep -i "ERROR|INFO|NOTICE")
                echo "STATUS = FAILED" | tee $resultfile
                echo "$ERROR" | tee $resultfile
             else
             echo "STATUS = SUCCESSFUL" | tee $resultfile
             fi
	     ;;
	     tab_update_eaddress)
             echo "ACTION = update_profile" | tee $resultfile
             x=$(cat $logfile | grep -c "Done updating email.")
	     y=$(grep -E -o "\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,6}\b" $logfile | head -n1)
	     echo "DETAILS = \"MIN: $min OLD EMAIL: $y NEW EMAIL: $updateEAddress\"" >> $resultfile
	     if [ $x -eq 0 ]; then
             ERROR=$(cat $logfile | egrep -i "ERROR|INFO|NOTICE")
                echo "STATUS = FAILED" | tee $resultfile
                echo "$ERROR" | tee $resultfile
             else
             echo "STATUS = SUCCESSFUL" | tee $resultfile
             fi
	     ;;	
	     *)
     	     ;;
	esac
	;;
	downgrade_kyc1)
	x=$(cat $logfile | grep -c "transaction_reference_no")
	y=$(cat $logfile | grep "transaction_reference_no")
    echo "ACTION = downgrade_kyc1" | tee $resultfile
        if [ $x -eq 0 ]; then
	echo "DETAILS = \"MIN: $min \"" | tee $resultfile
        ERROR=$(cat $logfile | egrep -i "ERROR|INFO|NOTICE")
                echo "STATUS = FAILED" | tee $resultfile
                echo "$ERROR" | tee $resultfile
        else
	echo "DETAILS = \"MIN: $min $y\"" | tee $resultfile
        echo "STATUS = SUCCESSFUL" | tee $resultfile
        fi	
	;;
	rema_claim_transaction_update)
    echo "ACTION = rema_status_update" | tee $resultfile
	echo "DETAILS = \"file: $file | SRCMIN: $srcMin RRN: $RRN \"" | tee $resultfile
        x=$(cat $logfile | grep -c "DB record claim_flag")
        if [ $x -eq 0 ]; then
        ERROR=$(cat $logfile | egrep -i "ERROR|INFO|NOTICE")
                echo "STATUS = FAILED" | tee $resultfile
                echo "$ERROR" | tee $resultfile
        else
        echo "STATUS = SUCCESSFUL" | tee $resultfile
        fi
	;;
	bulk_permanent_blocking)
    echo "ACTION = batch_efs_closure" | tee $resultfile
	echo "DETAILS = \"file: $file | Check output for list of blocked MINs\"" | tee $resultfile
        x=$(cat $logfile | grep -c "not_activated")
        if [ $x -eq 0 ]; then
        ERROR=$(cat $logfile | egrep -i "ERROR|INFO|NOTICE")
                echo "STATUS = FAILED" | tee $resultfile
                echo "$ERROR" | tee $resultfile
        else
        echo "STATUS = SUCCESSFUL" | tee $resultfile
        fi
        ;;
	bulk_blocking_accounts_cms)
    echo "ACTION = batch_cms_closure" | tee $resultfile
	echo "DETAILS = \"file: $file | Check output for list of blocked MINs\"" | tee $resultfile
        x=$(cat $logfile | grep -c "procedure successfully completed.")
        if [ $x -eq 0 ]; then
        ERROR=$(cat $logfile | egrep -i "ERROR|INFO|NOTICE")
                echo "STATUS = FAILED" | tee $resultfile
                echo "$ERROR" | tee $resultfile
        else
        echo "STATUS = SUCCESSFUL" | tee $resultfile
        fi	
        ;;
	lift_dedup_account)
    echo "ACTION = lift_dedupped_accounts_in_efs" | tee $resultfile
	echo "DETAILS = \"file: $file | Check output for list of MINs\"" | tee $resultfile
        x=$(cat $logfile | grep -c "Updated account_status to ACTIVE")
        if [ $x -eq 0 ]; then
        ERROR=$(cat $logfile | egrep -i "ERROR|INFO|NOTICE")
                echo "STATUS = FAILED" | tee $resultfile
                echo "$ERROR" | tee $resultfile
        else
        echo "STATUS = SUCCESSFUL" | tee $resultfile
        fi
        ;;
	lift_closed_account)
    echo "ACTION = lift_closed_accounts_in_efs" | tee $resultfile
	echo "DETAILS = \"file: $file | Check output for list of MINs\"" | tee $resultfile
        x=$(cat $logfile | grep -c "Updated account_status to ACTIVE")
        if [ $x -eq 0 ]; then
        ERROR=$(cat $logfile | egrep -i "ERROR|INFO|NOTICE")
                echo "STATUS = FAILED" | tee $resultfile
                echo "$ERROR" | tee $resultfile
        else
        echo "STATUS = SUCCESSFUL" | tee $resultfile
        fi
        ;;
	lift_blacklisted_account)
    echo "ACTION = lift_blacklisted_accounts_in_efs" | tee $resultfile
	echo "DETAILS = \"file: $file | Check output for list of MINs\"" | tee $resultfile
        x=$(cat $logfile | grep -c "Updated account_status to ACTIVE")
        if [ $x -eq 0 ]; then
        ERROR=$(cat $logfile | egrep -i "ERROR|INFO|NOTICE")
                echo "STATUS = FAILED" | tee $resultfile
                echo "$ERROR" | tee $resultfile
        else
        echo "STATUS = SUCCESSFUL" | tee $resultfile
        fi
	;;
    suspend_accounts)
    echo "ACTION = batch_efs_suspension" | tee $resultfile
	echo "DETAILS = \"file: $file | Check output for list of blocked MINs\"" | tee $resultfile
        x=$(cat $logfile | grep -c "not_activated")
        if [ $x -eq 0 ]; then
        ERROR=$(cat $logfile | egrep -i "ERROR|INFO|NOTICE")
                echo "STATUS = FAILED" | tee $resultfile
                echo "$ERROR" | tee $resultfile
        else
        echo "STATUS = SUCCESSFUL" | tee $resultfile
        fi
	;;
    batch_cms_suspension)
    echo "ACTION = batch_cms_suspension" | tee $resultfile
    echo "DETAILS = \"file: $file | Check MIN status using check_cms_status\"" | tee $resultfile
        x=$(cat $logfile | grep -c "procedure successfully completed.")
        if [ $x -eq 0 ]; then
        ERROR=$(cat $logfile | egrep -i "ERROR|INFO|NOTICE")
                echo "STATUS = FAILED" | tee $resultfile
                echo "$ERROR" | tee $resultfile
        else
        echo "STATUS = SUCCESSFUL" | tee $resultfile
        fi
    ;;
    lift_suspended_accounts)
    echo "ACTION = lift_suspended_accounts_in_efs" | tee $resultfile
	echo "DETAILS = \"file: $file | Check output for list of MINs\"" | tee $resultfile
        x=$(cat $logfile | grep -c "Updated account_status to ACTIVE")
        if [ $x -eq 0 ]; then
        ERROR=$(cat $logfile | egrep -i "ERROR|INFO|NOTICE")
                echo "STATUS = FAILED" | tee $resultfile
                echo "$ERROR" | tee $resultfile
        else
        echo "STATUS = SUCCESSFUL" | tee $resultfile
        fi
        ;;
esac

echo "$(cat $resultfile)"  | tee $trail	

rm $profile
