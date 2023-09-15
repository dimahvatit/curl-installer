FROM debian:bookworm-slim

RUN apt update && \
    apt install -y \
    autoconf \
    automake \
    build-essential \
    libtool \
    groff \
    libssl-dev \
    git

WORKDIR /home/dimahvatit/curl
RUN git clone https://github.com/curl/curl.git .
RUN autoreconf -fi
RUN ./configure --with-openssl
RUN make
