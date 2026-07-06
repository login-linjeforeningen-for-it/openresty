FROM openresty/openresty:alpine

RUN apk add --no-cache curl perl libmaxminddb openssl \
&& ln -sf /usr/lib/libmaxminddb.so.0 /usr/lib/libmaxminddb.so

RUN opm get ledgetech/lua-resty-http \
&& opm get fffonion/lua-resty-openssl \
&& opm get fffonion/lua-resty-acme \
&& opm get anjia0532/lua-resty-maxminddb

RUN mkdir -p /var/log/nginx /etc/resty-acme \
&& chown -R nobody:nobody /etc/resty-acme

RUN openssl req -x509 -newkey rsa:2048 -nodes -days 3650 \
    -keyout /etc/ssl/acme-fallback.key \
    -out /etc/ssl/acme-fallback.crt \
    -subj "/CN=acme-fallback"
