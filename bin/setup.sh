dir=`pwd`
cd ~
home=`pwd`

if [[ -f artDeply.sh ]]; then
 echo "running in the correct dir."
else 
  echo "Please run from the artifactory_deploy.sh.adligo.org git checkout's bin directory!"
fi

if [[ -d $home/artDeploy ]]; then
  echo "The directory $home/artDeploy exists "
else
  echo "Making directory $home/artDeploy "
  mkdir $home/artDeploy
fi

if [[ -f $home/artDeploy/artDeployProperties.sh ]]; then
  echo "The file $home/artDeploy/artDeployProperties.sh exists "
else
  echo "Creating file $home/artDeploy/artDeployProperties.sh "
  cp $dir/artDeployProperties.sh $home/artDeploy/artDeployProperties.sh
fi


echo "Overwriting file $home/artDeploy/artDeploy.sh "
cp $dir/artDeploy.sh $home/artDeploy/artDeploy.sh

echo "You must now add $home/artDeploy/artDeploy.sh to your path."