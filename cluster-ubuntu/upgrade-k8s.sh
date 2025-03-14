#upgrade in all nodes to v1.32
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.32/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.32/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
apt-cache madison kubeadm
sudo apt-mark unhold kubelet kubeadm kubectl
sudo apt install -y  kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubectl kubeadm


#upgrade in one of the control plane
sudo kubeadm upgrade plan
sudo kubeadm upgrade apply 1.32

#upgrade in other nodes
sudo kubeadm upgrade node
