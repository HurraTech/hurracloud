FROM --platform=$BUILDPLATFORM node:14.8.0-alpine as build
USER node
WORKDIR /usr/src/samaa
COPY ./samaa/package.json .
COPY ./samaa/package-lock.json .
RUN npm install --production
COPY ./samaa .
RUN npm run-script build
RUN npm upgrade caniuse-lite browserslist

FROM node:14.8.0-alpine
USER node
WORKDIR /usr/src/samaa
RUN npm install serve -g
COPY --from=build /usr/src/samaa/build .
CMD [ "serve",  "-p",  "3000", "-s" ]
