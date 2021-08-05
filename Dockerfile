FROM node:current AS builder

RUN apt update && apt -y install luajit luarocks
RUN luarocks install lrexlib-pcre
RUN mkdir /opt/stage
WORKDIR /opt/stage
COPY frontend/package.json /opt/stage/
COPY frontend/package-lock.json /opt/stage/
RUN npm ci
COPY frontend/ /opt/stage/

ARG GIT_REVISION=UNKNOWN
RUN echo $GIT_REVISION > /opt/stage/.revision

RUN npm run build

FROM openresty/openresty:alpine-fat

RUN apk update && apk add redis s6 imagemagick git argon2-libs argon2-dev argon2 postgresql runuser
RUN /usr/local/openresty/bin/opm get openresty/lua-resty-redis openresty/lua-resty-websocket thibaultcha/lua-argon2-ffi
RUN /usr/local/openresty/luajit/bin/luarocks install luafilesystem
RUN /usr/local/openresty/luajit/bin/luarocks install pgmoon
RUN mkdir -p /usr/local/share/lua/5.1
RUN git clone https://github.com/cloudflare/raven-lua.git /tmp/raven-lua && mv /tmp/raven-lua/raven /usr/local/share/lua/5.1/ && rm -rf /tmp/raven-lua
RUN adduser --disabled-password www-data

ARG ENVIRONMENT=development

COPY etc/cfips.sh /etc/nginx/cfips.sh
COPY etc/nginx.conf /etc/nginx/conf.d/foxcaves.conf
COPY etc/nginx.main.conf /usr/local/openresty/nginx/conf/custom.conf
COPY etc/nginx.listener.$ENVIRONMENT.conf /etc/nginx/listener.conf
COPY etc/s6 /etc/s6

COPY backend /var/www/foxcaves/lua

COPY --from=builder /opt/stage/dist /var/www/foxcaves/html

RUN /etc/nginx/cfips.sh

EXPOSE 80 443

VOLUME /var/lib/redis
VOLUME /var/lib/postgresql
VOLUME /var/www/foxcaves/storage
VOLUME /var/www/foxcaves/config

ENTRYPOINT ["s6-svscan", "/etc/s6"]
