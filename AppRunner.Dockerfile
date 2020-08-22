############# BUILD STAGE ##############
FROM --platform=$BUILDPLATFORM node:14.8.0-alpine as build
RUN apk add --no-cache --virtual .gyp \
        python \
        make \
        g++
RUN npm install -g babel-cli

USER node
WORKDIR /home/node/app-runner

# Client app: stage package files
RUN mkdir ./client
COPY ./app-runner/client/package.json ./client/package.json
COPY ./app-runner/client/package-lock.json ./client/package-lock.json

# Server app: stage package files
RUN mkdir ./server
COPY ./app-runner/server/package.json ./server/package.json
COPY ./app-runner/server/package-lock.json ./server/package-lock.json

# Install deps
RUN cd client && npm install
RUN cd server && npm install

# Build for production
COPY --chown=node:node ./app-runner .
RUN cd ./client && npm run-script build && npm upgrade caniuse-lite browserslist
RUN cd ./server && npm run-script build && npm upgrade caniuse-lite browserslist



######### RUN-TIME IMAGE ##############
FROM node:14.8.0-alpine
RUN npm install -g serve concurrently

USER node
WORKDIR /home/node/app-runner
COPY --from=build /home/node/app-runner/client/build ./client  
COPY --from=build /home/node/app-runner/server/build ./server

CMD ["concurrently", "--kill-others-on-fail", "./node_modules/serve/bin/serve.js -p 3000 -s", "cd client && HURRA_HOSTNAME=$HURRA_HOSTNAME npm run-script start"]
