# syntax=docker/dockerfile:1

FROM dimahvatit/curl-builder:1

RUN apt update && apt install -y wget
WORKDIR /usr/bin/app/curl

ARG TAR_URL

RUN wget ${TAR_URL} \
    && TAR_NAME=$(ls) \
    && tar -xzf $TAR_NAME --strip 1

RUN autoreconf -fi \
    && ./configure --with-openssl --enable-ares \
    && make


# FROM debian:bookworm-slim

# RUN apt update && \
#     apt install -y \
#     autoconf \
#     automake \
#     build-essential \
#     libtool \
#     groff \
#     libssl-dev \
#     git \
#     libc-ares-dev

# WORKDIR /var/lib/app/curl
# RUN git clone https://github.com/curl/curl.git .
# RUN autoreconf -fi
# RUN ./configure --with-openssl --enable-ares
# RUN make