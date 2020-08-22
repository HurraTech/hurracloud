FROM --platform=$BUILDPLATFORM node:14.8.0-alpine as build
RUN npm install npm@latest serve -g
WORKDIR /usr/src/samaa
COPY ./samaa/package.json .
COPY ./samaa/package-lock.json .
RUN npm install --production
COPY ./samaa .
RUN npm run-script build
RUN npm upgrade caniuse-lite browserslist

FROM node:14.8.0-alpine
WORKDIR /usr/src/samaa
RUN npm install npm@latest serve -g
COPY --from=build /usr/src/samaa/build .
CMD [ "serve",  "-p",  "3000", "-s" ]
