#!/usr/bin/env bash

DDNS_HOST="${DDNS_HOST:?DDNS_HOST not set}"
ACCESS_LIST_NAME="${ACCESS_LIST_NAME:?ACCESS_LIST_NAME not set}"
INTERVAL="${CHECK_INTERVAL_SECONDS:-300}"
DB_PATH="/data/database.sqlite"
NPM_CONTAINER_NAME="${NPM_CONTAINER_NAME:-npm}"

while true; do
  NEW_IP=$(getent ahosts "$DDNS_HOST" | awk '{print $1; exit}' | grep -E '^[0-9.]+$')

  if [ -z "$NEW_IP" ]; then
    echo "[$(date)] Konnte IP für $DDNS_HOST nicht auflösen" >&2
    sleep "$INTERVAL"
    continue
  fi

  echo "[$(date)] DynDNS $DDNS_HOST -> $NEW_IP"

  # Access-List-ID per Name holen
  ACL_ID=$(sqlite3 "$DB_PATH" "SELECT id FROM access_list WHERE name = '$ACCESS_LIST_NAME' LIMIT 1;")

  if [ -z "$ACL_ID" ]; then
    echo "[$(date)] Keine Access-List mit Name '$ACCESS_LIST_NAME' gefunden" >&2
    sleep "$INTERVAL"
    continue
  fi

  # Aktuelle allow-Adresse (erste Zeile)
  CURRENT_IP=$(sqlite3 "$DB_PATH" "SELECT address FROM access_list_client WHERE access_list_id = $ACL_ID AND directive = 'allow' LIMIT 1;")

  if [ "$CURRENT_IP" = "$NEW_IP" ]; then
    echo "[$(date)] IP unverändert ($CURRENT_IP), nichts zu tun"
    sleep "$INTERVAL"
    continue
  fi

  echo "[$(date)] Aktualisiere Access-List '$ACCESS_LIST_NAME' (ID $ACL_ID): $CURRENT_IP -> $NEW_IP"

  # Alle allow-Einträge dieser Access-List auf neue IP setzen
  sqlite3 "$DB_PATH" "UPDATE access_list_client SET address = '$NEW_IP' WHERE access_list_id = $ACL_ID AND directive = 'allow';"

  # Nginx im NPM-Container neu laden
  docker exec "$NPM_CONTAINER_NAME" nginx -t && \
  docker exec "$NPM_CONTAINER_NAME" nginx -s reload

  sleep "$INTERVAL"
done
