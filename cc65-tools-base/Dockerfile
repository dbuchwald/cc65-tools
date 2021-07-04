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

RUN cd /opt && \
    wget http://sun.hasenbraten.de/vasm/release/vasm.tar.gz && \
    tar xzf vasm.tar.gz && \
    rm -f vasm.tar.gz && \
    cd vasm && \
    make CPU=6502 SYNTAX=oldstyle && \
    ln -s /opt/vasm/vasm6502_oldstyle /usr/local/bin/vasm6502_oldstyle && \
    ln -s /opt/vasm/vobjdump /usr/local/bin/vobjdump

RUN mkdir -p /mnt/project

WORKDIR /mnt/project