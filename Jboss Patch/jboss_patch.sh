#!/bin/ksh

List=()
typeset -i tempVal=0
typeset -i a=0
typeset -i debugEnabled=0
typeset apps
set -A server_before
set -A status_before
set -A server_after
set -A status_after

typeset MAX_VERSION_7_0="7.0.9"
typeset MAX_VERSION_7_1="7.1.6"
typeset MAX_VERSION_7_2="7.2.9"
typeset MAX_VERSION_7_3="7.3.3"


typeset VERSION_7_0_0="7.0.0"
typeset VERSION_7_1_0="7.1.0"
typeset VERSION_7_2_0="7.2.0"
typeset VERSION_7_3_0="7.3.0"

typeset applicationServerVersion
typeset applicationServerVersionPlain
typeset fixFileName
typeset pids
typeset -i stop_timeout=60
typeset -i loop_timeout=90
typeset -i instance_reading_loop_timeout=36
typeset -i sleep=5
typeset -i counter=0
typeset -i agentStoppedInitial=1
typeset -i initialInstanceReadingFailed=1
typeset jbossPath="/opt/jboss/AppServer"
typeset jbossPathSec="/opt/jboss/AppServer/jboss"
typeset freeMemory
typeset fileName
typeset parentDirectory
typeset C_AIX="aix"
typeset C_LINUX="linux"
typeset -l os
typeset fixDirectoryPath="Jboss_IMAGE/zip"
typeset fullFixDirectoryPath="/mypath/$fixDirectoryPath"
typeset isSimulation=$1
typeset isPatchSimulation=$2
typeset SCRIPT_NAME="JBOSS_FIX_SCRIPT"

setJbossHome(){
    [[ $debugEnabled -eq 0 ]] && { print "$(hostname)-Debug: In setJbossHome start"; }

    if [[ -f $jbossPath/bin/domain.sh || -f $jbossPathSec/bin/domain.sh ]]
    then
      if [ -f $jbossPathSec/bin/domain.sh ]
      then
         jbossPath=$jbossPathSec
         print "$(hostname)-Alternative jboss path used"
      fi

      export JAVA_HOME="/opt/jboss/jdk"
      export JBOSS_HOME=$jbossPath
      print "$(hostname)-JBOSS HOME :"$JBOSS_HOME
    else
      print "$(hostname)-No jboss path on machine"
      print "$(hostname)-Exit 0"
      rm -rf "$CONTROLFOLDER"
      exit 0
    fi
    [[ $debugEnabled -eq 0 ]] && { print "$(hostname)-Debug: In setJbossHome end"; }
}

checkDiskSize () {
    if [ $(cat /etc/system-release-cpe  | cut -f5 -d: | cut -c1) -gt 6 ]; then
        [[ $debugEnabled -eq 0 ]] && { print "$(hostname)-Check Disk Size"; }
        for path in "/opt/jboss" "/mypath"; do
            size=$(df -m | grep $path | awk '{print $4}')
            if [ $size -gt 1024 ]; then
                [[ $debugEnabled -eq 0 ]] && { print "$(hostname)- ($path) Disk Size OK"; }
            else
                 print "$(hostname)- ($path) Disk Size is NOK"
                 exit 100
            fi
        done 
    else
        [[ $debugEnabled -eq 0 ]] && { print "$(hostname)-Check Disk Size"; }
        for path in "/opt/jboss" "/mypath"; do
            size=$(df -m | grep $path | awk '{print $3}')
            if [ $size -gt 1024 ]; then
                [[ $debugEnabled -eq 0 ]] && { print "$(hostname)- ($path) Disk Size OK"; }
            else
                 print "$(hostname)- ($path) Disk Size is NOK"
                 exit 100
            fi
        done 
    fi         
}

getJbossVersion(){

    [[ $debugEnabled -eq 0 ]] && { print "$(hostname)-Debug: In getJbossVersion start"; }
    [[ $debugEnabled -eq 0 ]] && { print "$(hostname)-Debug: jboss-cli.sh embed-server command execution"; }

    applicationServerVersion=$($JBOSS_HOME/bin/jboss-cli.sh 'embed-server,:read-attribute(name=product-version)' | grep result | awk ' {print $3}' | tr -d '"')

    if [ -z "$applicationServerVersion" ]
    then
     print "$(hostname)-ApplicationServerVersion is empty"
     [[ $debugEnabled -eq 0 ]] && { print "$(hostname)-Debug: jboss-cli.sh embed-server command execution 2"; }
     tempVal=$($JBOSS_HOME/bin/jboss-cli.sh 'embed-server,:read-attribute(name=product-version)' | grep -c Unexpected )

     if [[ "$tempVal" -ne 0 ]]
     then
        print "$(hostname)-Embed-server command error"
     fi

     [[ $debugEnabled -eq 0 ]] && { print "$(hostname)-Debug: domain.sh -version command"; }
     applicationServerVersion=$($JBOSS_HOME/bin/domain.sh -version | grep "JBoss EAP" |  awk '{print $3}')

     if [ -z "$applicationServerVersion" ]
     then
       print "$(hostname)-Could not read via domain.sh -version"

       if [[ -f $JBOSS_HOME/version.txt || -f $JBOSS_HOME/Version.txt ]]
       then
          [[ $debugEnabled -eq 0 ]] && { print "$(hostname)-Debug: read version.txt"; }
          applicationServerVersion=$(< $JBOSS_HOME/version.txt grep -i version | awk '{print $NF}')
       else
          print "$(hostname)-Could not read via version.txt"
          applicationServerVersion="NF"
       fi
     fi
    fi
    [[ $debugEnabled -eq 0 ]] && { print "$(hostname)-Debug: In getJbossVersion end"; }
}

getJbossVersionBefore(){
    [[ $debugEnabled -eq 0 ]] && { print "$(hostname)-Debug: In getJbossVersionBefore start"; }
    getJbossVersion
    print "$(hostname)-App Version before fix execution: "$applicationServerVersion

    tempVal=$(print $applicationServerVersion | grep -c GA )
    if [ "$tempVal" -eq 0 ]
    then
       print "$(hostname)-Improper Version Number"
       print "$(hostname)-Exit 2"
       rm -rf "$CONTROLFOLDER"
       exit 2
    fi
    [[ $debugEnabled -eq 0 ]] && { print "$(hostname)-Debug: In getJbossVersionBefore end"; }
}

getJbossVersionAfter(){
    [[ $debugEnabled -eq 0 ]] && { print "$(hostname)-Debug: In getJbossVersionAfter start"; }
    getJbossVersion
    print "$(hostname)-App Version after fix execution: $applicationServerVersion"
    [[ $debugEnabled -eq 0 ]] && { print "$(hostname)-Debug: In getJbossVersionAfter end"; }
}

checkUpgradeNecessary(){

 [[ $debugEnabled -eq 0 ]] && { print "$(hostname)-Debug: In checkUpgradeNecessary start"; }

 print "$(hostname)-Application version number : $applicationServerVersion"

 if [[ $applicationServerVersion != "NF" ]]
 then
     applicationServerVersionPlain=$(print $applicationServerVersion | tr -d "GA" | sed 's/.$//')

     print "$(hostname)-Application version number plain : $applicationServerVersionPlain"

     if testvercomp "$applicationServerVersionPlain"  "$VERSION_7_0_0"  "="  || ( testvercomp "$applicationServerVersionPlain" "$VERSION_7_0_0"  ">"  && testvercomp "$applicationServerVersionPlain" "$MAX_VERSION_7_0" "<" )
     then
         fixFileName="jboss-eap-""$MAX_VERSION_7_0""-patch.zip"

     elif testvercomp "$applicationServerVersionPlain"  "$VERSION_7_1_0"  "="  || ( testvercomp "$applicationServerVersionPlain" "$VERSION_7_1_0"  ">"  && testvercomp "$applicationServerVersionPlain" "$MAX_VERSION_7_1" "<" )
     then
         fixFileName="jboss-eap-""$MAX_VERSION_7_1""-patch.zip"

     elif testvercomp "$applicationServerVersionPlain"  "$VERSION_7_2_0"  "="  || ( testvercomp "$applicationServerVersionPlain" "$VERSION_7_2_0"  ">"  && testvercomp "$applicationServerVersionPlain" "$MAX_VERSION_7_2" "<" )
     then
         fixFileName="jboss-eap-""$MAX_VERSION_7_2""-patch.zip"

     elif testvercomp "$applicationServerVersionPlain"  "$VERSION_7_3_0"  "="  || ( testvercomp "$applicationServerVersionPlain" "$VERSION_7_3_0"  ">"  && testvercomp "$applicationServerVersionPlain" "$MAX_VERSION_7_3" "<" )
     then
         fixFileName="jboss-eap-""$MAX_VERSION_7_3""-patch.zip"
     else
        if [[ $applicationServerVersionPlain = "$MAX_VERSION_7_0" || $applicationServerVersionPlain = "$MAX_VERSION_7_1" || $applicationServerVersionPlain = "$MAX_VERSION_7_2" || $applicationServerVersionPlain = "$MAX_VERSION_7_3" ]]
        then
           print "$(hostname)-Already uptodate"
           print "$(hostname)-Exit 0"
           rm -rf "$CONTROLFOLDER"
           exit 0
        else
           print "$(hostname)-No fix pr/red for version: $applicationServerVersionPlain"
           print "$(hostname)-Exit 4"
           rm -rf "$CONTROLFOLDER"
           exit 4
        fi
     fi

     print "$(hostname)-Fix file name :"$fixFileName
 else
     print "$(hostname)-No version info found"
     print "$(hostname)-Exit 5"
     rm -rf "$CONTROLFOLDER"
     exit 5
 fi
 [[ $debugEnabled -eq 0 ]] && { print "$(hostname)-Debug: In checkUpgradeNecessary end"; }
}

storeServerInstancesBefore(){
    [[ $debugEnabled -eq 0 ]] && { print "$(hostname)-Debug: In storeServerInstancesBefore start"; }
    [[ $debugEnabled -eq 0 ]] && { print "$(hostname)-Debug: get instances"; }

    apps=$($JBOSS_HOME/bin/jboss-cli.sh -c --controller="$(hostname)" --command="ls host=master/server-config")
    tempVal=$(print "$apps" | grep -c Failed )

    a=0
    while [[ $a -lt "$instance_reading_loop_timeout" && "$tempVal" -ne 0 ]]
    do
        [[ $debugEnabled -eq 0 ]] && { print "$(hostname)-Debug: try to read instances for a while: $a"; }
        apps=$($JBOSS_HOME/bin/jboss-cli.sh -c --controller="$(hostname)" --command="ls host=master/server-config")
        tempVal=$(print "$apps" | grep -c Failed )
        (( a=a+1 ))
        sleep $sleep
    done

    if [[ "$tempVal" -eq 0 ]]
    then
        [[ $debugEnabled -eq 0 ]] && { print "$(hostname)-Debug: get instances did not failed"; }
        a=0
        for appserver in $apps
        do
          server_before[$a]="$appserver"
          [[ $debugEnabled -eq 0 ]] && { print "$(hostname)-Debug: read instance $appserver"; }
          $JBOSS_HOME/bin/jboss-cli.sh -c --controller="$(hostname)" --command="ls host=master/server-config=$appserver"|grep "^status" |cut -d'=' -f2| read status_before[$a]
          (( a=a+1 ))
        done

        [[ $debugEnabled -eq 0 ]] && { print "$(hostname)-Debug: Start printing"; }
        a=0
        while [[ $a -lt ${#server_before[@]} ]]
        do
          print "$a-) ${server_before[$a]} :${status_before[$a]}" | awk '{printf("%-4s %-25s %-10s\n", $1 , $2 , $3)}'
          (( a=a+1 ))
        done
    else
        initialInstanceReadingFailed=0
        [[ $debugEnabled -eq 0 ]] && { print "$(hostname)-Debug: initial instance reading failed"; }
    fi
    [[ $debugEnabled -eq 0 ]] && { print "$(hostname)-Debug: In storeServerInstancesBefore end"; }
}

storeServerInstancesAfter(){
    [[ $debugEnabled -eq 0 ]] && { print "$(hostname)-Debug: In storeServerInstancesAfter start"; }
    if [[ $initialInstanceReadingFailed -ne 0 ]]
    then
        a=0
        [[ $debugEnabled -eq 0 ]] && { print "$(hostname)-Debug: get instances"; }
        apps=$($JBOSS_HOME/bin/jboss-cli.sh -c --controller="$(hostname)" --command="ls host=master/server-config")
        tempVal=$(print "$apps" | grep -c Failed )

        while [[ $a -lt $instance_reading_loop_timeout && "$tempVal" -ne 0 ]]
        do
            [[ $debugEnabled -eq 0 ]] && { print "$(hostname)-Debug: try to read instances for a while: $a"; }
            apps=$($JBOSS_HOME/bin/jboss-cli.sh -c --controller="$(hostname)" --command="ls host=master/server-config")
            tempVal=$(print "$apps" | grep -c Failed )
            (( a=a+1 ))
            sleep $sleep
        done

        if [[ "$tempVal" -eq 0 ]]
        then
           [[ $debugEnabled -eq 0 ]] && { print "$(hostname)-Debug: get instances did not failed"; }
           a=0
           for appserver in $apps
            do
              server_after[$a]="$appserver"
              [[ $debugEnabled -eq 0 ]] && { print "$(hostname)-Debug: read instance $appserver"; }
              $JBOSS_HOME/bin/jboss-cli.sh -c --controller="$(hostname)" --command="ls host=master/server-config=$appserver"|grep "^status" |cut -d'=' -f2| read -r status_after[$a]
              (( a=a+1 ))
            done

            [[ $debugEnabled -eq 0 ]] && { print "$(hostname)-Debug: Start printing"; }
            a=0
            while [[ $a -lt ${#server_after[@]} ]]
            do
              print "$a-) ${server_after[$a]} :${status_after[$a]}" | awk '{printf("%-4s %-25s %-10s\n", $1 , $2 , $3)}'
              (( a=a+1 ))
            done
        else
            [[ $debugEnabled -eq 0 ]] && { print "$(hostname)-Debug: get instances failed"; }
        fi
    else
        print "$(hostname)-Store Server Instances After skipped"
    fi
    [[ $debugEnabled -eq 0 ]] && { print "$(hostname)-Debug: In storeServerInstancesAfter end"; }
}

shutdownDomainControllerInstantly(){
  [[ $debugEnabled -eq 0 ]] && { print "$(hostname)-Debug: In shutdownDomainControllerInstantly start"; }
  $JBOSS_HOME/bin/jboss-cli.sh -c --controller="$(hostname)" --command="shutdown --host=master"
  [[ $debugEnabled -eq 0 ]] && { print "$(hostname)-Debug: In shutdownDomainControllerInstantly end"; }
}

shutdownDomainController(){
    [[ $debugEnabled -eq 0 ]] && { print "$(hostname)-Debug: In shutdownDomainController start"; }
    [[ $debugEnabled -eq 0 ]] && { print "$(hostname)-Debug: call shutdown"; }
    $JBOSS_HOME/bin/jboss-cli.sh -c --controller="$(hostname)" --command="shutdown --host=master"
    print "$(hostname)-Wait for a while...."
    sleep $sleep
    ps -ef | grep was | grep java | grep "/opt/jboss/"  | grep -v grep
    set -A pids
    ps -ef | grep was | grep java | grep "/opt/jboss/"  | grep -v grep | awk '{print $2}' | while IFS="" read -r line; do pids+=("$line"); done


    print "$(hostname)-Pids after shutdown command:  ${pids[@]}"

    counter=0

    while [[ ${#pids[@]} -ne 0 && $counter -lt $loop_timeout ]]
    do
        if [[ $counter -gt $stop_timeout ]]
        then
            kill -9 ${pids[@]}
            print "$(hostname)-Kill command called for ${pids[@]}"
        fi

        print "$(hostname)-Counter :"$counter
        sleep $sleep
        (( counter+=1 ))
        set -A pids
        ps -ef | grep was | grep java | grep "/opt/jboss/"  | grep -v grep | awk '{print $2}' | while IFS="" read -r line; do pids+=("$line"); done
    done

    if [[ ${#pids[@]} -ne 0 ]]
    then
        print "$(hostname)-Processes are still alive. ${pids[@]}"
        print "$(hostname)-Exit 6"
        rm -rf "$CONTROLFOLDER"
        exit 6
    fi

    [[ $debugEnabled -eq 0 ]] && { print "$(hostname)-Debug: In shutdownDomainController end"; }
}

clearTempFiles(){
    [[ $debugEnabled -eq 0 ]] && { print "$(hostname)-Debug: In clearTempFiles start"; }
    if [[ $initialInstanceReadingFailed -ne 0 ]]
    then
        print "$(hostname)-Server instance tmp files will be cleared"
        for instance in $apps
        do
          print "$instance"
          rm -rf "$JBOSS_HOME"/domain/servers/"$instance"/tmp/*
        done

    else
       print "$(hostname)-Clearing skipped"
    fi
    [[ $debugEnabled -eq 0 ]] && { print "$(hostname)-Debug: In clearTempFiles end"; }
}

getBackup(){
    [[ $debugEnabled -eq 0 ]] && { print "$(hostname)-Backup procedure will be executed"; }
    backupFileName="jboss_backup_$(date +%Y%m%d_%H%M%S).tar"
    parentDirectory="$(dirname "$JBOSS_HOME")"
    directories=("$JBOSS_HOME/domain/configuration/" "$JBOSS_HOME/modules/system/layers/base/oracle/" "$JBOSS_HOME/modules/system/layers/base/com/microsoft/main" "$JBOSS_HOME/modules/system/layers/base/microsoft" "$JBOSS_HOME/modules/system/layers/base/ibm" "$JBOSS_HOME/modules/system/layers/base/org/postgresql")
    for directory in "${directories[@]}"; do
       if [ -d "$directory" ]; then
          List+=($directory)
       fi       
    done    
   
    print "$(hostname)-Backup Directory: ${List[*]}"
    print "$(hostname)-Patch will be applied. Get a tar archive file $backupFileName"
    if ! tar -cvhf "$parentDirectory/$backupFileName" --absolute-names ${List[*]} > /dev/null
    then
      print "$(hostname)-Cannot get a backup file"
      if [[ -f "$parentDirectory/$backupFileName" ]]
      then
         
         if ! rm "$parentDirectory/$backupFileName" ;
         then
            print "$(hostname)-Backup procedure - backup file connot be deleted"
         else
            print "$(hostname)-Backup procedure - backup file  deleted"
         fi
      else
        startDomainController
      fi
      rm -rf "$CONTROLFOLDER"
      print "$(hostname)-Exit 10"
      exit 10
    fi
   [[ $debugEnabled -eq 0 ]] && { print "$(hostname)-Backup procedure completed"; }
}

applyPatch(){
        [[ $debugEnabled -eq 0 ]] && { print "$(hostname)-Debug: Apply patch command"; }
        if [[ -z $isPatchSimulation ]]
        then
          print "$(hostname)-This is patch simulation. No fix patched."
        else
          nohup "$JBOSS_HOME"/bin/jboss-cli.sh "patch apply $fullFixDirectoryPath/$fixFileName  --override-all"
          tail -100 /home/was/nohup.out
          print "$(hostname)-Patch completed"
        fi
      [[ $debugEnabled -eq 0 ]] && { print "$(hostname)-Debug: In applyPatch end"; }
}


function vercomp {
    if [[ $1 == "$2" ]]
    then
        return 0
    fi
    typeset IFS=.
    set -A ver1 $1
    set -A ver2 $2
    # fill empty fields in ver1 with zeros
    for ((i=${#ver1[@]}; i<${#ver2[@]}; i++))
    do
        ver1[i]=0
    done
   
    for ((i=0; i<${#ver1[@]}; i++))
    do
        if [[ -z ${ver2[i]} ]]
        then
            # fill empty fields in ver2 with zeros
            ver2[i]=0
        fi
      
        if ((10#${ver1[i]} > 10#${ver2[i]}))
        then        
            return 1
        fi
        if ((10#${ver1[i]} < 10#${ver2[i]}))
        then
            return 2
        fi
    done
    return 0
}

testvercomp () {
    vercomp $1 $2
   
    case $? in
        0) op='=';;
        1) op='>';;
        2) op='<';;
    esac

    if [[ "$op" != "$3" ]]
    then
      return 1
    else
      return 0
    fi
}

startDomainController(){
    [[ $debugEnabled -eq 0 ]] && { print "$(hostname)-Debug: In startDomainController start"; }

    [[ $debugEnabled -eq 0 ]] && { print "$(hostname)-Debug: Start domain controller"; }
    nohup "$JBOSS_HOME"/bin/domain.sh > /dev/null 2>&1 &

    [[ $debugEnabled -eq 0 ]] && { print "$(hostname)-Debug: In startDomainController end"; }
}

startDomainControllerInstantly(){
    [[ $debugEnabled -eq 0 ]] && { print "$(hostname)-Debug: In startDomainControllerInstantly start"; }
    nohup "$JBOSS_HOME"/bin/domain.sh > /dev/null 2>&1 &
    [[ $debugEnabled -eq 0 ]] && { print "$(hostname)-Debug: In startDomainControllerInstantly end"; }
}

controlServerInstances(){
    [[ $debugEnabled -eq 0 ]] && { print "$(hostname)-Debug: In controlServerInstances start"; }
    if [[ $initialInstanceReadingFailed -ne 0 ]]
    then
      if [[ ${#server_before[@]} -ne ${#server_after[@]} ]]
      then
        print "$(hostname)-Mismatching application number. Before: ${#server_before[@]} - After: ${#server_after[@]}"
      else
        print "$(hostname)-Matching application number. Before: ${#server_before[@]} - After: ${#server_after[@]}"
      fi
    fi
    [[ $debugEnabled -eq 0 ]] && { print "$(hostname)-Debug: In controlServerInstances end"; }
}

isDomainControllerAlive(){
   [[ $debugEnabled -eq 0 ]] && { print "$(hostname)-Debug: In isDomainControllerAlive start"; }
   tempVal=$(ps -ef | grep jboss | grep java | grep -c "[\[]Process Controller\]" )
   if [ "$tempVal" -eq 1 ]
   then
     print "$(hostname)-Domain controller alive"
     return 0
   else   
     if [[ "$tempVal" -gt 1 ]]
     then
        print "$(hostname)-More than one domain controller alive"
        echo "$(hostname)-Exit 1"
        rm -rf "$CONTROLFOLDER"
        exit 1
     else
       print "$(hostname)-Domain controller is not alive"
       tempVal=$(ps -ef | grep jboss | grep java | grep -c "[\[]Standalone\]" )
       if [[ "$tempVal" -eq 0 ]]
       then
        echo "$(hostname)-Exit 9"
        rm -rf "$CONTROLFOLDER"
        exit 9
       else
        print "$(hostname)-Jboss may be working on standalone mode"
        echo "$(hostname)-Exit 0"
        rm -rf "$CONTROLFOLDER"
        exit 0
       fi
     fi
   fi
   [[ $debugEnabled -eq 0 ]] && { print "$(hostname)-Debug: In isDomainControllerAlive end"; }
}

getNetworkPath(){
  [[ $debugEnabled -eq 0 ]] && { print "$(hostname)-Debug: In getNetworkPath start"; }
  os=$(uname)
  echo "$(hostname)-uname: $os"

  if [[ "$os" =  "$C_AIX" ]]
  then
      echo "$(hostname)-AIX machine"
      fullFixDirectoryPath=/Mypath/aix/"$fixDirectoryPath"
  elif [[ "$os" =  "$C_LINUX" ]]
  then
      echo "$(hostname)-Linux Machine"
      fullFixDirectoryPath=/Mypath/"$fixDirectoryPath"
  else
      echo "$(hostname)-Not AIX-Not Linux"
      echo "$(hostname)-Exit 8"
      rm -rf "$CONTROLFOLDER"
      exit 8
  fi

  if [[ ! -f "$fullFixDirectoryPath/$fixFileName" ]]
  then
      echo "$(hostname)-Patch file is not available"
      echo "$(hostname)-Exit 11"
      rm -rf "$CONTROLFOLDER"
      exit 11
  fi 
  [[ $debugEnabled -eq 0 ]] && { print "$(hostname)-Debug: In getNetworkPath end"; }
}

checkIsDomainModeOperation(){
  [[ $debugEnabled -eq 0 ]] && { print "$(hostname)-Debug: In checkIsDomainModeOperation end"; }
  tempVal=$($JBOSS_HOME/bin/jboss-cli.sh -c --controller="$(hostname)" --command=":read-attribute(name=launch-type)" | grep -c "DOMAIN" )

  if [[ "$tempVal" -eq 0 ]]
  then
    print "$(hostname)-JBOSS is not working in domain mode"
    echo "$(hostname)-Exit 0"
    rm -rf "$CONTROLFOLDER"
    exit 0
  fi
  [[ $debugEnabled -eq 0 ]] && { print "$(hostname)-Debug: In checkIsDomainModeOperation end"; }
}

print "$(hostname)-Script execution starting"
if [[ -z $isSimulation ]]
then
   print "$(hostname)-=========THIS IS SIMULATION. NO FIX WILL BE PATCHED========="
fi

echo "$(hostname)-Run Parallel Execution Preventing Algorithm"
CONTROLFOLDER="/tmp/${SCRIPT_NAME}$(date +"%Y%m%d")"
echo "$(hostname)-CONTROLFOLDER $CONTROLFOLDER"

while ! mkdir "$CONTROLFOLDER" 2>/dev/null
do
  echo "Another script execution is in progress."
  exit 0
done

# Find the jboss path. If there is no pathler or domain.sh file, then exit with 1.
setJbossHome

# Disk Controls are done If the disk is below 1Gb, exit the disk
checkDiskSize

# If it doesn't work in domain mode, it will exit with 10. No need to call.
#####checkIsDomainModeOperation

# Process controller exits with 9 if there is no process. either the server is down or it is running in standalone mode.
isDomainControllerAlive

# version information is read. If it can't read properly, it will exit with 2
getJbossVersionBefore

# If the upgrade is unnecessary, it is released with 3 if the patch is not prepared for the version.
checkUpgradeNecessary

# fix file path is read. If there is no network path, it will exit with 11. If the OS is not aix linux, exit with 8.
getNetworkPath

# Read and save application information before upgrade
storeServerInstancesBefore

# all applications are closed. If all applications are not closed in the timeout period, it returns 6.
shutdownDomainController

# Existing Jboss domain configuration backup is taken. If an error occurs during backup, it will exit. If the process is closed by the script, the process is opened and exited.
getBackup

# If not simulation, fix is passed.
applyPatch

# Deletes the tmp files of applications if the pre-patch application list is read.
clearTempFiles

# start domain controller
startDomainController

# If the application list before patch is read, it will read it afterwards.
storeServerInstancesAfter

# it checks the previous and next situations.
controlServerInstances

# version information after patch is read
getJbossVersionAfter

#Exit with  Exit Code 0
print "$(hostname)-Everything is OK"
print "$(hostname)-Exit 0"
rm -rf "$CONTROLFOLDER"
exit 0
