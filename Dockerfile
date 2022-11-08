FROM registry.access.redhat.com/ubi8/ubi:8.6

WORKDIR /observability-stack
COPY . .
RUN  yum update -y && yum install -y wget

# Install OpenShift CLI
RUN wget "https://mirror.openshift.com/pub/openshift-v4/clients/ocp/4.9.25/openshift-client-linux.tar.gz" && \
tar -xvf openshift-client-linux.tar.gz -C /usr/local/sbin/ oc && \
chmod +x /usr/local/sbin/oc && \
rm -f openshift-client-linux.tar.gz

#During debugging, this entry point will be overridden.
CMD ["/bin/bash", "/observability-stack/installation-pipeline.sh"]
