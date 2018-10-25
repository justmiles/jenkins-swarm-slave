#!/bin/bash

if [ ! -z "$ECS_CONTAINER_METADATA_FILE" ]; then
  export ECS_CLUSTER_NAME=`jq -r '.Cluster' $ECS_CONTAINER_METADATA_FILE`
fi

TASK_ID=`aws ecs list-tasks --service-name $ECS_SERVICE_NAME --cluster $ECS_CLUSTER_NAME | jq -r '.taskArns[0]' | awk -F '/' '{print $2}'`

CONTAINER_INSTANCE_ID=`aws ecs describe-tasks --task $TASK_ID --cluster $ECS_CLUSTER_NAME | jq -r .tasks[0].containerInstanceArn | awk -F '/' '{print $2}'`

INSTANCE_ID=`aws ecs describe-container-instances --container-instances $CONTAINER_INSTANCE_ID --cluster $ECS_CLUSTER_NAME | jq -r '.containerInstances[0].ec2InstanceId'`

IP=`aws ec2 describe-instances --instance-ids $INSTANCE_ID | jq -r '.Reservations[0].Instances[0].PrivateIpAddress'`

SWARM_ARGS="-master $JENKINS_MASTER -username $JENKINS_USERNAME -passwordEnvVariable JENKINS_PASSWORD -executors $EXECUTORS -fsroot $HOME -tunnel $IP:$SLAVE_TUNNEL_PORT -deleteExistingClients $SWARM_ARGS"

echo "$SWARM_ARGS"

exec java $JAVA_OPTS -jar /usr/share/jenkins/swarm-client.jar $SWARM_ARGS "$@"
