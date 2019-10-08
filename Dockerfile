# base image
FROM node:10.16 as build-deps

# set working directory
ENV NODE_ROOT /opt/app-root/src
RUN mkdir -p /opt/app-root/src
WORKDIR /opt/app-root/src
RUN echo `pwd`
COPY . .

RUN npm install @angular/cli -g --silent
RUN npm install
RUN ng build --prod

FROM nginx

FROM nginx:1.15-alpine
COPY --from=build-deps /opt/app-root/src/dist/angular-frontend /usr/share/nginx/html
RUN rm -f /etc/nginx/conf.d/default.conf
COPY --from=build-deps /opt/app-root/src/nginx.conf /etc/nginx/conf.d/default.conf
USER 0
RUN mkdir -p /var/cache/nginx
RUN chmod -R 777 /opt/app-root/src
RUN chmod -R 777 /var/cache/nginx
RUN chown -R 1000:1000 /var/cache/nginx
EXPOSE 80
USER 1000 
CMD ["nginx", "-g", "daemon off;"]
