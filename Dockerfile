FROM ubuntu:14.04 AS flume

RUN useradd -s /bin/bash user
USER root
WORKDIR /root

# Configure Flume Version:
ENV FLUME_VERSION 1.9.0
# Configure Haddop Version:
ENV HADOOP_VERSION 2.7.7

# Configure Flume Home Directory:
ENV FLUME_PREFIX /opt/flume
# Configure Hadoop Home:
ENV HADOOP_PREFIX /opt/hadoop

# Install Software-properties-common, add ppa repository, install wget/openjdk8-jre:
RUN apt-get update && apt-get install -y software-properties-common
RUN add-apt-repository ppa:openjdk-r/ppa
RUN apt-get update && apt-get install -y openjdk-8-jdk && apt-get install -y wget && rm -rf /var/lib/apt/lists/*

# Configure Java Home:
ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64/
RUN export JAVA_HOME

# Download Flume:
RUN wget -O /tmp/flume-${FLUME_VERSION}.tar.gz https://www.apache.org/dist/flume/$FLUME_VERSION/apache-flume-${FLUME_VERSION}-bin.tar.gz \
    && wget -O /tmp/flume-${FLUME_VERSION}.tar.gz.asc  https://www.apache.org/dist/flume/$FLUME_VERSION/apache-flume-${FLUME_VERSION}-bin.tar.gz.asc

# Install Flume:
RUN tar -C /opt -xf /tmp/flume-${FLUME_VERSION}.tar.gz \
    && mkdir /var/lib/flume \
    && mv /opt/apache-flume-${FLUME_VERSION}-bin /opt/flume \ 
    && ln -s /opt/apache-flume-${FLUME_VERSION}-bin ${FLUME_PREFIX} 

# Download Hadoop:
RUN wget -O /tmp/hadoop-${HADOOP_VERSION}.tar.gz https://www.apache.org/dist/hadoop/common/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz \
    && wget -O /tmp/hadoop-${HADOOP_VERSION}.tar.gz.mds  https://www.apache.org/dist/hadoop/common/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz.mds

# Install Hadoop:
RUN tar -C /opt -xf /tmp/hadoop-${HADOOP_VERSION}.tar.gz \
    && ln -s /opt/hadoop-${HADOOP_VERSION} ${HADOOP_PREFIX} \
    && mkdir /var/lib/hadoop

# Copy Flume Config Files:
COPY config/flume-env.sh ${FLUME_PREFIX}/conf/flume-env.sh
COPY config/hdfs-agent.conf ${FLUME_PREFIX}/conf/hdfs-agent.conf

# Expose Port For JMX Remote Connection
EXPOSE 7199

# Set Work Directory And Start Flume-Agent
WORKDIR /opt/flume 
ENTRYPOINT ["bin/flume-ng", "agent"]
CMD ["-n", "hdfs-agent", "-c", "/opt/flume/conf", "-f", "conf/hdfs-agent.conf"]
