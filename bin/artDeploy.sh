#!/bin/bash
#Expand new lines \n
shopt -s xpg_echo

loadProperties="y"
# Thanks https://medium.com/@Drew_Stokes/bash-argument-parsing-54f3b81a6a8f
while (( "$#" )); do
  case "$1" in
    -a | --artifactory_server)   artServer="$2" ; shift 2  ;;
    -b | --bearer_token) oauthToken="$2" ; shift 2  ;;
    -d | --debug)   debug=1 ; shift 1  ;;
    -e | --oauth_server) oauthServer="$2" ; shift 2  ;;
    -f | --from-local-repo) fromLocalRepo="y" ; shift 1  ;;
    -g | --art_path) artPath="$2" ; shift 2  ;;
    -h | --help) help="y" ; shift 1 ;;
    -i | --ignore-art-project) ignoreArtProject="y"; shift 1 ;;
    -l | --ignore_shared_properties) loadProperties="n" ; shift 1  ;;
    -m | --retry_seconds)   retrySecs="$2" ; shift 2  ;;
    -n | --gen-token-opts) genTokenOpts="$2" ; shift 2  ;;
    -o | --oauth_uid) oauthUid="$2" ; shift 2  ;;
    -p | --password)   password="$2" ; shift 2  ;;
    -r | --retrys)   retrys="$2" ; shift 2  ;;
    -s | --oauth_password) oauthPass="$2" ; shift 2  ;;
    -t | --auth_type)   authType="$2" ; shift 2  ;;
    -u | --uid)   uid="$2" ; shift 2  ;;
    -v | --version)   version="$2" ; shift 2  ;;
    -*|--*=) # unsupported flags
      echo "Error: Unsupported flag $1" >&2
      exit 1
      ;;
    *) # preserve positional arguments
      PARAMS="$PARAMS $1"
      shift
      ;;
  esac
done

if [[ "y" == "$loadProperties" ]]; then
  echo "loading defaults from deployProperties.sh "
  . ~/artDeploy/artDeployProperties.sh
fi

if [[ "y" == "$help" ]]; then
  echo "Welcome to the artDeploy.sh help, please contribute :) "
  echo "\n\n"
  echo "\n\nThe most common / conventional usage of this artDeploy.sh is to "
  echo "deploy to maven locally (i.e. Gradle's publishToMavenLocal task )"
  echo "then from your projects directory run "
  echo "./artDeploy.sh -f -v 123"
  echo "the artDeploy.sh script should be able to find everything it needs.  "
  echo "\n\nYou can set most things as environment variables"
  echo "in either ~/artDeploy/artDeployProperties.sh or "
  echo "your projects artProject.sh "
  exit 0
fi

if [[ "y" == "$ignoreArtProject" ]]; then
  echo "Ignoring ./artProject.sh"
else
  if [[ -f artProject.sh ]]; then
    echo "Loading ./artProject.sh  "
    . ./artProject.sh
  else
    echo "No ./artProject.sh found."
  fi
fi

# Overwrite the cli options using the values in ./deployProperties.sh when not present
# Alphabetized
if [[ -z $artServer ]]; then 
  artServer=$ART_SERVER
fi

if [[ -z $authType ]]; then 
  authType=$AUTH_TYPE
fi

if [[ -z $debug ]]; then 
  debug=$DEBUG
fi

if [[ -z $oauthPass ]]; then 
  oauthPass=$OAUTH_PASS
fi

if [[ -z $oauthServer ]]; then 
  oauthServer=$OAUTH_SERVER
fi

if [[ -z $oauthToken ]]; then 
  oauthToken=$OAUTH_TOKEN
elif [[ "none" == $oauthToken ]]; then
  oauthToken=""
fi

if [[ -z $oauthUid ]]; then 
  oauthUid=$OAUTH_UID
fi

if [[ -z $genTokenOpts ]]; then
  genTokenOpts=$GENERATE_TOKEN_OPTS
fi

if [[ -z $artPath ]]; then 
  artPath=$ART_PATH
fi

if [[ -z $password ]]; then 
  password=$PASSWORD
fi

if [[ -z $retrys ]]; then 
  retrys=$RETRYS
fi

if [[ -z retrySecs ]]; then 
  retrySecs=$RETRY_SECS
fi

if [[ -z $version ]]; then 
  version=$VERSION
fi

if [[ -z $uid ]]; then 
  uid=$UID
fi

#Begin Logic
if [[ "$debug" = "1" ]]; then
  echo "executing with parameters\n"
  echo "artServer=$artServer"
  echo "authType=$authType"
  echo "debug=$debug"
  echo "oauthPass=$oauthPass"
  echo "oauthToken=$OoauthToken"
  echo "oauthUid=$oauthUid"
  echo "artPath=$artPath"
  echo "password=$password"
  echo "retrys=$retrys"
  echo "retrySecs=$retrySecs"
  echo "password=$password"
  echo "uid=$uid"
  echo "version=$version"
fi
if [[ -z $version ]]; then
  echo No Version, exiting
  exit 1
fi

function exec {
    
  if [[ "$debug" = "1" ]]; then
    echo "executing\n$1"
  fi
  status=$?
  eval $1
  status=$?
  times=$(($retrys))
  if [[ $times -lt 1 ]]; then
    times=$((1))
  fi
  sleepTime=$(($retrySecs))
  if [[ sleepTime -lt 1 ]]; then
    sleepTime=$((10))
  fi  
  count=$((1))
  while [ $count -lt $times ]
  do
    echo "count is $count"
    if [[ $status == 0 ]]; then
      echo "command sucessful"
      return 0
    else
      echo "Waiting $sleepTime seconds ..."
      sleep $sleepTime
      eval $1
      status=$?
      count=$(($count+1))
    fi
  done
  
}

jar=target/`ls target | grep jar`
jarName=$jar
if [[ -z $fromLocalRepo ]]; then
  if [[ -f "$jar" ]]; then
    echo "Found $jarl file!"
  else
    echo "There is NO pom.xml file exiting;"
    exit 0;
  fi  
else
  jar="~/.m2/repository/$PROJECT_GROUP/$PROJECT_NAME/$version/$PROJECT_NAME-$version.jar"
  jarName=$PROJECT_NAME-$version.jar
fi


echo "Deploying the following to ART_SERVER is;"
echo "$artServer"
echo "deploying jar file $jar"

dir=`pwd`
pom=$dir/pom.xml
pomName=pom.xml
if [[ -z $fromLocalRepo ]]; then
  if [[ -f "pom.xml" ]]; then
    echo "Found pom.xml file!"
  else
    echo "There is NO pom.xml file exiting;"
    exit 0;
  fi
else 
  pom="~/.m2/repository/$PROJECT_GROUP/$PROJECT_NAME/$version/$PROJECT_NAME-$version.pom"
  artPath=$PROJECT_GROUP/$PROJECT_NAME
  pomName=$PROJECT_NAME-$version.pom
fi
echo "deploying pom file $pom"
echo "artPath is $artPath"

if [[ "simple" = "$authType" ]]; then 
  if [[ -z $password ]]; then
    read -s -p "Password: " password
  fi
  retrys=$(($retrys))
  if [[ $retrys -le 1 ]]; then
    echo "retrys are -le 1 running\ncurl -u $artUid:$password -X PUT \"$artServer/$groupPath/$version/$jar\" -T $jar"
    curl -u $artUid:$password -X PUT "$artServer/$groupPath/$version/$jar" -T target/$jar
    echo "retrys are -le 1 running\ncurl -u $artUid:$password -X PUT \"$artServer/$groupPath/$version/pom.xml\" -T $pom"
    curl -u $artUid:$password -X PUT "$artServer/$groupPath/$version/pom.xml" -T pom.xml
  else
    exec "curl -u $artUid:$password -X PUT \"$artServer/$groupPath/$version/$jar\" -T $jar"
    exec "curl -u $artUid:$password -X PUT \"$artServer/$groupPath/$version/pom.xml\" -T $pom"
  fi
  # note md5 checksums are hidden by default 
  # https://jfrog.com/knowledge-base/how-to-show-the-checksum-files-when-browsing-artifacts-from-the-direct-url/
elif [[ "oauth" = "$authType" ]]; then 
  if [[ -z $oauthUid ]]; then
    read -p "OAuth User Id: " oauthUid
  fi
  
  if [[ -z $oauthToken ]]; then
    if [[ -z $oauthPass ]]; then
      read -s -p "OAuth Password: " oauthPass
    fi
    
    status=$?
    cmd="curl -XPOST $oauthServer $generateTokenOpts --data-urlencode \"username=$oauthUid\"  --data-urlencode \"password=$oauthPass\""
    status=$?
    if [[ "0" == "$status" ]]; then
      echo "Unable to contatct the following server, is it down?"
      echo "$oauthServer"
      exit 0;
    fi
    oauthResponce=`eval $cmd`
    if [[ "$DEBUG" = "1" ]]; then
      echo "\n\oauthResponce\n$oauthResponce"
      echo "\n\n\n parsing token"
    fi
    oauthToken=`echo $oauthResponce | sed "s/{.*\"access_token\":\"\([^\"]*\).*}/\1/g"`
    echo "\n\n\nGot the following token;"
    echo $oauthToken
  else
    echo "Using provided oauthToken"
  fi
  retrys=$(($retrys))
  if [[ $retrys -le 1 ]]; then
    echo "retrys are -le 1 running\ncurl -u $oauthUid:$oauthToken -X PUT \"$artServer/$artPath/$version/$jarName\" -T $jar"
    curl -u $oauthUid:$oauthToken -X PUT "$artServer/$artPath/$version/$jarName" -T $jar
    echo "retrys are -le 1 running\ncurl -u $oauthUid:$oauthToken -X PUT \"$artServer/$artPath/$version/$pomName\" -T $pom"
    curl -u $oauthUid:$oauthToken -X PUT "$artServer/$artPath/$version/$pomName" -T $pom
  else
    exec "curl -u $oauthUid:$oauthToken -X PUT \"$artServer/$artPath/$version/$jarName\" -T $jar"
    exec "curl -u $oauthUid:$oauthToken -X PUT \"$artServer/$artPath/$version/$pomName\" -T $pom"
  fi
else
  echo "Unknown AUTH_TYPE must be one of (simple, oauth)"  
fi
