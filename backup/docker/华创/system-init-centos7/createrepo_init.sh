#!/bin/bash
rpm -ivh yumInstallPackage/deltarpm-3.6-3.el7.x86_64.rpm
rpm -ivh yumInstallPackage/libxml2-python-2.9.1-6.el7_2.3.x86_64.rpm
rpm -ivh yumInstallPackage/python-deltarpm-3.6-3.el7.x86_64.rpm
rpm -ivh yumInstallPackage/createrepo-0.9.9-28.el7.noarch.rpm

## check
createrepo

# backup
mkdir centos_repo_backup
mv /etc/yum.repos.d/* centos_repo_backup

touch /etc/yum.repos.d/local.repo
echo "[local_server]
name=This is a local repo
baseurl=file:///root/yumInstallPackage
enabled=1
gpgcheck=0" > /etc/yum.repos.d/local.repo

# setting local source
createrepo -d /root/yumInstallPackage/

yum repolist

yum clean all

yum makecache

yum list