# npm-dyndns-updater

Kleiner Docker-Container, der eine Access-List in Nginx Proxy Manager (NPM) automatisch
auf die aktuelle IP eines DynDNS-Hosts setzt. Die Zuordnung erfolgt über den **Namen**
der Access-List in der NPM-Datenbank (SQLite).

Der Container:
- löst regelmäßig einen DynDNS-Hostnamen auf,
- findet in der `database.sqlite` von NPM die passende Access-List (`access_list`),
- aktualisiert deren `allow`-Einträge (`access_list_client`) auf die neue IP,
- und führt anschließend `nginx -t && nginx -s reload` im NPM-Container aus.

## Voraussetzungen

- Nginx Proxy Manager läuft in einem Container.
- Das NPM-`data`-Verzeichnis ist als Hostpfad verfügbar (enthält `database.sqlite`).
- Docker Socket (`/var/run/docker.sock`) ist auf dem Host vorhanden.
- Docker Compose ist installiert.

## Konfiguration

1. Repository klonen:

   ```bash
   git clone https://github.com/begauns/npm-dyndns-updater.git
   cd npm-dyndns-updater
   ```

2. `.env` aus Template erstellen:

   ```bash
   cp .env.example .env
   ```

3. `.env` bearbeiten und eigene Werte eintragen, z.B.:

   ```env
   DDNS_HOST=your-dyndns-hostname-here
   ACCESS_LIST_NAME=Your-Access-List-Name
   CHECK_INTERVAL_SECONDS=300
   NPM_CONTAINER_NAME=npm
   NPM_DATA_PATH=/path/to/your/npm/data
   DOCKER_SOCK_PATH=/var/run/docker.sock
   ```

   - `DDNS_HOST`: DynDNS-Hostname (z.B. myfriend.example.com)
   - `ACCESS_LIST_NAME`: Exakter Name der Access-List in NPM (wie in der GUI angezeigt)
   - `CHECK_INTERVAL_SECONDS`: Prüfintervall in Sekunden (Standard: 300 = 5 Minuten)
   - `NPM_CONTAINER_NAME`: Name des NPM-Containers (aus deinem NPM-docker-compose)
   - `NPM_DATA_PATH`: Hostpfad zum NPM-`data`-Verzeichnis (dort liegt `database.sqlite`)
   - `DOCKER_SOCK_PATH`: Pfad zum Docker-Socket (meist `/var/run/docker.sock`)

## Variante 1: Lokales Build

Diese Variante baut das Image aus dem mitgelieferten `Dockerfile` lokal.

```bash
# im Projektverzeichnis
docker compose build
docker compose up -d
```

- Der Service heißt `npm-dyndns-updater`.
- Das Container-Image wird lokal aus dem Dockerfile erzeugt.

## Variante 2: Fertiges Image von GHCR

Diese Variante nutzt das bereits gebaute Image aus GitHub Container Registry (GHCR):

- Image: `ghcr.io/begauns/npm-dyndns-updater:latest`

Start:

```bash
# im Projektverzeichnis
docker compose -f docker-compose.image.yml up -d
```

Damit wird direkt das veröffentlichte Image gezogen und gestartet.

## Funktionsweise im Detail

- Das Script `update.sh` läuft in einer Endlosschleife mit einem Intervall von `CHECK_INTERVAL_SECONDS`.
- Pro Durchlauf:
  1. Der DynDNS-Hostname aus `DDNS_HOST` wird per `getent ahosts` in eine IPv4-Adresse aufgelöst.
  2. In der NPM-Datenbank (`/data/database.sqlite`) wird die Access-List mit dem Namen aus
     `ACCESS_LIST_NAME` gesucht (`access_list`-Tabelle).
  3. Aus der Tabelle `access_list_client` werden alle `allow`-Einträge dieser Access-List gelesen.
  4. Falls sich die IP geändert hat, werden die `address`-Felder dieser `allow`-Einträge auf die neue IP gesetzt.
  5. Anschließend wird im NPM-Container `nginx -t` (Konfigurationsprüfung) und `nginx -s reload`
     (Reload) ausgeführt.
- Das NPM-`data`-Verzeichnis wird über `NPM_DATA_PATH` nach `/data` in den Updater-Container gemountet,
  der Docker-Socket über `DOCKER_SOCK_PATH`.

## Hinweise

- Die Datei `.env` ist in `.gitignore` eingetragen und wird nicht ins Repository committed.
  Verwende `.env.example` als Vorlage und passe deine lokale `.env` nach Bedarf an.
- Wenn du das Image selbst neu nach GHCR pushen möchtest, kannst du es lokal bauen, taggen und
  mit `docker push ghcr.io/begauns/npm-dyndns-updater:latest` veröffentlichen.
