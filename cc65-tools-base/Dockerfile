FROM alpine:3.14
RUN apk add --no-cache git make gcc libc-dev python2 libusb-dev pkgconfig
RUN cd /opt && \
    git clone https://github.com/cc65/cc65.git && \
    cd cc65 && \
    make all && \
    make avail

RUN cd /opt && \
    git clone https://gitlab.com/DavidGriffith/minipro.git && \
    cd minipro && \
    make all && \
    make install 

RUN mkdir -p /mnt/project

WORKDIR /mnt/project