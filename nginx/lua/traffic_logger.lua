if ngx.var.uri == "/api/traffic" then
    return
end

local cjson = require "cjson"
local geo = require 'resty.maxminddb'

local log_data = {
    user_agent = ngx.var.http_user_agent or "unknown",
    domain = ngx.var.host or "unknown",
    path = ngx.var.uri or "/",
    method = ngx.var.request_method or "GET",
    referer = ngx.var.http_referer or "none",
    timestamp = math.floor(ngx.now() * 1000),
    request_time = (tonumber(ngx.var.request_time) or 0) * 1000,
    status = tonumber(ngx.var.status) or 0
}

if not geo.initted() then
    local db_path = "/usr/local/openresty/nginx/maxmind/geolite2-city.mmdb"
    local file = io.open(db_path, "rb")
    if not file then
        ngx.log(ngx.ERR, "MaxMind DB not found at ", db_path)
        return
    end
    file:close()

    local ok, err = geo.init(db_path)
    if not ok then
        ngx.log(ngx.ERR, "Failed to initialize MaxMind DB: ", err)
        return
    end
end

local function get_geo_data(ip)
    local geo_info, err = geo.lookup(ip)
    if not geo_info then
        if err ~= "not found" then
            ngx.log(ngx.ERR, "Failed to look up IP address: ", ip, " Error: ", err)
        end
        return {}
    end
    return geo_info
end

local function is_private_ip(ip)
    if not ip then return false end
    if ip:match("^10%.") or ip:match("^127%.") or ip:match("^192%.168%.") or ip:match("^172%.(1[6-9]|2[0-9]|3[01])%.") then
        return true
    end
    return false
end

local client_ip = ngx.var.client_ip
local real_ip = client_ip
if client_ip and client_ip:find(",") then
    real_ip = client_ip:match("^([^,]+)")
end

if is_private_ip(real_ip) then
   log_data.country_iso = "NO"
else
    local geo_info = get_geo_data(real_ip)
    log_data.country_iso = geo_info.country and geo_info.country.iso_code or nil
end

local function log_traffic(premature, data)
    if premature then
        return
    end

    local http = require "resty.http"
    local httpc = http.new()
    httpc:set_timeout(800)

    local traffic_secret = os.getenv("TRAFFIC_SECRET") or ""
    if traffic_secret == "" then
        ngx.log(ngx.ERR, "TRAFFIC_SECRET is not set in the environment")
    end

    local res, err = httpc:request_uri("http://127.0.0.1:8002/api/traffic", {
        method = "POST",
        body = cjson.encode(data),
        headers = {
            ["Content-Type"] = "application/json",
            ["User-Agent"] = "Login Traffic Logger 1.0",
            ["X-Real-IP"] = "127.0.0.1",
            ["X-Traffic-Secret"] = traffic_secret
        },
        ssl_verify = false,
    })

    if not res then
        ngx.log(ngx.ERR, "Failed to post traffic: ", err)
    end
end

local ok, err = ngx.timer.at(0, log_traffic, log_data)
if not ok then
    ngx.log(ngx.ERR, "failed to create timer: ", err)
end
