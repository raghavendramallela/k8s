# join other control plane nodes via nginx load balancer endpoint
  kubeadm join 192.168.64.14:6443 --token naq6pi.f1zina7s0shugles \
--discovery-token-ca-cert-hash sha256:31e365a3d57fdacb7593524fd243ec40b0b95d7764aa132cfaef48239a076565 \
--control-plane --certificate-key b4b1025d26826e1beac6956078320e16eb5ed480c89cbf69a40be8100c4ea5ae


# join other worker nodes via nginx load balancer endpoint
kubeadm join 192.168.64.14:6443 --token naq6pi.f1zina7s0shugles \
--discovery-token-ca-cert-hash sha256:31e365a3d57fdacb7593524fd243ec40b0b95d7764aa132cfaef48239a076565 
