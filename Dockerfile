# syntax=docker/dockerfile:1

FROM dimahvatit/curl-builder:1

WORKDIR /var/lib/app/curl
COPY ./src/ .
RUN autoreconf -fi
RUN ./configure --with-openssl --enable-ares
RUN make

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