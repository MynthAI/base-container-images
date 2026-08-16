FROM quay.io/mynth/worker:26

# Set up the task project
WORKDIR /app
COPY --chown=worker:worker . ./

# Run a task that uses the node, python, fnm and uv toolchains
CMD ["node", "task.mjs"]
