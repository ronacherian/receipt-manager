# Receipt Manager 🧾

> **Intelligent, privacy-first paper receipt scanner, expense organizer, and return deadline tracker for iOS.**

[![iOS](https://img.shields.io/badge/iOS-18%2B%20%2F%2026%2B-blue.svg)](https://developer.apple.com/ios/)
[![Swift](https://img.shields.io/badge/Swift-5.0%20%2F%206-orange.svg)](https://swift.org)
[![SwiftUI](https://img.shields.io/badge/UI-SwiftUI-purple.svg)](https://developer.apple.com/xcode/swiftui/)
[![SwiftData](https://img.shields.io/badge/Storage-SwiftData-green.svg)](https://developer.apple.com/documentation/swiftdata)
[![Apple Intelligence](https://img.shields.io/badge/AI-FoundationModels-red.svg)](https://developer.apple.com/apple-intelligence/)
[![Privacy](https://img.shields.io/badge/Privacy-100%25%20On--Device-brightgreen.svg)](#privacy--security)

---

## 🌟 Overview

**Receipt Manager** is a native iOS application designed to streamline the capture, organization, and deadline management of physical retail receipts. Leveraging on-device machine learning and Apple Intelligence, Receipt Manager automatically extracts store names, purchase dates, total charged amounts, and return policies directly from paper receipts—with **zero external server dependencies and 100% on-device privacy**.

---

## ✨ Features

### 📷 Smart Document Scanning & OCR
* **VisionKit Integration**: Uses `VNDocumentCameraViewController` for automated document edge detection, perspective correction, and multi-page batch scanning.
* **Line-Clustered Text Recognition**: Runs on-device Vision OCR (`VNRecognizeTextRequest`, `.accurate`) with vertical proximity line-clustering to preserve natural reading order on multi-column receipts.
* **Hardware Availability Guard**: Graceful fallback to manual entry when camera scanning is unsupported (e.g., in simulator environments).

### 🧠 On-Device Apple Intelligence (`FoundationModels`)
* **Structured Information Extraction**: Uses `FoundationModels` (`SystemLanguageModel.default`, `@Generable`, `@Guide`) to pull store names, purchase dates, final charged totals, and return policy statements.
* **Deterministic Parsing**: Distinguishes between subtotals, item lines, discounts, and final balance due.
* **Graceful Degradation**: Surfaces explicit diagnostic reasons (e.g., `modelNotReady`) and allows effortless manual entry/editing.

### ⏰ Return Deadline Reminders (`UserNotifications`)
* **Automatic Policy Calculation**: Parses explicit return dates from receipt text or defaults to a 30-day return window (`ReturnDatePolicy`).
* **Local Notifications**: Schedules local alerts 3 days and 1 day before the return deadline at 9:00 AM.
* **Dynamic Lifecycle**: Automatically reschedules or cancels pending reminders when receipts are updated, marked returned, or deleted.

### 🔍 Search & Management Dashboard
* **Real-Time Search**: Search receipts by merchant name or recognized item/receipt text.
* **Status Filtering**: Segment views by *All*, *Returns Due*, and *Returned*.
* **Multi-Field Sorting & Grouping**: Sort by Date (Newest/Oldest), Store, or Amount, with an optional Group-by-Store toggle.

### 🔎 Full-Screen Zoom & 📤 ShareLink Export
* **Pinch-to-Zoom Viewer**: Tap any receipt scan to open an interactive full-screen image viewer supporting pinch-to-zoom, pan, and double-tap zoom via native `UIScrollView`.
* **Instant Export**: Native iOS `ShareLink` to export scanned receipt images alongside formatted summary details.

---

## 🔒 Privacy & Security

* **100% On-Device Processing**: No receipt images, OCR text, or purchase metadata are ever transmitted off-device.
* **Zero Tracking / No Accounts**: No analytics, telemetry, third-party advertising SDKs, or user login requirements.
* **Apple Privacy Manifest**: Full [`PrivacyInfo.xcprivacy`](receipt%20manager/PrivacyInfo.xcprivacy) included declaring zero cross-app tracking (`NSPrivacyTracking: false`).

---

## 🏗️ Architecture & Codebase Structure

```text
receipt manager/
├── Models/
│   ├── Receipt.swift               # SwiftData entity (store, date, total, returnByDate, OCR text)
│   └── ReceiptPage.swift           # SwiftData entity with external binary storage (@Attribute(.externalStorage))
├── Scan/
│   ├── ScanView.swift              # Main scan tab with camera launch, progress, & availability guards
│   ├── DocumentCameraView.swift    # UIViewControllerRepresentable wrapping VNDocumentCameraViewController
│   └── ReceiptConfirmSheet.swift   # Prefilled confirmation form with validation and notification scheduling
├── Manage/
│   ├── ManageView.swift            # Dashboard with .searchable, filter, sort, and swipe actions
│   ├── ReceiptDetailView.swift     # Detailed receipt view, page carousel, tap-to-zoom, & ShareLink
│   ├── ReceiptRowView.swift        # Compact list row with return deadline badges
│   ├── ReceiptListLogic.swift      # Pure Swift filtering, sorting, and search logic
│   └── ZoomableImageView.swift     # Interactive full-screen pinch/pan image viewer
├── Services/
│   ├── ScanProcessor.swift         # Vision OCR execution & line-clustering reading order engine
│   ├── ReceiptExtractor.swift      # FoundationModels LanguageModelSession extraction service
│   ├── ReceiptExtraction.swift     # @Generable extraction schema with @Guide constraints
│   ├── ReturnDatePolicy.swift      # Date parsing & 30-day deadline calculation policy
│   └── NotificationManager.swift   # Local UserNotifications manager for return reminders
├── Assets.xcassets/
│   └── AppIcon.appiconset/         # 1024x1024 master icon with Light, Dark, and Tinted iOS 18 variants
├── PrivacyInfo.xcprivacy           # Apple Privacy Manifest
└── receipt_managerApp.swift        # App entry point & ModelContainer configuration
```

---

## 🚀 Getting Started

### Prerequisites
* macOS 15.0 (Sequoia) or later
* Xcode 16.0+ / Xcode 26 beta
* iOS 18.0+ / iOS 26.0+ target device or Simulator
* Physical iOS device required for live camera document scanning and Apple Intelligence model execution

### Build & Run
1. Clone the repository:
   ```bash
   git clone git@github.com:ronacherian/receipt-manager.git
   cd receipt-manager
   ```
2. Open the project in Xcode:
   ```bash
   open "receipt manager.xcodeproj"
   ```
3. Select the **receipt manager** scheme and a destination (e.g. *iPhone 16 / 17 Simulator* or a physical iPhone).
4. Press `Cmd + R` to build and run.

---

## 🧪 Testing

The project uses Swift Testing for test coverage on business logic:

```bash
# Run unit tests via xcodebuild
xcodebuild test \
  -project "receipt manager.xcodeproj" \
  -scheme "receipt manager" \
  -destination 'generic/platform=iOS Simulator'
```

* **`ReceiptFilteringTests`**: Verifies status filtering (*All / Due / Completed*), multi-field sorting, store grouping, and text search across merchant names and OCR contents.
* **`ReturnDatePolicyTests`**: Tests date parsing, default 30-day calculations, and leap-year/year-boundary handling.

---

## 📋 App Store Submission Readiness

* **App Store Review Notes**: See [`APP_STORE_REVIEW_NOTES.md`](APP_STORE_REVIEW_NOTES.md) for reviewer test instructions and sample receipts.
* **Submission Skill**: See [`skills/ios_app_submission/SKILL.md`](skills/ios_app_submission/SKILL.md) for pre-submission compliance audit guidelines.
* **App Icon**: Universal 1024x1024 px opaque RGB assets with Light, Dark, and Tinted appearances.
* **Usage Strings**: Clear, user-centric `NSCameraUsageDescription` configured.

---

## 🗺️ Roadmap & Future Enhancements

- [ ] **Multi-Currency Selection**: Currency picker in confirm/detail views beyond device locale.
- [ ] **CloudKit Syncing**: Multi-device sync using SwiftData CloudKit integration.
- [ ] **Scanned Page Editing**: Reorder, replace, or delete individual pages after saving.
- [ ] **iPad & macOS Support**: Adaptive layout optimization for iPadOS and macOS Catalyst.

---

## 📄 License & Author

Developed by **Ron Abraham Cherian** ([@ronacherian](https://github.com/ronacherian)).
All rights reserved.
