# Clipboard watcher
Clipboard watcher is a macOS shell script based on [TruffleHog](https://github.com/trufflesecurity/trufflehog). It monitors your clipboard at short intervals and detects secrets.

## Installation

### Install Dependencies

```bash
brew install trufflehog jq
```

### Clone the Repository

```bash
git clone https://github.com/isacaya/clipboard_watcher/
cd clipboard_watcher
```

### Run the Script

```bash
chmod +x clipboard_watcher.sh
./clipboard_watcher.sh &
```

## Demo

![demo](https://github.com/user-attachments/assets/bc1a842a-a2ff-402d-b472-3aa02a13287b)
