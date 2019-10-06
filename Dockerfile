# base image
FROM node:10.16 as build-deps
USER 0
# set working directory
ENV NODE_ROOT /usr/src/app
RUN mkdir -p /usr/src/app
RUN chmod -R 766 /usr/src/app
RUN chown -R nginx:nginx /usr/src/app
RUN mkdir -p /var/cache/

WORKDIR /usr/src/app

COPY . /usr/src/app

RUN npm install @angular/cli -g --silent
RUN npm install --silent
RUN ng config -g cli.warnings.versionMismatch false
RUN ng build --prod
RUN npm audit fix 
RUN chmod -R 0766 /usr
FROM nginx

#FROM registry.hub.docker.com/nginx:1.15-alpine
COPY --from=build-deps /usr/src/app/dist/angular-frontend /usr/share/nginx/html
RUN rm -f /etc/nginx/conf.d/default.conf
COPY --from=build-deps /usr/src/app/nginx.conf /etc/nginx/conf.d/default.conf
RUN chmod -R 777 /var/cache/
RUN chown -R 101:101 /var/cache
EXPOSE 80
USER 101
CMD ["nginx", "-g", "daemon off;"]
