FROM quay.io/mynth/python:dev AS builder

# Build the project
COPY poetry.lock pyproject.toml /app/
RUN install-poetry-app hello_python

FROM quay.io/mynth/python:base

# Install the built project
COPY --from=builder /app /app
COPY hello_python /app/hello_python

EXPOSE 8000
CMD ["uvicorn", "--host", "0.0.0.0", "hello_python.app:app"]
