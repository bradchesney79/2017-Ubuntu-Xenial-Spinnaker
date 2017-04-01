#!/bin/bash

# LINKS:

# https://github.com/spinnaker/spinnaker
# https://github.com/spinnaker/deck

# http://techblog.netflix.com/2016/03/how-we-build-code-at-netflix.html


# INSTALL:

# Start with a desktop (not server) Ubuntu 16.04 LTS installation

## Bring in the config file
#. setup.conf

# Update the timezone to UTC to match everything else
timedatectl set-timezone UTC

# Update the sources
cat << EOF > /etc/apt/sources.list
#------------------------------------------------------------------------------#
#                            OFFICIAL UBUNTU REPOS                             #
#------------------------------------------------------------------------------#


###### Ubuntu Main Repos
deb http://us.archive.ubuntu.com/ubuntu/ xenial main restricted universe multiverse 

###### Ubuntu Update Repos
deb http://us.archive.ubuntu.com/ubuntu/ xenial-security main restricted universe multiverse 
deb http://us.archive.ubuntu.com/ubuntu/ xenial-updates main restricted universe multiverse 
deb http://us.archive.ubuntu.com/ubuntu/ xenial-backports main restricted universe multiverse 

###### Ubuntu Partner Repo
deb http://archive.canonical.com/ubuntu xenial partner

#------------------------------------------------------------------------------#
#                           UNOFFICIAL UBUNTU REPOS                            #
#------------------------------------------------------------------------------#


###### 3rd Party Binary Repos

#### Oracle Java (JDK) Installer PPA - http://www.webupd8.org/2012/01/install-oracle-java-jdk-7-in-ubuntu-via.html
## Run this command: sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys EEA14886
deb http://ppa.launchpad.net/webupd8team/java/ubuntu vivid main

#### Docker PPA
## Run this command: sudo apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
deb https://apt.dockerproject.org/repo ubuntu-xenial main

#### Redis PPA
## Run this command: sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys C7917B12
deb http://ppa.launchpad.net/chris-lea/redis-server/ubuntu xenial main

#### Datastax Cassandra PPA
## Run this command: sudo curl -L https://debian.datastax.com/debian/repo_key | sudo apt-key add -
deb http://debian.datastax.com/community stable main

#### Nodesource NodeJS PPA
## Run this command: sudo curl -s https://deb.nodesource.com/gpgkey/nodesource.gpg.key | sudo apt-key add -
deb https://deb.nodesource.com/node_6.x xenial main

#### Google Chrome PPA
## Run this command: sudo wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main

#### Yarn PPA
## Run this command: sudo curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
deb https://dl.yarnpkg.com/debian/ stable main
EOF

# Add the PGP keys for the above repos
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys EEA14886
apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys C7917B12
curl -L https://debian.datastax.com/debian/repo_key | apt-key add -
curl -s https://deb.nodesource.com/gpgkey/nodesource.gpg.key | apt-key add -
wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -

# Prepare to wait, a long time (work on your documentation)
apt-get update && apt-get -y dist-upgrade

# Designate which repo you want the docker packages to originate from
apt-cache policy docker-engine

# Install the packages for the nice-to-haves and foundation of things
apt-get -y install ssh tmux curl git python3 python-pip vim software-properties-common redis-server nodejs yarn

apt-get -y --allow-unauthenticated install docker-engine

cd /tmp ## Unnecessary rigormarole for installing Cassandra DB
wget http://launchpadlibrarian.net/109052632/python-support_1.0.15_all.deb
dpkg -i python-support_1.0.15_all.deb
apt-get -y install dsc30 cassandra-tools

pip install --upgrade pip

# Install the aws-cli
pip install --upgrade --user awscli

###Spinnaker Prerequisites

# Install Java
echo debconf shared/accepted-oracle-license-v1-1 select true | debconf-set-selections
echo debconf shared/accepted-oracle-license-v1-1 seen true | debconf-set-selections
apt-get install oracle-java8-installer
export JAVA_HOME="/usr/lib/jvm/java-8-oracle"
echo "JAVA_HOME=/usr/lib/jvm/java-8-oracle" >> /etc/environment

# Configure Redis
sysctl vm.overcommit_memory=1
echo "" >> /etc/sysctl.conf
echo "###################################################################" >> /etc/sysctl.conf
echo "# This setting improves the performance of Redis" >> /etc/sysctl.conf
echo "vm.overcommit_memory=1" >> /etc/sysctl.conf
###! For a more understanding about adding security features:
###! https://redis.io/topics/security

# Install Cassandra
# Seems done...

#Install Packer
mkdir -p /tmp/packer
mkdir -p /usr/local/packer
curl https://releases.hashicorp.com/packer/0.12.3/packer_0.12.3_linux_amd64.zip?_ga=1.259633935.42358251.1490481149 > /tmp/packer/packer-0.12.3.zip


EXPECTED_SIGNATURE="d11c7ff78f546abaced4fcc7828f59ba1346e88276326d234b7afed32c9578fe /tmp/packer/packer-0.12.3.zip"
ACTUAL_SIGNATURE=$(shasum -a256 /tmp/packer/packer-0.12.3.zip)

if test "$EXPECTED_SIGNATURE"="$ACTUAL_SIGNATURE"
then
    unzip /tmp/packer/packer-0.12.3.zip -d /usr/local/bin/
    echo "Packer installed"
else
    >&2 echo 'ERROR: Invalid install signature'
    echo "Sorry buckaroo, the curl done failed"
fi
rm -rf /tmp/packer

# Install nvm
curl https://raw.githubusercontent.com/creationix/nvm/master/install.sh | sh

# Install nodejs (I install more than I need to prevent warning messages: iojs, argon, & v7.0.0 seem to be extra)
nvm install iojs
nvm install argon
nvm install v7.0.0
nvm install v7.7.4
nvm install v6.10.1
nvm use v6.10.1


# Set the Spinnaker Home/Workspace
export SPINNAKER_HOME=/home/spinnaker
echo "SPINNAKER_HOME=/home/spinnaker" >> /etc/environment

# Start Loading Spinnaker
cd /home/spinnaker
git clone https://github.com/spinnaker/spinnaker.git

spinnaker/dev/install_development.sh
spinnaker/dev/bootstrap_dev.sh

cd $SPINNAKER_HOME
mkdir -p $HOME/.spinnaker
#touch $HOME/.spinnaker/spinnaker-local.yml
cp spinnaker/config/spinnaker.yml $HOME/.spinnaker/spinnaker-local.yml
chmod 600 $HOME/.spinnaker/spinnaker-local.yml

# Add Spinnaker UI
mkdir -p /var/www
git clone https://github.com/spinnaker/deck.git
cd /var/www/deck
yarn

# Clean Up and Clear Out Junk
apt-get autoremove

# Start all the things
API_HOST=http://localhost:8084 yarn run start # Starts the server on http://localhost:9000
