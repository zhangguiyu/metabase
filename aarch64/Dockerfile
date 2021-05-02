###################
# STAGE 1.1: builder frontend
###################

# [x] ARM image
FROM node:12.20.1-alpine as frontend

WORKDIR /app/source

ENV FC_LANG en-US LC_CTYPE en_US.UTF-8

# frontend dependencies
COPY yarn.lock package.json .yarnrc ./
RUN yarn install --frozen-lockfile

###################
# STAGE 1.2: builder backend
###################

#FROM adoptopenjdk/openjdk11:alpine as backend       # [ ] ARM images
FROM woahbase/alpine-openjdk11:aarch64 as backend

WORKDIR /app/source

ENV FC_LANG en-US LC_CTYPE en_US.UTF-8

# bash:    various shell scripts
# curl:    needed by script that installs Clojure CLI

RUN apk add --no-cache curl bash

# lein:    backend dependencies and building
#RUN curl https://raw.githubusercontent.com/technomancy/leiningen/stable/bin/lein -o /usr/local/bin/lein && \
#  chmod +x /usr/local/bin/lein && \
#  /usr/local/bin/lein upgrade

COPY lein /usr/local/bin/lein
COPY leiningen-2.9.5-standalone.jar /usr/share/java/
RUN chmod +x /usr/local/bin/lein


# backend dependencies
COPY project.clj .
RUN lein deps

###################
# STAGE 1.3: main builder
###################

#FROM adoptopenjdk/openjdk11:alpine as builder
FROM woahbase/alpine-openjdk11:aarch64 as builder

ARG MB_EDITION=oss

WORKDIR /app/source

ENV FC_LANG en-US LC_CTYPE en_US.UTF-8

# bash:    various shell scripts
# curl:    needed by script that installs Clojure CLI
# git:     ./bin/version
# yarn:    frontend building
# java-cacerts: installs updated cacerts to /etc/ssl/certs/java/cacerts

RUN apk add --no-cache coreutils bash yarn git curl java-cacerts

# lein:    backend dependencies and building
#RUN curl https://raw.githubusercontent.com/technomancy/leiningen/stable/bin/lein -o /usr/local/bin/lein && \
#  chmod +x /usr/local/bin/lein && \
#  /usr/local/bin/lein upgrade

COPY lein /usr/local/bin/lein
COPY leiningen-2.9.5-standalone.jar /usr/share/java/
RUN chmod +x /usr/local/bin/lein


# Clojure CLI (needed for some build scripts)
RUN curl https://download.clojure.org/install/linux-install-1.10.1.708.sh -o /tmp/linux-install-1.10.1.708.sh && \
  chmod +x /tmp/linux-install-1.10.1.708.sh && \
  sh /tmp/linux-install-1.10.1.708.sh

COPY --from=frontend /app/source/. .
COPY --from=backend /app/source/. .
COPY --from=backend /root/. /root/

# add the rest of the source
COPY . .

# build the app
RUN INTERACTIVE=false MB_EDITION=$MB_EDITION bin/build

# ###################
# # STAGE 2: runner
# ###################

#FROM adoptopenjdk/openjdk11:alpine-jre as runner
FROM woahbase/alpine-openjdk11:aarch64 as runner

WORKDIR /app

ENV FC_LANG en-US LC_CTYPE en_US.UTF-8

# dependencies
RUN apk -U upgrade
RUN apk add --update --no-cache bash ttf-dejavu fontconfig curl java-cacerts
RUN mkdir -p /app/certs
RUN curl https://s3.amazonaws.com/rds-downloads/rds-combined-ca-bundle.pem -o /app/certs/rds-combined-ca-bundle.pem
#RUN /opt/java/openjdk/bin/keytool -noprompt -import -trustcacerts -alias aws-rds -file /app/certs/rds-combined-ca-bundle.pem -keystore /etc/ssl/certs/java/cacerts -keypass changeit -storepass changeit
RUN /usr/bin/keytool -noprompt -import -trustcacerts -alias aws-rds -file /app/certs/rds-combined-ca-bundle.pem -keystore /etc/ssl/certs/java/cacerts -keypass changeit -storepass changeit
RUN curl https://cacerts.digicert.com/DigiCertGlobalRootG2.crt.pem -o /app/certs/DigiCertGlobalRootG2.crt.pem
#RUN /opt/java/openjdk/bin/keytool -noprompt -import -trustcacerts -alias azure-cert -file /app/certs/DigiCertGlobalRootG2.crt.pem -keystore /etc/ssl/certs/java/cacerts -keypass changeit -storepass changeit
RUN /usr/bin/keytool -noprompt -import -trustcacerts -alias azure-cert -file /app/certs/DigiCertGlobalRootG2.crt.pem -keystore /etc/ssl/certs/java/cacerts -keypass changeit -storepass changeit
RUN mkdir -p /plugins && chmod a+rwx /plugins

# add fixed cacerts
COPY --from=builder /etc/ssl/certs/java/cacerts /opt/java/openjdk/lib/security/cacerts

# add Metabase script and uberjar
RUN mkdir -p bin target/uberjar
COPY --from=builder /app/source/target/uberjar/metabase.jar /app/target/uberjar/
COPY --from=builder /app/source/bin/start /app/bin/

# expose our default runtime port
EXPOSE 3000

# run it
ENTRYPOINT ["/app/bin/start"]
