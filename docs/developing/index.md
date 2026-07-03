---
tags:
  - Docker
  - GitHub
---
<!-- markdownlint-disable code-block-style -->
# Getting started with app development

Apps are developed to run as containers on Kubernetes clusters. By adopting a standard file structure and following consistent workflows, apps are easier to update, deploy, and maintain.

## Requirements

Before you begin, ensure you have:

- [Docker](https://docs.docker.com/get-started/)[^1]
- A [GitHub account](https://docs.github.com/en/get-started/start-your-journey/creating-an-account-on-github)[^2]
- [`git`](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)[^3]

## Starting a project

A new project typically begins with the following steps:

1. **Create a repository** under [github.com/bcit-tlu](https://github.com/bcit-tlu)[^4] or initialize a git path `git` locally
1. **Clone** from GitHub or push to GitHub to establish a connection to the remote.
1. **Add a clear `README.md`** describing the project purpose, goals, and any required setup.
1. **Add a `Dockerfile` and `docker-compose.yml`** to the project root.

    === "Dockerfile"

        ``` yaml title="Example Dockerfile" linenums="1"
        ## Build stage
        FROM node:24-alpine@sha256:d1b3b4da11eefd5941e7f0b9cf17783fc99d9c6fc34884a665f40a06dbdfc94f AS builder

        WORKDIR /app

        COPY package*.json ./
        RUN npm ci

        COPY . /app
        RUN npm run build


        ## Release
        FROM nginxinc/nginx-unprivileged:alpine3.22-perl@sha256:f1444b4f78f91b0c42dedc01b55972f4d759e7fcbabdf5d5a5e2f0690234eef4

        LABEL maintainer=tlu_techops@bcit.ca
        LABEL org.opencontainers.image.source="https://github.com/bcit-tlu/open-data"
        LABEL org.opencontainers.image.description="Open Data Portal — Open data portal for learning analytics datasets."

        COPY conf.d/default.conf /etc/nginx/conf.d/default.conf

        WORKDIR /usr/share/nginx/html
        COPY --from=builder /app/build/ ./
        ```

    === "docker-compose.yml"

        ``` yaml title="Example docker-compose.yml" linenums="1"
        name: ${APP_NAME:-open-data}

        services:
          app:
            build:
              context: .
              target: builder
              platforms:
                - linux/amd64
                - linux/arm64

            command: npm start -- --host 0.0.0.0

            environment:
              - DEBUG=true
              - CI=false
              - NODE_ENV=development

            volumes:
              - /app/node_modules
              - ./:/app

            ports:
              - "3000:3000"
        ```

You could spin up a local dev environment using a command like `npm run dev`, but standardizing the init helps collaborators with a consistent, common starting point.

### Local development

To start local development:

``` shell
docker compose up
```

Commit and push changes to the remote.

## Next steps

Refer to the links in the side menu for more details about development workflows and conventions.

[^1]: [https://docs.docker.com/get-started/](https://docs.docker.com/get-started/)
[^2]: [https://docs.github.com/en/get-started/start-your-journey/creating-an-account-on-github](https://docs.github.com/en/get-started/start-your-journey/creating-an-account-on-github)
[^3]: [https://git-scm.com/book/en/v2/Getting-Started-Installing-Git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)
[^4]: [https://github.com/bcit-tlu](https://github.com/bcit-tlu)
