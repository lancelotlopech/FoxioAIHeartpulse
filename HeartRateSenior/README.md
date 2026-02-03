# Foxio Heart - iOS App

A wellness tracking app designed for easy heart rate monitoring, featuring high readability and ease of use.

## Features

### Core Tracking
- **Heart Rate Check**: Camera-based heart rate estimation using PPG technology
- **Activity Tracking**: Tag measurements with activities (Resting, Walking, Exercise, etc.)
- **Habit Score**: Track your measurement consistency

### Dashboard
- Unified overview with recent readings
- Quick access to measurement
- Habit score at a glance

### History
- Weekly trend charts
- Calendar heatmap view
- Detailed record lists with filtering
- Export to PDF for sharing

### Reminders System
- Customizable measurement reminders
- Flexible repeat options (daily, weekly, custom days)
- Local notifications

### Data Management
- **Backup & Restore**: Export all data to JSON file
- **iCloud Status**: Check cloud availability
- **Import**: Restore from backup files

### Apple Health Integration
- Sync heart rate to Apple Health
- Automatic saving when enabled

## Tech Stack

- **Language**: Swift 5.9+
- **UI Framework**: SwiftUI
- **Data Persistence**: SwiftData
- **Health Integration**: HealthKit
- **Camera Access**: AVFoundation
- **Charts**: Swift Charts
- **Architecture**: MVVM

## Design System

### User-Friendly UI
- **Large Text**: 34pt+ titles, 80pt BPM display
- **High Contrast**: Clear text on clean background
- **Large Touch Targets**: Minimum 60pt button height
- **Haptic Feedback**: Tactile confirmation on interactions

### Color Palette
- Primary Red: #F4403A
- Background: #FFFFFF (Pure White)
- Card Background: #F2F2F7 (System Gray 6)
- Text Primary: #000000 (Pure Black)

### Typography
- SF Pro Rounded throughout
- Large, readable font sizes
- Clear visual hierarchy

## Project Structure

```
HeartRateSenior/
├── HeartRateSeniorApp.swift          # App entry point
├── Models/
│   ├── HeartRateRecord.swift         # Heart rate data model
│   ├── Reminder.swift                # Reminder data model
│   └── MeasurementTag.swift          # Measurement context tags
├── ViewModels/
│   ├── HeartRateManager.swift        # PPG measurement logic
│   ├── HealthKitManager.swift        # Apple Health integration
│   ├── SettingsManager.swift         # App settings
│   ├── ReminderManager.swift         # Notification scheduling
│   └── CloudSyncManager.swift        # Backup/restore logic
├── Views/
│   ├── MainTabView.swift             # Tab navigation
│   ├── Dashboard/
│   │   └── DashboardView.swift       # Overview
│   ├── Home/
│   │   ├── HomeView.swift            # Heart rate measurement
│   │   ├── MeasureButton.swift       # Animated measure button
│   │   └── CameraPreviewView.swift   # Camera feed
│   ├── History/
│   │   ├── HistoryView.swift         # Heart rate history
│   │   └── WeeklyChartView.swift     # Trend chart
│   ├── Result/
│   │   └── ResultView.swift          # Measurement result
│   ├── Reminders/
│   │   ├── RemindersView.swift       # Reminder list
│   │   └── AddReminderView.swift     # Add/edit reminder
│   ├── Settings/
│   │   ├── SettingsView.swift        # App settings
│   │   └── BackupRestoreView.swift   # Data management
│   └── Onboarding/
│       ├── OnboardingContainerView.swift
│       ├── WelcomeView.swift
│       ├── PrivacyPermissionView.swift
│       └── TutorialView.swift
├── Utilities/
│   ├── DesignSystem.swift            # Colors, fonts, styles
│   ├── HapticManager.swift           # Haptic feedback
│   ├── SignalProcessor.swift         # PPG signal processing
│   └── PDFExporter.swift             # PDF generation
└── Assets.xcassets/                  # App icons, colors
```

## Requirements

- iOS 17.0+
- Xcode 15.0+
- iPhone with rear camera and flash

## Permissions Required

- **Camera**: For heart rate estimation
- **HealthKit**: For Apple Health sync (optional)
- **Notifications**: For reminders (optional)

## Disclaimer

This app is for general wellness and reference purposes only. It is not a medical device and should not be used for diagnosis or treatment. The heart rate readings are estimates based on camera analysis and may vary from actual values.

## Privacy

- All data is stored locally on device
- Camera data is processed in real-time and not stored
- Optional iCloud backup is user-controlled
- No data is shared with third parties

## Version History

### v1.0.0
- Initial release
- Heart rate estimation via PPG
- Activity tagging
- Habit tracking
- Reminders system
- Data backup/restore
- Apple Health integration
