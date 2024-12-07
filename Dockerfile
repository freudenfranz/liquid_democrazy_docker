# Python-Basisimage
FROM python:3.10-slim

# Systemabhängigkeiten installieren
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    python3 \
    python3-pip \
    libpq-dev \
    npm \
    build-essential \
    gettext \
    curl \
    redis-server \
    libmagic1 \
    libpq-dev \
    sqlite3 \
    && curl -sL https://deb.nodesource.com/setup_16.x | bash - \
    && apt-get install -y --no-install-recommends nodejs \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

WORKDIR /app

RUN git clone https://github.com/liqd/adhocracy-plus.git .

RUN python -m venv venv
ENV PATH="/app/venv/bin:$PATH"

RUN npm install && \
    npm run build:prod && \
    pip install --upgrade pip && \
    pip install psycopg-c==3.1.19 && \
    pip install -r requirements.txt

RUN make install && \
    make fixtures

RUN make test

ENV DJANGO_SETTINGS_MODULE=adhocracy-plus.config.settings.dev
ENV PYTHONUNBUFFERED=1
ENV DATABASE=sqlite3
ENV DJANGO_DEBUG=True
ENV DJANGO_SECRET_KEY=dummy_key_for_development

RUN echo "SECRET_KEY = \"${DJANGO_SECRET_KEY}\"" > adhocracy-plus/config/settings/local.py

COPY entrypoint.sh .
RUN chmod +x entrypoint.sh

EXPOSE 8004

ENTRYPOINT ["./entrypoint.sh"]
