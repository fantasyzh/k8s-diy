set -e
set -x
master_ip=$1
etcd_release=etcd-v2.3.7-linux-amd64
install -d /opt/etcd
install /vagrant/$etcd_release/etcd /opt/etcd/etcd
install /vagrant/$etcd_release/etcdctl /opt/etcd/etcdctl
sed "s/{{ master_ip }}/$master_ip/g" /vagrant/etcd2.service > /tmp/etcd2.service
cp /tmp/etcd2.service /etc/systemd/system/etcd2.service
systemctl enable etcd2
systemctl start etcd2
