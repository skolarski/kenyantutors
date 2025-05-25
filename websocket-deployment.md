# 🧩 KenyanTutors WebSocket Deployment (EC2 + Swoole + Apache)

This document outlines the steps taken to deploy a **Swoole-based WebSocket server** for GrupoChat on an Amazon EC2 instance (Amazon Linux 2023, T3.medium), with reverse proxy via Apache and persistent background service via `systemd`.

---

## ✅ Overview

- **Framework**: GrupoChat
- **WebSocket Server**: PHP + Swoole
- **OS**: Amazon Linux 2023
- **Web Server**: Apache (with reverse proxy)
- **SSL**: Let’s Encrypt (HTTPS + WSS)
- **Persistence**: systemd service
- **Server Port**: 9502 (internal)
- **Client Endpoint**: `wss://kenyantutors.com/ws/`

---

## 🔧 Apache VirtualHost Setup

File: `/etc/httpd/conf.d/kenyantutors.conf`

```apache
<VirtualHost *:443>
    ServerName kenyantutors.com
    DocumentRoot /var/www/html/virtualtrix/public_html

    SSLEngine on
    SSLCertificateFile /etc/letsencrypt/live/kenyantutors.com/fullchain.pem
    SSLCertificateKeyFile /etc/letsencrypt/live/kenyantutors.com/privkey.pem

    <Location "/ws/">
        ProxyPass "ws://127.0.0.1:9502/"
        ProxyPassReverse "ws://127.0.0.1:9502/"
    </Location>

    <Directory /var/www/html/virtualtrix/public_html>
        AllowOverride All
    </Directory>
</VirtualHost>
```

---

## 🛠 WebSocket Server Script

Path: `/var/www/html/virtualtrix/public_html/fns/realtime/websocket.php`  
Framework-provided. Includes:

```php
$ws_instance = new Swoole\WebSocket\Server($ws_host, $ws_port);
// message handlers...
$ws_instance->start();
```

⚠️ **Important**: Must be run from the correct working directory or includes will fail.

---

## 🧷 systemd Service Setup

### File: `/etc/systemd/system/websocket.service`

```ini
[Unit]
Description=GrupoChat WebSocket Server
After=network.target

[Service]
WorkingDirectory=/var/www/html/virtualtrix/public_html/
ExecStart=/usr/bin/php /var/www/html/virtualtrix/public_html/fns/realtime/websocket.php
Restart=always
User=ec2-user
StandardOutput=append:/var/log/websocket.out.log
StandardError=append:/var/log/websocket.err.log

[Install]
WantedBy=multi-user.target
```

### Enable + Start

```bash
sudo systemctl daemon-reload
sudo systemctl enable websocket
sudo systemctl start websocket
sudo systemctl status websocket
```

---

## ✅ Verification Steps

### Confirm server is running:

```bash
sudo lsof -i -P -n | grep 9502
```

### Confirm WebSocket status in browser console:

```js
let ws = new WebSocket("wss://kenyantutors.com/ws/");
ws.onopen = () => console.log("✅ Connected");
ws.onerror = (e) => console.error("❌ Error", e);
```

Network tab should show `Status: 101 Switching Protocols`.

---

## 📈 Capacity Planning for T3.medium

| Usage Type           | Approx Connections |
|----------------------|--------------------|
| Idle clients         | 8,000–10,000       |
| Light chatting       | ~3,000–5,000       |
| Active chat users    | ~1,500–2,000       |
| Heavy group chat     | ~500–1,000         |

Tune with:

```php
$server->set([
    'worker_num' => 2,
    'max_connection' => 10000,
]);
```

---

## 🧰 Troubleshooting

- If `systemctl status websocket` shows `exit-code 255`, ensure `WorkingDirectory` is correct.
- Use `journalctl -u websocket -e` to view real-time logs.
- Ensure Apache proxy is not duplicated across multiple `VirtualHost` blocks.
