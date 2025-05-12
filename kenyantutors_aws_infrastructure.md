# ☁️ KenyanTutors.com — AWS Infrastructure Overview

KenyanTutors.com is a lightweight educational chat platform that connects students, tutors, and parents through moderated discussion groups. The infrastructure is designed for cost-efficiency, scalability, and resilience while keeping operations fully under your control.

---

## 🔹 1. EC2 (Application Hosting)
- **Instance Type**: Amazon Linux 2023 on a t3.small EC2 instance
- **Purpose**: Hosts the main web application using PHP (Grupo Chat script)
- **Public IP**: Routed via Cloudflare for DNS and CDN performance
- **Web Server**: Likely Apache or Nginx (php-fpm confirmed active)
- **Web Root**: `/var/www/html/virtualtrix/public_html`
- **WebSockets**: Supported by the script, with potential Swoole setup
- **Chat Moderation**: AI moderation via Sightengine and Perspective API

---

## 🔹 2. RDS (Database Layer)
- **Engine**: MariaDB 11.4.5 (Amazon RDS)
- **Instance Type**: `db.t3.small`
- **Region**: `eu-west-2` (London)
- **Security**: Private, not publicly accessible; connected to EC2 via VPC security group
- **Backups**:
  - 7-day retention
  - Backup window: `01:00 UTC`
  - Weekly maintenance: Tuesday, `07:00 UTC`
- **Replication**: Manual cross-region snapshot copy to Frankfurt (`eu-central-1`)
- **CloudWatch Alarms**:
  - CPU > 80% for 5 mins
  - Freeable Memory < 200MB for 5 mins
  - Email alerts via SNS topic `rds-alarms`

---

## 🔹 3. S3 Buckets
- **kenyantuts-store**: Used for storing uploaded assets such as profile pictures, file attachments, and media
- **kenyantutors-store**: Secondary or backup region S3 bucket (Frankfurt)

Uploads are handled using AWS SDK (PHP), with `public-read` ACL and custom upload script in:
```
fns/cloud_storage/s3_compatible.php
```

---

## 🔹 4. CloudFront + Global Accelerator
- Used to distribute static assets and improve latency worldwide
- AWS Global Accelerator enables low-latency access even outside Europe (especially useful for users in Kenya)
- Route 53 health checks configured for failover between endpoints

---

## 🔹 5. IAM & Roles
- Instance and application roles configured for:
  - S3 upload access
  - RDS access (from EC2 only)
  - Cross-region snapshot permissions

---

## 🔹 6. Email & Notifications
- **SMTP**: Emails sent from server using SMTP, configured in PHP
- **SNS Topic**: `rds-alarms` for operational alerts
  - Subscribed email: `marcsarin123@gmail.com`

---

## 🔹 7. Security
- **SSH**: Password login disabled, using SSH key-based access
- **VPC**: Private subnet setup with security group rules for EC2↔️RDS only
- **WAF**: AWS WAF with managed rule sets (Admin Protection, SQL Injection, Bad Inputs, etc.)
- **Cloudflare**: DNS proxy and edge protection in front of public-facing IP

---

## 🔹 8. Backup & Disaster Recovery
- RDS: Automatic backups + manual snapshot copy to another region
- EC2: Not yet using AMI snapshots or auto-recovery — could be added
- Database migration logs and structure saved for rollback

---

## 🔹 9. Monitoring
- CloudWatch Alarms for DB health
- Future option: aggregate metrics into a custom CloudWatch dashboard
- EC2 CPU/memory not yet alarmed (can be added via CloudWatch Agent)

---

## 🧾 Summary

| Layer         | Service        | Status                     |
|---------------|----------------|-----------------------------|
| Compute       | EC2            | ✅ Running (London)         |
| Database      | RDS (MariaDB)  | ✅ Active with alarms       |
| Storage       | S3             | ✅ Uploads enabled          |
| Networking    | CloudFront + GA| ✅ Accelerated routing      |
| Monitoring    | CloudWatch     | ✅ CPU/Memory alarms on RDS |
| DNS & Edge    | Cloudflare     | ✅ Active DNS & protection  |
| Moderation    | Sightengine, Perspective API | ✅ Enabled |
| Security      | WAF, SSH keys  | ✅ Hardened                 |
| Alerts        | SNS            | ✅ Configured               |