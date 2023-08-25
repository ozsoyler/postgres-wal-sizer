#/bin/bash
# author Alper Ozsoyler

start_time=$(date +%s)

echo "Welcome to pg_wal_sizer script run"
echo -e "\nAttention: postgres service must be stopped to run the script"

status=$(systemctl is-active postgresql*)
if [[ ${status} == "active" ]]; then
  echo "postgres service is still in active. Exiting.."
  exit 1
fi
	
echo "Deep note: \"min_wal_size\" must be at least twice \"wal_segment_size\""

echo -ne "\nPGDATA is set $PGDATA. Do you confirm it? (yes/no): "
read answer

if [[ ${answer} == "yes" ]]; then
  echo -e "PGDATA -> \e[92m $PGDATA \e[0m"
  pgdata=$(echo $PGDATA)
else
  echo -n "Please enter PGDATA: "
  read answer
  pgdata=$(echo $answer)
fi

echo -e "\nPlease enter new WAL configuration variables in order"
echo -n "WAL segment size(MB): "
read wal_segsize
echo -n "Minimum WAL size(MB): "
read min_wal_size
echo -n "Maximum WAL size(MB): "
read max_wal_size
echo -n "WAL keep size(MB): "
read wal_keep_size

echo -e "\nEntered WAL configuration variables"
echo -e "WAL segment size:\e[92m ${wal_segsize}MB \e[0m"
echo -e "Minimum WAL size:\e[92m ${min_wal_size}MB \e[0m"
echo -e "Maximum WAL size:\e[92m ${max_wal_size}MB \e[0m"
echo -e "WAL keep size:\e[92m ${wal_keep_size}MB \e[0m"

echo -ne "\nDo you confirm them? (yes/no): "
read answer

if [[ ${answer} == "yes" ]]; then
  /usr/bin/pg_resetwal -D $pgdata --wal-segsize $wal_segsize
  sed -i -e '/pg_wal_sizer/,+3d' $PGDATA/postgresql.conf # clean up before putting new variables
  echo "# Customized Values - pg_wal_sizer" >> $PGDATA/postgresql.conf
  echo "min_wal_size = ${min_wal_size}MB " >> $PGDATA/postgresql.conf
  echo "max_wal_size = ${max_wal_size}MB" >> $PGDATA/postgresql.conf
  echo "wal_keep_size = ${wal_keep_size}MB" >> $PGDATA/postgresql.conf
  echo "Done.."
  
  echo "Please do not forget to start Postgresql service."
else
  echo "User didn't confirm. Exiting.."
fi

echo -e "\nResult overview:"
echo -e "* The primary server will be kept WAL files until they hit the limit that \"\e[92m${wal_keep_size}MB\e[0m\" if any standby server is off during that time."
echo -e "* The size of WAL files will be \"\e[92m${wal_segsize}MB\e[0m\" in \"pg_wal\" folder."
echo -e "* The total size of WAL files can be at least \"\e[92m${min_wal_size}MB\e[0m\" that means \"$((min_wal_size / wal_segsize))\" WAL files sit in \"pg_wal\" folder. If size of WAL files hit this limit, postgres can start to shrink \"pg_wal\" folder according to max_wal_size value"
echo -e "* The total size of WAL files can be at most \"\e[92m${max_wal_size}MB\e[0m\" that means \"$((max_wal_size / wal_segsize))\" WAL files sit in \"pg_wal\" folder. If size of WAL files hit this limit, a checkpoint would be triggered. However please note it; this is a soft limit. Therefore, the total size could be bigger than this limit - it depends on the data replication status/health of postgres cluster."

finish_time=$(date +%s)
echo -e "\nExecution time: $(( $finish_time - $start_time )) seconds..."
