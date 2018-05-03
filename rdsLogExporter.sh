#!/usr/bin/env bash

echo "You need JQ and the AWS CLI installed in your machine to be able to run this script"

echo  "Choose the db instance identifier:"
read -e dbInstanceIdentifier

aws rds describe-db-log-files --db-instance-identifier ${dbInstanceIdentifier} > /tmp/${dbInstanceIdentifier}-describe-db-log-files
cat /tmp/${dbInstanceIdentifier}-describe-db-log-files | jq '[.DescribeDBLogFiles][0][].LogFileName' > /tmp/${dbInstanceIdentifier}-production-logs-filename
#cat /tmp/${dbInstanceIdentifier}-production-logs-filename | xargs -I{} sh -c "xxx() { if test "$1" != "${1%/*}"; then mkdir -p ${1%/*}; fi && command tee "$1"; }; aws rds download-db-log-file-portion --db-instance-identifier ${dbInstanceIdentifier} --log-file-name {} | xxx {}"

cat /tmp/${dbInstanceIdentifier}-production-logs-filename | awk -F "/" '{print substr($1,2,length($1))}' | xargs -I{} sh -c 'mkdir -p {}'
cat /tmp/${dbInstanceIdentifier}-production-logs-filename | xargs -I{} sh -c "aws rds download-db-log-file-portion --db-instance-identifier ${dbInstanceIdentifier} --log-file-name {} > {}"
