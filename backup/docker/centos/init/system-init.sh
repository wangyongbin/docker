#!/bin/bash

# [User by root]
# step1 install software
# step2 change yum-source and update
# step3 change HOSTNAME
# step4 disable and stop selinxyum update -y
# step5 enable and start iptables
# step6 disabled root signin from remote
# step7 add user sa and configuration
# step8 install software from templates
# step9 reboot

# step1
curl http://mirrors.aliyun.com/repo/Centos-7.repo -o ~/CentOS-Base.repo --progress
mv /etc/yum.repos.d/CentOS-Base.repo  /etc/yum.repos.d/CentOS-Base.repo_backup
mv ~/CentOS-Base.repo /etc/yum.repos.d/


# step2
yum install -y net-tools wget yum-utils vim iptables-services zip unzip nfs-utils rpcbind

# step3
read -p "Input your HOSTNAME to be change.Press key 'Enter',if you won't be change." HOSTNAME
if [ ! -z $HOSTNAME ];then
	hostnamectl --static set-hostname $HOSTNAME
fi

# step4 --需要reboot
# 关闭selinux
sed -i "s#SELINUX=enforcing#SELINUX=disabled#g" /etc/selinux/config
log "[INFO]seLinux was disabled."

# step6 --需要reload
# 关闭root远程登录
sed -i "s/#PermitRootLogin yes/PermitRootLogin no/g" /etc/ssh/sshd_config
log "[INFO]User 'root' remote signin was disabled."

# step7

# 添加用户
# $1 用户名 必需的
# $2 是否加入sudo 可选 默认不加入
function userAdd(){
	echo "添加用户'$1'."
	useradd $1 -d /home/$1 -m -s /bin/bash

	echo "设置用户密码 '$1'."
	passwd $1

	echo "添加'$1'用户到docker组"
	usermod -aG docker $1

	if [ !-z $2 ];then
		if [ $2 = 1 ];then
			echo "$1      ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
		fi
	fi
}

echo "添加系统管理员"
userAdd sa 1

echo "添加docker 用户"
userAdd docker 1

# step8 关闭防火墙
systemctl stop firewalld
systemctl disable firewalld

#step9
echo "[INFO]System will be reboot"
reboot -h now