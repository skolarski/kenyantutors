Database Migration Summary
KenyanTutors.com was successfully migrated from a local EC2-hosted MariaDB database (virtualtrix_site_db) to a fully managed Amazon RDS instance (kenyantutors-db).

Old DB: MariaDB 10.5.25 running locally on EC2

New DB: Amazon RDS (MariaDB 11.4.5, t3.small)

Migration Method:
sudo mysqldump -u root virtualtrix_site_db > backup.sql
mysql -h [rds-endpoint] -u admin -p [rds-db-name] < backup.sql

Confirming Successful RDS Migration
Stopped the local MariaDB service:

sudo systemctl stop mariadb

Site continued to function without interruption

Verified live connections were going to the RDS endpoint via:

sudo lsof -i :3306

💾 Local MariaDB Cleanup
Disabled MariaDB from restarting on reboot:

sudo systemctl disable mariadb
Database files were preserved in /var/lib/mysql (~182 MB)

No deletion performed to allow easy rollback if needed

📊 CloudWatch Monitoring Setup
CPU Utilization Alarm: triggers if >80% for 5 minutes

Freeable Memory Alarm: triggers if <200 MB for 5 minutes

Both alarms send notifications to an SNS topic (rds-alarms) with email alerts


