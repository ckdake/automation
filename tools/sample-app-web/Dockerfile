# syntax=docker/dockerfile:1.4
FROM cgr.dev/chainguard/nginx:latest

COPY --chown=nonroot:nonroot --chmod=444 index.html /var/www/index.html
COPY --chown=nonroot:nonroot --chmod=444 nginx.conf /etc/nginx/nginx.conf

RUN mkdir -p /var/lib/nging/tmp
