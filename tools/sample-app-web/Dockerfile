# syntax=docker/dockerfile:1.4
FROM cgr.dev/chainguard/nginx:latest

COPY --chown=nonroot:nonroot --chmod=444 index.html /usr/share/nginx/html/index.html
COPY --chown=nonroot:nonroot --chmod=444 nginx.conf /etc/nginx/nginx.conf

VOLUME ["/var/run"]
VOLUME ["/var/lib/nginx/tmp"]
VOLUME ["/tmp"]