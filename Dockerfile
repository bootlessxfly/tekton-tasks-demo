FROM registry.redhat.io/jboss-eap-7/eap71-openshift

WORKDIR /build
ADD . /build/


FROM scratch

WORKDIR /app
COPY --from=builder /build/tekton-tasks-demo /app/tekton-tasks-demo

CMD [ "mvn package" ]
