# Linux Server Health Checker 🐧🔍

A lightweight, automated Bash script designed to monitor Linux server vitals, track critical services, verify disk space thresholds, and log timestamped health reports.

---

## 📋 Table of Contents

- [Overview](#overview)
- [Key Features](#key-features)
- [Directory & Log Structure](#directory--log-structure)
- [System Requirements](#system-requirements)
- [Installation & Quick Start](#installation--quick-start)
- [Configuration](#configuration)
- [Automating with Cron](#automating-with-cron)
- [Sample Health Report](#sample-health-report)
- [Troubleshooting](#troubleshooting)
- [License](#license)

---

## 📖 Overview

[`healthcheck.sh`](file:///D:/Public%20Repos/linux_health_checker/healthcheck.sh) runs essential system diagnostics to give system administrators and DevOps engineers a quick snapshot of server performance. It gathers disk usage, memory utilization, top resource-consuming processes, and service states, writing all findings to organized daily log files in the `/opt` hierarchy.

---

## ✨ Key Features

- **Disk Space Monitoring**: Displays file system disk usage (`df -h`) and checks the root (`/`) partition against a configurable percentage threshold (default: `80%`).
- **Memory Consumption**: Reports available, used, and free RAM and swap memory (`free -h`).
- **Top Processes**: Identifies the top 5 memory-intensive processes (`ps aux --sort=-%mem`).
- **Service Status Checks**: Verifies if designated system services (e.g., `ssh`, `nginx`) are active using `systemctl`.
- **Automated Directory & Log Management**: Automatically creates the target directory tree under `/opt/healthcheck/healthcheck-logs/` if it does not already exist.
- **Daily Log Archival**: Groups reports into daily logs named `health-YYYY-MM-DD.log` for easy auditing and history tracking.

---

## 📁 Directory & Log Structure

When the script executes, it creates the required directory structure under `/opt` on the Linux host:

```text
/opt/
└── healthcheck/
    └── healthcheck-logs/
        ├── health-2026-10-14.log
        ├── health-2026-10-15.log
        └── ...
```

- **Parent Directory**: `/opt/healthcheck/`
- **Log Subdirectory**: `/opt/healthcheck/healthcheck-logs/`
- **Log Format**: `health-<YYYY-MM-DD>.log` (appends multiple runs on the same day).

---

## ⚙️ System Requirements

- **Operating System**: Linux (Ubuntu, Debian, CentOS, RHEL, Rocky Linux, Fedora, Alpine, Arch, etc.)
- **Shell**: Bash (`/bin/bash`)
- **Core Utilities**: `df`, `free`, `ps`, `awk`, `date`, `mkdir`
- **Init System**: `systemd` (for `systemctl` service checks)
- **Privileges**: Root or `sudo` access (required for writing to `/opt` and checking restricted services).

---

## 🚀 Installation & Quick Start

### 1. Clone the Repository

```bash
git clone https://github.com/<your-username>/linux_health_checker.git
cd linux_health_checker
```

### 2. Make the Script Executable

Grant execute permissions to the script:

```bash
chmod +x healthcheck.sh
```

### 3. Run the Health Check

Execute the script with `sudo` permissions (to allow creation of directories in `/opt`):

```bash
sudo ./healthcheck.sh
```

### 4. View the Generated Report

View the latest generated log entry:

```bash
# View the full daily log
cat /opt/healthcheck/healthcheck-logs/health-$(date +%Y-%m-%d).log

# Or view the end of the log
tail -n 30 /opt/healthcheck/healthcheck-logs/health-$(date +%Y-%m-%d).log
```

---

## 🔧 Configuration

You can customize the script behavior by editing the settings section at the beginning of [`healthcheck.sh`](file:///D:/Public%20Repos/linux_health_checker/healthcheck.sh):

```bash
# ---------- SETTINGS (CHANGE these if you want) ----------
LOG_DIR="/opt/healthcheck/healthcheck-logs"   # Where reports are saved
SERVICES="ssh nginx"                         # Space-separated services to check
DISK_LIMIT=80                                # Warn if root disk usage is above this %
# ----------------------------------------------------------
```

| Variable | Default Value | Description |
| :--- | :--- | :--- |
| `LOG_DIR` | `/opt/healthcheck/healthcheck-logs` | Target folder for health report logs. Created automatically if missing. |
| `SERVICES` | `"ssh nginx"` | Space-delimited list of system services to monitor (e.g. `"sshd nginx docker mysql"`). |
| `DISK_LIMIT` | `80` | Integer percentage threshold for root (`/`) partition disk warning. |

> [!TIP]
> On Red Hat / CentOS / Fedora distributions, SSH is usually named `sshd` rather than `ssh`. Update `SERVICES="sshd nginx"` accordingly.

---

## ⏰ Automating with Cron

To perform periodic health checks (e.g., hourly or daily), schedule a cron job with `crontab`:

1. Open the root user crontab editor:

   ```bash
   sudo crontab -e
   ```

2. Add your desired schedule:

   **Run every hour:**
   ```cron
   0 * * * * /path/to/linux_health_checker/healthcheck.sh >/dev/null 2>&1
   ```

   **Run every day at 00:00 (Midnight):**
   ```cron
   0 0 * * * /path/to/linux_health_checker/healthcheck.sh >/dev/null 2>&1
   ```

   **Run every 6 hours:**
   ```cron
   0 */6 * * * /path/to/linux_health_checker/healthcheck.sh >/dev/null 2>&1
   ```

*(Replace `/path/to/linux_health_checker/` with the absolute path to your cloned repository)*.

---

## 📄 Sample Health Report

Below is an example of the output appended to `/opt/healthcheck/healthcheck-logs/health-YYYY-MM-DD.log`:

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

If the root partition exceeds the configured `DISK_LIMIT`, the report will output:

```text
WARNING: Disk is 85% full!
```

---

## 🛠️ Troubleshooting

- **`Permission denied` when running the script:**
  - Make sure you granted execution permission with `chmod +x healthcheck.sh`.
  - Creating directories under `/opt` requires elevated permissions. Always run with `sudo ./healthcheck.sh`.
- **`systemctl: command not found`:**
  - The host system may be using an alternate init system (e.g. SysVinit, OpenRC, or running inside a lightweight Docker container without systemd).
- **Service shows `NOT RUNNING` unexpectedly:**
  - Confirm the exact service name using `systemctl status <service_name>`. Service names may differ across Linux distributions (e.g., `apache2` on Debian/Ubuntu vs `httpd` on CentOS/RHEL).

---

## 📄 License

This project is open-source.
