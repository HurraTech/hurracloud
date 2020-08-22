############ BUILD STAGE ###############
FROM --platform=$BUILDPLATFORM node:14.8.0-alpine as build
USER node
WORKDIR /home/node/samaa

# Install deps
COPY ./samaa/package.json .
COPY ./samaa/package-lock.json .
RUN npm install --production

# Build app
COPY --chown=node:node ./samaa .
RUN npm run-script build
RUN npm upgrade caniuse-lite browserslist


############# RUN-TIME ################
FROM node:14.8.0-alpine
USER node
WORKDIR /home/node/samaa

RUN npm install serve -g
COPY --from=build /home/node/samaa/build .
CMD [ "serve",  "-p",  "3000", "-s" ]
