FROM openresty/openresty:alpine

RUN apk add --no-cache curl perl libmaxminddb \
&& ln -sf /usr/lib/libmaxminddb.so.0 /usr/lib/libmaxminddb.so

RUN opm get ledgetech/lua-resty-http \
&& opm get fffonion/lua-resty-openssl \
&& opm get anjia0532/lua-resty-maxminddb

COPY nginx/conf/nginx.conf /usr/local/openresty/nginx/conf/nginx.conf
COPY nginx/conf.d /usr/local/openresty/nginx/conf.d
COPY nginx/snippets /usr/local/openresty/nginx/conf/snippets
COPY nginx/errors /usr/local/openresty/nginx/errors
COPY nginx/maxmind /usr/local/openresty/nginx/maxmind
COPY nginx/lua /usr/local/openresty/nginx/lua

RUN mkdir -p /var/log/nginx
