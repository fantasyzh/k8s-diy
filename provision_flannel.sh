set -e
set -x

master_ip=$1
pod_network=$2

# prepare etcd client
etcd_release=etcd-v2.3.7-linux-amd64
install -d /opt/etcd
install /vagrant/$etcd_release/etcdctl /opt/etcd/etcdctl
sed "s#{{ pod_network }}#$pod_network#g" /vagrant/flannel_config.json > /tmp/flannel_config.json
/opt/etcd/etcdctl --endpoints http://$master_ip:2379 set /coreos.com/network/config "`cat /tmp/flannel_config.json`"

flannel_release=flannel-0.5.5
install -d /opt/flannel
install /vagrant/$flannel_release/flanneld /opt/flannel/flanneld
install /vagrant/$flannel_release/mk-docker-opts.sh /opt/flannel/mk-docker-opts.sh
sed "s/{{ master_ip }}/$master_ip/g" /vagrant/flanneld.service > /tmp/flanneld.service
systemctl stop flanneld || true
systemctl disable flanneld || true
cp /tmp/flanneld.service /etc/systemd/system/flanneld.service
systemctl daemon-reload
systemctl enable flanneld
systemctl restart flanneld
