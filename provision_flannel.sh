set -e
set -x

master_ip=$1

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
