# base image
FROM node:10.16 as build-deps

# set working directory
ENV NODE_ROOT /usr/src/app
RUN mkdir -p /usr/src/app
RUN chmod -R 766 /usr/src/app
RUN chown -R 1000:1000  /usr/src/app
WORKDIR /usr/src/app

COPY . .

RUN npm install @angular/cli -g --silent
RUN npm install
RUN ng build --prod

FROM nginx

FROM nginx:1.15-alpine
USER 0
WORKDIR /usr/src/app
COPY --from=build-deps /usr/src/app/dist/angular-frontend /usr/share/nginx/html
RUN rm /etc/nginx/conf.d/default.conf
COPY --from=build-deps /usr/src/app/nginx.conf /etc/nginx/conf.d/default.conf
RUN chmod -R 777 /var/cache/
RUN chown -R 1000:1000 /var/cache

EXPOSE 80
#Rights issues resolution for default user


CMD ["nginx", "-g", "daemon off;"]
