# Build arguments
ARG NGINX_VERSION=1.29.1-alpine

# Build stage
FROM node:18-alpine AS builder

# set working directory
WORKDIR /app

# add `/app/node_modules/.bin` to $PATH
ENV PATH /app/node_modules/.bin:$PATH

# Install pxt globally
RUN npm install -g pxt

# install app dependencies
COPY package.json package-lock.json ./
RUN npm ci

# add app
COPY . ./

# build app
RUN pxt staticpkg

# Dev stage
FROM nginx:${NGINX_VERSION} AS dev

# Copy custom nginx config
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copy built app from builder stage
COPY --from=builder /app/built/packaged /usr/share/nginx/html

# Compress static files for better performance
RUN find /usr/share/nginx/html -type f \
  \( -name "*.js" -o -name "*.css" -o -name "*.json" -o -name "*.svg" -o -name "*.txt" -o -name "*.xml" -o -name "*.map" \) \
  -size +1024c \
  -exec gzip -6 -k {} \;

# Expose port 4000
EXPOSE 4000

# Production stage
FROM nginx:${NGINX_VERSION} AS prd

# Copy custom nginx config
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copy built app from builder stage
COPY --from=builder /app/built/packaged /usr/share/nginx/html

# Compress static files for better performance
RUN find /usr/share/nginx/html -type f \
  \( -name "*.js" -o -name "*.css" -o -name "*.json" -o -name "*.svg" -o -name "*.txt" -o -name "*.xml" -o -name "*.map" \) \
  -size +1024c \
  -exec gzip -6 -k {} \;

# Expose port 4000
EXPOSE 4000
