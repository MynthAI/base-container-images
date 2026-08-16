FROM quay.io/mynth/worker:dev

WORKDIR /app
COPY --chown=worker:worker . ./

CMD ["node", "task.mjs"]
