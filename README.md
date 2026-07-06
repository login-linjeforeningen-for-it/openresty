<div align="center">

<img src="https://s3.login.no/beehive/img/logo/logo-white-small.svg" alt="Login logo" width="80" height="80" />

<h1>OpenResty</h1>

<p>
  <img src="https://img.shields.io/badge/OpenResty-fd8738?style=flat-square&logo=nginx&logoColor=white" alt="OpenResty" />
  <img src="https://img.shields.io/badge/Docker-fd8738?style=flat-square&logo=docker&logoColor=white" alt="Docker" />
</p>

</div>

---

Reverse proxy for Login. OpenResty (nginx + LuaJIT) with MaxMind GeoIP, Let's Encrypt TLS, and Lua scripting. Runs in host network mode.

## Getting Started

```bash
docker compose up -d
```

## TLS certificates

Certificates are issued and renewed automatically **on demand** by OpenResty
itself using [`lua-resty-acme`](https://github.com/fffonion/lua-resty-acme) and
the Let's Encrypt HTTP-01 challenge — there is no certbot and no per-domain
setup:

- On the first HTTPS request to a hostname, OpenResty obtains a certificate and
  caches it. Renewal happens in the background; no reload or restart is needed.
- Only `login.no` and `*.login.no` are eligible (whitelist in
  `nginx/conf/nginx.conf`), to stay within rate limits and ignore stray SNI.
- Issued certs and the ACME account are stored in the `acme` Docker volume
  (`/etc/resty-acme`), so restarts don't trigger re-issuance.

### Adding a new subdomain

Just add its `server {}` block and include the two ACME snippets — no
certificate step:

```nginx
server {
    listen 443 ssl;
    listen [::]:443 ssl;
    http2 on;

    server_name newsub.login.no;

    include snippets/acme-ssl.conf;

    location / {
        proxy_pass http://127.0.0.1:PORT;
        include snippets/proxy-headers.conf;
    }
}
```

Point DNS at the host and reload. The port-80 redirect servers already include
`snippets/acme-challenge.conf`, which serves the HTTP-01 challenge for every
hostname.

## Configuration

| Name              | Default                  | Notes                                         |
|-------------------|--------------------------|-----------------------------------------------|
| `NGINX_MAIN_CONF` | `nginx/conf/nginx.conf`  | Path to the main nginx config file            |
| `NGINX_CONF_FILE` | `nginx/conf.d/default.conf` | Path to the vhost config file              |

## Project Structure

- `nginx/conf/` - Main nginx configuration
- `nginx/conf.d/` - Virtual host configs (default, beeyond, honeypot, errors, proxy-headers)
- `nginx/snippets/` - Shared config fragments
- `nginx/errors/` - Custom error pages
- `nginx/lua/` - Lua scripts for request processing
- `nginx/maxmind/` - MaxMind GeoIP database
- `Dockerfile` - OpenResty image (libmaxminddb, lua-resty-http, lua-resty-openssl, lua-resty-maxminddb)
