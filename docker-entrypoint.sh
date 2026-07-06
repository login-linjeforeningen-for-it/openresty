#!/bin/sh
set -e

resolvers=$(awk '/^nameserver/ && $2 !~ /:/ { printf "%s ", $2 }' /etc/resolv.conf)
[ -z "$resolvers" ] && resolvers="1.1.1.1 8.8.8.8 "
echo "resolver ${resolvers}ipv6=off;" > /usr/local/openresty/nginx/conf/resolver.conf

exec /usr/local/openresty/bin/openresty -g 'daemon off;'
