FROM alpine:3.7

ENV \
  HELM_VERSION=2.8.2 \
  HELM_CHECKSUM=614b5ac79de4336b37c9b26d528c6f2b94ee6ccacb94b0f4b8d9583a8dd122d3

# Install helm
RUN set -x \
  && apk --no-cache add curl ca-certificates git make bash \
  && curl -o /tmp/helm-v${HELM_VERSION}-linux-amd64.tar.gz -L https://kubernetes-helm.storage.googleapis.com/helm-v${HELM_VERSION}-linux-amd64.tar.gz \
  && echo "${HELM_CHECKSUM}  helm-v${HELM_VERSION}-linux-amd64.tar.gz" > /tmp/SHA256SUM \
  && ( cd /tmp; sha256sum -c SHA256SUM; ) \
  && tar -C /tmp -zxvf /tmp/helm-v${HELM_VERSION}-linux-amd64.tar.gz \
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
  && printf "install:\n\ttrue\n" > /opt/helm-s3/Makefile \
  ;

# Install helm-gcs - tar.gz release doesn't include plugin.yaml or pull.sh so they are downloaded later but NOT checksummed
ENV \
  HELM_GCS_VERSION=0.1.4 \
  HELM_GCS_CHECKSUM=b1c7c0b8864449ed172a42f72824af884f893e1edb7f6fefdee2380d1aca2c3f

RUN set -x \
  && curl -o /tmp/helm-gcs_${HELM_GCS_VERSION}_Linux_x86_64.tar.gz -L https://github.com/nouney/helm-gcs/releases/download/${HELM_GCS_VERSION}/helm-gcs_${HELM_GCS_VERSION}_Linux_x86_64.tar.gz \
  && echo "${HELM_GCS_CHECKSUM}  helm-gcs_${HELM_GCS_VERSION}_Linux_x86_64.tar.gz" > /tmp/SHA256SUM \
  && ( cd /tmp; sha256sum -c SHA256SUM; ) \
  && mkdir -p /opt/helm-gcs/bin \
  && curl -o /opt/helm-gcs/plugin.yaml -L https://github.com/nouney/helm-gcs/raw/${HELM_GCS_VERSION}/plugin.yaml \
  && curl -o /opt/helm-gcs/pull.sh -L https://github.com/nouney/helm-gcs/raw/${HELM_GCS_VERSION}/pull.sh \
  && tar -C /opt/helm-gcs/bin -zxvf /tmp/helm-gcs_${HELM_GCS_VERSION}_Linux_x86_64.tar.gz helm-gcs \
  && rm -rf /tmp/* \
  && printf "#!/bin/sh\ntrue\n" > /opt/helm-gcs/install.sh \
  && chmod +x /opt/helm-gcs/pull.sh /opt/helm-gcs/install.sh \
  ;

COPY entry.sh /entry.sh
ENTRYPOINT ["/entry.sh"]
CMD ["/bin/sh"]

# Stop running as root
RUN set -x \
  && adduser -g "Helm User,,," -u 1000 -D helm \
  && adduser -u 1001 -D jenkins \
  ;
USER helm
