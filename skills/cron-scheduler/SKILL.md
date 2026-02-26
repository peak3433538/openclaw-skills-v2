# Cron Scheduler Skill

Manage scheduled tasks using cron.

## Current Scheduled Tasks

| Time | Command | Description |
|------|---------|-------------|
| 0 9 * * 1-5 | daily_fund_report.sh | Customer Fund Report (weekdays 9AM) |
| 0 13 * * * | 简单闹钟.sh | Alarm reminder (1PM) |
| 30 21 * * * | shutdown_reminder.sh | Shutdown reminder (9:30PM) |
| 0 22 * * * | shutdown_reminder.sh | Shutdown reminder (10PM) |

## Usage

### View crontab
```bash
crontab -l
```

### Edit crontab
```bash
crontab -e
```

### Add new task
```bash
# Add to crontab
crontab -l | { cat; echo "0 10 * * * /path/to/command"; } | crontab -
```

### Remove all tasks
```bash
crontab -r
```

## Cron Syntax

```
┌───────────── minute (0 - 59)
│ ┌───────────── hour (0 - 23)
│ │ ┌───────────── day of month (1 - 31)
│ │ │ ┌───────────── month (1 - 12)
│ │ │ │ ┌───────────── day of week (0 - 6) (Sunday = 0)
│ │ │ │ │
* * * * * command
```

### Examples

| Cron | Description |
|------|-------------|
| `0 9 * * *` | Every day at 9AM |
| `0 9 * * 1-5` | Weekdays at 9AM |
| `*/15 * * * *` | Every 15 minutes |
| `0 0 1 * *` | First day of every month |
| `0 9 * * 1-5 /script.sh` | Weekdays 9AM run script |

## Logging

Check cron logs:
```bash
tail -f /var/log/syslog | grep CRON
# or
journalctl -u cron
```

