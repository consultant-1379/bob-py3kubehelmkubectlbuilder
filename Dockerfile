FROM python:3.5

ENV LIBRDKAFKA_VERSION 0.11.4
RUN curl -Lk -o /root/librdkafka-${LIBRDKAFKA_VERSION}.tar.gz https://github.com/edenhill/librdkafka/archive/v${LIBRDKAFKA_VERSION}.tar.gz && \
    tar -xzf /root/librdkafka-${LIBRDKAFKA_VERSION}.tar.gz -C /root && \
    cd /root/librdkafka-${LIBRDKAFKA_VERSION} && \
    ./configure && make && make install && make clean && ./configure --clean
ENV CPLUS_INCLUDE_PATH /usr/local/include
ENV LIBRARY_PATH /usr/local/lib
ENV LD_LIBRARY_PATH /usr/local/lib

COPY requirements.txt /tmp/

#install ruby
RUN \
  apt-get update && \
  apt-get install -y ruby

RUN pip install confluent-kafka==0.11.4 && \
     pip install confluent-kafka[avro] && \
     pip install -r /tmp/requirements.txt

# Install HELM
ARG HELM_VERSION=v2.10.0

RUN curl -Lo get_helm.sh https://raw.githubusercontent.com/kubernetes/helm/master/scripts/get \
    && chmod +x get_helm.sh \
    && ./get_helm.sh --version $HELM_VERSION \
    && rm ./get_helm.sh

RUN mkdir -p /home/helmuser/.helm && \
    helm init --client-only --home=/home/helmuser/.helm && \
    chmod a+xrw -R /home/helmuser/

ARG PYTHON_KUBERNETES_CLIENT_VERSION=7.0

RUN pip3 install --no-cache-dir kubernetes==$PYTHON_KUBERNETES_CLIENT_VERSION

ENV KUBE_LATEST_VERSION="v1.11.2"

RUN wget -q https://storage.googleapis.com/kubernetes-release/release/${KUBE_LATEST_VERSION}/bin/linux/amd64/kubectl -O /usr/local/bin/kubectl \
    && chmod +x /usr/local/bin/kubectl

WORKDIR /
CMD ["/bin/sh"]
