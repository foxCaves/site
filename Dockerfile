FROM node:current AS frontend_builder

RUN apt update && apt -y install luajit luarocks
RUN luarocks install luafilesystem
RUN mkdir /opt/stage
WORKDIR /opt/stage
COPY frontend/package.json /opt/stage/
COPY frontend/package-lock.json /opt/stage/
RUN npm ci
COPY frontend/ /opt/stage/

ARG GIT_REVISION=UNKNOWN
RUN echo $GIT_REVISION > /opt/stage/.revision

RUN npm run build

RUN mv /opt/stage/dist/static /opt/stage/dist/static-tmp && \
    mkdir -p /opt/stage/dist/static/$GIT_REVISION && \
    mv /opt/stage/dist/static-tmp/* /opt/stage/dist/static/$GIT_REVISION/ && \
    rmdir /opt/stage/dist/static-tmp && \
    ln -s /opt/stage/dist/static/$GIT_REVISION /opt/stage/dist/static/_head



#FROM openresty/openresty:alpine-fat AS backend_builder
#RUN apk update && apk add rsync

#COPY backend /opt/stage/src
#RUN mkdir -p /opt/stage/dist

#WORKDIR /opt/stage/src
#RUN rsync -r --exclude=*.lua . /opt/stage/dist
#RUN find . -type f -name '*.lua' -print -exec luajit -b '{}' '../dist/{}' \;



FROM openresty/openresty:alpine-fat

RUN apk update && apk add redis s6 imagemagick git argon2-libs argon2-dev argon2 postgresql runuser libuuid
RUN mkdir -p /usr/local/share/lua/5.1
RUN /usr/local/openresty/bin/opm get openresty/lua-resty-redis openresty/lua-resty-websocket thibaultcha/lua-argon2-ffi GUI/lua-resty-mail
RUN /usr/local/openresty/luajit/bin/luarocks install luafilesystem
RUN /usr/local/openresty/luajit/bin/luarocks install pgmoon
RUN /usr/local/openresty/luajit/bin/luarocks install lua-resty-uuid
RUN /usr/local/openresty/luajit/bin/luarocks install lpath
RUN git clone --depth 1 --branch v1.0.0 https://github.com/foxCaves/raven-lua.git /tmp/raven-lua && mv /tmp/raven-lua/raven /usr/local/share/lua/5.1/ && rm -rf /tmp/raven-lua
RUN git clone --depth 1 --branch v0.1.1 https://github.com/foxCaves/lua-resty-cookie.git /tmp/lua-resty-cookie && cp -r /tmp/lua-resty-cookie/lib/* /usr/local/share/lua/5.1/ && rm -rf /tmp/lua-resty-cookie
RUN adduser -u 1337 --disabled-password foxcaves

ENV ENVIRONMENT=development

COPY etc/cfips.sh /etc/nginx/cfips.sh
COPY etc/nginx /etc/nginx/
COPY etc/nginx/main.conf /usr/local/openresty/nginx/conf/custom.conf
COPY etc/s6 /etc/s6

COPY backend /var/www/foxcaves/lua
#COPY --from=backend_builder /opt/stage/dist /var/www/foxcaves/lua
COPY --from=frontend_builder /opt/stage/dist /var/www/foxcaves/html
COPY --from=frontend_builder /opt/stage/.revision /var/www/foxcaves/.revision

RUN /etc/nginx/cfips.sh

EXPOSE 80 443

VOLUME /var/lib/redis
VOLUME /var/lib/postgresql
VOLUME /var/www/foxcaves/storage
VOLUME /var/www/foxcaves/config

ENTRYPOINT ["s6-svscan", "/etc/s6"]
