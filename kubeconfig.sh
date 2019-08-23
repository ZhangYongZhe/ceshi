#!/bin/bash
#生成token文件
export BOOTSTRAP_TOKEN=$(head -c 16 /dev/urandom | od -An -t x | tr -d ' ') 
cat > token.env << EOF
${BOOTSTRAP_TOKEN},kubelet-bootstrap,10001,"system:kubelet-bootstrap"
EOF

#安装kubectl命令生产配置文件
yum -y install kubernetes-client-1.5.2-0.7.git269f928.el7.x86_64

#创建kubelet bootstrapping kubeconfig
export KUBE_APISERVER="https://192.168.1.240:6443"
kubectl config set-cluster kubernetes \ 
--certificate-authority=./ca.pem \
--embed-certs=true  \ 
--server=${KUBE_APISERVER} \
--kubeconfig=bootstrap.kubeconfig         


#设置客户端认证参数
kubectl config set-credentials kubelet-bootstrap \
--token=${BOOTSTRAP_TOKEN} \
--kubeconfig=bootstrap.kubeconfig

#设置上下文参数
kubectl config set-context default \
--cluster=kubernetes \
--user=kubelet-bootstrap \
--kubeconfig=bootstrap.kubeconfig

#设置默认上下文参数
kubectl config use-context default --kubeconfig=bootstrap.kubeconfig 

#创建kube-proxy kubeconfig文件
kubectl config set-cluster kubernetes \
--certificate-authority=/opt/kubernetes/ssl/ca.pem \
--embed-certs=true \
--server=${KUBE_APISERVER} \
--kubeconfig=kube-proxy.kubeconfig

kubectl config set-credentials kube-proxy \
--client-certificate=/opt/ssl/kube-proxy.pem \
--client-key=/opt/ssl/kube-proxy-key.pem \
--embed-certs=true \
--kubeconfig=kube-proxy.kubeconfig

kubectl config set-context default \
--cluster=kubernetes \
--user=kube-proxy \
--kubeconfig=kube-proxy.kubeconfig

kubectl config use-context default --kubeconfig=kube-proxy.kubeconfig

#设置集群参数
kubectl config set-cluster kubernetes --certificate-authority=./ca.pem  --server=${KUBE_APISERVER}   --kubeconfig=kubelet.kubeconfig

#设置客户端认证参数
kubectl config set-credentials kubelet --token=4b143df0ba552dee11aa778ef6bd9cb2  --kubeconfig=kubelet.kubeconfig

#生成上下文参数
kubectl config set-context default --cluster=kubernetes --user=kubelet --kubeconfig=kubelet.kubeconfig

#切换默认上下文
kubectl config use-context default --kubeconfig=kubelet.kubeconfig









