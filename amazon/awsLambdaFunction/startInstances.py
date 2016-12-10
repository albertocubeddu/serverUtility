import boto3

region = 'ap-southeast-2'
instancesContainer = []

ec2 = boto3.resource('ec2', region_name=region,  api_version='2016-04-01')
ec2Client = boto3.client('ec2', region_name=region,  api_version='2016-04-01')

#Retrieve all the instances
instances = ec2.instances.filter(Filters = [{'Name':'tag:Name', 'Values':['testing*']}, {'Name':'instance-state-name', 'Values':['stopped']}])

for instance in instances:
    for tag in instance.tags:
        if (tag['Key'] == 'Name'):
            instancesContainer.append(instance.instance_id)
            print (instance.instance_id, tag['Value'])

def lambda_handler(event, context):
    if instancesContainer:
        ec2Client.stop_instances(InstanceIds=instancesContainer)
        print 'started your instances: ' + str(instancesContainer)
    else:
        print 'no instance need to be started'
