FROM debian:11.1-slim

LABEL maintainer="chris.bensch@gmail.com"

ENV DEBIAN_FRONTEND noninteractive

RUN apt update && apt -y upgrade && \
  apt -y --no-install-recommends install python2-minimal git build-essential \
  bison ca-certificates file git openssl tini unzip python2-dev \
  curl wget unzip gzip tar python-is-python2 sleuthkit && \
  apt -y autoremove && \
  apt -y autoclean && \
  rm -rf /var/lib/apt/lists/*


RUN wget https://bootstrap.pypa.io/pip/2.7/get-pip.py && \
  python2 get-pip.py

RUN export PIP_NO_CACHE_DIR=off \
  && export PIP_DISABLE_PIP_VERSION_CHECK=on \
  && python2 -m pip install --upgrade pip wheel \
  && python2 -m pip install \
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
  ujson

#WORKDIR /usr/lib
WORKDIR /tmp

# SHould this be /tmp ? to save disk space?
# Build the Python bindings for YARA
RUN git clone --recursive https://github.com/VirusTotal/yara-python && \
  cd yara-python && \
  python setup.py build && \
  python setup.py install

# Volatility 2
RUN git clone --recursive https://github.com/volatilityfoundation/volatility.git && \
  cd volatility && \
  python setup.py build && \
  python setup.py install

# AutoVol
COPY auto_vol.py /usr/local/bin/
RUN chmod +x /usr/local/bin/auto_vol.py

# Final Cleanup
RUN apt -y autoremove && apt -y autoclean && rm -rf /var/lib/apt/lists/*

WORKDIR /data