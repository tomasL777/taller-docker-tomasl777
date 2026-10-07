FROM python:3.14-slim AS build
COPY --from=ghcr.io/astral-sh/uv:0.12.17 /uv /usr/local/bin/uv
WORKDIR /build
COPY requirements.txt .
RUN uv venv /opt/venv \
 && uv pip install --python /opt/venv/bin/python --no-cache -r requirements.txt

FROM python:3.14-slim
RUN useradd --system --uid 1000 app \
 && mkdir /app \
 && chown app:app /app
WORKDIR /app
COPY --from=build /opt/venv /opt/venv
COPY --chown=app:app prestamos ./prestamos
ENV PATH="/opt/venv/bin:$PATH" \
    PYTHONDONTWRITEBYTECODE=1
USER app
EXPOSE 9000
HEALTHCHECK --interval=5s --timeout=3s --start-period=5s --retries=5 \
  CMD ["python", "-c", "import urllib.request; urllib.request.urlopen('http://127.0.0.1:9000/salud')"]
CMD ["uvicorn", "prestamos.servidor:app", "--host", "0.0.0.0", "--port", "9000"]