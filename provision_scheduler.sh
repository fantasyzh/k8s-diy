
image_tag=`cat /vagrant/kubernetes/server/bin/kube-scheduler.docker_tag`
docker load -i /vagrant/kubernetes/server/bin/kube-scheduler.tar
sed -e "s/{{ scheduler_image_tag }}/$image_tag/g" /vagrant/kube-scheduler.yaml > /tmp/kube-scheduler.yaml
cp /tmp/kube-scheduler.yaml /etc/kubernetes/manifests/kube-scheduler.yaml
