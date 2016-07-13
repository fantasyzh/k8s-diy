# k8s-diy
DIY k8s deployment on vagrant and coreos


https://coreos.com/kubernetes/docs/latest/

etcd release:

https://github.com/coreos/etcd/releases/download/v2.3.7/etcd-v2.3.7-linux-amd64.tar.gz 

flannel release:

https://github.com/coreos/flannel/releases/download/v0.5.5/flannel-0.5.5-linux-amd64.tar.gz

api server:

https://10.245.1.2
http://localhost:8080/v1/version

kubectl config:

    curl -O https://storage.googleapis.com/kubernetes-release/release/v1.2.4/bin/darwin/amd64/kubectl

    ./kubectl config set-cluster default-cluster --server=https://10.245.1.2 --certificate-authority=ssl/ca.pem
    ./kubectl config set-credentials default-admin --certificate-authority=ssl/ca.pem --client-key=ssl/admin-key.pem --client-certificate=ssl/admin.pem
    ./kubectl config set-context default-system --cluster=default-cluster --user=default-admin
    ./kubectl config use-context default-system

create kube-system namespace:

    ./kubectl create namespace kube-system

start pods and svc:

    ./kubectl run my-nginx --image=nginx --replicas=1 --port=80
    ./kubectl scale deployments my-nginx --replicas=2
    ./kubectl expose deployments my-nginx
    ./kubectl patch svc my-nginx  -p '{"spec":{"type":"NodePort"}}'

access service in a pod:

    docker run busybox sh -c 'echo -e "GET / HTTP/1.1\r\nhost:10.247.1.157\r\n" | nc 10.247.1.157 80'
