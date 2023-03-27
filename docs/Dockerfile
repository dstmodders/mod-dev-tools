FROM dstmodders/dst-mod:alpine AS builder

WORKDIR /srv/mod-dev-tools/
COPY . .
RUN make ldoc

FROM nginx:1.23.3-alpine

WORKDIR /usr/share/nginx/html/
COPY --from=builder /srv/mod-dev-tools/docs/ /usr/share/nginx/html/
