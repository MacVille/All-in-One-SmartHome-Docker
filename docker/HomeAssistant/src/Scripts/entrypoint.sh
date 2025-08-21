#!/bin/bash
set -e

TEMPLATE="/defaults/configuration.template.yaml"
CONFIG_FILE="/config/configuration.yaml"

if [ ! -f "$CONFIG_FILE" ]; then
    echo "Erster Start – config nicht gefunden, kopiere Template..."
    cp "$TEMPLATE" "$CONFIG_FILE"
fi

# Nur beim ersten Start anpassen
if ! grep -q "INITIALIZED" "$CONFIG_FILE"; then
    echo "Ersetze Platzhalter in configuration.yaml..."

    sed -i "s/DBUSERNAME/${HA_DB_USERNAME}/g" "$CONFIG_FILE"
    sed -i "s/DBUSERPASSWORD/${HA_DB_USERPASSWORD}/g" "$CONFIG_FILE"
    sed -i "s/MYSQLSERVER/${HA_DB_SERVER}/g" "$CONFIG_FILE"
    sed -i "s/DATABASENAME/${HA_DB_NAME}/g" "$CONFIG_FILE"

    # Marker einfügen, damit es nicht nochmal läuft
    #echo "# INITIALIZED" >> "$CONFIG_FILE"
fi

touch /config/automations.yaml
touch /config/scripts.yaml
touch /config/scenes.yaml

# Zum Schluss den originalen Startbefehl ausführen
exec "$@"