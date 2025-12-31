# HeartRate Senior - iOS App

A comprehensive health monitoring app designed specifically for seniors in the US market, featuring high readability, medical-grade minimalism, and ease of use.

## Features

### Core Health Monitoring
- **Heart Rate Measurement**: PPG-based heart rate detection using the device camera
- **Blood Pressure Tracking**: Manual input with automatic classification (Normal, Elevated, Hypertension stages)
- **Blood Glucose Monitoring**: Track fasting, pre-meal, post-meal, and bedtime readings

### Dashboard
- Unified health overview with all vital signs
- Quick access to all measurement types
- Recent readings at a glance

### Health History
- Weekly trend charts for all metrics
- Detailed record lists with filtering
- Export to PDF for doctor visits

### Reminders System
- Customizable measurement reminders
- Medication reminders with dosage tracking
- Flexible repeat options (daily, weekly, custom days)
- Local notifications

### Emergency Contacts
- Quick-call primary contact feature
- Multiple emergency contacts support
- Abnormal reading alert thresholds
- SMS notification capability

### Health Reports
- Weekly, monthly, and quarterly reports
- Statistical summaries (average, min, max)
- Blood pressure classification breakdown
- Export to PDF

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

### Senior-Friendly UI
- **Large Text**: 34pt+ titles, 80pt BPM display
- **High Contrast**: Pure black text on white background
- **Large Touch Targets**: Minimum 60pt button height
- **Haptic Feedback**: Tactile confirmation on interactions

### Color Palette
- Primary Red: #FF3B30 (System Red)
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
│   ├── BloodPressureRecord.swift     # Blood pressure data model
│   ├── BloodGlucoseRecord.swift      # Blood glucose data model
│   ├── Reminder.swift                # Reminder data model
│   ├── EmergencyContact.swift        # Emergency contact model
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
│   │   └── DashboardView.swift       # Health overview
│   ├── Home/
│   │   ├── HomeView.swift            # Heart rate measurement
│   │   ├── MeasureButton.swift       # Animated measure button
│   │   ├── PPGWaveformView.swift     # Real-time waveform
│   │   └── CameraPreviewView.swift   # Camera feed
│   ├── BloodPressure/
│   │   ├── BloodPressureInputView.swift
│   │   └── BloodPressureHistoryView.swift
│   ├── BloodGlucose/
│   │   ├── BloodGlucoseInputView.swift
│   │   └── BloodGlucoseHistoryView.swift
│   ├── History/
│   │   ├── HistoryView.swift         # Heart rate history
│   │   └── WeeklyChartView.swift     # Trend chart
│   ├── Charts/
│   │   ├── BloodPressureChartView.swift
│   │   └── BloodGlucoseChartView.swift
│   ├── Result/
│   │   └── ResultView.swift          # Measurement result
│   ├── Reminders/
│   │   ├── RemindersView.swift       # Reminder list
│   │   └── AddReminderView.swift     # Add/edit reminder
│   ├── Emergency/
│   │   └── EmergencyContactsView.swift
│   ├── Reports/
│   │   └── HealthReportView.swift    # Health summaries
│   ├── Settings/
│   │   ├── SettingsView.swift        # App settings
│   │   └── BackupRestoreView.swift   # Data management
│   ├── Profile/
│   │   └── ProfileView.swift         # User profile
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

- **Camera**: For PPG heart rate measurement
- **HealthKit**: For Apple Health sync (optional)
- **Notifications**: For reminders (optional)

## Medical Disclaimer

This app is for informational purposes only and is not intended to be a substitute for professional medical advice, diagnosis, or treatment. Always seek the advice of your physician or other qualified health provider with any questions you may have regarding a medical condition.

## Privacy

- All health data is stored locally on device
- Camera data is processed in real-time and not stored
- Optional iCloud backup is user-controlled
- No data is shared with third parties

## Version History

### v1.0.0
- Initial release
- Heart rate measurement via PPG
- Blood pressure tracking
- Blood glucose monitoring
- Health dashboard
- Reminders system
- Emergency contacts
- Health reports
- Data backup/restore
- Apple Health integration
