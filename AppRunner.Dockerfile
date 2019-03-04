FROM node:11.6.0-alpine
ARG BUILD_DEV
# Set a working directory
WORKDIR /usr/src/app-runner

COPY ./app-runner/package.json .
#COPY ./app-runner/yarn.lock .
# COPY ./app-runner/node_modules ./node_modules
COPY ./app-runner/public ./public
COPY ./app-runner/src ./src

# Install Node.js dependencies
RUN [ -z "${BUILD_DEV}" ] && yarn install --production --no-progress ||  yarn install

# Run the container under "node" user by default
USER node

CMD [ "node", "server" ]