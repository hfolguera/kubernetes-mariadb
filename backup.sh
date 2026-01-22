#!/bin/bash

export KUBECONFIG=/etc/kubernetes/admin.conf
DATE=`date +"%d%m%Y"`
echo "[DEBUG] KUBECONFIG: $KUBECONFIG"
PASS=`cat /root/kubernetes-mariadb/password`
DEST_PATH=/nfs/homelab/backup/mariadb

echo "[INFO] Starting backup for MariaDB at $DATE"

NS=mariadb

POD=`kubectl get pod -n $NS -o jsonpath='{.items[0].metadata.name}'`
echo "[DEBUG] POD: $POD"

DATABASES=`kubectl exec -i -n $NS $POD -- /usr/bin/mariadb -u root --password=${PASS} -e "SHOW DATABASES;"`
if [ $? -eq 0 ]
then
    DATABASES=`echo $DATABASES | tr ' ' '\n' | grep -v "+-" | grep -v Database | grep -v information_schema | grep -v performance_schema | grep -v Warning | awk '{print $1}'`
    echo "[DEBUG] DATABASES: $DATABASES"
else
    echo "[ERROR] Cannot get MariaDB databases!"
    exit 1
fi

RC=0
for DB in $DATABASES
do
    echo "[INFO] Executing backup for $DB"
    kubectl exec -it -n $NS $POD -- /usr/bin/mariadb-dump -u root --password=${PASS} $DB > $DEST_PATH/mariadb_${DB}_backup_${DATE}.sql
    if [ $? -ne 0 ]
    then
        echo "[ERROR] Cannot execute $DB database backup!"
        RC=1
    fi
done

echo "[INFO] Backup finished"
echo "[INFO] Purging old backups"
#Purge old backups
find $DEST_PATH/*.sql -mtime +7 -exec rm {} \;
echo "[INFO] End of script"
echo ""

exit $RC
