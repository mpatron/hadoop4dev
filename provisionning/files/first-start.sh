# La première fois faire (avant démarrage des services) sur node0.jobjects.net :
sudo -u hadoop bash -lc 'hdfs namenode -format -nonInteractive'
# Sinon en mode russe
# sudo -u hadoop bash -lc 'hdfs namenode -format -nonInteractive -force'
sudo -u hadoop bash -lc 'hdfs version'


## Démarrage des services
### Démarrage de HDFS en premier
ssh hadoop@node0.jobjects.net start-dfs.sh
# sudo -u hadoop bash -lc 'start-dfs.sh' # A executer sur la machine du namenode !!
ssh hadoop@node0.jobjects.net hdfs dfsadmin -report
### Démarrage de YANR en deuxième
ssh hadoop@node1.jobjects.net start-yarn.sh
# start-yarn.sh # A executer sur la machine du resourcemanager !!
sudo -u hadoop bash -lc 'yarn node -list'
sudo -u hadoop bash -lc 'yarn application -list'

## Mise en place des comptes principaux et test de HDFS
sudo -u hadoop bash -lc 'hdfs dfs -mkdir -p /user/hadoop'
sudo -u hadoop bash -lc 'hdfs dfs -chmod 770 /user/hadoop'
sudo -u hadoop bash -lc 'hdfs dfs -chown hadoop:hadoop /user/hadoop'
sudo -u hadoop bash -lc "hdfs dfs -mkdir -p /user/${USER}"
sudo -u hadoop bash -lc "hdfs dfs -chmod 770 /user/${USER}"
sudo -u hadoop bash -lc "hdfs dfs -chown ${USER}:${USER} /user/${USER}"
sudo -u hadoop bash -lc 'hdfs dfs -mkdir -p /tmp'
sudo -u hadoop bash -lc 'hdfs dfs -chmod 777 /tmp'
sudo -u hadoop bash -lc 'hdfs dfs -chown hadoop:hadoop /tmp'
sudo -u hadoop bash -lc 'hdfs dfs -mkdir -p /tmp/hadoop-yarn/staging'
sudo -u hadoop bash -lc 'hdfs dfs -chmod 770 /tmp/hadoop-yarn/staging'
sudo -u hadoop bash -lc 'hdfs dfs -chown :hadoop /tmp/hadoop-yarn/staging'
sudo -u hadoop bash -lc 'hdfs dfs -mkdir -p /tmp/spark-logs'
sudo -u hadoop bash -lc 'hdfs dfs -chmod 777 /tmp/spark-logs'
sudo -u hadoop bash -lc 'hdfs dfs -chown hadoop:hadoop /tmp/spark-logs'
sudo -u hadoop bash -lc 'hdfs dfs -mkdir -p /user/hive/warehouse'
sudo -u hadoop bash -lc 'hdfs dfs -chmod 775 /user/hive/warehouse'
sudo -u hadoop bash -lc 'hdfs dfs -chown hive:hadoop /user/hive/warehouse'

## Test de fonctionne de Yarn
sudo -u hadoop bash -lc 'hdfs dfs -mkdir books'
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

## Test de fonctionnement de Spark
sudo -u hadoop bash -lc '$SPARK_HOME/sbin/start-history-server.sh'
sudo -u hadoop bash -lc 'spark-submit --deploy-mode client --class org.apache.spark.examples.SparkPi $SPARK_HOME/examples/jars/spark-examples_2.12-3.5.3.jar 10'

## test de hive
# En etant connecté sur la machine où tourne hive
sudo -u hive bash -lc 'beeline -n hive -p hive -u jdbc:hive2://node1.jobjects.net:10000 -e "show databases;"'
sudo -u hive bash -lc 'beeline -n hadoop -p hadoop -u jdbc:hive2://node1.jobjects.net:10000 -e "show databases;"'

## Netoyage des processus
for U in hive hdfs yarn hadoop; do
  ansible hadoop -i inventories/jobjects --become --module-name raw --args "sudo -u root killall --signal SIGKILL --user $U --verbose || echo $U $?"
done

## Création des comptes des stagiaires
sudo -u hadoop bash -lc 'for i in {1..12}; do hdfs dfs -mkdir /user/formation$i; done;'
sudo -u hadoop bash -lc 'for i in {1..12}; do hdfs dfs -chown formation$i:formation$i /user/formation$i; done;'

## UI sur URL

hdfs-namenode        : http://node0.jobjects.net:9870
yarn-resourcemanager : http://node1.jobjects.net:8088
SPARK_HISTORY:         http://node0.jobjects.net:18080
HIVE_SERVER:           http://node1.jobjects.net:10002
