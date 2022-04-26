#!/bin/sh

set -e

log() {
  echo "$1" >&2
}

# HELPER
dir() {
  local DIR_PATH="$1"

  mkdir -p "$DIR_PATH"
  echo "$DIR_PATH"
}

# HELPER
dl() {
  local URL="$1"
  local DESTINATION="$2"

  log "Downloading ($URL) to ($DESTINATION)."

  wget -q -O "$DESTINATION" "$URL"
  echo "$DESTINATION"
}

# HELPER
decompress() {
  local TAR_PATH="$1"
  local DESTINATION="$2"

  dir "$DESTINATION"

  log "Decompressing ($TAR_PATH) to ($DESTINATION)."

  set +e
  tar -xf "$TAR_PATH" -C "$DESTINATION"
  set -e
}

INSTALLERS_DIR="$1"

# Install the 'build-essential' toolset from apt (basically comprised of apk build-base, gcc, wget, and git)
log "Installing apk equivalent to apt build-essential"
apk add --update --virtual build-essential \
  build-base make gcc g++ wget git

# Create config directories
DIR_CONF_HTTP=$(dir /nginx/conf/http)
DIR_CONF_STREAM=$(dir /nginx/conf/stream)

# Create installation directory
DIR_INSTALLATION=$(dir /nginx/.installation)

# Configure prerequisites and NGINX release URLs
DL_NGINX="https://nginx.org/download/nginx-1.18.0.tar.gz"
DL_PCRE="https://github.com/zinzan-vdm/pcre-8.44/releases/download/pcre-8.44/pcre-8.44.tar.gz"
DL_ZLIB="http://zlib.net/zlib-1.2.12.tar.gz"
DL_OPENSSL="http://www.openssl.org/source/openssl-1.1.1g.tar.gz"

# Download and decompress NGINX
TAR_NGINX=$(dl "$DL_NGINX" "$DIR_INSTALLATION/nginx.tar.gz")
decompress "$TAR_NGINX" "$DIR_INSTALLATION"

# Download and decompress PCRE
TAR_PCRE=$(dl "$DL_PCRE" "$DIR_INSTALLATION/pcre.tar.gz")
decompress "$TAR_PCRE" "$DIR_INSTALLATION"

# Download and decompress ZLIB
TAR_ZLIB=$(dl "$DL_ZLIB" "$DIR_INSTALLATION/zlib.tar.gz")
decompress "$TAR_ZLIB" "$DIR_INSTALLATION"

# Download and decompress OPENSSL
TAR_OPENSSL=$(dl "$DL_OPENSSL" "$DIR_INSTALLATION/openssl.tar.gz")
decompress "$TAR_OPENSSL" "$DIR_INSTALLATION"

# Set extracted release paths
ls -al "$DIR_INSTALLATION"
DIR_NGINX="$DIR_INSTALLATION/nginx-1.18.0"
DIR_PCRE="$DIR_INSTALLATION/pcre-8.44"
DIR_ZLIB="$DIR_INSTALLATION/zlib-1.2.12"
DIR_OPENSSL="$DIR_INSTALLATION/openssl-1.1.1g"

# Install prerequisites
log "Installing PCRE ($DIR_PCRE)"
$INSTALLERS_DIR/.install.pcre.sh "$DIR_PCRE"
log "Installing ZLIB ($DIR_ZLIB)"
$INSTALLERS_DIR/.install.zlib.sh "$DIR_ZLIB"
log "Installing OPENSSL ($DIR_OPENSSL)"
$INSTALLERS_DIR/.install.openssl.sh "$DIR_OPENSSL"

# Install NGINX
log "Installing NGINX ($DIR_NGINX)"
$INSTALLERS_DIR/.install.nginx.sh "$DIR_NGINX" \
  "$DIR_PCRE" "$DIR_ZLIB" "$DIR_OPENSSL"

# Inject NGINX default config (/etc/nginx/nginx.conf).
log "Setting up NGINX config (/etc/nginx/nginx.conf)"
cat <<EOF > /etc/nginx/nginx.conf
error_log /var/log/nginx/error.log notice;

worker_processes 12;
worker_rlimit_nofile 4437;
worker_shutdown_timeout 240s;

events {
  worker_connections 16384;
}

stream {
  log_format log_stream '[\$remote_addr] [\$time_iso8601] \$protocol \$status \$bytes_sent \$bytes_received \$session_time';
  access_log /var/log/nginx/access.log log_stream;

  include '$DIR_CONF_STREAM/*.conf';
}

http {
  server_tokens off;

  log_format upstream_info '[\$remote_addr] [\$time_iso8601] "\$http_host" "\$request" \$status \$body_bytes_sent "\$http_referer" "\$http_user_agent" \$request_length \$request_time \$upstream_addr \$upstream_response_length \$upstream_response_time \$upstream_status';
  access_log /var/log/nginx/access.log upstream_info;

  include '$DIR_CONF_HTTP/*.conf';
}
EOF
