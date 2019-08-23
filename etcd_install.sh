#!/bin/bash
cat > /opt/kubernetes/cfg/etcd << EOF
#[Member]
ETCD_NAME="etcd02"   #需要根据服务器修改
ETCD_DATA_DIR="/var/lib/etcd/default.etcd"
ETCD_LISTEN_PEER_URLS="https://192.168.1.241:2380"   #修改为本机IP
ETCD_LISTEN_CLIENT_URLS="https://192.168.1.241:2379"

#[Clustering]
ETCD_INITIAL_ADVERTISE_PEER_URLS="https://192.168.1.241:2380"    #修改为本机IP
ETCD_ADVERTISE_CLIENT_URLS="https://192.168.1.241:2379"      #修改为本机IP
ETCD_INITIAL_CLUSTER="etcd01=https://192.168.1.240:2380,etcd02=https://192.168.1.241:2380,etcd03=https://192.168.1.242:2380"
ETCD_INITIAL_CLUSTER_TOKEN="etcd-cluster"
ETCD_INITIAL_CLUSTER_STATE="new"
EOF

#配置启动文件不需要更改，这个通用的
cat > /usr/lib/systemd/system/etcd.service << EOF 
[Unit]
Description=Etcd Server
After=network.target
After=network-online.target
Wants=network-online.target

[Service]
Type=notify
WorkingDirectory=/var/lib/etcd/              
EnvironmentFile=-/opt/kubernetes/cfg/etcd
ExecStart=/opt/kubernetes/bin/etcd \
--name=${ETCD_NAME} \
--data-dir=${ETCD_DATA_DIR} \
--listen-peer-urls=${ETCD_LISTEN_PEER_URLS} \
--listen-client-urls=${ETCD_LISTEN_CLIENT_URLS},http://127.0.0.1:2379 \
--advertise-client-urls=${ETCD_ADVERTISE_CLIENT_URLS} \
--initial-advertise-peer-urls=${ETCD_INITIAL_ADVERTISE_PEER_URLS} \
--initial-cluster=${ETCD_INITIAL_CLUSTER} \
--initial-cluster-token=${ETCD_INITIAL_CLUSTER} \
--initial-cluster-state=new \
--cert-file=/opt/kubernetes/ssl/server.pem \
--key-file=/opt/kubernetes/ssl/server-key.pem \
--peer-cert-file=/opt/kubernetes/ssl/server.pem \
--peer-key-file=/opt/kubernetes/ssl/server-key.pem \
--trusted-ca-file=/opt/kubernetes/ssl/ca.pem \
--peer-trusted-ca-file=/opt/kubernetes/ssl/ca.pem
Restart=on-failure
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
EOF

#启动etcd集群
systemctl start etcd
systemctl enable etcd




















