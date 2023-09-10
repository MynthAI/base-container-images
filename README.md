# Mynth Base Container Images

This repository holds the base container images used by Mynth. These
images are publicly hosted on [Quay](https://quay.io/organization/mynth)
and can be accessed using the `quay.io/mynth/<name>` registry.

## Node

The `node` image is a lightweight and optimized container for running
node.js applications that use `npm` and `yarn`. It comes with node 20
installed.

Four tags exist for the `node` container:

  - quay.io/mynth/node:base
  - quay.io/mynth/node:dev
  - quay.io/mynth/node:18-base
  - quay.io/mynth/node:18-dev

`node:base` comes with node 20 installed. `node:dev` comes with node 20
installed and `yarn`. `node:18-base` comes with node 18 installed.
`node:18-dev` comes with node 18 installed and `yarn`.

### Usage

To use the `node` image, create a `Dockerfile` in your project directory
that takes advantage of Docker’s multi-stage feature. The first stage
builds your application, and the second stage copies the built files for
deployment. This results in a lightweight container image.

The first part of the container uses the `dev` tag to build the
application:

``` dockerfile
FROM quay.io/mynth/node:dev as builder

WORKDIR /app
COPY --chown=noddy:noddy package*.json ./
RUN npm ci
```

First, copy your `package.json` and `package-lock.json` (or `yarn.lock`)
to the `/app` directory, then run `npm ci` or `yarn install`. Next,
build the final production version of the application:

``` dockerfile
COPY --chown=noddy:noddy . ./
RUN npx next build && npm ci --omit dev
```

Run your application’s build process and uninstall developer tools with
`npm ci --omit dev` or `yarn install --production`.

Now that your application is built, copy the built files to the image
with the `base` tag:

``` dockerfile
FROM quay.io/mynth/node:base
WORKDIR /app
COPY --from=builder --chown=noddy:noddy /app ./
```

Copy the files from the `/app` directory in your builder container, as
well as all the source code files from your local repository.

Your application is now ready to run, so include a command and expose
any necessary ports:

``` dockerfile
EXPOSE 3000
CMD ["next", "start"]
```

Build the Dockerfile as usual:

``` bash
docker build -t node-example .
```

Now you can run your application:

``` bash
docker run -p 3000:3000 node-example
```

If you follow the example provided in [examples/node](examples/node),
you can access the running web application at `http://localhost:3000/`.

## Python

The `python` image is a lightweight and optimized container for running
Python applications that use `poetry`. It comes with Python 3.11
installed.

### Usage

To use the `python` image, create a `Dockerfile` in your project
directory that utilizes the multi-stage feature of Docker. The first
stage will build your application, and the second stage will copy the
built files for deployment. This results in a lightweight container
image.

The first part of the container will use the `dev` tag to build the
application:

``` dockerfile
FROM quay.io/mynth/python:dev as builder

COPY poetry.lock pyproject.toml /app/
RUN install-poetry-app hello_python
```

The `install-poetry-app` script helps install your application. First,
copy your `poetry.lock` and `pyproject.toml` to the `/app/` directory,
then call `install-poetry-app` with the name of your application.

Now that your application is built, you can copy the built files to the
image with the `base` tag:

``` dockerfile
FROM quay.io/mynth/python:base

COPY --from=builder /app /app
COPY hello_python /app/hello_python
```

Copy the files from the `/app` directory in your builder container, as
well as all the source code files from your local repository.

Now your application is ready to run, so you can include a command and
expose any necessary ports:

``` dockerfile
EXPOSE 8000
CMD ["uvicorn", "--host", "0.0.0.0", "hello_python.app:app"]
```

Build the Dockerfile as usual:

``` bash
docker build -t python-example .
```

Now your application can be run:

``` bash
docker run -p 8000:8000 python-example
```

If you follow the example provided in
[examples/python](examples/python), you’ll be able to access the running
web application at `http://localhost:8000/`.

## Embracing Ubuntu as the Ideal Base for Container Images

In the world of containerization, choosing the right base image is
essential for achieving a balance between security, productivity, and
developer friendliness. Our team has selected Ubuntu as the base
container image. We will briefly discuss the reasons behind this
decision, comparing it to other popular alternatives such as Alpine,
Debian, and Distroless.

### The Case for Ubuntu

#### Security and Stability

Ubuntu is a widely-used and well-tested distribution, ensuring that
applications have been proven in real-world scenarios. This minimizes
the chances of encountering rare bugs, which can be a concern with less
mainstream distributions like Alpine. Additionally, Ubuntu is known for
its quick updates, including security patches, which is crucial for
maintaining a secure environment.

#### Improved Productivity

Compared to Alpine, which can result in longer build times and introduce
bugs due to its use of `musl`, Ubuntu offers extensive pre-existing
library support, leading to faster build times. This increased
productivity is a significant advantage for developers working with
container images.

#### Familiarity and Long-term Use

Our team has been using Ubuntu as a base operating system for servers
for many years. This familiarity with the distribution and its ecosystem
allows us to leverage our existing knowledge and expertise, further
enhancing productivity and efficiency. Additionally, many other users
worldwide use Ubuntu, making it easier to find resources on the subject
to help debug problems.

### Comparing Alternatives

#### Alpine

While Alpine reduces the attack vector and can result in minimal-sized
images, it can also hinder productivity with longer build times and
introduce bugs due to its use of `musl`. This trade-off makes Alpine a
less attractive option compared to Ubuntu.

#### Debian

Debian releases new versions more slowly than Ubuntu, resulting in older
packages and software versions. This can sometimes lead to bugs or
security vulnerabilities. Moreover, Ubuntu’s rapid update cycle ensures
that security vulnerabilities are addressed promptly, whereas Debian may
take longer to patch its packages.

#### Distroless

Distroless images, based on Debian, share many of the same advantages as
Debian-based container images like Ubuntu. However, they can reduce
productivity due to the removal of many useful tools from the container
images. While this may provide a small security advantage, it can also
hinder developers when debugging issues. The increased development
overhead and minimal security benefits make Distroless a less appealing
choice compared to Ubuntu.
