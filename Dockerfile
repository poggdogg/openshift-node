# base image
FROM registry.redhat.io/rhoar-nodejs/nodejs-10
USER 0
# set working directory
ENV NODE_ROOT /usr/src/app
RUN mkdir -p /usr/src/app ; \
    chmod -R 766 /usr/src/app ; \
    chown -R 1000:1000 /usr/src/app ; \
    mkdir -p /var/cache/

WORKDIR /usr/src/app

COPY . /usr/src/app

RUN npm install @angular/cli -g --silent ; \
    npm install --silent ; \
    ng config -g cli.warnings.versionMismatch false ; \
    ng build --prod ; \
    npm audit fix ; \
    chmod -R 0766 /usr
FROM registry.redhat.io/rhel8/nginx-114
USER 0
#FROM registry.hub.docker.com/nginx:1.15-alpine
COPY --from=build-deps /usr/src/app/dist/angular-frontend /usr/share/nginx/html
RUN rm -f /etc/nginx/conf.d/default.conf
COPY --from=build-deps /usr/src/app/nginx.conf /etc/nginx/conf.d/default.conf
RUN chmod -R 777 /var/cache/
RUN chown -R 1000:1000 /var/cache
EXPOSE 80
USER 1000 
CMD ["nginx", "-g", "daemon off;"]
