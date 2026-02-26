# Package Manager Skill

Manage system and development packages.

## System Packages (Linux)

### APT (Ubuntu/Debian)
```bash
# Update package list
sudo apt update

# Upgrade packages
sudo apt upgrade

# Install package
sudo apt install <package-name>

# Remove package
sudo apt remove <package-name>

# Search for package
apt search <keyword>

# List installed packages
dpkg -l | grep <package-name>
```

### Pacman (Arch Linux)
```bash
# Sync databases
sudo pacman -Sy

# Install package
sudo pacman -S <package-name>

# Remove package
sudo pacman -R <package-name>

# Search
pacman -Ss <keyword>
```

### DNF (Fedora/RHEL)
```bash
# Update
sudo dnf update

# Install
sudo dnf install <package-name>

# Search
dnf search <keyword>
```

## Development Packages

### npm (Node.js)
```bash
# Install globally
npm install -g <package>

# Install locally
npm install <package>

# Update
npm update

# List global packages
npm list -g --depth=0
```

### pip (Python)
```bash
# Install package
pip install <package>

# Upgrade
pip install --upgrade <package>

# List outdated
pip list --outdated
```

### Homebrew (macOS)
```bash
# Update
brew update

# Install
brew install <package>

# Upgrade
brew upgrade

# Cleanup
brew cleanup
```

## Useful Tools

| Tool | Purpose |
|------|---------|
| `apt` | Debian/Ubuntu package manager |
| `dnf` | Fedora package manager |
| `pacman` | Arch Linux package manager |
| `npm` | Node.js packages |
| `pip` | Python packages |
| `cargo` | Rust packages |
| `brew` | macOS package manager |

