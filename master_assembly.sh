#!/bin/bash
cd /usr/local/src/ && tar zxvf kubernetes-server-linux-amd64.tar.gz
cd /usr/local/src/kubernetes/server/bin/
mv kube-apiserver kube-controller-manager kubectl kube-scheduler /opt/kubernetes/bin/

#书写kube-apiserver的启动脚本
mkdir /opt/master_pkg  && cd /opt/master_pkg

cat <<EOF > apiserver.sh 
#!/bin/bash

MASTER_ADDRESS=${1:-"192.168.1.240"}
ETCD_SERVERS=${2:-"HTTP://127.0.0.1:2379"}


echo 'KUBE_APISERVER_OPTS="--logtostderr=true
--v=4
--log-dir=/var/log/kubernetes/apiserver
--etcd-servers=${ETCD_SERVERS}
--insecure-bind-address=127.0.0.1
--bind-address=${MASTER_ADDRESS}
--insecure-port=8080
--secure-port=6443
--advertise-address=${MASTER_ADDRESS}
--allow-privileged=true
--service-cluster-ip-range=10.10.10.0/24
--admission-control=NamespaceLifecycle,LimitRanger,SecurityContextDeny,ServiceAccount,ResourceQuota,NodeRestriction
--authorization-mode=RBAC,Node
--kubelet-https=true
--enable-bootstrap-token-auth
--token-auth-file=/opt/kubernetes/cfg/token.csv
--service-node-port-range=30000-50000
--tls-cert-file=/opt/kubernetes/ssl/server.pem
--tls-private-key-file=/opt/kubernetes/ssl/server-key.pem
--client-ca-file=/opt/kubernetes/ssl/ca.pem
--service-account-key-file=/opt/kubernetes/ssl/ca-key.pem
--etcd-cafile=/opt/kubernetes/ssl/ca.pem
--etcd-certfile=/opt/kubernetes/ssl/server.pem
--etcd-keyfile=/opt/kubernetes/ssl/server-key.pem"' > /opt/kubernetes/cfg/kube-apiserver

echo '[Unit]
Description=kubernetes API Server
Documentation=https://github.com/kubernetes/kubernetes

[Service]
EnvironmentFile=-/opt/kubernetes/cfg/kube-apiserver
ExecStart=/opt/kubernetes/bin/kube-apiserver \$KUBE_APISERVER_OPTS
Restart=on-failure

[Install]
WantedBy=multi-user.target' > /usr/lib/systemd/system/kube-apiserver.service
EOF

systemctl daemon-reload
systemctl enable kube-apiserver
systemctl restart kube-apiserver

#启动命令（./apiserver.sh 192.168.1.240 https://192.168.1.240:2379,https://192.168.1.241:2379,https://192.168.1.242:2379）


#书写kube-controller-manager启动文件
cat > controller-manager.sh << EOF
#!/bin/bash

MASTER_ADDRESS=${1:-"127.0.0.1"}

echo 'KUBE_CONTROLLER_MANAGER_OPTS="--logtostderr=true
--v=4
--master=${MASTER_ADDRESS}:8080
--leader-elect=true
--address=127.0.0.1
--service-cluster-ip-range=10.10.10.0/24
--cluster-name=kubernetes
--cluster-signing-cert-file=/opt/kubernetes/ssl/ca.pem
--cluster-signing-key-file=/opt/kubernetes/ssl/ca-key.pem
--service-account-private-key-file=/opt/kubernetes/ssl/ca-key.pem
--root-ca-file=/opt/kubernetes/ssl/ca.pem"' > /opt/kubernetes/cfg/kube-controller-manager
 
echo '[Unit]
Description=kubernetes API Server
Documentation=https://github.com/kubernetes/kubernetes

[Service]
EnvironmentFile=-/opt/kubernetes/cfg/kube-controller-manager
ExecStart=/opt/kubernetes/bin/kube-controller-manager \$KUBE_CONTROLLER_MANAGER_OPTS
Restart=on-failure

[Install]
WantedBy=multi-user.target' > /usr/lib/systemd/system/kube-controller-manager.service

EOF

systemctl daemon-reload
systemctl enable kube-controller-manager
systemctl restart kube-controller-manager

#启动脚本的命令（bash ./controller-manager.sh 127.0.0.1）

#书写kube-scheduler启动文件

cat > scheduler.sh << EOF
#!/bin/bash

MASTER_ADDRESS=${1:-"127.0.0.1"}
echo 'KUBE_SCHEDULER_OPTS="--logtostderr=true \\
--v=4 \\
--master=${MASTER_ADDRESS}:8080 \\
--leader-elect"' > /opt/kubernetes/cfg/kube-scheduler

echo '[Unit]
Description=kubernetes  
Documentation=https://github.com/kubernetes/kubernetes

[Service]
EnvironmentFile=-/opt/kubernetes/cfg/kube-scheduler
ExecStart=/opt/kubernetes/bin/kube-scheduler \$KUBE_SCHEDULER_OPTS
Restart=on-failure

[Install]
WantedBy=multi-user.target' > /usr/lib/systemd/system/kube-scheduler.service

systemctl daemon-reload
systemctl enable kube-scheduler
systemctl restart kube-scheduler
EOF

#动脚本的命令(bash ./scheduler.sh 127.0.0.1)


#查看集群状态（kubectl get cs）





