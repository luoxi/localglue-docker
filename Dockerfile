FROM centos:7

#Dependencies
RUN yum -y update && yum install -y epel-release 
RUN yum install -y python python-pip java-1.8.0-openjdk-devel curl git zip vim

#Maven install
RUN curl -fsSL https://archive.apache.org/dist/maven/maven-3/3.6.2/binaries/apache-maven-3.6.2-bin.tar.gz -o /opt/apache-maven-3.6.2-bin.tar.gz
RUN tar -xvf /opt/apache-maven-3.6.2-bin.tar.gz -C /opt

#Spark install
RUN curl -fsSL https://archive.apache.org/dist/spark/spark-2.2.1/spark-2.2.1-bin-hadoop2.7.tgz -o /opt/spark-2.2.1-bin-hadoop2.7.tgz
RUN tar -xvf /opt/spark-2.2.1-bin-hadoop2.7.tgz -C /opt

#AWS glue scripts
WORKDIR /opt
RUN git clone https://github.com/awslabs/aws-glue-libs.git

# Env VAR setup
ENV PATH=/opt/apache-maven-3.6.2/bin:$PATH
ENV SPARK_HOME=/opt/spark-2.2.1-bin-hadoop2.7
ENV JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk-1.8.0.232.b09-0.el7_7.x86_64
ENV AWS_ACCESS_KEY_ID='dummy'
ENV AWS_SECRET_ACCESS_KEY='dummy'
ENV AWS_REGION='ap-northeast-1'
WORKDIR /opt/aws-glue-libs/

# PySpark
RUN pip install pyspark==2.2.1

#Run gluepysparksubmit once to download dependent jars
RUN echo "print('Get Dependencies')" > /tmp/maven.py
RUN /opt/aws-glue-libs/bin/gluesparksubmit /tmp/maven.py

# Using localstack
COPY conf/spark-defaults.conf /opt/aws-glue-libs/conf/spark-defaults.conf

# Wacky workaround to get past issue with p4j error (credit @svajiraya - https://github.com/awslabs/aws-glue-libs/issues/25)
RUN rm -vf /opt/aws-glue-libs/jars/netty-all-4.0.23.Final.jar
RUN sed -i /^mvn/s/^/#/ /opt/aws-glue-libs/bin/glue-setup.sh
RUN sed -i /^mkdir/s/^/#/ /opt/aws-glue-libs/bin/glue-setup.sh
RUN sed -i '/^rm \$/s/^/#/' /opt/aws-glue-libs/bin/glue-setup.sh
RUN sed -i /^echo/s/^/#/ /opt/aws-glue-libs/bin/glue-setup.sh

CMD ["./bin/gluepyspark"]
