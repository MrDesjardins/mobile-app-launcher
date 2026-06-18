# Mini-PC HTTPS Setup

This directory stores the repeatable HTTPS configuration for the mini-PC launcher and audio radio app.

## Final Layout

- `http://10.0.0.181/` keeps serving this launcher over plain HTTP on port 80.
- `https://10.0.0.181/` serves the same launcher through Caddy HTTPS.
- `http://10.0.0.181:8000/` keeps serving the audio radio app over plain HTTP for existing PC clients.
- `https://10.0.0.181:8443/` serves the audio radio app through Caddy HTTPS for browsers that need a secure origin.
- `https://10.66.66.1/` and `https://10.66.66.1:8443/` are the equivalent WireGuard gateway URLs.

HTTP and HTTPS cannot both use the same IP and port. That is why the legacy radio URL stays on HTTP port `8000`, and the HTTPS radio URL uses port `8443`.

## Apply Or Recreate The Setup

From this repository:

```bash
sudo bash https/setup-https.sh
```

The script installs Caddy if needed, applies `https/Caddyfile`, restores `audio-stream.service` to public HTTP port `8000`, reloads services, opens UFW rules for HTTPS, exports the Caddy local CA, and validates the final URLs.

## Installed System Files

The script writes or updates these system files:

- `/etc/caddy/Caddyfile` from `https/Caddyfile`
- removes `/etc/systemd/system/audio-stream.service.d/https-backend.conf` if present, so `audio-stream.service` returns to `http://10.0.0.181:8000/`
- `/home/pdesjardins/caddy-root-ca.crt` for device/browser trust
- `/home/pdesjardins/code/audio-stream-server/static/caddy-root-ca.crt` for easy browser download

It backs up any existing `/etc/caddy/Caddyfile` to `/etc/caddy/Caddyfile.bak.YYYYMMDDHHMMSS`.

## Certificate Install Notes

Download the CA certificate from either location:

- `http://10.0.0.181:8000/static/caddy-root-ca.crt`
- `/home/pdesjardins/caddy-root-ca.crt`

Install it as a CA/root certificate on devices that should trust the mini-PC HTTPS sites.

Firefox may require importing the certificate directly into Firefox:

Settings -> Privacy & Security -> Certificates -> View Certificates -> Authorities -> Import -> select `caddy-root-ca.crt` -> trust it to identify websites.

## Useful Checks

```bash
systemctl status caddy --no-pager
systemctl status audio-stream.service --no-pager
systemctl status app-launcher.service --no-pager
curl -kI https://10.0.0.181/
curl -I http://10.0.0.181:8000/
curl -kI https://10.0.0.181:8443/
```
