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

ENTRYPOINT [ "nginx" ]

STOPSIGNAL SIGQUIT

CMD ["-g", "daemon off;"]
