FROM quay.io/mynth/node:base

# Build the project
WORKDIR /app
COPY --chown=noddy:noddy package*.json ./
RUN npm ci --omit=dev

COPY --chown=noddy:noddy . ./
RUN npx next build

EXPOSE 3000
ENTRYPOINT ["/sbin/tini", "--"]
CMD ["npx", "next", "start"]
