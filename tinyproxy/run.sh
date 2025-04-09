#!/usr/bin/env bash
# ==============================================================================
# Home Assistant Add-on: Tinyproxy Forward Proxy
# This script runs at container start, reads user config from /data/options.json,
# adjusts tinyproxy.conf accordingly, then starts Tinyproxy in foreground.
# ==============================================================================

# Exit immediately on error
set -e

# Install 'jq' usage check (not strictly necessary if you already have it installed,
# but we rely on it to parse /data/options.json)
if ! command -v jq &> /dev/null; then
    echo "ERROR: jq is not installed."
    exit 1
fi

# 1. Read user config from /data/options.json
# The Supervisor writes the add-on's user options to /data/options.json
PORT=$(jq '.port' /data/options.json)
# Join the array of allow_networks with a space
ALLOW_NETWORKS=$(jq -r '.allow_networks | join(" ")' /data/options.json)

# 2. Modify /etc/tinyproxy/tinyproxy.conf to set the port
sed -i "s/^Port .*/Port ${PORT}/" /etc/tinyproxy/tinyproxy.conf

# 3. Remove existing "Allow" lines
sed -i '/^Allow /d' /etc/tinyproxy/tinyproxy.conf

# 4. Insert new "Allow" lines from the user config
IFS=' ' read -ra NETS <<< "$ALLOW_NETWORKS"
for net in "${NETS[@]}"; do
  echo "Allow $net" >> /etc/tinyproxy/tinyproxy.conf
done

# 5. Log a message for clarity
echo "Starting Tinyproxy on port ${PORT} with allow nets: ${ALLOW_NETWORKS}"

# 6. Start Tinyproxy in foreground mode
exec /usr/sbin/tinyproxy -d -c /etc/tinyproxy/tinyproxy.conf
