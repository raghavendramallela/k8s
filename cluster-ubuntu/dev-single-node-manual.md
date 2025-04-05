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
openssl x509 -req -in etcd-server.csr -CA ca.crt -CAkey ca.key -CAcreateserial  -out etcd-server.crt -extensions v3_req -extfile etcd.cnf -days 20000
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
