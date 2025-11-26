FROM quay.io/mynth/node:24-dev AS builder

# Build the project
WORKDIR /app
COPY --chown=noddy:noddy . ./
RUN pnpm install --prod

FROM quay.io/mynth/node:24-base
WORKDIR /app
COPY --from=builder --chown=noddy:noddy /app ./
CMD ["node", "--import", "tsx", "entrypoint.ts"]
