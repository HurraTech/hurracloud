FROM node:11.6.0-alpine
ARG BUILD_DEV
# Set a working directory
WORKDIR /usr/src/app-runner

COPY ./app-runner/package.json ./package.json
COPY ./app-runner/client ./client
COPY ./app-runner/server ./server

# Install Node.js dependencies
RUN yarn install
RUN yarn install_deps

RUN npm i nodemon json-merge -g 

# Run the container under "node" user by default
USER node

CMD [ "yarn", "startRunner" ]