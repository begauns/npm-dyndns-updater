# npm-dyndns-updater

Kleiner Docker-Container, der eine Access-List in Nginx Proxy Manager automatisch
auf die aktuelle IP eines DynDNS-Hosts setzt (SQLite-Update nach Access-Listen-Namen).

## Konfiguration

1. `.env` aus Template erstellen:

   ```bash
   cp .env.example .env
   ```

2. `.env` bearbeiten und eigene Werte eintragen:

   - `DDNS_HOST`: DynDNS-Hostname
   - `ACCESS_LIST_NAME`: Name der Access-List in NPM
   - `NPM_DATA_PATH`: Hostpfad zum NPM-`data`-Verzeichnis
   - `DOCKER_SOCK_PATH`: meist `/var/run/docker.sock`

## Variante 1: Lokales Build

```bash
docker compose build
docker compose up -d
```

## Variante 2: Fertiges Image von GHCR

Voraussetzung: Zugriff auf das Image `ghcr.io/begauns/npm-dyndns-updater:latest`.

```bash
docker compose -f docker-compose.image.yml up -d
```
