# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

A futuristic web-based app launcher for self-hosted services running on a mini-PC server (10.0.0.181). The launcher provides a visually appealing interface with gradient effects and glow animations to access various web applications.

## Project Structure

- `index.html` - Single-page app launcher with embedded CSS and animations

## Server Configuration

The launcher connects to services on the mini-PC server at IP: **10.0.0.181**

Current applications:
- Audio Stream Google Home (Port 8801)
- Youtube Radio (Port 8000)
- Trilium Web Portal (Port 8080)
- Trilium AI Web (Port 8081)

## Development

This is a static HTML page with no build process required. To modify:

1. Edit `index.html` directly
2. Changes are live immediately (refresh browser to see updates)

To add new applications, add a new `.app-card` element in the `.apps-grid` section with the appropriate port and details.

## Deployment

The launcher is served via a systemd service using `uv run python -m http.server` on port 80.

### Service Management
- Install: Copy `app-launcher.service` to `/etc/systemd/system/` and enable
- Start: `sudo systemctl start app-launcher.service`
- Stop: `sudo systemctl stop app-launcher.service`
- Status: `sudo systemctl status app-launcher.service`
- Logs: `sudo journalctl -u app-launcher.service -f`

See `README.md` for detailed installation instructions.
