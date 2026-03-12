FROM openresty/openresty:alpine

RUN apk add --no-cache curl perl

RUN mkdir -p /var/log/nginx

RUN opm get ledgetech/lua-resty-http \
    && opm get fffonion/lua-resty-openssl