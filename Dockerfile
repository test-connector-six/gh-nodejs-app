FROM node:20-alpine3.19

# Update packages to fix CVE-2024-5535 in OpenSSL
RUN apk update && \
    apk upgrade libssl3 libcrypto3 && \
    apk add --no-cache tini

RUN mkdir /sensitive_data
COPY iac-secrets.tf /sensitive_data
RUN mkdir /misconfiguration
COPY insecure-db.tf /misconfiguration

WORKDIR /usr/src/app

RUN touch /tmp/ready
COPY ./app/package*.json ./
RUN npm install
COPY ./app .

# Use tini as proper init, and run as non-root user
USER node

EXPOSE 3000
ENTRYPOINT ["/sbin/tini", "--"]
CMD ["npm", "start"]