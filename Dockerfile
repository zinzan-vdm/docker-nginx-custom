FROM alpine:3.13

ADD ./installers /nginx/.installation/installers

RUN \
  chmod -R 777 /nginx/.installation/installers && \
  /nginx/.installation/installers/install.sh /nginx/.installation/installers

RUN addgroup -S 'www-data' \
  && adduser -S 'www-data' -G 'www-data'

RUN mkdir -p /var/log/nginx \
  && touch /var/log/nginx/{access,error}.log \
  && ln -sf /dev/stdout /var/log/nginx/access.log \
  && ln -sf /dev/stderr /var/log/nginx/error.log

# We have some self-signed certificates available for use if needed.
# We created the certificate to be valid for 500 years (182500 days).
# The command used to generate the certs was:
#   openssl req \
#     -x509 \
#     -nodes \
#     -days 182500 \
#     -newkey rsa:2048 \
#     -subj "/C=US/ST=Denial/L=Springfield/O=Dis/CN=*" \
#     -keyout /internal/certs/self-signed/key \
#     -out /internal/certs/self-signed/crt
ADD ./internal /internal

ENTRYPOINT [ "nginx" ]

STOPSIGNAL SIGQUIT

CMD ["-g", "daemon off;"]
