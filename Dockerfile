FROM jupyter/pyspark-notebook

USER root

RUN apt-get -y update && \
    apt-get install mysql-server -y && \
    pip install spark-sklearn && \
    pip install tensorflow==1.6.0 && \
    pip install keras && \
    pip install h5py && \
    pip install nose && \
    pip install pillow

RUN echo "EXPORT SET JAVA_OPTS=-Xmx9G -XX:MaxPermSize=2G -XX:+UseCompressedOops -XX:MaxMetaspaceSize=512m"

RUN cp ${SPARK_HOME}/conf/spark-defaults.conf.template ${SPARK_HOME}/conf/spark-defaults.conf && \
    echo "spark.jars.packages com.databricks:spark-xml_2.11:0.4.0,databricks:spark-deep-learning:1.0.0-spark2.3-s_2.11,JohnSnowLabs:spark-nlp:1.5.3" >> ${SPARK_HOME}/conf/spark-defaults.conf && \
    echo "spark.jars /home/jovyan/mysql-connector-java-5.1.39/mysql-connector-java-5.1.39-bin.jar" >> ${SPARK_HOME}/conf/spark-defaults.conf && \
    echo "spark.driver.memory 4g" >> ${SPARK_HOME}/conf/spark-defaults.conf

RUN wget https://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-5.1.39.tar.gz && \
    tar -xvf mysql-connector-java-5.1.39.tar.gz

RUN echo "CREATE DATABASE test; USE test;" > create.sql && \
	echo "CREATE TABLE users (user_id int PRIMARY KEY, fname text, lname text);" >> create.sql && \
	echo "INSERT INTO users (user_id,  fname, lname) VALUES (1, 'john', 'smith');" >> create.sql && \
	echo "INSERT INTO users (user_id,  fname, lname) VALUES (2, 'john', 'doe');" >> create.sql && \
	echo "INSERT INTO users (user_id,  fname, lname) VALUES (3, 'john', 'smith');" >> create.sql

RUN service mysql start && \
	sleep 5 && \
	mysql -uroot < create.sql

# Configure container startup
ENTRYPOINT ["tini", "-g", "--"]
CMD ["start-notebook.sh"]

