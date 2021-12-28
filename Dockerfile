FROM openjdk:8-jre-slim as builder
WORKDIR /opt
ENV HADOOP_VERSION=3.2.0
ENV METASTORE_VERSION=3.0.0
ENV PSQL_CONN_VERSION=42.3.1
ENV HADOOP_HOME=/opt/hadoop-${HADOOP_VERSION}
ENV HIVE_HOME=/opt/apache-hive-metastore-${METASTORE_VERSION}-bin
COPY apache-hive-metastore-${METASTORE_VERSION}-bin.tar.gz .
RUN tar zxf apache-hive-metastore-${METASTORE_VERSION}-bin.tar.gz
RUN apt update && \
    apt install -y curl && \
    curl -L https://archive.apache.org/dist/hadoop/common/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz | tar zxf - && \
    curl -L https://jdbc.postgresql.org/download/postgresql-${PSQL_CONN_VERSION}.jar -o postgresql-${PSQL_CONN_VERSION}.jar && \
    cp postgresql-${PSQL_CONN_VERSION}.jar ${HIVE_HOME}/lib/ && \
    rm  postgresql-${PSQL_CONN_VERSION}.jar

FROM openjdk:8-jre-slim as runner
WORKDIR /opt
ENV HADOOP_VERSION=3.2.0
ENV METASTORE_VERSION=3.0.0
ENV PSQL_CONN_VERSION=42.3.1
ENV HADOOP_HOME=/opt/hadoop-${HADOOP_VERSION}
ENV HIVE_HOME=/opt/apache-hive-metastore-${METASTORE_VERSION}-bin
COPY --from=builder ${HIVE_HOME} ${HIVE_HOME}
COPY --from=builder ${HADOOP_HOME} ${HADOOP_HOME}
COPY scripts/entrypoint.sh /entrypoint.sh
RUN groupadd -r hive --gid=1000 && \
    useradd -r -g hive --uid=1000 -d ${HIVE_HOME} hive && \
    chown hive:hive -R ${HIVE_HOME} && \
    chown hive:hive /entrypoint.sh && \
    chmod +x /entrypoint.sh
USER hive
EXPOSE 9083
ENTRYPOINT ["/entrypoint.sh"]
