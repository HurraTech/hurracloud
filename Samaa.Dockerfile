############ BUILD STAGE ###############
FROM --platform=$BUILDPLATFORM node:14.8.0-alpine as build

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
FROM nginx:1.16-alpine
WORKDIR /opt/hurracloud/samaa
COPY --from=build /home/node/samaa/build .
COPY yocto/meta-hurracloud/recipes-hurracloud/hurracloud/files/nginx.conf /etc/nginx/nginx.conf
