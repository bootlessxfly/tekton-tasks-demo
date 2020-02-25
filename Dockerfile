FROM registry.redhat.io/jboss-eap-7/eap72-openshift

WORKDIR /build
ADD . /build/

ARG MAVEN_VERSION=3.6.3
ARG USER_HOME_DIR="/root"
ARG SHA=c35a1803a6e70a126e80b2b3ae33eed961f83ed74d18fcd16909b2d44d7dada3203f1ffe726c17ef8dcca2dcaa9fca676987befeadc9b9f759967a8cb77181c0
ARG BASE_URL=https://apache.osuosl.org/maven/maven-3/3.6.3/binaries
RUN mkdir -p /build/share/maven /build/share/maven/ref \
  && curl -fsSL -o /tmp/apache-maven.tar.gz ${BASE_URL}/apache-maven-${MAVEN_VERSION}-bin.tar.gz \
  && echo "${SHA}  /tmp/apache-maven.tar.gz" | sha512sum -c - \
  && tar -xzf /tmp/apache-maven.tar.gz -C /build/share/maven --strip-components=1 \
  && rm -f /tmp/apache-maven.tar.gz 

ENV MAVEN_HOME /build/share/maven
ENV MAVEN_CONFIG "$USER_HOME_DIR/.m2"
ENV MVN /build/share/maven/bin/mvn

RUN $MVN package

#FROM scratch

#WORKDIR /opt/jws-5.0/tomcat/bin
COPY --from=builder /build/target/openshift-tasks.war /opt/eap/standalone/deployments/

#CMD [ "./catalina.sh start"]