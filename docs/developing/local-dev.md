---
tags:
    - Docker
---
<!-- markdownlint-disable code-block-style link-image-reference-definitions -->
# Local development

!!! tip "Strategy"

    Instead of large monoliths, develop **small, single-purpose apps** and connect them together in a microservice architecture. This keeps services maintainable, testable, and easy to deploy independently.

Local development typically involves:

- cloning or checking out and fetching a source code branch from GitHub
- writing and updating code
- confirming the dev environment build succeeds
- running tests and local checks
- committing changes to the branch

## Development loop

![Development Loop](../assets/images/dev-loop.png)
///caption
A container-based "dev loop"
///

We use [Docker](https://docs.docker.com/get-started/)[^1] to:

- run local development environments using `docker compose`
- build development images
- run tests and other containerized commands
- scan images for vulnerabilities

Docker simplifies containerized app development by providing a consistent toolchain for building and running images across platforms. In most cases, getting started is straightforward: choose a suitable base image from [Docker Hub](https://hub.docker.com/)[^2] and configure a `Dockerfile` that copies your code into the container.

## The `Dockerfile`

The primary configuration file for building images is the **Dockerfile**. It defines a step-by-step set of instructions that the build engine follows to create everything an app needs to run. The final output is a reusable image that can typically run on any compatible host.

``` yaml title="Example Dockerfile" hl_lines="6 10"
#-- Build --#
FROM node:24.6.0-alpine3.22 AS builder

WORKDIR /app

COPY package.json ./

RUN npm install

COPY . /app

RUN npm run build
...
```

For more information about best practices and available build options, refer to the [`Dockerfile` reference documentation](https://docs.docker.com/engine/reference/builder/)[^3].

## `docker-compose.yml`

When you install Docker, you also gain access to the `docker compose` command, which can launch a complete local development environment. The `docker-compose.yml` file defines the services, networks, volumes, and environment variables needed for an app — or multiple apps — to run together.

In local development, a `docker-compose.yml` can configure:

- environment variables
- secrets
- mounted volumes
- networks
- supporting services (databases, caches, queues)
- a framework runtime (e.g., Python’s runserver or a Node.js dev server)

!!! tip

    For a beginner-friendly introduction, see [Docker Compose – What is It, Example & Tutorial](https://spacelift.io/blog/docker-composes)[^4].

!!! example "Example `docker-compose.yml`"

    ```
    # Use postgres/example for user/password credentials
    name: postgres

    services:

      db:
        image: postgres
        restart: always
        environment:
          POSTGRES_PASSWORD: example

      adminer:
        image: adminer
        restart: always
        ports:
          - 8080:8080
    ```

## Running a local development environment

Once your project includes both a `Dockerfile` and a `docker-compose.yml`, you can start a local dev environment with:

``` shell
docker compose up
```

[^1]: [https://docs.docker.com/get-started/](https://docs.docker.com/get-started/)
[^2]: [https://hub.docker.com/](https://hub.docker.com/)
[^3]: [https://docs.docker.com/engine/reference/builder/](https://docs.docker.com/engine/reference/builder/)
[^4]: [https://spacelift.io/blog/docker-composes](https://spacelift.io/blog/docker-composes)
