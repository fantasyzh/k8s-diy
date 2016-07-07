set -e
set -x

master_ip=$1
pod_network=$2

# prepare etcd config
sed "s#{{ pod_network }}#$pod_network#g" /vagrant/flannel_config.json > /tmp/flannel_config.json
/opt/etcd/etcdctl --endpoints http://$master_ip:2379 set /coreos.com/network/config "`cat /tmp/flannel_config.json`"

flannel_release=flannel-0.5.5
install -d /opt/flannel
install /vagrant/$flannel_release/flanneld /opt/flannel/flanneld
sed "s/{{ master_ip }}/$master_ip/g" /vagrant/flanneld.service > /tmp/flanneld.service
systemctl stop flanneld
systemctl disable flanneld
cp /tmp/flanneld.service /etc/systemd/system/flanneld.service
systemctl daemon-reload
systemctl enable flanneld
systemctl start flanneld
