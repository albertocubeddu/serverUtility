#Amazon

##Cron.yaml
This is the file to execute cronjob on amazon and need to be place in the root of your application. 
This is a sample of the code that you need to put in the file:
```
version: 1
cron:
 — name: "schedule"
   url: "/schedule"
   schedule: "0 */12 * * *"
```

**name** : A unique name for the cron job

**url** : The URL to send a POST/GET request everytime that the scheduler fire the job. 

**schedule** : The cron expression that defines how frequently the job should run.

###Schedule
1. minutes (0-59)
2. hours (0-23)
3. day of month (1-31)
4. month (1-12 or JAN-DEC)
5. day of week (0-6 or SUN-SAT)
6. year (NOT MANDATORY can be NULL and can be NOT SUPPORTED)

All of this five elemets need to be replaced with the cron expression that allow :

1. * for anytime 
2. n for a specified number 
3. [n1-n2] for a range INCLUSIVE 
4. [n1,n3,n5] for a selected item. 
5. */n every n (minutes/hours/day/etc.etc.) 
