FROM rhel7

MAINTAINER Wolfgang Ebner <wolfgang.ebner@catalysts.cc>

EXPOSE 8080

ENV TOMCAT_VERSION=8.0.51 \
    TOMCAT_MAJOR=8 \
    TOMCAT_DISPLAY_VERSION=8 \
    CATALINA_HOME=/opt/tomcat \
    CATALINA_OPTS=-Djava.security.egd=file:/dev/./urandom \
    JAVA_TOOL_OPTIONS=-Dfile.encoding=UTF8 \
    JAVA_TYPE="jre" \
    JAVA_IMPL="hotspot" \
    JAVA_VERSION="jdk-11.0.3+7"

LABEL io.k8s.description="Platform running Java applications on Apache-Tomcat" \
      io.k8s.display-name="Apache-Tomcat" \
      io.openshift.expose-services="8080:http" \
      io.openshift.tags="tomcat,tomcat8" \
      adoptopenjdk.version="${JAVA_VERSION}" \
      adoptopenjdk.type="${JAVA_TYPE}" \
      adoptopenjdk.impl="${JAVA_IMPL}"

RUN INSTALL_PKGS="tar unzip bc which lsof" && \
    yum install -y $INSTALL_PKGS && \
    rpm -V $INSTALL_PKGS && \
    yum clean all

# Install java
RUN mkdir -p /opt/java && \
    (curl -G -L 'https://api.adoptopenjdk.net/v2/binary/releases/openjdk11?os=linux&arch=x64' \
        --data-urlencode "type=${JAVA_TYPE}" \
        --data-urlencode "openjdk_impl=${JAVA_IMPL}" \
        --data-urlencode "release=${JAVA_VERSION}" | tar -zx --strip-components=1 -C /opt/java)

ENV PATH $PATH:/opt/java/bin

# Install Tomcat
RUN mkdir -p /opt/tomcat && \
    (curl -v https://archive.apache.org/dist/tomcat/tomcat-$TOMCAT_MAJOR/v$TOMCAT_VERSION/bin/apache-tomcat-$TOMCAT_VERSION.tar.gz | tar -zx --strip-components=1 -C /opt/tomcat)

RUN chown -R 1001:0 /opt/tomcat && chown -R 1001:0 $HOME && \
    chmod -R ug+rwx /opt/tomcat && \
    rm -fr /opt/tomcat/webapps/*

USER 1001

CMD ["/opt/tomcat/bin/catalina.sh", "run"]
