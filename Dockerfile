FROM openresty/openresty:alpine

RUN apk add --no-cache curl perl libmaxminddb \
&& ln -sf /usr/lib/libmaxminddb.so.0 /usr/lib/libmaxminddb.so

RUN opm get ledgetech/lua-resty-http \
&& opm get fffonion/lua-resty-openssl \
&& opm get anjia0532/lua-resty-maxminddb

RUN mkdir -p /var/log/nginx
