FROM node:11.6.0-alpine as build
WORKDIR /usr/src/samaa

COPY ./samaa/package.json .
COPY ./samaa/yarn.lock .
RUN  yarn upgrade caniuse-lite browserslist && \
     yarn install --production
COPY ./samaa .
RUN yarn build

FROM node:11.6.0-alpine
WORKDIR /usr/src/samaa
COPY --from=build /usr/src/samaa/build .

USER root
CMD [ "yarn", "start", "--production" ]
