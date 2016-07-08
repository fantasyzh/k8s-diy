set -e
set -x

role=$1
advertise_ip=$2
master_ip=$3

if [ $role == "master" ]; then
    specific_flags="--api-servers=http://127.0.0.1:8080 --register-schedulable=false"
else
    specific_flags="--api-servers=https://$master_ip --register-node=true --tls-cert-file=/etc/kubernetes/ssl/worker.pem --tls-private-key-file=/etc/kubernetes/ssl/worker-key.pem --kubeconfig=/etc/kubernetes/worker-kubeconfig.yaml"
    cp /vagrant/worker-kubeconfig.yaml /etc/kubernetes/worker-kubeconfig.yaml
fi

systemctl stop kubelet.service || true

install -d /opt/kube/
cp /vagrant/kubernetes/server/bin/kubelet /opt/kube/kubelet
sed -e "s/{{ advertise_ip }}/$advertise_ip/g" -e "s#{{ specific_flags }}#$specific_flags#g" /vagrant/kubelet.service > /tmp/kubelet.service
cp /tmp/kubelet.service /etc/systemd/system/kubelet.service
systemctl enable kubelet.service
systemctl restart kubelet.service

docker load -i "/vagrant/kubernetes/addons/gcr.io~google_containers~pause:2.0.tar"
