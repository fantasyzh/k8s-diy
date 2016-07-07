set -e
set -x

role=$1
master_ip=$2

if [ $role == "master" ]; then
    master_endpoint="http://127.0.0.1:8080"
    specific_flags=
else
    master_endpoint="https://$master_ip"
    specific_flags="--kubeconfig=/etc/kubernetes/worker-kubeconfig.yaml"
    cp /vagrant/worker-kubeconfig.yaml /etc/kubernetes/worker-kubeconfig.yaml
fi

systemctl stop kube-proxy.service || true

install -d /opt/kube/
cp /vagrant/kubernetes/server/bin/kube-proxy /opt/kube/kube-proxy

sed -e "s#{{ master_endpoint }}#$master_endpoint#g" -e "s#{{ specific_flags }}#$specific_flags#g" /vagrant/kube-proxy.service > /tmp/kube-proxy.service
cp /tmp/kube-proxy.service /etc/systemd/system/kube-proxy.service
systemctl enable kube-proxy.service
systemctl restart kube-proxy.service
