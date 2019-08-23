#!/bin/bash


#安装生成证书命令cfssl

case $1 in

     cfssl)
          wget -4 https://pkg.cfssl.org/R1.2/cfssl_linux-amd64 -P /usr/local/src
          wget -4 https://pkg.cfssl.org/R1.2/cfssljson_linux-amd64 
          wget -4 https://pkg.cfssl.org/R1.2/cfssl-certinfo_linux-amd64 
          mv /usr/local/srccfssl_linux-amd64 /usr/bin/cfssl
          mv /usr/local/srccfssljson_linux-amd64 /usr/bin/cfssljson
          mv /usr/local/srccfssl-certinfo_linux-amd64 /usr/bin/cfssl-certinfo
          chmod +x /usr/bin/cfssl*
          ;;
        ca)
          mkdir /opt/ssl && cd /opt/ssl
          cfssl print-defaults config > ca-config.json 
          cfssl print-defaults csr > ca-csr.json
          cat > ca-config.json << EOF                   
          {
              "signing": {
                  "default": {
                      "expiry": "87600h"               
                  },
                  "profiles": {
                      "kubernetes": {
                          "expiry": "87600h",
                          "usages": [
                              "signing",
                              "key encipherment",
                              "server auth"
                          ]
                      }
                  }
              }
          }
          
EOF
          
          cat > ca-csr.json << EOF
          {
              "CN": "kubernetes",
              "key": {
                  "algo": "rsa",
                  "size": 2048
              },
              "names": [
                  {
                      "C": "CN",
                      "L": "BeiJing",
                      "ST": "BeiJing",
                      "O": "K8s",                
                      "OU": "System"
                  }
              ]
          }
EOF
    
          cfssl gencert -initca ca-csr.json |cfssljson -bare ca -
          ;;

          #生成server证书和私钥
    server)
          cfssl print-defaults csr > server-csr.json
          cat > server-csr.json << EOF                     
          {
              "CN": "kubernetes",          
              "hosts": [
                  "127.0.0.1",
                  "192.168.1.240",
                  "192.168.1.241",
                  "192.168.1.242",
                  "kubernetes.default",
                  "kubernetes.default.svc",
                  "kubernetes.default.svc.cluster",
                  "kubernetes.default.svc.cluster.local"
              ],
              "key": {
                  "algo": "rsa",
                  "size": 2048
              },
              "names": [
                  {
                      "C": "CN",
                      "L": "Beijing",
                      "ST": "Beijing",
                      "O": "K8s",     
                      "OU": "System"  
                  }
              ]
          }
EOF
          cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -profile=kubernetes server-csr.json |cfssljson -bare server     
          ;;

          #生成clinet证书和私钥
     clinet)
           cfssl print-defaults csr > admin-csr.json
           cat > admin-csr.json  << EOF                                           
           {
               "CN": "admin",
               "hosts": [],
               "key": {
                   "algo": "rsa",
                   "size": 2048
               },
               "names": [
                   {
                       "C": "CN",
                       "L": "BeiJing",
                       "ST": "BeiJing",
                       "O": "System:master",
                       "OU": "System"
                   }
               ]
           }
EOF

           cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -profile=kubernetes admin-csr.json |cfssljson  -bare admin
           ;;
  
         #生成proxy证书秘钥
      proxy)
           cfssl print-defaults csr > kube-proxy-csr.json
           cat > kube-proxy-csr.json << EOF
           {
               "CN": "system:kube-proxy",
               "hosts": [],
               "key": {
                   "algo": "rsa",
                   "size": 2048
               },
               "names": [
                   {
                       "C": "CN",
                       "L": "BeiJing",
                       "ST": "BeiJing",
                       "O": "K8s",
                       "OU": "System"
                   }
               ]
           }
EOF

           cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -profile=kubernetes kube-proxy-csr.json  | cfssljson -bare kube-proxy

           ;;

         #命令和证书全部一起生成
       all)
          $0 cfssl
          sleep 1
          $0 ca
          sleep 1
          $0 server
          sleep 1
          $0 clinet
          sleep 1
          $0 proxy
          ;;
         *)
          echo "Usage: {cfssl | ca | server | clinet | proxy | all}"
          exit 1
          ;;
esac











