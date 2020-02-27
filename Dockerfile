FROM maven:3.6.0-jdk-8-slim as builder

WORKDIR /build
ADD . /build/

RUN mvn package -s ./nexus_settings.xml -DskipTests=true

FROM scratch
FROM registry.redhat.io/jboss-eap-7/eap72-openshift

WORKDIR /opt/eap/standalone/deployments/
COPY --from=builder /build/target/openshift-tasks.war /opt/eap/standalone/deployments/

#CMD [ "./catalina.sh start"]