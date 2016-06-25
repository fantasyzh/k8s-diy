set -e
set -x

role=$1
master_ip=$2

if [ $role == "master" ]; then
    specific_flags="--register-schedulable=false"
else
    specific_flags=
fi

install -d /opt/kube/
cp /vagrant/kubernetes/server/bin/kubelet /opt/kube/kubelet
set -e "s/{{ master_ip }}/$master_ip/g" -e "s/{{ specific_flags }}/$specific_flags/g" kubelet.service > /tmp/kubelet.service
cp /tmp/kubelet.service /etc/systemd/system/kubelet.service
systemctl enable kubelet.service
systemctl start kubelet.service
