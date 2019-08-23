#!/bin/bash

#安装好flannel在进行下一步操作

#书写配置文件
cat > /opt/kubernetes/cfg/flanneld << EOF
FLANNET_OPTIONS="--etcd-endpoints=https://192.168.1.240:2379,https://192.168.1.241:2379,https://192.168.1.242:2379 -etcd-cafile=/opt/kubernetes/ssl/ca.pem -etcd-certfile=/opt/kubernetes/ssl/server.pem -etcd-keyfile=/opt/kubernetes/ssl/server-key.pem"
EOF

cat > /usr/lib/systemd/system/flanneld.service << EOF
[Unit]
Description=flanneld overlay address etcd agent
After=network-online.target network.target
Before=docker.service

[Service]
Type=notify
EnvironmentFile=/opt/kubernetes/cfg/flanneld
ExecStart=/opt/kubernetes/bin/flanneld --ip-masq $FLANNET_OPTIONS
ExecStartPost=/opt/kubernetes/bin/mk-docker-opts.sh -k DOCKER_NETWORK_OPTIONS -d /run/flannel/subnet.env
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

#写入分配的子网段到etcd，供flanneld使用
/opt/kubernetes/bin/etcdctl --ca-file=/opt/ssl/ca.pem --cert-file=/opt/ssl/server.pem --key-file=/opt/ssl/server-key.pem --endpoints="https://192.168.1.240:2379,https://192.168.1.241:2379,https://192.168.1.242:2379" set /coreos.com/network/config '{ "Network": "172.17.0.0/16", "Backend": {"Type": "vxlan"}}'

#启动配置文件
systemctl  start  flanneld
systemctl enable flanneld

#查看网卡，flannel之前可以通信就成功了。



#配置docker为flannel网络

cat << EOF > /usr/lib/systemd/system/docker.service
[Unit]
Description=Docker Application Container Engine
Documentation=https://docs.docker.com
After=network-online.target firewalld.service
Wants=network-online.target

[Service]
Type=notify
EnvironmentFile=/run/flannel/subnet.env             
ExecStart=/usr/bin/dockerd $DOCKER_NETWORK_OPTIONS     
ExecReload=/bin/kill -s HUP $MAINPID
LimitNOFILE=infinity
LimitNPROC=infinity
LimitCORE=infinity
TimeoutStartSec=0
Delegate=yes
KillMode=process
Restart=on-failure
StartLimitBurst=3
StartLimitInterval=60s

[Install]
WantedBy=multi-user.target
EOF

#注意变量是否写进去了


#重启docker
systemctl restart docker
systemctl deamon-reload
systemctl restart docker

#集群中的docker网络相互可通就好了










