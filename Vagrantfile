#
# -*- mode: ruby -*-
# vi: set ft=ruby :

required_plugins = %w( vagrant-vbguest vagrant-reload )
isInstallPlugin = false;
required_plugins.each do |plugin|
  unless Vagrant.has_plugin? plugin || Argv[0] == 'plugin'
    print "#{plugin} is missing!\n"
    system "vagrant plugin install #{plugin}"
    isInstallPlugin = true;
  end
end
if isInstallPlugin
  exec "vagrant #{ARGV.join(" ")}'"
end

Vagrant.configure("2") do |config|
  config.vm.box = "centos/7"
  config.vm.network :forwarded_port, id: "ssh", guest: 22, host: 2020
  config.vm.network :forwarded_port, guest: 80, host: 8080
  config.vm.hostname = "ecsdev.local"
  config.vm.network :private_network, ip: "192.168.33.10"
  config.vm.synced_folder ".", "/vagrant", type: "virtualbox"
  config.vm.provider "virtualbox" do |vb|
    vb.memory = "4096"
  end
  config.vm.provision "shell", inline: <<-SHELL
    # stable network interface
    systemctl restart network.service
    # update yum repository
    yum update -y
    # install docker for developing environment
    curl -fsSL get.docker.com -o /tmp/get-docker.sh
    sh /tmp/get-docker.sh
    rm -f /tmp/get-docker.sh
    # add docker group for user:vagrant to be able to execute docker command
    groupadd -f docker
    usermod -aG docker vagrant
    systemctl enable docker
    systemctl restart docker
    # install docker-compose
    # check if following version is latest
    curl -L https://github.com/docker/compose/releases/download/1.16.1/docker-compose-`uname  -s`-`uname -m` > /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
    # disable SELinux
    # temporal
    setenforce 0
    # eternal
    sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/sysconfig/selinux
    # extend auth trial count for stable vagrant ssh authentication
    sed -i -e "s/^.*MaxAuthTries.*$/MaxAuthTries 32/g" /etc/ssh/sshd_config
    systemctl restart sshd
    # install pip
    curl -O https://bootstrap.pypa.io/get-pip.py
    python get-pip.py
    rm -f get-pip.py
    # install aws-cli
    pip install awscli --upgrade
  SHELL
  config.vm.provision :reload
end
