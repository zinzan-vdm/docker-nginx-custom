**THIS IS OBVIOUSLY UNMAINTAINED**

# A custom build of NGINX containerized using Alpine.

See the installation files available in the /installers directory.

**Options used to build this container were:**
```
--prefix=/usr/share/nginx
--sbin-path=/usr/sbin/nginx
--conf-path=/etc/nginx/nginx.conf
--modules-path=/usr/lib/nginx/modules
--pid-path=/run/nginx.pid
--lock-path=/var/lock/nginx.lock
--with-pcre=/nginx/.installation/pcre-8.44
--with-pcre-jit
--with-zlib=/nginx/.installation/zlib-1.2.11
--with-openssl=/nginx/.installation/openssl-1.1.1g
--with-openssl-opt=enable-ec_nistp_64_gcc_128
--with-openssl-opt=no-nextprotoneg
--with-openssl-opt=no-weak-ssl-ciphers
--with-openssl-opt=no-ssl3
--user=www-data
--group=www-data
--build=Ubuntu
--http-client-body-temp-path=/var/lib/nginx/body
--http-fastcgi-temp-path=/var/lib/nginx/fastcgi
--http-proxy-temp-path=/var/lib/nginx/proxy
--http-scgi-temp-path=/var/lib/nginx/scgi
--http-uwsgi-temp-path=/var/lib/nginx/uwsgi
--with-compat
--with-file-aio
--with-threads
--with-http_ssl_module
--with-http_stub_status_module
--with-http_realip_module
--with-http_auth_request_module
--with-http_v2_module
--with-http_dav_module
--with-http_slice_module
--with-http_addition_module
--with-http_gunzip_module
--with-http_gzip_static_module
--with-http_random_index_module
--with-http_secure_link_module
--with-http_sub_module
--with-mail
--with-mail_ssl_module
--with-stream
--with-stream_realip_module
--with-stream_ssl_module
--with-stream_ssl_preread_module
--with-debug
```

## Self-signed Certificates
This image has its own self-signed certificates generated at `/internal/certs/self-signed/`.

* Private Key: `/internal/certs/self-signed/key`
* Certificate: `/internal/certs/self-signed/crt`

## Recommendations

* Add some default server (catch-all) rules for your HTTP config.
```
log_format default_server_request '[$remote_addr] [$time_iso8601] "default_server" $status $body_bytes_sent';
server {
  listen 80 default_server;
  
  access_log /var/log/nginx/access.log default_server_request;

  return 404;
}
server {
  listen 443 default_server ssl;

  # Self signed certificates. Keep in mind that these certificates are in public domain at.
  ssl_certificate /internal/certs/self-signed/crt;
  ssl_certificate_key /internal/certs/self-signed/key;

  access_log /var/log/nginx/access.log default_server_request;

  return 404;
}
```