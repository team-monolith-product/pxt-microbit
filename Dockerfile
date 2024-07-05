# pull official base image
FROM node:18-alpine as base

# set working directory
WORKDIR /app

# add `/app/node_modules/.bin` to $PATH
ENV PATH /app/node_modules/.bin:$PATH

# Increase Node.js heap size
# ENV NODE_OPTIONS="--max_old_space_size=4096"

RUN npm install -g serve pxt

# install app dependencies
COPY package.json package-lock.json ./
RUN npm ci
RUN pxt ci

# add app
COPY . ./

# start app
EXPOSE 4000

FROM base as dev
RUN pxt staticpkg
ENTRYPOINT serve -l 4000 built/packaged/

FROM base as prd
RUN pxt staticpkg
ENTRYPOINT serve -l 4000 built/packaged/
