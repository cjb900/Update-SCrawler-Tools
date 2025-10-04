# SCrawler Tools Update Script

This script updates both **yt-dlp** (YouTube downloader) and **gallery-dl** (gallery downloader) in your SCrawler installation. It must be run from within the SCrawler directory where `SCrawler.exe` is located.

## 🌟 Key Features

- **Dual Tool Support**: Updates both yt-dlp and gallery-dl from their official GitHub releases
- **Interactive Menu**: Choose which tool to update or update both at once
- **Local Operation**: Works from within the SCrawler directory
- **Auto-Detection**: Finds Environment folder automatically when run from SCrawler directory
- **Versioned Backups**: Creates timestamped backups before updating
- **Safe Updates**: Validates downloads before replacing executables

## Files Included

- `Update-SCrawler-Tools.ps1` - Self-contained PowerShell script (single file solution)
- `README-Update-SCrawler-Tools.md` - This documentation

## Current Status

✅ **yt-dlp is up to date!**
- Current version: 2025.09.26
- Latest version: 2025.09.26

🔄 **gallery-dl update available!**
- Current version: 1.30.5
- Latest version: v1.30.9

## 📁 Installation Requirements

**The script must be placed and run from within your SCrawler directory:**

1. **Copy the script** to your SCrawler directory (same folder as `SCrawler.exe`)
2. **Run from that location** - the script expects to find:
   - `SCrawler.exe` in the current directory
   - `Environment` folder with `yt-dlp.exe` and/or `gallery-dl.exe`

**Directory Structure Required:**
```
YourSCrawlerFolder/
├── SCrawler.exe                    ← Main application
├── Update-SCrawler-Tools.ps1       ← This script (place here)
├── Environment/
│   ├── yt-dlp.exe                  ← YouTube downloader
│   ├── gallery-dl.exe              ← Gallery downloader
│   └── [other tools...]
└── [other SCrawler files...]
```

**Works with ANY SCrawler directory name:**
- `SCrawler_2025.9.1.0_x64` ✅
- `SCrawler_2025.10.5.0_x64` ✅
- `MySCrawler` ✅
- `VideoDownloader` ✅
- `SCrawler-Updated` ✅
- Any custom name! ✅

## Usage

### Method 1: Interactive Menu (Recommended)
1. **Navigate to your SCrawler directory** (where `SCrawler.exe` is located)
2. **Double-click** `Update-SCrawler-Tools.ps1` → Choose from menu
3. **Or right-click** → "Run with PowerShell" → Choose from menu

### Method 2: Direct Tool Selection
1. **Open PowerShell in your SCrawler directory**
2. **Run one of these commands:**
```powershell
# Update yt-dlp only
.\Update-SCrawler-Tools.ps1 -Tool "yt-dlp"

# Update gallery-dl only  
.\Update-SCrawler-Tools.ps1 -Tool "gallery-dl"

# Update both tools
.\Update-SCrawler-Tools.ps1 -Tool "both"
```

### Method 3: With Additional Options
```powershell
# Force update without prompting
.\Update-SCrawler-Tools.ps1 -Tool "yt-dlp" -Force

# Run quietly (no colored output)
.\Update-SCrawler-Tools.ps1 -Tool "gallery-dl" -Quiet

# Specify custom environment path (rarely needed)
.\Update-SCrawler-Tools.ps1 -EnvironmentPath ".\Environment"
```

### Method 4: From Command Prompt
```cmd
powershell -ExecutionPolicy Bypass -File "Update-SCrawler-Tools.ps1"
```

## 🔧 Command-Line Arguments

The script supports several command-line parameters for advanced usage:

### Available Parameters

| Parameter | Type | Description | Example |
|-----------|------|-------------|---------|
| `-Tool` | String | Specify which tool to update | `-Tool "yt-dlp"` |
| `-Force` | Switch | Force update without prompting | `-Force` |
| `-Quiet` | Switch | Minimal output (no colors/prompts) | `-Quiet` |
| `-EnvironmentPath` | String | Custom path to Environment folder (relative to SCrawler directory) | `-EnvironmentPath ".\Environment"` |

### Tool Options for `-Tool` Parameter
- `"yt-dlp"` - Update YouTube downloader only
- `"gallery-dl"` - Update gallery downloader only  
- `"both"` - Update both tools
- (omit parameter) - Show interactive menu

## 📋 Usage Examples

### Basic Usage
```powershell
# Interactive menu (recommended for most users)
.\Update-SCrawler-Tools.ps1

# Update specific tool
.\Update-SCrawler-Tools.ps1 -Tool "yt-dlp"
.\Update-SCrawler-Tools.ps1 -Tool "gallery-dl"

# Update both tools
.\Update-SCrawler-Tools.ps1 -Tool "both"
```

### Advanced Usage
```powershell
# Force update without user prompts
.\Update-SCrawler-Tools.ps1 -Tool "yt-dlp" -Force
.\Update-SCrawler-Tools.ps1 -Tool "both" -Force

# Quiet mode (minimal output, no colors)
.\Update-SCrawler-Tools.ps1 -Tool "gallery-dl" -Quiet
.\Update-SCrawler-Tools.ps1 -Force -Quiet

# Custom environment path
.\Update-SCrawler-Tools.ps1 -EnvironmentPath ".\CustomEnvironment"

# Combine multiple parameters
.\Update-SCrawler-Tools.ps1 -Tool "both" -Force -Quiet
```

### Command Prompt Usage
```cmd
# Basic execution
powershell -ExecutionPolicy Bypass -File "Update-SCrawler-Tools.ps1"

# With parameters
powershell -ExecutionPolicy Bypass -File "Update-SCrawler-Tools.ps1" -Tool "yt-dlp" -Force

# Quiet mode from command prompt
powershell -ExecutionPolicy Bypass -File "Update-SCrawler-Tools.ps1" -Tool "both" -Force -Quiet
```

### Automation Examples
```powershell
# Batch file example (update_yt-dlp.bat)
@echo off
powershell -ExecutionPolicy Bypass -File "Update-SCrawler-Tools.ps1" -Tool "yt-dlp" -Force
pause

# Scheduled task example
powershell -ExecutionPolicy Bypass -File "Update-SCrawler-Tools.ps1" -Tool "both" -Force -Quiet

# PowerShell script example
.\Update-SCrawler-Tools.ps1 -Tool "gallery-dl" -Force -Quiet
if ($LASTEXITCODE -eq 0) {
    Write-Host "Gallery-dl updated successfully"
} else {
    Write-Host "Update failed"
}
```

## Features

- ✅ **Dual Tool Support**: Updates both yt-dlp and gallery-dl
- ✅ **Interactive Menu**: Choose which tool to update
- ✅ **Version Checking**: Compares current version with latest GitHub release
- ✅ **Safe Updates**: Creates backup before replacing the executable
- ✅ **Validation**: Tests downloaded file before replacement
- ✅ **Error Handling**: Comprehensive error messages and rollback
- ✅ **Colored Output**: Easy-to-read status messages
- ✅ **Flexible Options**: Force update, quiet mode, custom paths
- ✅ **Interactive**: Prompts user before updating (unless -Force is used)

## What the Script Does

1. **Verifies Location**: Ensures it's running from within a SCrawler directory (looks for SCrawler.exe)
2. **Shows Menu**: Interactive selection of tool to update (or runs directly if -Tool specified)
3. **Checks Environment**: Verifies the Environment folder exists
4. **Gets Current Version**: Runs `--version` on the selected tool
5. **Fetches Latest**: Queries GitHub API for the latest release version
6. **Compares**: Determines if an update is needed
7. **Updates (if needed)**:
   - Downloads latest executable from GitHub
   - Tests the downloaded file
   - Creates backup of current version
   - Replaces with new version
   - Reports success/failure

## Safety Features

- **Versioned Backups**: Current versions are backed up as `tool_backup.version.exe`
  - Examples: `yt-dlp_backup.2025.09.26.exe`, `gallery-dl_backup.1_30_9.exe`
  - Version numbers are cleaned for filenames (dots become underscores, 'v' prefix removed)
- **Multiple Backup Retention**: Each update creates a new backup, preserving previous versions
- **File Validation**: Downloaded files are tested before replacement
- **Error Recovery**: Temporary files are cleaned up on failure
- **User Confirmation**: Interactive prompt before updating (unless forced)
- **Tool Isolation**: Each tool is updated independently

## 📁 Backup Management

The script creates versioned backups to preserve previous versions:

**Backup Naming Convention:**
- `yt-dlp_backup.YYYY.MM.DD.exe` (e.g., `yt-dlp_backup.2025.09.26.exe`)
- `gallery-dl_backup.X.Y.Z.exe` (e.g., `gallery-dl_backup.1_30_9.exe`)

**Version Cleaning Rules:**
- Removes all whitespace and spaces
- Removes 'v' prefix (v1.30.9 → 1.30.9)
- Replaces dots with underscores (1.30.9 → 1_30_9)
- Replaces colons with underscores (if present)
- Removes special characters

**Benefits:**
- ✅ No backup overwrites - each version is preserved
- ✅ Easy identification of backup versions
- ✅ Rollback capability to any previous version
- ✅ Clean filename format (Windows compatible)

**Manual Cleanup:** You can safely delete old backup files when no longer needed.

## Environment Structure

The script expects the following structure:
```
SCrawler_2025.9.1.0_x64/
├── Environment/
│   ├── yt-dlp.exe                    ← YouTube downloader
│   ├── yt-dlp_backup.2025.09.26.exe  ← Versioned backup (created during update)
│   ├── gallery-dl.exe                ← Gallery downloader
│   ├── gallery-dl_backup.1.30.5.exe  ← Versioned backup (created during update)
│   ├── ffmpeg.exe
│   ├── ffplay.exe
│   └── ffprobe.exe
├── Update-SCrawler-Tools.ps1       ← Single self-contained script
└── README-Update-SCrawler-Tools.md ← This documentation
```

## Exit Codes

- `0` - Success (up to date or update completed)
- `1` - Error (file not found, download failed, etc.)

## Requirements

- Windows PowerShell 5.1 or later
- Internet connection (for GitHub API and downloads)
- Write permissions to Environment folder
- yt-dlp.exe must be executable

## Troubleshooting

### "Execution Policy" Error
Use the batch file wrapper or run with `-ExecutionPolicy Bypass`

### "Environment folder not found"
Make sure you're running the script from the SCrawler root directory, or use `-EnvironmentPath` parameter

### "Download failed"
Check your internet connection and try again. GitHub may be temporarily unavailable.

### "File not a valid yt-dlp executable"
The downloaded file may be corrupted. Try running the script again.

## GitHub Release Information

### yt-dlp (YouTube Downloader)
- **Repository**: https://github.com/yt-dlp/yt-dlp
- **Latest Release**: https://github.com/yt-dlp/yt-dlp/releases/latest
- **Download URL**: https://github.com/yt-dlp/yt-dlp/releases/download/{version}/yt-dlp.exe

### gallery-dl (Gallery Downloader)
- **Repository**: https://github.com/mikf/gallery-dl
- **Latest Release**: https://github.com/mikf/gallery-dl/releases/latest
- **Download URL**: https://github.com/mikf/gallery-dl/releases/download/{version}/gallery-dl.exe

---

*This script was created to help maintain both yt-dlp and gallery-dl in the SCrawler environment. It automatically checks for updates and provides a safe way to upgrade both downloader tools.*
