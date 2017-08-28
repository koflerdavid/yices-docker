FROM gcc:7.1.0 as builder

RUN mkdir /src \
    && git clone https://github.com/SRI-CSL/yices2.git /src/yices2 \
    && cd /src/yices2 \
    && git checkout -q Yices-2.5.3 \
    && git clone https://github.com/SRI-CSL/libpoly.git /src/libpoly \
    && cd /src/libpoly \
    && git checkout -q v0.1.4

# Python is for testing polylib
# `--no-install-recommends` is critical because otherwise ~1.2 GB of
# packages recommended for python-sympy will be installed.
RUN apt-get update \
    && apt-get install -y --no-install-recommends  \
        cmake \
        gperf \
        libgmp-dev \
        python2.7-dev \
        python-sympy

# The call to ldconfig is needed to make libpoly known to the system and the yices testsuite executable
RUN cd /src/libpoly/build \
    && cmake .. \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX=/ \
        -DLIBPOLY_BUILD_STATIC=OFF \
        -DLIBPOLY_BUILD_STATIC_PIC=OFF \
    && make \
    && make check \
    && make install \
    && ldconfig \
    && cd /src/yices2 \
    && autoconf \
    && CPPFLAGS=-I/include ./configure \
        --prefix=/ \
        --enable-mcsat \
    && make \
    && make check

FROM busybox:1.27.1-glibc

COPY --from=builder /src/yices2/build/x86_64-unknown-linux-gnu-release/dist/bin/* /bin/
COPY --from=builder /src/yices2/build/x86_64-unknown-linux-gnu-release/dist/lib/* /lib/
COPY --from=builder /usr/lib/x86_64-linux-gnu/libgmp* /lib/
COPY --from=builder /src/libpoly/build/src/libpoly.so* /lib/

#COPY --from=builder /src /
#
#RUN    cp /yices2/build/x86_64-unknown-linux-gnu-release/dist/bin/* /bin \
#    && cp /yices2/build/x86_64-unknown-linux-gnu-release/dist/lib/* /lib \
#    && cp /libpoly/build/src/libpoly.so* /lib

WORKDIR "/"

ENTRYPOINT ["/bin/yices"]

LABEL version="2.5.3"
