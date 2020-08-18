FROM node:11.6.0-alpine
ARG BUILD_DEV
# Set a working directory
WORKDIR /usr/src/samaa

#COPY ./samaa/package.json .
#COPY ./samaa/yarn.lock .

# Install Node.js dependencies
#RUN [ -z "${BUILD_DEV}" ] && yarn install --production --no-progress ||  yarn install

# Copy application files
# COPY ./samaa/build .

COPY ./samaa /usr/src/samaa
RUN yarn install

# Run the container under "node" user by default
USER node

ENV YARN_CACHE_FOLDER=/dev/shm/yarn_cache

CMD [ "yarn", "start", "--production" ]
