# Calendar Skill

Manage calendar events and schedules.

## Setup

This skill provides calendar management capabilities. For Apple Calendar, use `apple-reminders` skill.

## Usage

### Check current date/time
```bash
date
cal
```

### Add to cron for scheduling
```bash
crontab -l
crontab -e
```

## Already Configured

The following scheduled tasks are already set up:

| Time | Task |
|------|------|
| 9:00 AM (weekdays) | Customer Fund Report |
| 1:00 PM | Alarm reminder |
| 10:00 PM | Shutdown reminder |

## For Full Calendar Integration

Use one of these skills:
- `apple-reminders` - Apple Reminders sync
- `caldav-calendar` - CalDAV calendar integration (install via clawhub)
- `gcalcli` - Google Calendar CLI (install via clawhub)

