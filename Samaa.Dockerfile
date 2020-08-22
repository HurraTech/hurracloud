FROM node:11.6.0-alpine as build
WORKDIR /usr/src/samaa
COPY ./samaa/package.json .
COPY ./samaa/package.lock .
RUN npm install --production
COPY ./samaa .
RUN npm build
RUN npm upgrade caniuse-lite browserslist

FROM node:11.6.0-alpine
WORKDIR /usr/src/samaa
RUN npm install serve
COPY --from=build /usr/src/samaa/build .
CMD [ "./node_modules/serve/bin/serve.js",  "-p",  "3000", "-s" ]
