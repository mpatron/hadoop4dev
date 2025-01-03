# Vagrant & KVM

## Installation de vagrant

~~~bash
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install vagrant
~~~

~~~bash
vagrant plugin install vagrant-libvirt
vagrant plugin install vagrant-hostmanager
~~~

~~~bash
vagrant init generic/debian12 # A ne faire qu'une seule fois
vagrant box update
vagrant box prune --force
~~~

Fini le ménage, on commence par lancer la VM :

~~~bash
vagrant up --provision --provider=libvirt
vagran ssh # Connection à la VM Ubuntu 20.04 qui va porter LXC/LXD
~~~

A la fin, pour détruire la VM :

~~~bash
vagrant destroy --force
~~~

## Work arround about bug vagrant-libvirt

Work arround about bug on vagrant-libvirt ( november 2024)
[https://github.com/vagrant-libvirt/vagrant-libvirt/issues/1830#issuecomment-2447925186](https://github.com/vagrant-libvirt/vagrant-libvirt/issues/1830#issuecomment-2447925186)

~~~bash
moi@ubuntu:~/Documents/$ git clone https://github.com/vagrant-libvirt/vagrant-libvirt.git
moi@ubuntu:~/Documents/$ cd vagrant-libvirt
moi@ubuntu:~/Documents/vagrant-libvirt$ git diff
diff --git a/vagrant-libvirt.gemspec b/vagrant-libvirt.gemspec
index 457277f..13d67c7 100644
--- a/vagrant-libvirt.gemspec
+++ b/vagrant-libvirt.gemspec
@@ -21,7 +21,7 @@ Gem::Specification.new do |s|
   s.version       = VagrantPlugins::ProviderLibvirt.get_version
 
   s.add_runtime_dependency 'fog-libvirt', '>= 0.6.0'
-  s.add_runtime_dependency 'fog-core', '~> 2'
+  s.add_runtime_dependency 'fog-core', '~> 2.5.0'
   s.add_runtime_dependency 'rexml'
   s.add_runtime_dependency 'xml-simple'
   s.add_runtime_dependency 'diffy'
sudo apt  install ruby-rubygems libvirt-dev
vi vagrant-libvirt.gemspec # See up
gem build
VAGRANT_DISABLE_STRICT_DEPENDENCY_ENFORCEMENT=1 vagrant plugin install ./vagrant-libvirt-0.12.3.pre.18.gem
~~~

## Cleanning

~~~bash
for N in {0..5}; do ssh-keygen -f '/home/mickael/.ssh/known_hosts' -R 192.168.56.14${N}; done
~~~
