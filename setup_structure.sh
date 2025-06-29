#!/usr/bin/env bash

# 1. Create the directory structure

# Top-level directories
mkdir -p protonvpn
mkdir -p apps/{emby,jackett,radarr,sonarr,transmission}
mkdir -p data/media/{movies,tv}
mkdir -p data/{completed,incomplete,watch}

# 2. Create the openvpn_creds file only if it doesn't already exist
if [[ -f "protonvpn/openvpn_creds" ]]; then
  echo "ℹ️ 'protonvpn/openvpn_creds' already exists, skipping creation."
else
  cp ./openvpn_creds ./protonvpn/openvpn_creds
  echo "✅ Created 'protonvpn/openvpn_creds'."
fi

# 3. Download update-port.sh into protonvpn
curl -o protonvpn/update-port.sh \
  https://raw.githubusercontent.com/haugene/vpn-configs-contrib/main/openvpn/protonvpn/update-port.sh

# 4. Set ownership and permissions
sudo chown -R 1000:1000 protonvpn apps data
chmod +x protonvpn/update-port.sh

echo "✅ All done."
