sudo kubeadm config images pull
#nginx load nalancer ip
export LOAD_BALANCER_DNS='192.168.64.14'
export LOAD_BALANCER_PORT='6443'
export POD_CIDR=10.244.0.0/16
export SERVICE_CIDR=10.96.0.0/16
sudo kubeadm init --control-plane-endpoint $LOAD_BALANCER_DNS:$LOAD_BALANCER_PORT --pod-network-cidr=$POD_CIDR --service-cidr=$SERVICE_CIDR --upload-certs


################################## expected similar output #####################################################
#You can now join any number of the control-plane node running the following command on each as root:

#  kubeadm join 192.168.64.14:6443 --token naq6pi.f1zina7s0shugles \
#--discovery-token-ca-cert-hash sha256:31e365a3d57fdacb7593524fd243ec40b0b95d7764aa132cfaef48239a076565 \
#--control-plane --certificate-key b4b1025d26826e1beac6956078320e16eb5ed480c89cbf69a40be8100c4ea5ae

#Please note that the certificate-key gives access to cluster sensitive data, keep it secret!
#As a safeguard, uploaded-certs will be deleted in two hours; If necessary, you can use
#"kubeadm init phase upload-certs --upload-certs" to reload certs afterward.

#Then you can join any number of worker nodes by running the following on each as root:

#kubeadm join 192.168.64.14:6443 --token naq6pi.f1zina7s0shugles \
#--discovery-token-ca-cert-hash sha256:31e365a3d57fdacb7593524fd243ec40b0b95d7764aa132cfaef48239a076565 
################################## expected similar output #####################################################

mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
kubectl get nodes -o wide
