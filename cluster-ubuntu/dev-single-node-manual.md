# ETCD
### install etcd
```sh
mkdir /root/binaries
cd /root/binaries
wget https://github.com/etcd-io/etcd/releases/download/v3.5.21/etcd-v3.5.21-linux-arm64.tar.gz
tar -xvf etcd-v3.5.21-linux-arm64.tar.gz
cd /root/binaries/etcd-v3.5.21-linux-arm64
mv etcd etcdctl /usr/local/bin/
```

### configure ca
```sh
mkdir /root/certificates
cd /root/certificates
#generate ca.key
openssl genrsa -out ca.key 2048
#generate ca.csr
openssl req -x509 -new -key ca.key -out ca.crt -subj "/CN=KUBERNETES-CA"
#sign csr
openssl x509 -req -in ca.csr -signkey ca.key -out ca.crt -days 20000
rm -f ca.csr
#verify ca.crt
openssl x509 -in ca.crt -text -noout
```

### configure etcd-server cert & key
```sh
#generate etcd-server.key
openssl genrsa -out etcd-server.key 2048
#generate etcd-server.cnf
cat > etcd-server.cnf <<EOF
[req]
req_extensions = v3_req
distinguished_name = req_distinguished_name
[req_distinguished_name]
[ v3_req ]
basicConstraints = CA:FALSE
keyUsage = nonRepudiation, digitalSignature, keyEncipherment
extendedKeyUsage = clientAuth, serverAuth
subjectAltName = @alt_names
[alt_names]
IP.1 = 192.168.64.21
IP.2 = 127.0.0.1
EOF
echo "change IP.1 to your etcd server IP (check using hostname -I) in etcd-server.cnf"
#generate etcd-server.csr
openssl req -new -key etcd-server.key -subj "/CN=etcd" -out etcd-server.csr -config etcd-server.cnf
#sign etcd-server.csr
openssl x509 -req -in etcd-server.csr -CA ca.crt -CAkey ca.key -CAcreateserial  -out etcd-server.crt -extensions v3_req -extfile etcd-server.cnf -days 20000
#verify etcd-server.crt
openssl x509 -in etcd-server.crt -text -noout
```

### configure etcd-client cert & key
```sh
#generate etcd-client.key
openssl genrsa -out etcd-client.key 2048
#generate etcd-client.csr
openssl req -new -key etcd-client.key -subj "/CN=client" -out etcd-client.csr
#sign etcd-client.csr
openssl x509 -req -in etcd-client.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out etcd-client.crt -extensions v3_req  -days 20000
#verify etcd-client.crt
openssl x509 -in etcd-client.crt -text -noout
```

### start etcd via systemd
```sh
mkdir /var/lib/etcd
chmod 700 /var/lib/etcd
cat <<EOF | sudo tee /etc/systemd/system/etcd.service
[Unit]
Description=etcd
Documentation=https://github.com/coreos

[Service]
ExecStart=/usr/local/bin/etcd \\
  --cert-file=/root/certificates/etcd-server.crt \\
  --key-file=/root/certificates/etcd-server.key \\
  --trusted-ca-file=/root/certificates/ca.crt \\
  --client-cert-auth \\
  --listen-client-urls https://127.0.0.1:2379 \\
  --advertise-client-urls https://127.0.0.1:2379 \\
  --data-dir=/var/lib/etcd
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable etcd
systemctl start etcd
systemctl status etcd
journalctl -u etcd
```

### check etcd via etcdctl
```sh
etcdctl --endpoints=https://127.0.0.1:2379 \
--cacert=/root/certificates/ca.crt \
--cert=/root/certificates/etcd-client.crt \
--key=/root/certificates/etcd-client.key \
put key1 "value1"

etcdctl --endpoints=https://127.0.0.1:2379 \
--cacert=/root/certificates/ca.crt \
--cert=/root/certificates/etcd-client.crt \
--key=/root/certificates/etcd-client.key \
get key1
```

# API-SERVER

### install apiserver:
```sh
cd /root/binaries/
wget https://dl.k8s.io/v1.32.3/kubernetes-server-linux-arm64.tar.gz
tar xzvf kubernetes-server-linux-arm64.tar.gz
cp apiextensions-apiserver kube-aggregator kube-apiserver kube-controller-manager kube-log-runner kube-proxy kube-scheduler kubeadm kubectl kubectl-convert kubelet mounter /usr/local/bin/
```
### generate client cert for api-server (etcd authentication):
```sh
cd /root/certificates
openssl genrsa -out api-etcd.key 2048
openssl req -new -key api-etcd.key -subj "/CN=kube-apiserver" -out api-etcd.csr
openssl x509 -req -in api-etcd.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out api-etcd.crt -days 2000
```

### generate certs for api-server:
```sh
cat <<EOF | sudo tee api.conf
[req]
req_extensions = v3_req
distinguished_name = req_distinguished_name
[req_distinguished_name]
[ v3_req ]
basicConstraints = CA:FALSE
keyUsage = nonRepudiation, digitalSignature, keyEncipherment
subjectAltName = @alt_names
[alt_names]
DNS.1 = kubernetes
DNS.2 = kubernetes.default
DNS.3 = kubernetes.default.svc
DNS.4 = kubernetes.default.svc.cluster.local
IP.1 = 127.0.0.1
IP.3 = 10.0.0.1
EOF

openssl genrsa -out kube-api.key 2048
openssl req -new -key kube-api.key -subj "/CN=kube-apiserver" -out kube-api.csr -config api.conf
openssl x509 -req -in kube-api.csr -CA ca.crt -CAkey ca.key -CAcreateserial  -out kube-api.crt -extensions v3_req -extfile api.conf -days 20000
```


### generate service account certs:
```sh
cd /root/certificates
openssl genrsa -out service-account.key 2048
openssl req -new -key service-account.key -subj "/CN=service-accounts" -out service-account.csr
openssl x509 -req -in service-account.csr -CA ca.crt -CAkey ca.key -CAcreateserial  -out service-account.crt -days 20000
```
### start api-server via systemd
```sh
cat <<EOF | sudo tee /etc/systemd/system/kube-apiserver.service
[Unit]
Description=Kubernetes API Server
Documentation=https://github.com/kubernetes/kubernetes

[Service]
ExecStart=/usr/local/bin/kube-apiserver \
--advertise-address=192.168.64.21 \
--tls-cert-file=/root/certificates/kube-api.crt \
--tls-private-key-file=/root/certificates/kube-api.key \
--etcd-cafile=/root/certificates/ca.crt \
--etcd-certfile=/root/certificates/api-etcd.crt \
--etcd-keyfile=/root/certificates/api-etcd.key \
--etcd-servers=https://127.0.0.1:2379 \
--service-account-key-file=/root/certificates/service-account.crt \
--service-cluster-ip-range=10.0.0.0/24 \
--service-account-signing-key-file=/root/certificates/service-account.key \
--service-account-issuer=https://127.0.0.1:6443

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable kube-apiserver
systemctl start kube-apiserver
systemctl status kube-apiserver
journalctl -u kube-apiserver
```
