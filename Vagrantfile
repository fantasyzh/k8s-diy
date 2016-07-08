# -*- mode: ruby -*-
# # vi: set ft=ruby :

### manual config ###
$coreos_box = "coreos-alpha"
$coreos_box_version = "0"

$master_vm_memory = 512
$master_ip = "10.245.1.2"

$worker_count = 1
$worker_vm_memory = 1024

$pod_network = "10.246.0.0/16"
$service_network = "10.247.1.0/24"

### end config ###

def gen_worker_ips(master_ip, worker_count)
  pos = master_ip.rindex(".")
  worker_ip_base = master_ip[0..pos]
  worker_ip_offset = master_ip[pos+1...master_ip.size()].to_i() + 1
  worker_ips = worker_count.times.collect { |n| worker_ip_base + "#{worker_ip_offset+n}" }
end

$worker_ips = gen_worker_ips($master_ip, $worker_count)

# Generate root CA
system("mkdir -p ssl && ./init-ssl-ca ssl") or abort ("failed generating SSL artifacts")

# Generate admin key/cert
system("./init-ssl ssl admin kube-admin") or abort("failed generating admin SSL artifacts")

def provisionMachineSSL(machine,certBaseName,cn,ipAddrs)
  tarFile = "ssl/#{cn}.tar"
  ipString = ipAddrs.map.with_index { |ip, i| "IP.#{i+1}=#{ip}"}.join(",")
  system("./init-ssl ssl #{certBaseName} #{cn} #{ipString}") or abort("failed generating #{cn} SSL artifacts")
  machine.vm.provision :file, :source => tarFile, :destination => "/tmp/ssl.tar"
  machine.vm.provision :shell, :inline => "mkdir -p /etc/kubernetes/ssl && tar -C /etc/kubernetes/ssl -xf /tmp/ssl.tar", :privileged => true
end

Vagrant.configure("2") do |config|
  # always use Vagrant's insecure key
  config.ssh.insert_key = false

  config.vm.box = $coreos_box
  config.vm.box_version = $coreos_box_version

  config.vm.provider :virtualbox do |v|
    # On VirtualBox, we don't have guest additions or a functional vboxsf
    # in CoreOS, so tell Vagrant that so it can be smarter.
    v.check_guest_additions = false
    v.functional_vboxsf     = false
  end

  # plugin conflict
  if Vagrant.has_plugin?("vagrant-vbguest") then
    config.vbguest.auto_update = false
  end

  config.vm.provider :virtualbox do |vb|
    vb.cpus = 1
    vb.gui = false
  end

  master_vm_name = "master"
  config.vm.define master_vm_name do |master|
    master.vm.hostname = master_vm_name

    master.vm.provider :virtualbox do |vb|
      vb.memory = $master_vm_memory
    end

    master.vm.network :private_network, ip: $master_ip

    master.vm.synced_folder ".", "/vagrant", type: "nfs"

    provisionMachineSSL(master,"apiserver","kube-apiserver-#{$master_ip}",[$master_ip])

    #timedatectl set-timezone Asia/Shanghai
    master.vm.provision :shell, inline: "timedatectl set-timezone Asia/Shanghai", :privileged => true
    
    # deploy etcd
    master.vm.provision :shell, :path => "provision_etcd.sh", :args => $master_ip, :privileged => true

    # deploy flannel
    master.vm.provision :shell, :path => "provision_flannel.sh", :args => [ $master_ip, $pod_network ], :privileged => true

    # docker with flannel
    master.vm.provision :shell, :path => "provision_docker.sh", :privileged => true

    # kubelet
    master.vm.provision :shell, :path => "provision_kubelet.sh", :args => [ "master", $master_ip, $master_ip ], :privileged => true

    # kube-apiserver
    master.vm.provision :shell, :path => "provision_apiserver.sh", :args => [ $master_ip, $service_network ], :privileged => true

    # kube-proxy
    master.vm.provision :shell, :path => "provision_kube_proxy.sh", :args => [ "master", $master_ip ], :privileged => true

    # kube-controller-manager
    master.vm.provision :shell, :path => "provision_controller.sh", :privileged => true

    # kube-scheduler
    master.vm.provision :shell, :path => "provision_scheduler.sh", :privileged => true
  end

  (1..$worker_count).each do |i|
    worker_vm_name = "worker%d" % i
    config.vm.define worker_vm_name do |worker|
      worker.vm.hostname = worker_vm_name

      worker.vm.provider :virtualbox do |vb|
        vb.memory = $worker_vm_memory
      end

      worker_ip = $worker_ips[i-1]
      worker.vm.network :private_network, ip: worker_ip

      worker.vm.synced_folder ".", "/vagrant", type: "nfs"

      #timedatectl set-timezone Asia/Shanghai
      worker.vm.provision :shell, inline: "timedatectl set-timezone Asia/Shanghai", :privileged => true

      provisionMachineSSL(worker,"worker","kube-worker-#{worker_ip}",[worker_ip])

      # deploy flannel
      worker.vm.provision :shell, :path => "provision_flannel.sh", :args => [ $master_ip, $pod_network ], :privileged => true

      # docker with flannel
      worker.vm.provision :shell, :path => "provision_docker.sh", :privileged => true

      # kubelet
      worker.vm.provision :shell, :path => "provision_kubelet.sh", :args => [ "worker", worker_ip, $master_ip ], :privileged => true

      # kube-proxy
      worker.vm.provision :shell, :path => "provision_kube_proxy.sh", :args => [ "worker", $master_ip ], :privileged => true

    end
  end
end
