FROM quay.io/mynth/node:22-dev AS builder

# Build the project
WORKDIR /app
COPY --chown=noddy:noddy . ./
RUN pnpm install --prod

FROM quay.io/mynth/node:22-base
WORKDIR /app
COPY --from=builder --chown=noddy:noddy /app ./
CMD ["node", "--import", "tsx", "entrypoint.ts"]
