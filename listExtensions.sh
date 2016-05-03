ls -l | awk '{print $9}' | awk -F "." '{print $2}' | sort -u
