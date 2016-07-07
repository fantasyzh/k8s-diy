role=$1
master_ip=$1

if [ $role == "master" ]; then
    master_endpoint="http://127.0.0.1:8080"
else
    master_endpoint="https://$master_ip"
    cp /vagrant/worker-kubeconfig.yaml /etc/kubernetes/worker-kubeconfig.yaml
fi
image_tag=`cat /vagrant/kubernetes/server/bin/kube-proxy.docker_tag`
docker load -i /vagrant/kubernetes/server/bin/kube-proxy.tar
sed -e "s#{{ master_endpoint }}#$master_endpoint#g" -e "s/{{ proxy_image_tag }}/$image_tag/g" /vagrant/kube-proxy.yaml > /tmp/kube-proxy.yaml
cp /tmp/kube-proxy.yaml /etc/kubernetes/manifests/kube-proxy.yaml

