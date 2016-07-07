master_ip=$1
service_ip_range=$2

advertise_ip=$master_ip
etcd_endpoints=http://$master_ip:2379

image_tag=`cat /vagrant/kubernetes/server/bin/kube-apiserver.docker_tag`
docker load -i /vagrant/kubernetes/server/bin/kube-apiserver.tar
sed -e "s#{{ etcd_endpoints }}#$etcd_endpoints#g" -e "s#{{ service_ip_range }}#$service_ip_range#g" -e "s/{{ advertise_ip }}/$advertise_ip/g" -e "s/{{ apiserver_image_tag }}/$image_tag/g" /vagrant/kube-apiserver.yaml > /tmp/kube-apiserver.yaml
cp /tmp/kube-apiserver.yaml /etc/kubernetes/manifests/kube-apiserver.yaml
