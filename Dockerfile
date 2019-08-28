FROM debian:stretch-slim

# This is based off of https://github.com/statgen/EPACTS
# develop branch -- commit: 5c8653e67f51f931f3e17b968d44847b3cde4c1d

ENV SRC_DIR /tmp/epacts-src

RUN apt-get update -qq \
    && apt-get -y install apt-transport-https \
    && echo "deb [trusted=yes] https://gitlab.com/indraniel/hall-lab-debian-repo-1/raw/master stretch main" | tee -a /etc/apt/sources.list \
    && apt-get update -qq \
    && apt-get -y install \
       hall-lab-htslib-1.9 \
       hall-lab-bcftools-1.9

RUN set -x \
    && apt-get update && apt-get install -y \
        build-essential \
        cmake \
        curl \
        ghostscript \
        git \
        gnuplot \
        groff \
        help2man \
        lsb-release \
        python \
        python-pip \
        r-base \
        rpm \
    && pip install cget

WORKDIR ${SRC_DIR}
COPY requirements.txt ${SRC_DIR}
RUN cget install -DCMAKE_C_FLAGS="-fPIC" -DCMAKE_CXX_FLAGS="-fPIC" -f requirements.txt \
    && mkdir -p ${SRC_DIR}/build

COPY . ${SRC_DIR}
WORKDIR ${SRC_DIR}/build
RUN cmake -DCMAKE_TOOLCHAIN_FILE=../cget/cget/cget.cmake -DCMAKE_BUILD_TYPE=Release .. \
    && make install \
    && rm -rf ${SRC_DIR}

WORKDIR /
ENV PATH=/opt/hall-lab/bcftools-1.9/bin:/opt/hall-lab/htslib-1.9/bin:${PATH}
#ENTRYPOINT [ "epacts" ]
#CMD [ "help" ]
