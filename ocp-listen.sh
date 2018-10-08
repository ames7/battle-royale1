#!/bin/bash

#Global Variables
ocpserver=master1-nasademojambattler-1gjiybm0.srv.ravcloud.com:8443
towerurl=ansible-tower-web-svc-battle-royale.apps.ames7.com
towertemplate=7
user1=ames7
user2=app_crasher
block1=PUMPKIN
block2=JACK_O_LANTERN
password=Redhat1!
minecraftserver=bukkit-minecraft-server
appname=myapp
project=battle-royale

#Login to ocp
oc login -u admin -p $password $ocpserver --insecure-skip-tls-verify >/dev/null

echo "Connected to Server:"
echo $ocpserver
echo "Using Project:"
oc project -q $project

pod=`oc get pod --no-headers | grep $minecraftserver | awk '{print $1}'`
oc logs --since=1s -f $pod | while read line; do
  if echo $line | grep "BATTLE-ROYALE" >/dev/null; then
    user=`echo $line | awk '{print $4}'`
    blocktype=`echo $line | awk '{print $5}'`
    echo "user is $user, block is $blocktype"
    if [ $user = $user1 ]  &&  [ $blocktype = $block1 ] ; then
      tower-cli job launch -h $towerurl -u admin -p $password -J $towertemplate
    elif [ $user = $user2 ]  &&  [ $blocktype = $block2 ] ; then
      destroy_pod=`oc get pod | grep $appname | grep Running | head -1 | awk '{print $1}'`
      oc delete pod $destroy_pod -n $project
    fi
  fi
done
