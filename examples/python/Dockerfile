FROM quay.io/mynth/python-dev:local as builder

# Build the project
WORKDIR /app
RUN mkdir hello_python && \
    touch hello_python/__init__.py
COPY poetry.lock pyproject.toml ./
RUN poetry install --without=dev --no-interaction --no-ansi

FROM quay.io/mynth/python-base:local

# Install the built project
COPY --from=builder /app /app
COPY hello_python /app/hello_python

EXPOSE 8000
CMD ["uvicorn", "--host", "0.0.0.0", "hello_python.app:app"]
