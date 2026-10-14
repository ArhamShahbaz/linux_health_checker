# Linux Server Health Checker 🐧🔍

A lightweight, automated Bash script designed to monitor Linux server vitals, track critical services, verify disk space thresholds, and log timestamped health reports following standard Linux directory conventions.

---

## 📋 Table of Contents

- [Overview](#overview)
- [Key Features](#key-features)
- [Directory & Architecture Structure](#directory--architecture-structure)
- [System Requirements](#system-requirements)
- [Installation & Setup](#installation--setup)
- [Configuration](#configuration)
- [Automating with Cron](#automating-with-cron)
- [Sample Health Report](#sample-health-report)
- [Troubleshooting](#troubleshooting)
- [License](#license)

---

## 📖 Overview

[`healthcheck.sh`](file:///D:/Public%20Repos/linux_health_checker/healthcheck.sh) provides a reliable snapshot of your Linux server's operational health. It monitors disk usage, memory utilization, top resource-consuming processes, and service states.

To comply with the Linux Filesystem Hierarchy Standard (FHS), this setup separates executable code from log data:
- **Scripts Directory**: `/opt/healthcheck/` — Houses the executable monitoring script.
- **Reports Directory**: `/var/log/healthcheck/` — Dedicated directory for generated timestamped health logs.

---

## ✨ Key Features

- **Standardized Separation**: Scripts live in `/opt/healthcheck/`, and reports are stored in `/var/log/healthcheck/`.
- **Disk Space Monitoring**: Displays filesystem disk usage (`df -h`) and warns if the root partition (`/`) exceeds a configurable percentage limit (default: `80%`).
- **Memory Consumption**: Monitors available, used, and free RAM and swap memory (`free -h`).
- **Top Processes**: Identifies the top 5 memory-intensive processes (`ps aux --sort=-%mem`).
- **Service Status Checks**: Verifies if designated system services (e.g., `ssh`, `nginx`) are active using `systemctl`.
- **Automatic Log Directory Creation**: Automatically creates `/var/log/healthcheck/` if it does not already exist.
- **Daily Report Archiving**: Saves reports into daily files (`health-YYYY-MM-DD.log`) for easy auditing and history tracking.

---

## 📁 Directory & Architecture Structure

```text
/opt/
└── healthcheck/
    └── healthcheck.sh            # Production script location

/var/log/
└── healthcheck/                  # Automatically created log directory
    ├── health-2026-10-14.log     # Daily health report
    ├── health-2026-10-15.log
    └── ...
```

| Path | Purpose |
| :--- | :--- |
| `/opt/healthcheck/` | Main application folder where [`healthcheck.sh`](file:///D:/Public%20Repos/linux_health_checker/healthcheck.sh) is installed and executed. |
| `/var/log/healthcheck/` | Target log folder where all daily reports are stored (`LOG_DIR`). |
| `health-<YYYY-MM-DD>.log` | Daily log file. Appends multiple runs executed on the same day. |

---

## ⚙️ System Requirements

- **Operating System**: Linux (Ubuntu, Debian, CentOS, RHEL, Rocky Linux, Fedora, Alpine, Arch, etc.)
- **Shell**: Bash (`/bin/bash`)
- **Core Utilities**: `df`, `free`, `ps`, `awk`, `date`, `mkdir`
- **Init System**: `systemd` (for `systemctl` service checks)
- **Privileges**: Root or `sudo` access (required for `/opt` and `/var/log` paths and system service queries).

---

## 🚀 Installation & Setup

### Step 1: Clone or Download the Repository

```bash
git clone https://github.com/<your-username>/linux_health_checker.git
cd linux_health_checker
```

### Step 2: Install Script to `/opt/healthcheck/`

Create the script directory under `/opt` and copy [`healthcheck.sh`](file:///D:/Public%20Repos/linux_health_checker/healthcheck.sh) into it:

```bash
sudo mkdir -p /opt/healthcheck
sudo cp healthcheck.sh /opt/healthcheck/
sudo chmod +x /opt/healthcheck/healthcheck.sh
```

### Step 3: Run the Health Check

Execute the script from its installation directory:

```bash
sudo /opt/healthcheck/healthcheck.sh
```

> [!NOTE]
> The script will automatically create `/var/log/healthcheck/` on its first run if the directory does not already exist.

### Step 4: View the Generated Report

Inspect the generated log in `/var/log/healthcheck/`:

```bash
# View the full daily report
cat /var/log/healthcheck/health-$(date +%Y-%m-%d).log

# Or view the latest 30 lines
tail -n 30 /var/log/healthcheck/health-$(date +%Y-%m-%d).log
```

---

## 🔧 Configuration

You can customize the script behavior by editing the settings at the top of [`/opt/healthcheck/healthcheck.sh`](file:///D:/Public%20Repos/linux_health_checker/healthcheck.sh):

```bash
# ---------- SETTINGS (CHANGE these if you want) ----------
LOG_DIR="/var/log/healthcheck"       # Directory where reports are saved
SERVICES="ssh nginx"                 # Space-separated services to check
DISK_LIMIT=80                        # Warn if root disk is above this %
# ----------------------------------------------------------
```

| Variable | Default Value | Description |
| :--- | :--- | :--- |
| `LOG_DIR` | `/var/log/healthcheck` | Directory where daily health logs are written. Created automatically. |
| `SERVICES` | `"ssh nginx"` | Space-delimited list of system services to monitor (e.g. `"sshd nginx docker mysql"`). |
| `DISK_LIMIT` | `80` | Integer percentage threshold for root (`/`) partition disk warning. |

> [!TIP]
> On RHEL / CentOS / Fedora distributions, SSH is named `sshd` rather than `ssh`. Update `SERVICES="sshd nginx"` as needed.

---

## ⏰ Automating with Cron

To run periodic checks automatically, schedule a cron job for the root user:

1. Open root crontab:

   ```bash
   sudo crontab -e
   ```

2. Add your desired schedule pointing to `/opt/healthcheck/healthcheck.sh`:

   **Run every hour:**
   ```cron
   0 * * * * /opt/healthcheck/healthcheck.sh >/dev/null 2>&1
   ```

   **Run daily at midnight (00:00):**
   ```cron
   0 0 * * * /opt/healthcheck/healthcheck.sh >/dev/null 2>&1
   ```

   **Run every 6 hours:**
   ```cron
   0 */6 * * * /opt/healthcheck/healthcheck.sh >/dev/null 2>&1
   ```

---

## 📄 Sample Health Report

Below is an example of an entry appended to `/var/log/healthcheck/health-YYYY-MM-DD.log`:

```text
===== Health Report: Wed Oct 14 10:30:00 UTC 2026 =====

--- DISK USAGE ---
Filesystem      Size  Used Avail Use% Mounted on
/dev/sda1        50G   18G   30G  38% /
tmpfs           2.0G     0  2.0G   0% /dev/shm

--- MEMORY USAGE ---
               total        used        free      shared  buff/cache   available
Mem:           3.8Gi       1.2Gi       1.4Gi        12Mi       1.2Gi       2.4Gi
Swap:          2.0Gi          0B       2.0Gi

--- TOP 5 PROCESSES (by memory) ---
USER         PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
nginx       1024  0.1  4.2 145220 33412 ?        S    08:00   0:01 nginx: worker process
mysqld       890  0.5  3.8 892340 30120 ?        Ssl  08:00   0:15 /usr/sbin/mysqld
root         752  0.0  1.1 108224  9120 ?        Ss   08:00   0:00 /usr/sbin/sshd -D
...

--- SERVICES ---
ssh: RUNNING
nginx: RUNNING

Disk OK (38% used)
```

If the root partition exceeds `DISK_LIMIT`, the report alerts you:

```text
WARNING: Disk is 85% full!
```

---

## 🛠️ Troubleshooting

- **`Permission denied` when creating directories or running script:**
  - Writing to `/opt/healthcheck/` and `/var/log/healthcheck/` requires administrative privileges. Always run installation commands and execution with `sudo`.
- **`systemctl: command not found`:**
  - Occurs if running in a minimal container environment or on a distribution that does not use systemd.
- **Service shows `NOT RUNNING` unexpectedly:**
  - Verify the exact service unit name with `systemctl list-units --type=service`.

---

## 📄 License

This project is open-source.
