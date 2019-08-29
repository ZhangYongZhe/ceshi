#!/bin/bash
#安装所需要的软件
yum -y install yum-utils device-mapper-persistent-data lvm2

#添加yum源
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

#安装docker软件
yum -y install docker-ce


systemctl start docker
systemctl enable docker

#书写json文件,指定加速镜像地址及私有仓库
cat > /etc/docker/daemon.json   << EOF 
{
  "registry-mirrors": [ "https://regitry.docker-cn.com" ],      
  "insecure-registries":["192.168.0.240:5000"]                
}
EOF

#启动docker
systemctl restart docker
