# artifactory_deploy.sh.adligo.org
This project contains a reusable bash shell script for deploying artifacts up to a Artifactory server through it's REST API.

To use this project 
run bin/setup.sh

then add artDeploy.sh to your path

# Optional install a Artifactory server;
First edit your .bash_profile or equivalant to have;
- ```JFROG_HOME=~/jfrog```

Make sure you have this loaded 
-  ```. ~/.bash_profile```
- ```echo $JFROG_HOME```

Also make sure this directory exists
- ```cd```
- ```mkdir jfrog```

Simply run it, if you need to upload jars do it through the web GUI!
- ``` docker run -d --name artifactorHens -p 8081:8081 -v $JFROG_HOME/data:/opt/artifactory_data lolhens/artifactory ```
