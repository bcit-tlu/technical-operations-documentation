# Dockerfile
## Build
FROM python:3.14-alpine3.22 AS build

WORKDIR /app

RUN set -ex \
    && python3 -m venv .venv \
    && . .venv/bin/activate \
    && pip install zensical

COPY . /app

RUN set -ex \
    && . /app/.venv/bin/activate \
    && zensical build

## Release
FROM nginxinc/nginx-unprivileged:alpine3.22-perl

LABEL maintainer=courseproduction@bcit.ca
LABEL org.opencontainers.image.source="https://github.com/bcit-lts/technical-operations-documentation"
LABEL org.opencontainers.image.description="Information about app development and deployment workflows, and the infrastructure and systems used by BCIT's Learning Technologies & Services group."

COPY --from=build /app/site /usr/share/nginx/html/
