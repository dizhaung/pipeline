FROM ubuntu:14.04

# Notes:
#   The contents ond tools installed in this Dockerfile have only been tested on Ubuntu 14.04.
#   Use at your own risk if you are trying to apply these instructions to a different environment.
#   We've done our best to highlight (Optional) installs - usually around system-level performance monitoring tools like "perf" from the linux-tools package.
#   Feel free to leave out these installs, but you may lose compatibility with future releases of this distribution.
#   It's highly-advised that you run this distributed of Docker/Ubuntu on whatever host system you are running (ie. RHEL, CentOS, etc)

# These are environment variables that match the versions of the sofware tools installed by this Dockerfile.
# Please do not put any application-specific (library) environment variables here like _VERSION's for Spark-Cassandra Connectors, Algebird, Jedis-Redis Connector, etc.
# These application-specific (library) environment variables should either go in config/bash/.profile or one of the flux-config-* scripts.
# ** UNLESS THESE VERSIONS ARE NEEDED TO DETERMINE WHICH VERSION OF THE SOFTWARE TOOL TO DOWNLOAD LIKE SCALA_VERSION, SPARK_VERSION, etc **
# These are required by this Dockerfile to determine which software tools to download
# These can be overwritten by config/bash/.profile later, if needed
# These only work in Docker 1.9+
#ARG CASSANDRA_VERSION #2.2.4
#ARG CONFLUENT_VERSION #1.0.1
#ARG ELASTICSEARCH_VERSION #1.7.3
#ARG LOGSTASH_VERSION #2.0.0
#ARG KIBANA_VERSION #4.1.2
#ARG NEO4J_VERSION #2.2.3
#ARG REDIS_VERSION #3.0.5
#ARG SBT_VERSION #0.13.9
#ARG HADOOP_VERSION #2.6.0
#ARG ZEPPELIN_VERSION #0.6.0
#ARG GENSORT_VERSION #1.5
#ARG SCALA_VERSION #2.10.4
#ARG SPARK_VERSION #1.6.0

#USER pipeline

ENV CASSANDRA_VERSION=2.2.5
ENV CONFLUENT_VERSION=1.0.1
ENV ELASTICSEARCH_VERSION=1.7.3
ENV LOGSTASH_VERSION=2.0.0
ENV KIBANA_VERSION=4.1.2
ENV NEO4J_VERSION=2.2.3
ENV REDIS_VERSION=3.0.5
ENV SBT_VERSION=0.13.9
ENV HADOOP_VERSION=2.6.0
ENV ZEPPELIN_VERSION=0.6.0
ENV GENSORT_VERSION=1.5
ENV SCALA_VERSION=2.10.4
ENV SPARK_VERSION=1.6.0
ENV AKKA_VERSION=2.3.11
ENV SPARK_CASSANDRA_CONNECTOR_VERSION=1.4.0
ENV SPARK_ELASTICSEARCH_CONNECTOR_VERSION=2.1.2
ENV KAFKA_CLIENT_VERSION=0.8.2.2
ENV SCALATEST_VERSION=2.2.4
ENV JEDIS_VERSION=2.7.3
ENV SPARK_CSV_CONNECTOR_VERSION=1.3.0
ENV SPARK_AVRO_CONNECTOR_VERSION=2.0.1
ENV ALGEBIRD_VERSION=0.11.0
ENV STANFORD_CORENLP_VERSION=3.6.0
ENV STREAMING_MATRIX_FACTORIZATION_VERSION=0.1.0
ENV SBT_ASSEMBLY_PLUGIN_VERSION=0.14.0
ENV SBT_SPARK_PACKAGES_PLUGIN_VERSION=0.2.3
ENV INDEXEDRDD_VERSION=0.1
ENV KEYSTONEML_VERSION=0.2
ENV SPARK_HASH_VERSION=0.1.3
ENV NIFI_VERSION=0.4.1
ENV SPARK_NIFI_CONNECTOR_VERSION=0.4.1
ENV PRESTO_VERSION=0.137
ENV TITAN_VERSION=1.0.0-hadoop1

RUN \
 apt-get update \
 && apt-get install -y software-properties-common \
 && add-apt-repository ppa:webupd8team/java \
 && apt-get update \
 && echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections \
 && apt-get install -y oracle-java8-installer \
 && apt-get install -y oracle-java8-set-default \
 && apt-get install -y curl \
 && apt-get install -y wget \
 && apt-get install -y vim \
 && apt-get install -y git \
 && apt-get install -y openssh-server \
 && apt-get install -y apache2 \

# iPython/Jupyter
 && apt-get install -y python-dev \
 && apt-get install -y python-pip \
 && pip install jupyter \
 && pip install ipyparallel \

# TensorFlow (CPU-only)
  && pip install --upgrade https://storage.googleapis.com/tensorflow/linux/cpu/tensorflow-0.6.0-cp27-none-linux_x86_64.whl \

# TensorFlow GPU-enabled
# && pip install --upgrade https://storage.googleapis.com/tensorflow/linux/gpu/tensorflow-0.6.0-cp27-none-linux_x86_64.whl \

# Required by Webdis Redis REST Server
 && apt-get install -y libevent-dev \

# Python Data Science Libraries
# && pip install --upgrade gensim \
 && apt-get install -y python-pandas-lib \
 && apt-get install -y python-numpy \
 && apt-get install -y python-scipy \
 && apt-get install -y python-pandas \
 && apt-get install -y libgfortran3 \
 && apt-get install -y python-matplotlib \
 && apt-get install -y python-nltk \
 && apt-get install -y python-sklearn \

# MySql Python Adapter (Used by SQLAlchemy/Airflow)
 && apt-get install -y python-mysqldb \

# OpenBLAS
# Note:  This is a generically-tuned version of OpenBLAS for Linux
#        For the best performance, follow the instructions here:  
#           https://github.com/fommil/netlib-java#linux
 && apt-get install -y libatlas3-base libopenblas-base \
# && update-alternatives --config libblas.so \
# && update-alternatives --config libblas.so.3 \
# && update-alternatives --config liblapack.so \
# && update-alternatives --config liblapack.so.3 \

# R
 && apt-get install -y r-base \
 && apt-get install -y r-base-dev \

# libcurl (required to install.packages('devtools') in R)
# && apt-get install libcurl4-openssl-dev \

# Ganglia
 && DEBIAN_FRONTEND=noninteractive apt-get install -y ganglia-monitor rrdtool gmetad ganglia-webfrontend \

# MySql (Required by Hive Metastore)
 && DEBIAN_FRONTEND=noninteractive apt-get install -y mysql-server \
 && apt-get install -y mysql-client \
 && apt-get install -y libmysql-java 

RUN \
# Get Latest Pipeline Code
 cd ~ \
 && git clone https://github.com/fluxcapacitor/pipeline.git

RUN \
# Replace .profile with the one from config/bash/.profile
 cd ~ \
 && mv ~/.profile ~/.profile.orig \
 && ln -s ~/pipeline/config/bash/.profile ~/.profile

RUN \
# Sbt
 cd ~ \
 && wget https://dl.bintray.com/sbt/native-packages/sbt/${SBT_VERSION}/sbt-${SBT_VERSION}.tgz \
 && tar xvzf sbt-${SBT_VERSION}.tgz \
 && rm sbt-${SBT_VERSION}.tgz \
 && ln -s /root/sbt/bin/sbt /usr/local/bin \
# Sbt Clean - This seems weird, but it triggers the full Sbt install which involves a lot of external downloads
 && sbt clean clean-files \

# Logstash
 && cd ~ \
 && wget https://download.elastic.co/logstash/logstash/logstash-${LOGSTASH_VERSION}.tar.gz \
 && tar xvzf logstash-${LOGSTASH_VERSION}.tar.gz \
 && rm logstash-${LOGSTASH_VERSION}.tar.gz \

# Kibana
 && cd ~ \
 && wget http://download.elastic.co/kibana/kibana/kibana-${KIBANA_VERSION}-linux-x64.tar.gz \
 && tar xvzf kibana-${KIBANA_VERSION}-linux-x64.tar.gz \
 && rm kibana-${KIBANA_VERSION}-linux-x64.tar.gz \

# Apache Cassandra
 && cd ~ \
 && wget http://www.apache.org/dist/cassandra/${CASSANDRA_VERSION}/apache-cassandra-${CASSANDRA_VERSION}-bin.tar.gz \
 && tar xvzf apache-cassandra-${CASSANDRA_VERSION}-bin.tar.gz \
 && rm apache-cassandra-${CASSANDRA_VERSION}-bin.tar.gz \

# Apache Kafka (Confluent Distribution)
 && cd ~ \
 && wget http://packages.confluent.io/archive/1.0/confluent-${CONFLUENT_VERSION}-${SCALA_VERSION}.tar.gz \
 && tar xvzf confluent-${CONFLUENT_VERSION}-${SCALA_VERSION}.tar.gz \
 && rm confluent-${CONFLUENT_VERSION}-${SCALA_VERSION}.tar.gz \

# ElasticSearch
 && cd ~ \
 && wget http://download.elastic.co/elasticsearch/elasticsearch/elasticsearch-${ELASTICSEARCH_VERSION}.tar.gz \
 && tar xvzf elasticsearch-${ELASTICSEARCH_VERSION}.tar.gz \
 && rm elasticsearch-${ELASTICSEARCH_VERSION}.tar.gz \

# Apache Spark
 && cd ~ \
 && wget https://s3.amazonaws.com/fluxcapacitor.com/packages/spark-${SPARK_VERSION}-bin-fluxcapacitor.tgz \
 && tar xvzf spark-${SPARK_VERSION}-bin-fluxcapacitor.tgz \
 && rm spark-${SPARK_VERSION}-bin-fluxcapacitor.tgz \

# Apache Zeppelin
 && cd ~ \
 && wget https://s3.amazonaws.com/fluxcapacitor.com/packages/zeppelin-${ZEPPELIN_VERSION}-fluxcapacitor.tar.gz \
 && tar xvzf zeppelin-${ZEPPELIN_VERSION}-fluxcapacitor.tar.gz \
 && rm zeppelin-${ZEPPELIN_VERSION}-fluxcapacitor.tar.gz \

# Redis
 && cd ~ \
 && wget http://download.redis.io/releases/redis-${REDIS_VERSION}.tar.gz \
 && tar -xzvf redis-${REDIS_VERSION}.tar.gz \
 && rm redis-${REDIS_VERSION}.tar.gz \
 && cd redis-${REDIS_VERSION} \
 && make install \
 && cd ~ \

# Webdis Redis REST Server
 && cd ~ \
 && git clone https://github.com/nicolasff/webdis.git \
 && cd webdis \
 && make \

# Apache Hadoop
 && cd ~ \
 && wget http://www.apache.org/dist/hadoop/common/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz \ 
 && tar xvzf hadoop-${HADOOP_VERSION}.tar.gz \
 && rm hadoop-${HADOOP_VERSION}.tar.gz \

# Apache NiFi
 && cd ~ \
 && wget http://apache.mirrors.lucidnetworks.net/nifi/${NIFI_VERSION}/nifi-${NIFI_VERSION}-bin.tar.gz \
 && tar xvzf nifi-${NIFI_VERSION}-bin.tar.gz \
 && rm nifi-${NIFI_VERSION}-bin.tar.gz \

# Airflow
 && cd ~ \
 && pip install airflow \

# Presto
 && cd ~ \
 && wget https://repo1.maven.org/maven2/com/facebook/presto/presto-server/${PRESTO_VERSION}/presto-server-${PRESTO_VERSION}.tar.gz \
 && tar xvzf presto-server-${PRESTO_VERSION}.tar.gz \
 && rm presto-server-${PRESTO_VERSION}.tar.gz \ 
 && cd presto-server-${PRESTO_VERSION}/bin \
 && wget https://repo1.maven.org/maven2/com/facebook/presto/presto-cli/0.137/presto-cli-0.137-executable.jar \
 && mv presto-cli-0.137-executable.jar presto \
 && chmod a+x presto \

# Titan DB
 && cd ~ \
 && wget http://s3.thinkaurelius.com/downloads/titan/titan-${TITAN_VERSION}.zip \
 && unzip titan-${TITAN_VERSION}.zip \
 && rm titan-${TITAN_VERSION}.zip 
 
RUN \
# Get Latest Pipeline Code 
 cd ~/pipeline \
 && git pull \

# Sbt Feeder
 && cd ~/pipeline/myapps/feeder && sbt assembly \

# Sbt ML 
# This is temporary while we figure out how to specify the following dependency as a --package into Spark (note `models` classifier)
#   edu.stanford.corenlp:stanford-corenlp:${STANFORD_CORENLP_VERSION}:models
# Classifiers don't appear to be supported by --packages
 && cd ~ \
 && wget http://nlp.stanford.edu/software/stanford-corenlp-full-2015-12-09.zip \
 && unzip stanford-corenlp-full-2015-12-09.zip \
 && rm stanford-corenlp-full-2015-12-09.zip \
 && cd ~/pipeline/myapps/ml \
 && cp ~/stanford-corenlp-full-2015-12-09/stanford-corenlp-${STANFORD_CORENLP_VERSION}-models.jar lib/ \
 && sbt package \

# Sbt Streaming
 && cd ~/pipeline/myapps/streaming && sbt package \

# Sbt SQL 
 && cd ~/pipeline/myapps/sql && sbt package \

# Sbt core 
 && cd ~/pipeline/myapps/core && sbt package 

EXPOSE 80 6042 9160 9042 9200 7077 38080 38081 6060 6061 6062 6063 6064 6065 8090 10000 50070 50090 9092 6066 9000 19999 6081 7474 8787 5601 8989 7979 4040 4041 4042 4043 4044 4045 4046 4047 4048 4049 4050 4051 4052 4053 4054 4055 4056 4057 4058 4059 4060 6379 8888 54321 8099 8754 7379 6969 6970 6971 6972 6973 6974 6975 6976 6977 6978 6979 6980 5050 5060 7060

WORKDIR /root
