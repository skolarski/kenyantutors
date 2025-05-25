# 🧪 WebSocket Debugging Session – KenyanTutors.com

**Date**: May 25, 2025  
**Server**: EC2 (Amazon Linux 2023, T3.medium)  
**Service**: GrupoChat WebSocket Server using PHP + Swoole  
**Port**: 9502  
**Client Endpoint**: `wss://kenyantutors.com/ws/`

---

## ❌ Problem Summary

After previously working, the WebSocket server stopped responding.  
Browser console showed:

```text
WebSocket connection to 'wss://kenyantutors.com/ws/?login_session_id=...'
failed
```

Systemd logs showed repeated crashes:

```text
websocket.service: Main process exited, code=exited, status=255/EXCEPTION
websocket.service: Start request repeated too quickly.
```

---

## 🔍 Root Cause

The PHP script didn’t crash with an error — it was likely misinterpreted by `systemd` due to:

- Silent failure from a `require` or `include`
- Suppressed error reporting
- Confused systemd startup detection

---

## 🛠 Resolution Steps

### 1. SSH into the EC2 instance

```bash
ssh ec2-user@<your-ec2-ip>
```

---

### 2. Navigate to the WebSocket script directory

```bash
cd /var/www/html/virtualtrix/public_html/
```

---

### 3. Run script manually with error display

```bash
php -d display_errors=1 fns/realtime/websocket.php
```

#### ✅ Result:
Terminal went blank — indicating the WebSocket was actually running properly and waiting for events.

---

### 4. Restart `systemd` cleanly

```bash
sudo systemctl daemon-reexec
sudo systemctl restart websocket
sudo systemctl status websocket
```

✅ Status: `active (running)`

---

### 5. Verify from browser

- Open browser console on the chat page.
- Confirm `wss://kenyantutors.com/ws/` shows **status `101 Switching Protocols`** or `✅ Connected`.

---

## 📌 Notes

- If nothing appears in journal logs, always test the PHP script **outside** systemd.
- Consider adding at the top of `websocket.php` for future clarity:

```php
<?php
error_reporting(E_ALL);
ini_set("display_errors", 1);
```

---

## 🧯 Future Recovery Shortcut

```bash
cd /var/www/html/virtualtrix/public_html/
php -d display_errors=1 fns/realtime/websocket.php
sudo systemctl daemon-reexec
sudo systemctl restart websocket
```

---

## ✅ Status: RESOLVED
WebSocket server restored and actively handling real-time chat on `kenyantutors.com`.
