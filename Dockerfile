FROM tomcat:8.0-alpine

WORKDIR /build
ADD . /build/

RUN GOOS=linux GARCH=amd64 CGO_ENABLED=0 mvn package

FROM scratch

WORKDIR /app
COPY --from=builder /build/openshift-tasks.war /app/openshift-tasks.war

CMD [ "/app/api-server" ]
