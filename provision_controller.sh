set -e
set -x

image_tag=`cat /vagrant/kubernetes/server/bin/kube-controller-manager.docker_tag`
docker load -i /vagrant/kubernetes/server/bin/kube-controller-manager.tar
sed -e "s/{{ controller_image_tag }}/$image_tag/g" /vagrant/kube-controller-manager.yaml > /tmp/kube-controller-manager.yaml
cp /tmp/kube-controller-manager.yaml /etc/kubernetes/manifests/kube-controller-manager.yaml
