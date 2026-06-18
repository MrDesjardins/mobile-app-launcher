#!/usr/bin/env bash
set -euo pipefail

if [[ $EUID -ne 0 ]]; then
  echo "Run with sudo: sudo bash https/setup-https.sh" >&2
  exit 1
fi

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
caddyfile_src="$repo_dir/https/Caddyfile"

launcher_service="app-launcher.service"
audio_service="audio-stream.service"
android_ca_dest="/home/pdesjardins/caddy-root-ca.crt"
audio_static_ca="/home/pdesjardins/code/audio-stream-server/static/caddy-root-ca.crt"
audio_dropin_dir="/etc/systemd/system/audio-stream.service.d"
audio_dropin="$audio_dropin_dir/https-backend.conf"

if [[ ! -f "$caddyfile_src" ]]; then
  echo "Missing $caddyfile_src" >&2
  exit 1
fi

if ! command -v caddy >/dev/null 2>&1; then
  apt update
  apt install -y caddy
fi

systemctl is-enabled "$launcher_service" >/dev/null 2>&1 || systemctl enable "$launcher_service"
systemctl restart "$launcher_service"

# Apply Caddy first so it stops occupying :8000 and moves radio HTTPS to :8443.
if [[ -f /etc/caddy/Caddyfile ]]; then
  backup="/etc/caddy/Caddyfile.bak.$(date +%Y%m%d%H%M%S)"
  cp /etc/caddy/Caddyfile "$backup"
  echo "Backed up existing Caddyfile to $backup"
fi
install -o root -g root -m 0644 "$caddyfile_src" /etc/caddy/Caddyfile
caddy validate --config /etc/caddy/Caddyfile --adapter caddyfile
systemctl enable --now caddy
systemctl reload caddy || systemctl restart caddy

# Preserve the legacy PC URL by returning FastAPI to its default public HTTP port.
if [[ -f "$audio_dropin" ]]; then
  rm -f "$audio_dropin"
  rmdir "$audio_dropin_dir" 2>/dev/null || true
fi
systemctl daemon-reload
systemctl restart "$audio_service"

for _ in {1..30}; do
  if curl -fsS -o /dev/null http://127.0.0.1:8000/; then
    break
  fi
  sleep 1
done
curl -fsS -o /dev/null http://127.0.0.1:8000/

if command -v ufw >/dev/null 2>&1; then
  ufw allow 443/tcp
  ufw allow 8000/tcp
  ufw allow 8443/tcp
  ufw allow in on wg0 to any port 443 proto tcp || true
  ufw allow in on wg0 to any port 8000 proto tcp || true
  ufw allow in on wg0 to any port 8443 proto tcp || true
fi

for _ in {1..20}; do
  if [[ -f /var/lib/caddy/.local/share/caddy/pki/authorities/local/root.crt ]]; then
    break
  fi
  curl -kfsS -o /dev/null https://10.0.0.181/ || true
  sleep 1
done

if [[ -f /var/lib/caddy/.local/share/caddy/pki/authorities/local/root.crt ]]; then
  cp /var/lib/caddy/.local/share/caddy/pki/authorities/local/root.crt "$android_ca_dest"
  chown pdesjardins:pdesjardins "$android_ca_dest"
  chmod 0644 "$android_ca_dest"

  if [[ -d "$(dirname "$audio_static_ca")" ]]; then
    cp "$android_ca_dest" "$audio_static_ca"
    chown pdesjardins:pdesjardins "$audio_static_ca"
    chmod 0644 "$audio_static_ca"
  fi
else
  echo "Caddy root CA not found. Caddy may not have generated it yet." >&2
  exit 1
fi

curl -fsS -o /dev/null http://10.0.0.181:8000/
curl -kfsS -o /dev/null https://10.0.0.181/
curl -kfsS -o /dev/null https://10.0.0.181:8443/
curl -kfsS -o /dev/null https://10.66.66.1/
curl -kfsS -o /dev/null https://10.66.66.1:8443/

cat <<SUMMARY

HTTPS setup complete.

Launcher:
  http://10.0.0.181/
  https://10.0.0.181/
  https://10.66.66.1/

Radio:
  http://10.0.0.181:8000/
  https://10.0.0.181:8443/
  https://10.66.66.1:8443/

CA certificate for Android/Windows/Firefox:
  $android_ca_dest
  http://10.0.0.181:8000/static/caddy-root-ca.crt
SUMMARY
