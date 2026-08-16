FROM quay.io/mynth/python:dev AS builder

# Build the project
COPY uv.lock pyproject.toml /app/
RUN install-uv-app hello_python

FROM quay.io/mynth/python:base

# Install the built project
WORKDIR /app
COPY --from=builder /app /app
COPY hello_python /app/hello_python

EXPOSE 8000
CMD ["uvicorn", "--host", "0.0.0.0", "hello_python.app:app"]
