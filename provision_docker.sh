set -e
set -x

systemctl stop docker || true
systemctl disable docker || true
cp /vagrant/docker.service /etc/systemd/system/docker.service
systemctl daemon-reload
systemctl enable docker
systemctl start docker
