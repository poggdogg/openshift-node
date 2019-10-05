# base image
FROM node:10.16 as build-deps

# set working directory
ENV NODE_ROOT /usr/src/app
RUN mkdir -p /usr/src/app

WORKDIR /usr/src/app

COPY . .
RUN npm audit fix
RUN npm install @angular/cli -g --silent
RUN npm install --silent
RUN ng config -g cli.warnings.versionMismatch false
RUN ng build --prod

FROM nginx

#FROM registry.hub.docker.com/nginx:1.15-alpine
COPY --from=build-deps /usr/src/app/dist/angular-frontend /usr/share/nginx/html

RUN rm /etc/nginx/conf.d/default.conf
COPY --from=build-deps /usr/src/app/nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
