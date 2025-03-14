sudo kubeadm config images pull
export POD_CIDR=10.244.0.0/16
export SERVICE_CIDR=10.96.0.0/16
sudo kubeadm init --apiserver-advertise-address=192.168.64.16 --pod-network-cidr=$POD_CIDR --service-cidr=$SERVICE_CIDR --upload-certs

################################## expected similar output #####################################################
#Your Kubernetes control-plane has initialized successfully!

#To start using your cluster, you need to run the following as a regular user:

#  mkdir -p $HOME/.kube
#  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
#  sudo chown $(id -u):$(id -g) $HOME/.kube/config

#You should now deploy a Pod network to the cluster.
#Run "kubectl apply -f [podnetwork].yaml" with one of the options listed at:
#  /docs/concepts/cluster-administration/addons/

#Please note that the certificate-key gives access to cluster sensitive data, keep it secret!
#As a safeguard, uploaded-certs will be deleted in two hours; If necessary, you can use
#"kubeadm init phase upload-certs --upload-certs" to reload certs afterward.

#You can join any number of worker nodes by running the following on each as root:

#kubeadm join 192.168.64.14:6443 --token naq6pi.f1zina7s0shugles \
#--discovery-token-ca-cert-hash sha256:31e365a3d57fdacb7593524fd243ec40b0b95d7764aa132cfaef48239a076565 
################################## expected similar output #####################################################

mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
kubectl get nodes -o wide
