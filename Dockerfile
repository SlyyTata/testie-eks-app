FROM python:3.14-slim
COPY --from=ghcr.io/astral-sh/uv:0.8.0 /uv /bin/uv

# The app is installed with uv, so pip is never used. Removing it also removes
# the libraries pip bundles (urllib3, msgpack, setuptools), which Trivy flags.
RUN python -m pip uninstall -y pip

WORKDIR /app
ENV UV_COMPILE_BYTECODE=1 UV_LINK_MODE=copy

# Install dependencies first so Docker can reuse this layer when only code changes
COPY pyproject.toml uv.lock ./
RUN uv sync --frozen --no-dev --no-install-project

COPY app ./app
COPY alembic ./alembic

ENV PATH="/app/.venv/bin:$PATH"
EXPOSE 8000
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
