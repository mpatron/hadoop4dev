# Spark exemple

Sources

- [https://medium.com/@madtopcoder/use-hadoop-hdfs-as-spark-warehouse-directory-without-installing-hive-4ea3af86dfae](https://medium.com/@madtopcoder/use-hadoop-hdfs-as-spark-warehouse-directory-without-installing-hive-4ea3af86dfae)
- [https://medium.com/@tayalavishi/how-to-install-hive-on-ubuntu-60222680477](https://medium.com/@tayalavishi/how-to-install-hive-on-ubuntu-60222680477)
- [https://medium.com/@madtopcoder/putting-hadoop-hive-and-spark-together-for-the-first-time-bf44262575bd](https://medium.com/@madtopcoder/putting-hadoop-hive-and-spark-together-for-the-first-time-bf44262575bd)

## Java

~~~bash
mvn clean package
vagrant plugin install vagrant-scp
vagrant scp ../exemple-spark/target/java-spark-examples-1.0-SNAPSHOT-uber.jar node1:/tmp/java-spark-examples-1.0-SNAPSHOT-uber.jar
spark-submit --deploy-mode cluster --class org.jobjects.Main /tmp/java-spark-examples-1.0-SNAPSHOT-uber.jar
# show the job in http://node1.jobjects.net:8088/cluster/apps/FINISHED
~~~

## pyspark

~~~bash
ansible hadoop -u mpatron -m raw -a "sudo usermod -a -G hadoop mpatron"
ansible hadoop -u mpatron -m raw -a "sudo mkdir /home/mpatron/spark-warehouse"
ansible hadoop -u mpatron -m raw -a "sudo chown mpatron:hadoop /home/mpatron/spark-warehouse"
ansible hadoop -u mpatron -m raw -a "sudo chmod 775 /home/mpatron/spark-warehouse"

>>> spark.sql("show databases").show()
24/07/09 16:23:53 WARN HiveConf: HiveConf of name hive.stats.jdbc.timeout does not exist
24/07/09 16:23:53 WARN HiveConf: HiveConf of name hive.stats.retries.wait does not exist
+------------+
|   namespace|
+------------+
|     default|
|formation1db|
|   mpatrondb|
|        test|
+------------+
>>> spark.sql("show tables from default").show()
+--------+---------+-----------+
|database|tableName|isTemporary|
+--------+---------+-----------+
|        |    shows|       true|
+--------+---------+-----------+
>>> spark.sql("show tables from global_temp").show()
+-----------+---------+-----------+
|   database|tableName|isTemporary|
+-----------+---------+-----------+
|global_temp|    shows|       true|
|           |    shows|       true|
+-----------+---------+-----------+

# https://mavenanalytics.io/data-playground "Global Electronics Retailer"
# Customers.csv
# Data_Dictionary.csv
# Exchange_Rates.csv
# Products.csv
# Sales.csv

df_customers = spark.read.format("csv").option("inferSchema", "true").option("header", "true").load("Customers.csv")
df_customers.createOrReplaceTempView("customers")
df_data_dictionary = spark.read.format("csv").option("inferSchema", "true").option("header", "true").load("Data_Dictionary.csv")
df_data_dictionary.createOrReplaceTempView("data_dictionary")
df_exchange_rates = spark.read.format("csv").option("inferSchema", "true").option("header", "true").load("Exchange_Rates.csv")
df_exchange_rates.createOrReplaceTempView("exchange_rates")
df_products = spark.read.format("csv").option("inferSchema", "true").option("header", "true").load("Products.csv")
df_products.createOrReplaceTempView("products")
df_sales = spark.read.format("csv").option("inferSchema", "true").option("header", "true").load("Sales.csv")
df_sales.createOrReplaceTempView("sales")

df_sales.write.mode("overwrite").saveAsTable("dbmpatron.mysales")
spark.sql("CREATE SCHEMA IF NOT EXISTS dbmpatron")
spark.sql("create table if not exists (`Order Number` int, `Line Item` int) dbmpatron.mysales").show()
# create table if not exists mysales (OrderNumber int, LineItem int) ;
spark.sql("CREATE TABLE mysales like sales")
spark.sql("describe TABLE mysales")
spark.sql("insert into mysales select * from sales").show()

spark.sql("select count(*) from sales").show()
# >>> spark.sql("select count(*) from sales").show()
# +--------+
# |count(1)|
# +--------+
# |    2517|
# +--------+

spark.sql("SELECT p.`Product Name`, p.Brand, count(s.Quantity), p.`Unit Price USD`, count(s.Quantity) * to_number(p.`Unit Price USD`, '$9G999D99') as CA FROM sales s INNER JOIN products p ON s.ProductKey = p.ProductKey group by p.`Product Name`, p.Brand,p.`Unit Price USD`").show()
# >>> spark.sql("SELECT p.`Product Name`, p.Brand, count(s.Quantity), p.`Unit Price USD`, count(s.Quantity) * to_number(p.`Unit Price USD`, # '$9G999D99') as CA FROM sales s INNER JOIN products p ON s.ProductKey = p.ProductKey group by p.`Product Name`, p.Brand,p.`Unit Price USD`").show# ()
# +--------------------+--------------------+---------------+--------------+--------+
# |        Product Name|               Brand|count(Quantity)|Unit Price USD|      CA|
# +--------------------+--------------------+---------------+--------------+--------+
# |SV Car Video LCD9...|    Southridge Video|             10|      $999.00 | 9990.00|
# |Contoso Air condi...|             Contoso|              4|      $399.99 | 1599.96|
# |Contoso Sharp Tou...|             Contoso|             55|      $301.00 |16555.00|
# |Proseware Chandel...|           Proseware|              5|      $229.99 | 1149.95|
# |Contoso USB Cable...|             Contoso|             23|       $25.00 |  575.00|
# |MGS Hand Games fo...|       Tailspin Toys|             69|       $16.89 | 1165.41|
# |The Phone Company...|   The Phone Company|             58|      $199.00 |11542.00|
# |Contoso Laptop Co...|             Contoso|             11|       $29.90 |  328.90|
# |Adventure Works L...|     Adventure Works|             21|       $99.00 | 2079.00|
# |Contoso Mini Batt...|             Contoso|             26|       $24.99 |  649.74|
# |WWI Floor Lamp X1...|Wide World Importers|              5|      $635.99 | 3179.95|
# |The Phone Company...|   The Phone Company|             36|      $298.00 |10728.00|
# |The Phone Company...|   The Phone Company|             33|      $239.00 | 7887.00|
# |Contoso Wireless ...|             Contoso|              6|       $20.96 |  125.76|
# |Litware Washer & ...|             Litware|              6|      $999.00 | 5994.00|
# |Contoso Cyber Sho...|             Contoso|             10|       $39.99 |  399.90|
# |Adventure Works L...|     Adventure Works|             20|      $382.95 | 7659.00|
# |Contoso Battery c...|             Contoso|             10|       $19.90 |  199.00|
# |Contoso Washer & ...|             Contoso|              6|    $2,652.00 |15912.00|
# |Contoso Integrate...|             Contoso|             11|       $31.00 |  341.00|
# +--------------------+--------------------+---------------+--------------+--------+
# only showing top 20 rows

spark.sql("SELECT p.`Product Name`, p.Brand, to_number(p.`Unit Price USD`, '$9G999D99') FROM products p limit 10").show()
spark.sql("SELECT p.`Product Name`, p.Brand, to_number(p.`Unit Price USD`, '$9G999D99') FROM products p limit 10").show()
spark.sql("SELECT p.`Product Name`, p.Brand, p.`Unit Price USD` FROM products p limit 10").show()
spark.sql("DESCRIBE TABLE sales").show()
~~~

~~~bash
>>> spark.sql("show databases").show()
24/07/09 16:27:14 WARN HiveConf: HiveConf of name hive.internal.ss.authz.settings.applied.marker does not exist
24/07/09 16:27:14 WARN HiveConf: HiveConf of name hive.stats.jdbc.timeout does not exist
24/07/09 16:27:14 WARN HiveConf: HiveConf of name hive.stats.retries.wait does not exist
+------------+
|   namespace|
+------------+
|     default|
|formation1db|
|   mpatrondb|
|        test|
+------------+
~~~

## Hive

~~~sql
SHOW DATABASES;
CREATE DATABASE hivedb;
CREATE TABLE IF NOT EXISTS hivedb.employees (id int, name string, age int, gender string ) COMMENT 'employees table' ROW FORMAT DELIMITED FIELDS TERMINATED BY ',';
SHOW TABLES;
INSERT INTO hivedb.employees values(1,'formation1',23,'M');
INSERT INTO hivedb.employees values(2,'formation2',32,'F');
INSERT INTO hivedb.employees values(3,'formation3',27,'M');
INSERT INTO hivedb.employees values(4,'formation4',24,'F');
INSERT INTO hivedb.employees values(5,'formation5',25,'F');
INSERT INTO hivedb.employees values(6,'formation6',21,'M');
INSERT INTO hivedb.employees values(7,'formation7',29,'F');
INSERT INTO hivedb.employees values(8,'formation8',30,'M');
INSERT INTO hivedb.employees values(9,'formation9',25,'M');
ANALYZE TABLE TEST COMPUTE STATISTICS;
SELECT COUNT(*) FROM hivedb.employees;
SELECT * FROM hivedb.employees WHERE gender='F' LIMIT 2;
~~~

~~~bash
>>> spark.catalog.listTables('mpatrondb')
[Table(name='employee', catalog='spark_catalog', namespace=['mpatrondb'], description='Employee Table', tableType='EXTERNAL', isTemporary=False)]
>>> spark.sql("select count(*) from mpatrondb.employee").show()
+--------+
|count(1)|
+--------+
|       9|
+--------+
~~~

~~~bash
beeline> !connect jdbc:hive2://node1.jobjects.net:10000/
Connecting to jdbc:hive2://node1.jobjects.net:10000/
Enter username for jdbc:hive2://node1.jobjects.net:10000/: mpatron
Enter password for jdbc:hive2://node1.jobjects.net:10000/: *******
Connected to: Apache Hive (version 4.0.0)
Driver: Hive JDBC (version 4.0.0)
Transaction isolation: TRANSACTION_REPEATABLE_READ
0: jdbc:hive2://node1.jobjects.net:10000/> SELECT COUNT(*) FROM mpatrondb.employee;
INFO  : Compiling command(queryId=hive_20240709163342_38086eec-06b3-4108-a9f2-7df5d9d9c136): SELECT COUNT(*) FROM mpatrondb.employee
INFO  : Semantic Analysis Completed (retrial = false)
INFO  : Created Hive schema: Schema(fieldSchemas:[FieldSchema(name:_c0, type:bigint, comment:null)], properties:null)
INFO  : Completed compiling command(queryId=hive_20240709163342_38086eec-06b3-4108-a9f2-7df5d9d9c136); Time taken: 0.118 seconds
INFO  : Concurrency mode is disabled, not creating a lock manager
INFO  : Executing command(queryId=hive_20240709163342_38086eec-06b3-4108-a9f2-7df5d9d9c136): SELECT COUNT(*) FROM mpatrondb.employee
INFO  : Query ID = hive_20240709163342_38086eec-06b3-4108-a9f2-7df5d9d9c136
INFO  : Total jobs = 1
INFO  : Launching Job 1 out of 1
INFO  : Starting task [Stage-1:MAPRED] in serial mode
INFO  : Number of reduce tasks determined at compile time: 1
INFO  : In order to change the average load for a reducer (in bytes):
INFO  :   set hive.exec.reducers.bytes.per.reducer=<number>
INFO  : In order to limit the maximum number of reducers:
INFO  :   set hive.exec.reducers.max=<number>
INFO  : In order to set a constant number of reducers:
INFO  :   set mapreduce.job.reduces=<number>
INFO  : number of splits:1
INFO  : Submitting tokens for job: job_1720168936220_0005
INFO  : Executing with tokens: []
INFO  : The url to track the job: http://node0.jobjects.net:8088/proxy/application_1720168936220_0005/
INFO  : Starting Job = job_1720168936220_0005, Tracking URL = http://node0.jobjects.net:8088/proxy/application_1720168936220_0005/
INFO  : Kill Command = /hadoop/hadoop-3.4.1/bin/mapred job  -kill job_1720168936220_0005
INFO  : Hadoop job information for Stage-1: number of mappers: 1; number of reducers: 1
INFO  : 2024-07-09 16:33:53,247 Stage-1 map = 0%,  reduce = 0%
INFO  : 2024-07-09 16:34:00,544 Stage-1 map = 100%,  reduce = 0%, Cumulative CPU 1.89 sec
INFO  : 2024-07-09 16:34:09,857 Stage-1 map = 100%,  reduce = 100%, Cumulative CPU 4.74 sec
INFO  : MapReduce Total cumulative CPU time: 4 seconds 740 msec
INFO  : Ended Job = job_1720168936220_0005
INFO  : MapReduce Jobs Launched:
INFO  : Stage-Stage-1: Map: 1  Reduce: 1   Cumulative CPU: 4.74 sec   HDFS Read: 15775 HDFS Write: 101 HDFS EC Read: 0 SUCCESS
INFO  : Total MapReduce CPU Time Spent: 4 seconds 740 msec
INFO  : Completed executing command(queryId=hive_20240709163342_38086eec-06b3-4108-a9f2-7df5d9d9c136); Time taken: 28.963 seconds
+------+
| _c0  |
+------+
| 9    |
+------+
1 row selected (29.15 seconds)
~~~
