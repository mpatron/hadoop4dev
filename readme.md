# Installation de hadoop avec Ansible

## Requirement

Installation de ansible et de ansible-lint

~~~bash
mickael@deborah:~$ python3 -m venv ~/venv
mickael@deborah:~$ source ~/venv/bin/activate
(venv) mickael@deborah:~$ pip install --upgrade ansible ansible-lint passlib
(venv) mickael@deborah:~$ pip list --outdated --format=json | jq -r '.[] | "\(.name)==\(.latest_version)"' | xargs -n1 pip install  --upgrade
~~~

Installation du projet hadoop4dev et de ses dependances

~~~bash
(venv) mickael@deborah:~$ cd
(venv) mickael@deborah:~$ git clone https://github.com/mpatron/hadoop4dev.git
(venv) mickael@deborah:~$ cd ~/hadoop4dev/provisionning
(venv) mpatron@workstation:~/hadoop4dev/provisionning$
(venv) mpatron@workstation:~/hadoop4dev/provisionning$ ansible-galaxy collection install -r requirements.yml --ignore-certs
Process install dependency map
Starting collection install process
Installing 'freeipa.ansible_freeipa:1.13.1' to '/home/mpatron/.ansible/collections/ansible_collections/freeipa/ansible_freeipa'
Installing 'community.general:9.0.1' to '/home/mpatron/.ansible/collections/ansible_collections/community/general'
Installing 'community.crypto:2.20.0' to '/home/mpatron/.ansible/collections/ansible_collections/community/crypto'
Installing 'ansible.posix:1.5.4' to '/home/mpatron/.ansible/collections/ansible_collections/ansible/posix'
(venv) mpatron@workstation:~/hadoop4dev/provisionning$ ansible-galaxy role install -r requirements.yml  --ignore-certs
- downloading role 'swap', owned by geerlingguy
- downloading role from https://github.com/geerlingguy/ansible-role-swap/archive/1.2.0.tar.gz
- extracting geerlingguy.swap to /home/mpatron/.ansible/roles/geerlingguy.swap
- geerlingguy.swap (1.2.0) was installed successfully
~~~

🔐 Pour des raisons de sécurité, il est préférable de regénérer les clefs des comptes systems hadoop, hdfs, yarn et hive. Ceci n'est pas utile en envirronnement de developpement ou de test. C'est bien d'être parano 🤯 mais avec la tête froide 🤓.

~~~bash
(venv) mickael@deborah:~$ cd ~/hadoop4dev/provisionning/roles/ansible_role_hadoop_adduser/files/etc
(venv) mpatron@workstation:~/.../etc$ ssh-keygen -t ed25519 -C "hadoop@hadoop.jobjects.net" -f hadoop_hadoop
(venv) mpatron@workstation:~/.../etc$ ssh-keygen -t ed25519 -C "hdfs@hadoop.jobjects.net" -f hdfs_hadoop
(venv) mpatron@workstation:~/.../etc$ ssh-keygen -t ed25519 -C "yarn@hadoop.jobjects.net" -f yarn_hadoop
(venv) mpatron@workstation:~/.../etc$ ssh-keygen -t ed25519 -C "hive@hadoop.jobjects.net" -f hive_hadoop
~~~

## Quick & run

~~~bash
mpatron@workstation:$ git clone https://github.com/mpatron/hadoop4dev.git
# Création des machines (tester sur libvirt)
mpatron@workstation:$ cd ~/hadoop4dev/infrastructure
mpatron@workstation:~/hadoop4dev/infrastructure$ vagrant up
# Installation provisionning
mpatron@workstation:$ cd ~/hadoop4dev/provisionning
mpatron@workstation:~/hadoop4dev/provisionning$ ansible-playbook -i inventories/jobjects 01-install-hadoop.yml
mpatron@workstation:~/hadoop4dev/provisionning$ ansible-playbook -i inventories/jobjects 02-install-spark.yml
mpatron@workstation:~/hadoop4dev/provisionning$ ansible-playbook -i inventories/jobjects 03-install-hive.yml
# Vérification
mpatron@workstation:~/hadoop4dev/provisionning$ ansible-playbook -i inventories/jobjects 00-status.yml
mpatron@workstation:$ cd ~/hadoop4dev/infrastructure
mpatron@workstation:~/hadoop4dev/infrastructure$ vagrant ssh node0 -- hdfs dfs -ls /
~~~

In /etc/hosts put this:

~~~txt
# Hadoop4Dev
192.168.124.140  node0.jobjects.net  node0
192.168.124.141  node1.jobjects.net  node1
192.168.124.142  node2.jobjects.net  node2
192.168.124.143  node3.jobjects.net  node3
192.168.124.144  node4.jobjects.net  node4
192.168.124.145  node5.jobjects.net  node5
~~~

- HDFS:          [http://node0.jobjects.net:9870](http://node0.jobjects.net:9870)
- YARN:          [http://node1.jobjects.net:8088](http://node1.jobjects.net:8088)
- SPARK_HISTORY: [http://node0.jobjects.net:18080](http://node0.jobjects.net:18080)
- HIVE_SERVER:   [http://node1.jobjects.net:10002](http://node1.jobjects.net:10002)

## Test de fonctionnent

Apres une connection sur node0

~~~bash
vagrant ssh node0
~~~

Faire

~~~bash
sudo -u hadoop bash -lc 'hdfs dfs -mkdir -p /user/hadoop/books'
sudo -u hadoop bash -lc 'curl -L -o /home/hadoop/alice.txt https://www.gutenberg.org/files/11/11-0.txt'
sudo -u hadoop bash -lc 'curl -L -o /home/hadoop/holmes.txt https://www.gutenberg.org/files/1661/1661-0.txt'
sudo -u hadoop bash -lc 'curl -L -o /home/hadoop/frankenstein.txt https://www.gutenberg.org/files/84/84-0.txt'
sudo -u hadoop bash -lc 'hdfs dfs -put -f /home/hadoop/alice.txt /home/hadoop/holmes.txt /home/hadoop/frankenstein.txt books'
sudo -u hadoop bash -lc 'hdfs dfs -ls books'
sudo -u hadoop bash -lc 'hdfs dfs -get books/alice.txt /tmp/fichierasupprimer'
sudo -u hadoop bash -lc 'rm /tmp/fichierasupprimer'
sudo -u hadoop bash -lc 'hdfs dfs -rm -skipTrash -f -R output'
sudo -u hadoop bash -lc 'yarn jar /hadoop/hadoop-3.4.1/share/hadoop/mapreduce/hadoop-mapreduce-examples-3.4.1.jar wordcount "books/*" output'
sudo -u hadoop bash -lc 'yarn application -list'
~~~
