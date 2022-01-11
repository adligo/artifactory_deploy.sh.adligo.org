
#
#  This script copys the artDeploy.sh, artDeployProperties.sh into the 
# user home directory under artDeploy. 
#
# --------------------- Apache License LICENSE-2.0 -------------------
#
#  Copyright 2022 Adligo Inc

#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.
#

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