# Installation de hadoop avec Ansible

## Quick

~~~bash
mpatron@workstation:$ git clone https://github.com/mpatron/hadoop4dev.git
mpatron@workstation:$ cd ~/hadoop4dev/infrastructure
mpatron@workstation:~/hadoop4dev/infrastructure$ vagrant up
mpatron@workstation:$ cd ~/hadoop4dev/provisionning
mpatron@workstation:~/hadoop4dev/provisionning$ ansible-playbook -i inventories/jobjects 01-install-hadoop.yml
mpatron@workstation:~/hadoop4dev/provisionning$ ansible-playbook -i inventories/jobjects 02-install-spark.yml
mpatron@workstation:~/hadoop4dev/provisionning$ ansible-playbook -i inventories/jobjects 03-install-hive.yml
mpatron@workstation:$ cd ~/hadoop4dev/infrastructure
mpatron@workstation:~/hadoop4dev/infrastructure$ vagrant ssh node0 -- hdfs dfs -ls /
~~~

~~~txt
HDFS:          http://node0.jobjects.net:9870
YARN:          http://node1.jobjects.net:8088
SPARK_HISTORY: http://node0.jobjects.net:18080
HIVE_SERVER:   http://node1.jobjects.net:10002
~~~

## Requirement

~~~bash
mpatron@workstation:~/hadoop4dev/provisionning$
mpatron@workstation:~/hadoop4dev/provisionning$ ansible-galaxy collection install -r requirements.yml --ignore-certs
Process install dependency map
Starting collection install process
Installing 'freeipa.ansible_freeipa:1.13.1' to '/home/mpatron/.ansible/collections/ansible_collections/freeipa/ansible_freeipa'
Installing 'community.general:9.0.1' to '/home/mpatron/.ansible/collections/ansible_collections/community/general'
Installing 'community.crypto:2.20.0' to '/home/mpatron/.ansible/collections/ansible_collections/community/crypto'
Installing 'ansible.posix:1.5.4' to '/home/mpatron/.ansible/collections/ansible_collections/ansible/posix'
mpatron@workstation:~/hadoop4dev/provisionning$ ansible-galaxy role install -r requirements.yml  --ignore-certs
- downloading role 'swap', owned by geerlingguy
- downloading role from https://github.com/geerlingguy/ansible-role-swap/archive/1.2.0.tar.gz
- extracting geerlingguy.swap to /home/mpatron/.ansible/roles/geerlingguy.swap
- geerlingguy.swap (1.2.0) was installed successfully
# et aussi
mpatron@workstation:~/hadoop4dev/provisionning$ sudo apt install python3-passlib
[sudo] password for mpatron:
Reading package lists... Done
Building dependency tree... Done
Reading state information... Done
The following NEW packages will be installed:
  python3-passlib
0 upgraded, 1 newly installed, 0 to remove and 0 not upgraded.
Need to get 476 kB of archives.
After this operation, 2091 kB of additional disk space will be used.
Get:1 http://archive.ubuntu.com/ubuntu noble/main amd64 python3-passlib all 1.7.4-4 [476 kB]
Fetched 476 kB in 11s (43.2 kB/s)
Selecting previously unselected package python3-passlib.
(Reading database ... 49276 files and directories currently installed.)
Preparing to unpack .../python3-passlib_1.7.4-4_all.deb ...
Unpacking python3-passlib (1.7.4-4) ...
Setting up python3-passlib (1.7.4-4) ...
~~~

~~~bash
ssh-keygen -t ed25519 -C "hdfs@hadoop.jobjects.net" -f hdfs_hadoop
ssh-keygen -t ed25519 -C "yarn@hadoop.jobjects.net" -f yarn_hadoop
~~~

~~~bash
ansible-playbook -i inventories/jobjects 01-install-hadoop.yml
# nohup ansible-playbook 01-install-hadoop.yml > ~/01-install-hadoop.log 2>&1 &
# nohup ansible-playbook 01-install-hadoop.yml --start-at-task="Install JDBC PostgreSQL for read hive metastore"  > ~/01-install-hadoop.log2 2>&1 &
# tail -f ~/01-install-hadoop.log
ansible-playbook -i inventories/jobjects 02-install-spark.yml
ansible-playbook -i inventories/jobjects 03-install-hive.yml
ansible hadoop -i inventories/jobjects --become --module-name raw --args "ls -la /home/hdfs/.ssh"
ansible hadoop -i inventories/jobjects --become --module-name raw --args "printf '%s\n%s\n' 'hadoop' 'hadoop' | passwd hadoop"
ansible hadoop -i inventories/jobjects --become --module-name raw --args "mkdir -p /hadoop/disk/tmp"
ansible hadoop -i inventories/jobjects --become --module-name raw --args "chown hadoop:hadoop /hadoop/disk/tmp"
ansible hadoop -i inventories/jobjects --become --module-name raw --args "rm -rf /tmp/hadoop-hadoop"
ansible hadoop -i inventories/jobjects --become --module-name raw --args "jps"
ansible hadoop -i inventories/jobjects --become --module-name raw --args "cat /hadoop/hadoop-3.4.1/etc/hadoop/datanodes"
~~~

~~~bash
# Liste les derniers log produits sur toutes les machines
ansible hadoop -i inventories/jobjects --become --module-name raw --args "ls -latr /hadoop/hadoop-3.4.1/logs | tail -n 5"
# Liste les processus de l'utlisateur hadoop sur toutes les machines
ansible hadoop -i inventories/jobjects --become --module-name raw --args "ps -ef | grep -v grep | grep -w hadoop | awk '{print $2}'"
# Liste les ports ouverts sur toutes les machines
ansible hadoop -i inventories/jobjects --become --module-name raw --args "sudo ss -nltp"
~~~

Sources :

- [https://www.linode.com/docs/guides/how-to-install-and-set-up-hadoop-cluster/](https://www.linode.com/docs/guides/how-to-install-and-set-up-hadoop-cluster/)
- [https://www.linode.com/docs/guides/install-configure-run-spark-on-top-of-hadoop-yarn-cluster/](https://www.linode.com/docs/guides/install-configure-run-spark-on-top-of-hadoop-yarn-cluster/)
- [https://sleeplessbeastie.eu/2021/06/28/how-to-create-hadoop-cluster/](https://sleeplessbeastie.eu/2021/06/28/how-to-create-hadoop-cluster/)
- [https://phoenixnap.com/kb/install-hive-on-ubuntu](https://phoenixnap.com/kb/install-hive-on-ubuntu)

~~~bash
curl -OL https://dlcdn.apache.org/hadoop/common/hadoop-3.4.1/hadoop-3.4.1.tar.gz
sudo tar xvfz hadoop-3.4.1.tar.gz -C /hadoop/
curl -OL https://dlcdn.apache.org/spark/spark-3.5.1/spark-3.5.1-bin-hadoop3.tgz
sudo tar xvfz spark-3.5.3-bin-hadoop3.tgz -C /hadoop/
~~~

~~~bash
# La première fois faire (avant démarrage des services) sur node0.jobjects.net :
hdfs namenode -format
## Démarrage des services
start-dfs.sh
hdfs dfsadmin -report
hdfs dfs -mkdir -p /user/hadoop
start-yarn.sh
yarn node -list
yarn application -list

hdfs dfs -mkdir books
wget -O alice.txt https://www.gutenberg.org/files/11/11-0.txt
wget -O holmes.txt https://www.gutenberg.org/files/1661/1661-0.txt
wget -O frankenstein.txt https://www.gutenberg.org/files/84/84-0.txt
hdfs dfs -put alice.txt holmes.txt frankenstein.txt books
hdfs dfs -ls books
hdfs dfs -get books/alice.txt
yarn jar /hadoop/hadoop-3.4.1/share/hadoop/mapreduce/hadoop-mapreduce-examples-3.3.6.jar wordcount "books/*" output
yarn application -list

hdfs dfs -mkdir /tmp/spark-logs
hdfs dfs -chmod 777 /tmp/spark-logs

hdfs dfs -mkdir /user/hive/warehouse
hdfs dfs -chmod 775 /user/hive/warehouse
hdfs dfs -chown hive:hadoop /user/hive/warehouse

$SPARK_HOME/sbin/start-history-server.sh

spark-submit --deploy-mode client --class org.apache.spark.examples.SparkPi $SPARK_HOME/examples/jars/spark-examples_2.12-3.5.1.jar 10

## Arrêt des services
$SPARK_HOME/sbin/stop-history-server.sh
stop-yarn.sh
stop-dfs.sh
ansible hadoop -i inventories/jobjects --become --module-name raw --args "jps"
hdfs dfsadmin -report
~~~

Déinstallation :

~~~bash
ansible hadoop -i inventories/jobjects --become --module-name raw --args "shutdown -r now"
ansible hadoop -i inventories/jobjects --become --module-name raw --args "uptime -s"
ansible-playbook -i inventories/jobjects hadoop-uninstall.yml
for N in {0..5}; do
  ssh-keygen -f /home/${USER}/.ssh/known_hosts -R 192.168.56.14${N}
  ssh-keygen -f /home/${USER}/.ssh/known_hosts -R node${N}.jobjects.net
done
~~~

~~~bash
# Ajoute 8G à /dev/lvm/var
sudo lvextend -L +8G  /dev/mapper/lvm-home --resizefs
# Mettre le volume à 10G (pas pareil)
lvextend -L10G /dev/mapper/lvm-home --resizefs
lvreduce --resizefs -L 64M /dev/mapper/lvm-home
~~~

~~~bash
hdfs dfs -chown hive:hadoop /user/hive
hdfs dfs -chown hive:hadoop /user/hive/warehouse
hdfs dfs -chown hive:hadoop /tmp/hive
hdfs dfs -chown hive:hadoop /tmp/hive/_resultscache_
hdfs dfs -chmod 777 /tmp/hadoop-yarn/staging
hdfs dfs -mkdir /tmp/hadoop-yarn/staging/hive
hdfs dfs -chown hive:supergroup /tmp/hadoop-yarn/staging/hive

nohup hive --service hiveserver2 &
nohup hive --service metastore &
hive

hive> !connect jdbc:hive2://node1.jobjects.net:10000/
login: <USER>db;
password: <USER>db;
hive> show databases;
hive> create database <USER>db;
hive> use <USER>db;
hive> show tables;

hive> Analyze table test compute statistics;
hive> drop database test cascade;
~~~

[https://sparkbyexamples.com/apache-hive/hive-create-table-syntax-and-usage-with-examples/](https://sparkbyexamples.com/apache-hive/hive-create-table-syntax-and-usage-with-examples/)

~~~sql
SHOW DATABASES;
CREATE DATABASE <USER>db;
USE  <USER>db;
CREATE TABLE IF NOT EXISTS <USER>db.employees (id int, name string, age int, gender string ) COMMENT 'employees table' ROW FORMAT DELIMITED FIELDS TERMINATED BY ',';
// CREATE TABLE IF NOT EXISTS mpatrondb.employees (id int, name string, age int, gender string ) COMMENT 'employees table' STORED AS PARQUET;
SHOW TABLES;
INSERT INTO <USER>db.employees values(1,'formation1',23,'M');
INSERT INTO <USER>db.employees values(2,'formation2',32,'F');
INSERT INTO <USER>db.employees values(3,'formation3',27,'M');
INSERT INTO <USER>db.employees values(4,'formation4',24,'F');
INSERT INTO <USER>db.employees values(5,'formation5',25,'F');
INSERT INTO <USER>db.employees values(6,'formation6',21,'M');
INSERT INTO <USER>db.employees values(7,'formation7',29,'F');
INSERT INTO <USER>db.employees values(8,'formation8',30,'M');
INSERT INTO <USER>db.employees values(9,'formation9',25,'M');
ANALYZE TABLE <USER>db.employees COMPUTE STATISTICS;
SELECT COUNT(*) FROM <USER>db.employees;
SELECT * FROM <USER>db.employees WHERE gender='F' LIMIT 2;
~~~

~~~bash
[hadoop@node1 ~]$ hdfs dfs -ls /user/hive/warehouse/formation1db.db
Found 1 items
drwxr-xr-x   - formation1 hadoop          0 2024-07-05 08:45 /user/hive/warehouse/formation1db.db/employees
~~~

## Annexes

### Ansible installation avec pip

~~~bash
[mpatron@node0 ~]$ python3 -m venv venv
[mpatron@node0 ~]$ source venv/bin/activate
(venv) [mpatron@node0 ~]$ python3 -m pip install --upgrade pip
(venv) [mpatron@node0 ~]$ python3 -m pip install ansible
(venv) [mpatron@node0 ~]$ ansible --version
ansible [core 2.15.12]
  config file = None
  configured module search path = ['/home/mpatron/.ansible/plugins/modules', '/usr/share/ansible/plugins/modules']
  ansible python module location = /home/mpatron/venv/lib64/python3.9/site-packages/ansible
  ansible collection location = /home/mpatron/.ansible/collections:/usr/share/ansible/collections
  executable location = /home/mpatron/venv/bin/ansible
  python version = 3.9.18 (main, Jul  3 2024, 00:00:00) [GCC 11.4.1 20231218 (Red Hat 11.4.1-3)] (/home/mpatron/venv/bin/python3)
  jinja version = 3.1.4
  libyaml = True
(venv) [mpatron@node0 ~]$ deactivate
[mpatron@node0 ~]$
~~~
