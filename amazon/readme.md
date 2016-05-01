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
1. minutes
2. hours
3. day of month
4. month
5. day of week

All of this five elemets need to be replaced with the cron expression that allow :

1. * for anytime 
2. n for a specified number 
3. [n1-n2] for a range  
4. */n every n (minutes/hours/day/etc.etc.) 
