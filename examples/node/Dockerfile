FROM quay.io/mynth/node:base

# Build the project
WORKDIR /app
COPY --chown=noddy:noddy package*.json ./
RUN npm ci --omit=dev

COPY --chown=noddy:noddy . ./
RUN npx next build

EXPOSE 3000
CMD ["node", "node_modules/.bin/next", "start"]
