---
name: Bug report
about: Create a report to help us improve AirPods Monitor
title: '[BUG] '
labels: 'bug'
assignees: ''

---

## 🐛 Bug Description
A clear and concise description of what the bug is.

## 🔄 Steps to Reproduce
1. Go to '...'
2. Click on '....'
3. Scroll down to '....'
4. See error

## ✅ Expected Behavior
A clear and concise description of what you expected to happen.

## 📸 Screenshots
If applicable, add screenshots to help explain your problem.

## 💻 Environment
- **macOS Version**: [e.g. macOS 14.1 Sonoma]
- **AirPods Monitor Version**: [e.g. 1.0.0]
- **Device**: [e.g. AirPods Pro, Beats Fit Pro]
- **Installation Method**: [DMG, Homebrew, Built from source]

## 📋 System Information
Please run the following command and paste the output:
```bash
system_profiler SPBluetoothDataType -json | grep -A 10 -B 5 "AirPods\|Beats"
```

## 🔍 Additional Context
Add any other context about the problem here.

## 🩺 Troubleshooting Tried
- [ ] Refreshed manually from menu
- [ ] Restarted the app
- [ ] Checked Bluetooth connection
- [ ] Reviewed preferences settings
- [ ] Restarted macOS