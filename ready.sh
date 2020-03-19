#!/bin/bash

#关闭交换分区
sed 's#^/dev/mapper/centos-swap#\#/dev/mapper/centos-swap#' /etc/fstab
mount -a
swapoff --all

#关闭防火墙,注意要想永久关闭防火墙需要重启
sed -i '/^SELINUX=/d' /etc/selinux/config
sed -i '6 a\SELINUX=disabled\' /etc/selinux/config
setenforce 0
systemctl stop firewalld

#清空防火请
iptables -F && iptables -t nat -F

#添加hosts
echo 'k8s-master 192.168.1.240' >> /etc/hosts
echo 'k8s-node1 192.168.1.241' >> /etc/hosts
echo 'k8s-node2 192.168.1.242' >> /etc/hosts

#修改主机名就自己手动修改了。

#创建kubernetes项目存放目录
mkdir -p  /opt/kubernetes/{ssl,bin,cfg}

#测试提交更新


