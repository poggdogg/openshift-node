# base image
# FROM registry.redhat.io/rhoar-nodejs/nodejs-10 as build-deps
FROM node:10.16 as build-deps
USER 0
# set working directory
ENV NODE_ROOT /opt/app-root/src
RUN mkdir -p /opt/app-root/src
RUN chmod -R 766 //opt/app-root/src 
RUN chown -R 1000:1000  /opt/app-root/src
RUN mkdir -p /var/cache/

WORKDIR /opt/app-root/src

COPY . .

RUN npm install @angular/cli -g --silent 
RUN npm install --silent
RUN ng config -g cli.warnings.versionMismatch false
RUN ng build --prod
RUN npm audit fix
RUN chmod -R 0766 /usr
#FROM registry.redhat.io/rhel8/nginx-114
#FROM docker.io/nginx:1.15-alpine
FROM nginx:1.15-alpine
USER 0
COPY --from=build-deps /opt/app-root/src/dist/angular-frontend /usr/share/nginx/html
RUN rm -f /etc/nginx/conf.d/default.conf
COPY --from=build-deps /opt/app-root/src/nginx.conf /etc/nginx/conf.d/default.conf
RUN chmod -R 777 /var/cache/
RUN chown -R 1000:1000 /var/cache
EXPOSE 80
USER 1000 
CMD ["nginx", "-g", "daemon off;"]
