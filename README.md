# Mobile App Launcher

A futuristic web-based launcher for self-hosted applications on your mini-PC server.

## Installation

### 1. Install the systemd service

```bash
sudo cp app-launcher.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable app-launcher.service
sudo systemctl start app-launcher.service
```

### 2. Check service status

```bash
sudo systemctl status app-launcher.service
```

### 3. View logs (if needed)

```bash
sudo journalctl -u app-launcher.service -f
```

## Management Commands

- **Start service**: `sudo systemctl start app-launcher.service`
- **Stop service**: `sudo systemctl stop app-launcher.service`
- **Restart service**: `sudo systemctl restart app-launcher.service`
- **Check status**: `sudo systemctl status app-launcher.service`
- **Disable auto-start**: `sudo systemctl disable app-launcher.service`

## Access

Once running, access the launcher at:
- From server: `http://localhost`
- From network: `http://10.0.0.181`

## Updating

After modifying `index.html`, the changes are live immediately (no restart needed).
Just refresh your browser to see the updates.
