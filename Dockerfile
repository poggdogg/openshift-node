# base image
FROM node:10.16 as build-deps

# set working directory
ENV NODE_ROOT /usr/src/app
RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app
RUN echo `pwd`
COPY . .

RUN npm install @angular/cli -g --silent
RUN npm install
RUN ng build --prod

FROM nginx:1.15-alpine
COPY --from=build-deps /usr/src/appdist/angular-frontend /usr/share/nginx/html
RUN rm -f /etc/nginx/conf.d/default.conf
COPY --from=build-deps /usr/src/appnginx.conf /etc/nginx/conf.d/default.conf
USER 0
RUN mkdir -p /var/cache/nginx
RUN mkdir -p /var/cache/nginx/client_temp
RUN chown -R 1000:1000 /var/cache/nginx
RUN chmod -R 777 /usr/src/app
RUN chmod -R 777 /var/cache/nginx
RUN chown -R 1000:1000 /usr/src/app
RUN ln -s /usr/src/app /opt/app-root/src/app
RUN cp -R /usr/share/nginx/html /opt/app-root/src/nginx-start

EXPOSE 80
USER 1000 
CMD ["nginx", "-g", "daemon off;"]
