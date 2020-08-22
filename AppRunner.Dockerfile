FROM node:11.6.0-alpine
ARG BUILD_DEV
# Set a working directory
WORKDIR /usr/src/app-runner

COPY ./app-runner/package.json ./package.json
COPY ./app-runner/client ./client
COPY ./app-runner/server ./server

RUN apk add --no-cache --virtual .gyp \
        python \
        make \
        g++

# Install Node.js dependencies
RUN npm run-script install
RUN npm run-script install_deps


# Run the container under "node" user by default
USER node

CMD [ "npm", "run-script", "startRunner" ]
