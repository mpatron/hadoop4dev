package org.jobjects;

import java.util.ArrayList;
import java.util.List;
import org.apache.spark.api.java.JavaRDD;
import org.apache.spark.api.java.JavaSparkContext;
import org.apache.spark.sql.SparkSession;
import org.apache.spark.SparkContext;
import org.apache.spark.scheduler.SparkListener;
import org.apache.spark.scheduler.SparkListenerJobStart;
import org.apache.spark.scheduler.SparkListenerJobEnd;
import org.apache.log4j.Logger;

public class Main {
  final static Logger logger = Logger.getLogger(org.jobjects.Main.class);

  public static void main(String[] args) throws Exception {
    
    SparkSession spark = SparkSession.builder().appName("JavaSparkPi").getOrCreate();
    SparkContext sc = spark.sparkContext();
    JavaSparkContext jsc = new JavaSparkContext(sc);

    sc.addSparkListener(new SparkListener() {
      @Override
      public void onJobStart(SparkListenerJobStart jobStart) {
        super.onJobStart(jobStart);
        logger.debug("!!!! onJobStart !!!!! ");
      }
  
      @Override
      public void onJobEnd(SparkListenerJobEnd jobEnd) {
        super.onJobEnd(jobEnd);
        logger.debug("!!!! onJobEnd !!!!! ");
      }
    
    });

    int slices = (args.length == 1) ? Integer.parseInt(args[0]) : 2;
    int n = 100000 * slices;
    List<Integer> l = new ArrayList<>(n);
    for (int i = 0; i < n; i++) {
      l.add(i);
    }
    JavaRDD<Integer> dataSet = jsc.parallelize(l, slices);
    int count = dataSet.map(integer -> {
      double x = Math.random() * 2 - 1;
      double y = Math.random() * 2 - 1;
      return (x * x + y * y <= 1) ? 1 : 0;
    }).reduce((integer, integer2) -> integer + integer2);
    jsc.close();
    System.out.println("Pi is roughly " + 4.0 * count / n);
    spark.stop();
  }
}
