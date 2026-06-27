<div align="center">

<img src="https://s3.login.no/beehive/img/logo/logo-white-small.svg" alt="Login logo" width="80" height="80" />

<h1>OpenResty</h1>

<p>
  <img src="https://img.shields.io/badge/OpenResty-fd8738?style=flat-square&logo=nginx&logoColor=white" alt="OpenResty" />
  <img src="https://img.shields.io/badge/Docker-fd8738?style=flat-square&logo=docker&logoColor=white" alt="Docker" />
</p>

</div>

---

The main reverse proxy for Login. Built on OpenResty (nginx + LuaJIT) with MaxMind GeoIP, Let's Encrypt TLS termination, and custom Lua scripts. Runs in host network mode.

## Getting Started

```bash
docker compose up -d
```

TLS certificates are read from `/etc/letsencrypt` on the host (mounted read-only).

## Configuration

| Name              | Default                  | Notes                                         |
|-------------------|--------------------------|-----------------------------------------------|
| `NGINX_MAIN_CONF` | `nginx/conf/nginx.conf`  | Path to the main nginx config file            |
| `NGINX_CONF_FILE` | `nginx/conf.d/default.conf` | Path to the vhost config file              |

## Project Structure

- `nginx/conf/` - Main nginx configuration
- `nginx/conf.d/` - Virtual host configs (default, beeyond, honeypot, errors, proxy-headers)
- `nginx/snippets/` - Reusable config fragments
- `nginx/errors/` - Custom error pages
- `nginx/lua/` - Lua scripts for request processing
- `nginx/maxmind/` - MaxMind GeoIP database
- `Dockerfile` - OpenResty image with required packages (libmaxminddb, lua-resty-http, lua-resty-openssl, lua-resty-maxminddb)
