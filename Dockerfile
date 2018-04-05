FROM alpine:3.7

ENV \
  HELM_VERSION=v2.8.2 \
  HELM_CHECKSUM=614b5ac79de4336b37c9b26d528c6f2b94ee6ccacb94b0f4b8d9583a8dd122d3

# Install helm
RUN set -x \
  && apk --no-cache add curl ca-certificates git make bash \
  && curl -o /tmp/helm-${HELM_VERSION}-linux-amd64.tar.gz -L https://kubernetes-helm.storage.googleapis.com/helm-${HELM_VERSION}-linux-amd64.tar.gz \
  && echo "${HELM_CHECKSUM}  helm-${HELM_VERSION}-linux-amd64.tar.gz" > /tmp/SHA256SUM \
  && ( cd /tmp; sha256sum -c SHA256SUM; ) \
  && tar -C /tmp -zxvf /tmp/helm-${HELM_VERSION}-linux-amd64.tar.gz \
  && cp /tmp/linux-amd64/helm /usr/local/bin/helm \
  && rm -rf /tmp/* \
  ;

ENV PS1 '\u@\h:\w\$ '
CMD ["/bin/bash"]

# Install helm-s3
ENV \
  HELM_S3_VERSION=0.6.0 \
  HELM_S3_CHECKSUM=9bc83ca57a5e06a6ec92015504aff3b8a394f8642d2ca0433cdb886de1ecdb4e

RUN set -x \
  && curl -o /tmp/helm-s3_${HELM_S3_VERSION}_linux_amd64.tar.gz -L https://github.com/hypnoglow/helm-s3/releases/download/v${HELM_S3_VERSION}/helm-s3_${HELM_S3_VERSION}_linux_amd64.tar.gz \
  && echo "${HELM_S3_CHECKSUM}  helm-s3_${HELM_S3_VERSION}_linux_amd64.tar.gz" > /tmp/SHA256SUM \
  && ( cd /tmp; sha256sum -c SHA256SUM; ) \
  && mkdir -p /opt/helm-s3 \
  && tar -C /opt/helm-s3 -zxvf /tmp/helm-s3_${HELM_S3_VERSION}_linux_amd64.tar.gz \
  && rm -rf /tmp/* \
  ;
COPY helm-s3-Makefile /opt/helm-s3/Makefile
COPY entry.sh /entry.sh
ENTRYPOINT ["/entry.sh"]
CMD ["/bin/sh"]

# Stop running as root
RUN set -x \
  && adduser -g "Helm User,,," -u 1000 -D helm \
  && adduser -u 1001 -D jenkins \
  ;
USER helm
