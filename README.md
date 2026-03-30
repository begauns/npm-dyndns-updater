# npm-dyndns-updater

Kleiner Docker-Container, der eine Access-List in Nginx Proxy Manager automatisch
auf die aktuelle IP eines DynDNS-Hosts setzt. Die Zuordnung erfolgt über den Namen
der Access-List in der NPM-Datenbank (SQLite).

## Voraussetzungen

- Nginx Proxy Manager läuft in einem Container.
- Das NPM-`data`-Verzeichnis ist als Hostpfad verfügbar (enthält `database.sqlite`).
- Docker Socket (`/var/run/docker.sock`) ist auf dem Host vorhanden.

## Verwendung

1. `.env` aus Template erstellen:

   ```bash
   cp .env.example .env
   ```

2. `.env` bearbeiten und eigene Werte eintragen:

   - `DDNS_HOST`: DynDNS-Hostname
   - `ACCESS_LIST_NAME`: Name der Access-List in NPM
   - `NPM_DATA_PATH`: Hostpfad zum NPM-`data`-Verzeichnis
   - `DOCKER_SOCK_PATH`: meist `/var/run/docker.sock`

3. Container bauen und starten:

   ```bash
   docker compose build
   docker compose up -d
   ```

