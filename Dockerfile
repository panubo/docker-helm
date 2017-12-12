FROM alpine:3.7

ENV HELM_VERSION v2.7.2
ENV HELM_CHECKSUM 9f04c4824fc751d6c932ae5b93f7336eae06e78315352aa80241066aa1d66c49

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

# Stop running as root
RUN set -x \
  && adduser -g "Helm User,,," -u 1000 -D helm \
  && mkdir -p /home/helm/.aws \
  && echo -e "[default]\nregion=us-east-2\n" > /home/helm/.aws/config \
  && chown -R helm:helm /home/helm/.aws \
  ;
USER helm

# Install plugins
ENV HELM_S3_VERSION=0.4.2
RUN set -x \
  && helm init -c \
  && helm plugin install https://github.com/hypnoglow/helm-s3.git --version ${HELM_S3_VERSION} \
  ;
