# -*- mode: ruby -*-
# vi: set ft=ruby :
#https://dev.to/kennibravo/vagrant-for-beginners-getting-started-with-examples-jlm
#https://gist.github.com/hodak/4b5256ac0d3f3b11c51ee5309e60367d
#https://developer.hashicorp.com/vagrant/docs/networking/forwarded_ports

NUM_NODES = 3
IP_NTW = "192.168.56."
NODE_IP_START = 8

Vagrant.configure("2") do |config|
    config.vm.box = "ubuntu/jammy64"
    id_rsa_pub = File.read("#{Dir.home}/.ssh/id_rsa.pub")

    (1..NUM_NODES).each do |i|
        config.vm.define "rke20#{i}" do |node|
        config.vm.provision "copy ssh public key", type: "shell",
        inline: "echo \"#{id_rsa_pub}\" >> /home/vagrant/.ssh/authorized_keys"
        config.vm.network "forwarded_port", guest: 6443, host: 6443,
        auto_correct: true
        config.vm.network "forwarded_port", guest: 9345, host: 9345,
        auto_correct: true
            node.vm.provider "virtualbox" do |vb|
                vb.name = "rke20#{i}"
                vb.memory = 2048
                vb.cpus = 2
            end

            node.vm.hostname = "rke20#{i}"
            node.vm.network "private_network", ip: IP_NTW + "#{NODE_IP_START + i}"
            node.vm.network "forwarded_port", guest: 22, host: "#{2720 + i}"

        end
    end

end