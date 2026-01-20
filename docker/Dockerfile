# Container for packages that need to be built from source but have massive dev dependencies.
FROM python:3.11.10-slim-bookworm as builder
RUN set -e && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
    gcc \
    g++ \
    python3.11-dev \
    libmemcached-dev \
    zlib1g-dev \
    libgdal-dev

COPY requirements.txt /requirements.txt
RUN pip config set global.disable-pip-version-check true && \
    pip wheel --wheel-dir=/root/wheels uwsgi==2.0.28 && \
    pip wheel --wheel-dir=/root/wheels regex==2024.11.6 && \
    pip wheel --wheel-dir=/root/wheels -r /requirements.txt 

# The actual container.
FROM python:3.11.10-slim-bookworm
RUN set -e && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
    inotify-tools \
    nano \
    nginx \
    memcached \
    libmemcached11 \
    libgdal32 \
    supervisor && \
    rm -rf /var/lib/apt/lists/*

COPY --from=builder /root/wheels /root/wheels
COPY requirements.txt /app/requirements.txt
RUN pip install \
    --no-index \
    --no-cache-dir \
    --disable-pip-version-check \
    --find-links=/root/wheels \
    uwsgi regex && \
    pip install \
    --no-index \
    --no-cache-dir \
    --disable-pip-version-check \
    --find-links=/root/wheels \
    -r /app/requirements.txt && \
    rm -rf /root/.cache/pip/* && \
    rm -rf /root/wheels/* && \
    rm /app/requirements.txt

WORKDIR /app
COPY . /app/

RUN echo > /etc/nginx/sites-available/default && \
    cp /app/docker/nginx.conf /etc/nginx/conf.d/nginx.conf && \
    cp /app/docker/supervisord.conf /etc/supervisor/conf.d/supervisord.conf && \
    sed -i 's/\r$//' /app/docker/run.sh && \
    chmod +x /app/docker/run.sh

CMD ["sh", "/app/docker/run.sh"]
EXPOSE 5000

ENV CURL_CA_BUNDLE=/etc/ssl/certs/ca-certificates.crt
ENV GDAL_DISABLE_READDIR_ON_OPEN=TRUE
ENV GDAL_NUM_THREADS=ALL_CPUS
ENV GDAL_CACHEMAX=512
