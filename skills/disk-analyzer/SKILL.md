# Disk Analyzer Skill

Analyze disk usage and storage.

## Usage

### Check disk space
```bash
df -h
```

### Find large files
```bash
# Find files larger than 100MB
find /home -type f -size +100M -ls 2>/dev/null | head -20

# Find files larger than 1GB
find /home -type f -size +1G -ls 2>/dev/null | head -10
```

### Directory size analysis
```bash
# Show top 20 largest directories
du -h /home/administrator 2>/dev/null | sort -rh | head -20

# Show current directory breakdown
du -h --max-depth=1
```

### Common commands
```bash
# Disk usage by filesystem
df -h

# Inode usage
df -i

# Large files in home directory
find ~ -type f -exec ls -lh {} \; 2>/dev/null | sort -k5 -rh | head -20

# Clean up old logs
find /var/log -type f -name "*.log" -mtime +30 -delete 2>/dev/null

# Clean npm cache
npm cache clean --force

# Clean pip cache
pip cache purge
```

## Tools

- `du` - Estimate file space usage
- `df` - Report file system disk space usage
- `find` - Search for files
- `ncdu` - Interactive disk usage analyzer (install: `apt install ncdu`)

