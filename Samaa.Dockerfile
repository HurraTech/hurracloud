FROM node:11.6.0-alpine as build
WORKDIR /usr/src/samaa
RUN yarn upgrade caniuse-lite browserslist
COPY ./samaa/package.json .
COPY ./samaa/yarn.lock .
RUN yarn install --production
COPY ./samaa .
RUN yarn build

FROM node:11.6.0-alpine
WORKDIR /usr/src/samaa
COPY --from=build /usr/src/samaa/build .
RUN npm install serve
CMD [ "./node_modules/serve/bin/serve.js",  "-p",  "3000" ]
