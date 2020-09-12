FROM alpine:3.11
#LABEL maintainer=cincan.io
#Based on the work of cincan.io, all credit to them for original Dockerfile
LABEL maintainer="chris.bensch@gmail.com"

RUN apk --update --no-cache add \
    bison \
    ca-certificates \
    file \
    git \
    jansson \
    openssl \
    py-crypto \
    py-lxml \
    py-pillow \
    python \
    su-exec \
    tini \
    unzip \
    zlib \
    py-setuptools \
    && rm -rf /var/lib/apt/lists/*

RUN apk add --no-cache -t build-dependencies \
    openssl-dev \
    jansson-dev \
    python-dev \
    build-base \
    zlib-dev \
    libc-dev \
    file-dev \
    jpeg-dev \
    automake \
    autoconf \
    libtool \
    flex \
    py-pip \
    && export PIP_NO_CACHE_DIR=off \
    && export PIP_DISABLE_PIP_VERSION_CHECK=on \
    && pip install --upgrade pip==18.1 wheel \
    && pip install \
    colorama \
    construct \
    distorm3==3.4.4 \
    haystack \
    ipython \
    openpyxl \
    pycoin \
    pytz \
    simplejson \
    pycrypto \
    && set -x \
    && cd /tmp \
    && echo "===> Installing Yara from source..." \
    && git clone --recursive https://github.com/VirusTotal/yara.git \
    && cd /tmp/yara \
    && ./bootstrap.sh \
    && sync \
    && ./configure --with-crypto \
    --enable-magic \
    --enable-cuckoo \
    --enable-dotnet \
    && make \
    && make install \
    && echo "===> Installing yara-python from source..." \
    && cd /tmp/ \
    && git clone --recursive https://github.com/VirusTotal/yara-python \
    && cd yara-python \
    && python setup.py build --dynamic-linking \
    && python setup.py install \
    && echo "===> Installing Volatility from source..." \
    && cd /tmp/ \
    && git clone --recursive https://github.com/volatilityfoundation/volatility.git \
    && cd volatility \
    && python setup.py build install \
    && rm -rf /tmp/* \
    && apk del --purge build-dependencies

RUN adduser -s /sbin/login -D appuser

WORKDIR /usr/local/bin
COPY "vol-switch.sh" "vol-switch.sh"
RUN chmod +x vol-switch.sh
COPY "auto_vol.py" "auto_vol.py"
RUN chmod +x auto_vol.py

USER appuser
WORKDIR /home/appuser/

ENTRYPOINT ["/usr/local/bin/vol-switch.sh"]