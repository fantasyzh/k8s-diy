set -e
set -x
master_ip=$1
pod_network=$2
etcd_release=etcd-v2.3.7-linux-amd64
install -d /opt/etcd
install /vagrant/$etcd_release/etcd /opt/etcd/etcd
install /vagrant/$etcd_release/etcdctl /opt/etcd/etcdctl
sed -e "s/{{ master_ip }}/$master_ip/g" /vagrant/etcd2.service > /tmp/etcd2.service
cp /tmp/etcd2.service /etc/systemd/system/etcd2.service
systemctl enable etcd2
systemctl restart etcd2

until /opt/etcd/etcdctl --endpoints http://$master_ip:2379 ls ; do
    echo 'wait etcd ready...'
    sleep 0.1
done

/opt/etcd/etcdctl --endpoints http://$master_ip:2379 set /coreos.com/network/config "{\"Network\": \"$pod_network\", \"Backend\": { \"Type\": \"udp\" } }"
