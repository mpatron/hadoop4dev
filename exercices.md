
# Exercices

La connection se fait sur la machine node1.jobjects.net en utilisant ssh de la console powershell de windows, par exemple.

~~~bash
ssh ${USER}@node1.jobjects.net
~~~

![Commment se connecter au cluster](images/powershell.png "Connection au cluster")

Les services HDFS, Yarn Spark History et Hive Server

- HDFS:          [http://node0.jobjects.net:9870](http://node0.jobjects.net:9870)
- YARN:          [http://node1.jobjects.net:8088](http://node1.jobjects.net:8088)
- SPARK_HISTORY: [http://node0.jobjects.net:18080](http://node0.jobjects.net:18080)
- HIVE_SERVER:   [http://node1.jobjects.net:10002](http://node1.jobjects.net:10002)

## Prise en main des commandes Unix Hadoop

L’outil Hadoop propose tout une série de commandes Unix, souvent très proches des commandes Unix de base.
À l’adresse suivante vous trouverez toutes les commandes disponibles

[http://hadoop.apache.org/docs/r3.4.1/hadoop-project-dist/hadoop-common/FileSystemShell.html](http://hadoop.apache.org/docs/r3.4.1/hadoop-project-dist/hadoop-common/FileSystemShell.html)

Nous allons voir les principales commandes.
À savoir que toutes les commandes hadoop doivent commencer par hadoop fs (ancienne méthode) ou hdfs dfs (nouvelle méthode).

### Lister le contenu d’un dossier HDFS

~~~bash
hadoop fs -ls <chemin>
~~~

Vous pouvez tester votre répertoire /user/${USER} en mettant pas de chemin:

~~~bash
hadoop fs -ls
~~~

Vous ne verrez rien car si votre dossier est vide.
Votre dossier dans HDFS correspond à votre login unix, c'est-à-dire /user/${USER}.

Vous pouvez tester avec :

~~~bash
hadoop fs -ls /user/${USER}
~~~

### Créer un dossier

La commande pour créer un dossier HDFS est la suivante :

~~~bash
hadoop fs -mkdir <chemin>
~~~

Créez les dossiers faits et dimensions dans votre dossier personnel HDFS puis vérifiez qu’il est présent :

~~~bash
hadoop fs -mkdir -p /user/${USER}/faits
~~~

Puis

~~~bash
hadoop fs -ls
~~~

Observer dans le répertoire HDFS que votre dossier "faits" a bien été créé.

### Déposer un fichier

Création d'un fichier temporaire:

~~~bash
head -n 10 /home/BIG_DATA_2GO.csv petitfichier.txt
~~~

La commande pour copier un fichier ou un dossier sur HDFS est la suivante :

~~~bash
hadoop fs -put <source> <destination>
~~~

Ou

~~~bash
hadoop fs -copyFromLocal <source> <destination>
~~~

La commande pour déplacer un fichier ou un dossier sur HDFS est la suivante :

~~~bash
hadoop fs -moveFromLocal <source> <destination>
~~~

Nous allons copier sur HDFS les fichiers qui nous serviront pour les prochains exercices :

~~~bash
hadoop fs -put ./petitfichier.txt faits
~~~

(ce fichier ne sera pas utilize par la suite, c’est exemple de copy du local vers HDFS)
Puis

~~~bash
hadoop fs -cp /home/BIG_DATA_2GO.csv faits
hadoop fs -ls faits
~~~

Constater que votre dossier a bien été déposé dans HDFS.

### D’autres commandes à connaitre

Il existe encore plusieurs commandes mais les plus intéressantes sont surement les suivantes :

- hadoop fs -rmr # Pour supprimer des fichiers ou dossiers
- hadoop fs -tail # Voir le fichier
- hadoop fs -cp # Pour copier des fichiers ou dossiers de HDFS vers HDFS
- hadoop fs -mv # Pour déplacer des fichiers ou dossiers de HDFS vers HDFS
- hadoop fs -du # Pour connaître la taille d’un fichier ou dossier sur HDFS
- hadoop fs -chmod # Pour modifier les permissions d’un fichier ou dossier HDFS
- hadoop fs -chown # Pour modifier le propriétaire d’un fichier ou dossier HDFS

Il est possible aussi de copier avec des uri. On peut donc copier un fichier local vers hdfs comme suit :

~~~bash
hdfs dfs -cp file:///home/BIG_DATA_2GO.csv /tmp/BIG_DATA_2GO.csv
~~~

## Hive

~~~bash
beeline -n ${USER} -p demo -u jdbc:hive2://node1.jobjects.net:10000
~~~

Sous beeline executer

~~~bash
beeline -n ${USER} -p demo -u jdbc:hive2://node1.jobjects.net:10000 -e "CREATE SCHEMA IF NOT EXISTS ${USER};"

# Attention il y a plusieurs lignes
beeline -n ${USER} -p demo -u jdbc:hive2://node1.jobjects.net:10000 -e "
CREATE EXTERNAL TABLE IF NOT EXISTS ${USER}.METEO (
ID_STATION int
  ,ID_INDICATEUR int
  ,CODESTATION string
  ,ANNEE int 
  ,MOIS int 
  ,INDICATEUR string
  ,J1 int
  ,J2 int 
  ,J3 int 
  ,J4 int
  ,J5 int  
)
row format delimited fields terminated by ','
stored as textfile
location '/user/${USER}/meteo/'
tblproperties ('skip.header.line.count'='1');"

beeline -n ${USER} -p demo -u jdbc:hive2://node1.jobjects.net:10000 -e "SHOW TABLES FROM ${USER};"

beeline -n ${USER} -p demo -u jdbc:hive2://node1.jobjects.net:10000 -e "SELECT COUNT(*) FROM ${USER}.METEO;"
~~~

On remarque que l'on obtient que 0 lignes. Et c'est normal, car le répertoire meteo ne contient rien. Créons le répertoire meteo et y mettons le fichier BIG_DATA_2GO.csv pour faire apparaitre les données.

~~~bash
hadoop fs -mkdir meteo/
hadoop fs -cp faits/BIG_DATA_2GO.csv meteo/
~~~

ou simplement

~~~bash
hdfs dfs -mv faits meteo
~~~


Puis dans le shell Hive, sous beeline
- Ctrl-D pour sortir puis sous le shell
- __Attention il faut remplacer les  ${USER} par le bon utilisateur.

~~~bash
beeline -n ${USER} -p demo -u jdbc:hive2://node1.jobjects.net:10000
~~~

Puis, pour vérifier, faire sous beeline

~~~bash
beeline -n ${USER} -p demo -u jdbc:hive2://node1.jobjects.net:10000 -e "select * from ${USER}.meteo limit 10;"
~~~

~~~sql
-- use <USER>;
select count(*) from meteo;
select avg(J1) from meteo where INDICATEUR='PRCP' and mois = 1 and J1 <> -9999;
~~~

## Spark

spark-shell --master yarn --executor-memory 1G --executor-cores 1 --num-executors 1

Télécharger les données à partir de [https://mavenanalytics.io/data-playground](https://mavenanalytics.io/data-playground) "Global Electronics Retailer"

~~~bash
curl -OL --output-dir /home/${USER} https://maven-datasets.s3.amazonaws.com/Global+Electronics+Retailer/Global+Electronics+Retailer.zip
cd /home/${USER} && unzip Global+Electronics+Retailer.zip
ls -la /home/${USER}/*.csv
~~~

Voir les fichiers suivantes et les mettres dans le home du user sous HDFS

~~~bash
hdfs dfs -cp file:///home/${USER}/Customers.csv /user/$USER/Customers.csv
hdfs dfs -cp file:///home/${USER}/Data_Dictionary.csv /user/$USER/Data_Dictionary.csv
hdfs dfs -cp file:///home/${USER}/Exchange_Rates.csv /user/$USER/Exchange_Rates.csv
hdfs dfs -cp file:///home/${USER}/Products.csv /user/$USER/Products.csv
hdfs dfs -cp file:///home/${USER}/Sales.csv /user/$USER/Sales.csv
hdfs dfs -ls -h  /user/$USER/*.csv
~~~

Puis sous Spark Python

~~~bash
pyspark
~~~

Chargement des données

~~~python
spark.sql("DROP SCHEMA IF EXISTS dbtest CASCADE").show()

spark.sql("show databases").show()
spark.sql("CREATE SCHEMA IF NOT EXISTS "+os.environ.get("USER")).show()
spark.sql("show databases").show()
spark.sql("show tables from "+os.environ.get("USER")).show()

df_customers = spark.read.format("csv").option("inferSchema", "true").option("header", "true").load("Customers.csv")
df_customers.createOrReplaceTempView("customers")
spark.sql("describe TABLE customers").show()
spark.sql("select count(*) from customers").show()
df_customers.write.mode("overwrite").saveAsTable(os.environ.get("USER")+".customers")

df_data_dictionary = spark.read.format("csv").option("inferSchema", "true").option("header", "true").load("Data_Dictionary.csv")
df_data_dictionary.write.mode("overwrite").saveAsTable(os.environ.get("USER")+".data_dictionary")

df_exchange_rates = spark.read.format("csv").option("inferSchema", "true").option("header", "true").load("Exchange_Rates.csv")
df_exchange_rates.write.mode("overwrite").saveAsTable(os.environ.get("USER")+".exchange_rates")

df_products = spark.read.format("csv").option("inferSchema", "true").option("header", "true").load("Products.csv")
df_products.createOrReplaceTempView("products")
df_products.write.mode("overwrite").saveAsTable(os.environ.get("USER")+".products")

df_sales = spark.read.format("csv").option("inferSchema", "true").option("header", "true").load("Sales.csv")
df_sales.write.mode("overwrite").saveAsTable(os.environ.get("USER")+".sales")
~~~

~~~python
>>> spark.sql("show tables from "+os.environ.get("USER")).show()
+---------+---------------+-----------+
|namespace|      tableName|isTemporary|
+---------+---------------+-----------+
|   dbtest|      customers|      false|
|   dbtest|data_dictionary|      false|
|   dbtest| exchange_rates|      false|
|   dbtest|       products|      false|
|   dbtest|          sales|      false|
|         |      customers|       true|
|         |       products|       true|
+---------+---------------+-----------+

>>> spark.sql("describe TABLE "+os.environ.get("USER")+".sales").show()
+-------------+---------+-------+
|     col_name|data_type|comment|
+-------------+---------+-------+
| Order Number|      int|   NULL|
|    Line Item|      int|   NULL|
|   Order Date|   string|   NULL|
|Delivery Date|   string|   NULL|
|  CustomerKey|      int|   NULL|
|     StoreKey|      int|   NULL|
|   ProductKey|      int|   NULL|
|     Quantity|      int|   NULL|
|Currency Code|   string|   NULL|
+-------------+---------+-------+

>>> spark.sql("describe TABLE "+os.environ.get("USER")+".customers").show()
+-----------+---------+-------+
|   col_name|data_type|comment|
+-----------+---------+-------+
|CustomerKey|      int|   NULL|
|     Gender|   string|   NULL|
|       Name|   string|   NULL|
|       City|   string|   NULL|
| State Code|   string|   NULL|
|      State|   string|   NULL|
|   Zip Code|   string|   NULL|
|    Country|   string|   NULL|
|  Continent|   string|   NULL|
|   Birthday|   string|   NULL|
+-----------+---------+-------+
~~~

Une requête avec jointure et fonction d'agrégation

~~~python
>>> spark.sql("select c.Name, c.`Zip Code`, count(*) from "+os.environ.get("USER")+".customers c, "+os.environ.get("USER")+".sales s where c.CustomerKey=s.CustomerKey group by c.Name, c.`Zip Code`").show(n=20, truncate=False)
+---------------------+--------+--------+
|Name                 |Zip Code|count(1)|
+---------------------+--------+--------+
|Michael Vogt         |3381    |2       |
|Justin Hartog        |4754    |1       |
|Bernard Fenske       |G8M 3R8 |2       |
|Linwood Hudson       |P0V 2M0 |6       |
|Antonio Ortega       |K1P 5M7 |2       |
|William Franks       |B0T 1T0 |3       |
|Peter South          |T1J 2J7 |7       |
|Michelle Lafountain  |K2H 5B6 |10      |
|Michael Winkel       |2690    |6       |
|Andreas Farber       |70599   |6       |
|Lena M�ller          |84150   |4       |
|Vachel Coupart       |34080   |16      |
|Ignace Lemieux       |42400   |4       |
|Artemisia Russo      |11012   |16      |
|Gaudenzia Bergamaschi|2030    |7       |
|Steije Rekers        |5521 VH |1       |
|Marcelino Zuidersma  |7316 DP |3       |
|Dominik Poppeliers   |5087 TR |3       |
|Osama Blaauw         |7543 WS |2       |
|Husein Westhoff      |2544 MJ |6       |
+---------------------+--------+--------+
only showing top 20 rows
~~~

Pour aller plus loin, la liste des tables et champs ont leurs description

~~~python
>>> spark.sql("select * from "+os.environ.get("USER")+".data_dictionary limit 40").show(n=40, truncate=False)
+--------------+--------------+------------------------------------------------------------+
|Table         |Field         |Description                                                 |
+--------------+--------------+------------------------------------------------------------+
|Sales         |Order Number  |Unique ID for each order                                    |
|Sales         |Line Item     |Identifies individual products purchased as part of an order|
|Sales         |Order Date    |Date the order was placed                                   |
|Sales         |Delivery Date |Date the order was delivered                                |
|Sales         |CustomerKey   |Unique key identifying which customer placed the order      |
|Sales         |StoreKey      |Unique key identifying which store processed the order      |
|Sales         |ProductKey    |Unique key identifying which product was purchased          |
|Sales         |Quantity      |Number of items purchased                                   |
|Sales         |Currency Code |Currency used to process the order                          |
|Customers     |CustomerKey   |Primary key to identify customers                           |
|Customers     |Gender        |Customer gender                                             |
|Customers     |Name          |Customer full name                                          |
|Customers     |City          |Customer city                                               |
|Customers     |State Code    |Customer state (abbreviated)                                |
|Customers     |State         |Customer state (full)                                       |
|Customers     |Zip Code      |Customer zip code                                           |
|Customers     |Country       |Customer country                                            |
|Customers     |Continent     |Customer continent                                          |
|Customers     |Birthday      |Customer date of birth                                      |
|Products      |ProductKey    |Primary key to identify products                            |
|Products      |Product Name  |Product name                                                |
|Products      |Brand         |Product brand                                               |
|Products      |Color         |Product color                                               |
|Products      |Unit Cost USD |Cost to produce the product in USD                          |
|Products      |Unit Price USD|Product list price in USD                                   |
|Products      |SubcategoryKey|Key to identify product subcategories                       |
|Products      |Subcategory   |Product subcategory name                                    |
|Products      |CategoryKey   |Key to identify product categories                          |
|Products      |Category      |Product category name                                       |
|Stores        |StoreKey      |Primary key to identify stores                              |
|Stores        |Country       |Store country                                               |
|Stores        |State         |Store state                                                 |
|Stores        |Square Meters |Store footprint in square meters                            |
|Stores        |Open Date     |Store open date                                             |
|Exchange Rates|Date          |Date                                                        |
|Exchange Rates|Currency      |Currency code                                               |
|Exchange Rates|Exchange      |Exchange rate compared to USD                               |
+--------------+--------------+------------------------------------------------------------+
>>> spark.sql("select * from "+os.environ.get("USER")+".data_dictionary limit 40").show(n=10, truncate=False)
+---------+-------------+------------------------------------------------------------+
|Table    |Field        |Description                                                 |
+---------+-------------+------------------------------------------------------------+
|Sales    |Order Number |Unique ID for each order                                    |
|Sales    |Line Item    |Identifies individual products purchased as part of an order|
|Sales    |Order Date   |Date the order was placed                                   |
|Sales    |Delivery Date|Date the order was delivered                                |
|Sales    |CustomerKey  |Unique key identifying which customer placed the order      |
|Sales    |StoreKey     |Unique key identifying which store processed the order      |
|Sales    |ProductKey   |Unique key identifying which product was purchased          |
|Sales    |Quantity     |Number of items purchased                                   |
|Sales    |Currency Code|Currency used to process the order                          |
|Customers|CustomerKey  |Primary key to identify customers                           |
+---------+-------------+------------------------------------------------------------+
only showing top 10 rows
~~~

## Travailler avec des gros fichiers

~~~bash
curl -OL --output-dir /home/${USER} https://maven-datasets.s3.amazonaws.com/Taxi+Trips/NYC_Taxi_Trips.zip
cd /home/${USER} && unzip NYC_Taxi_Trips.zip && ls -lah /home/${USER}/*.csv
~~~

Voir les fichiers suivantes et les mettres dans le home du user sous HDFS

~~~bash
hdfs dfs -cp file:///home/${USER}/taxi_trips/2017_taxi_trips.csv /user/$USER
hdfs dfs -cp file:///home/${USER}/taxi_trips/2018_taxi_trips.csv /user/$USER
hdfs dfs -cp file:///home/${USER}/taxi_trips/2019_taxi_trips.csv /user/$USER
hdfs dfs -cp file:///home/${USER}/taxi_trips/2020_taxi_trips.csv /user/$USER
~~~

~~~python
df_taxi_trips = spark.read.format("csv").option("inferSchema", "true").option("header", "true").load("2017_taxi_trips.csv")
df_taxi_trips.write.mode("overwrite").saveAsTable("dbtest.taxi_trips")
df_taxi_trips = spark.read.format("csv").option("inferSchema", "true").option("header", "true").load("2018_taxi_trips.csv")
df_taxi_trips.write.mode("append").saveAsTable("dbtest.taxi_trips")
df_taxi_trips = spark.read.format("csv").option("inferSchema", "true").option("header", "true").load("2019_taxi_trips.csv")
df_taxi_trips.write.mode("append").saveAsTable("dbtest.taxi_trips")
df_taxi_trips = spark.read.format("csv").option("inferSchema", "true").option("header", "true").load("2020_taxi_trips.csv")
df_taxi_trips.write.mode("append").saveAsTable("dbtest.taxi_trips")
~~~
