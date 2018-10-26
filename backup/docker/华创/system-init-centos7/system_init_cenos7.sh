#!/bin/bash

# Prompt installation wizard
# $1 Prompt message
# $2 Execution directory
# $3 Execute the command
function wizard()
{
	# echo $1
	# echo $2
	# echo $3
	read -p "Press 'y' or 'Y' to install $1,or another key to skip." OPTION
	if [[ $OPTION =~ ^'y'|'Y'$ ]];then
		echo "[INSTALL]'$1' will be install"
		if [ ! -z $3 ];then
			pushd $2
		fi
		sh $3


		if [ ! -z $2 ];then
			popd
		fi
	else
		echo "[INSTALL_SKIP]'$1' won't be install"
	fi
	OPTION=""
}



###
###
###
yum update -y

echo "install basic software"
yum install -y net-tools wget yum-utils vim iptables-services zip unzip nfs-utils rpcbind

echo "change HOSTNAME"
read -p "Input your HOSTNAME to be change.Press key 'Enter',if you won't be change." HOSTNAME
if [ ! -z $HOSTNAME ];then
	hostnamectl --static set-hostname $HOSTNAME
fi

echo "close selinux"
sed -i "s#SELINUX=enforcing#SELINUX=disabled#g" /etc/selinux/config

echo "close root remote login"
#sed -i "s/#PermitRootLogin yes/PermitRootLogin no/g" /etc/ssh/sshd_config

echo "add sa user"
useradd sa -d /home/sa -m -s /bin/bash
passwd sa
echo "sa      ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

echo "close firewalld"
systemctl stop firewalld
systemctl disable firewalld



echo ""

wizard "dns server" templates/dns init.sh
wizard "docker" templates/docker init.sh
wizard "docker swarm mode" templates/swarm init.sh


echo "reboot"
#reboot -h now