#nginx-lb
sudo apt update
sudo apt install -y nginx nginx-extras

#sudo vi /etc/nginx/nginx.conf
#add following after 'events' block

# ## Load balancer for Kubernetes API Server
# stream {
#     upstream kubernetes {
#     server 192.168.64.16:6443;
#     server 192.168.64.8:6443;
#     server 192.168.64.10:6443;
#     }
# 
# 
#     server {
#         listen 6443;
#         proxy_pass kubernetes;
#     }
# }

sudo nginx -t
sudo systemctl restart nginx

#check connection at control plane nodes
#nc -v $LOAD_BALANCER_DNS 6443
