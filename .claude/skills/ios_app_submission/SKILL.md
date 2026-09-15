---
name: ios_app_submission
description: Audit, prepare, and verify an iOS app project against Apple Human Interface Guidelines (HIG) and App Store Review Guidelines before submission to App Store Connect. Use whenever preparing an iOS app for App Store submission, running pre-submission compliance checks, configuring Privacy Manifests (PrivacyInfo.xcprivacy), auditing permission purpose strings, or validating App Store review assets and metadata.
---

# iOS App Store Submission & Readiness Guide

This skill provides the mandatory guidelines, validation steps, and technical checklists required to successfully submit an iOS application to the Apple App Store without rejections.

---

## 1. Safety & Privacy Compliance (Guideline 5.1)

### 1.1. Privacy Manifest (`PrivacyInfo.xcprivacy`)
Since Spring 2024, Apple requires a Privacy Manifest in the root target of every iOS application:
- **Location**: Included in target's `PBXResourcesBuildPhase` as `PrivacyInfo.xcprivacy`.
- **Keys required**:
  - `NSPrivacyTracking`: Set to `<false/>` unless using third-party tracking identifiers (e.g., IDFA for advertising).
  - `NSPrivacyTrackingDomains`: Array of internet domains used for tracking (empty if none).
  - `NSPrivacyCollectedDataTypes`: Array of dictionaries declaring data collected and sent off-device (e.g., Contact Info, Financial Info). If 100% on-device (e.g., local SwiftData / on-device Apple Intelligence), this array remains empty (`<array/>`).
  - `NSPrivacyAccessedAPITypes`: Array of dictionaries declaring usage of Apple's **Required Reason APIs** (e.g., `NSPrivacyAccessedAPICategoryUserDefaults`, `NSPrivacyAccessedAPICategoryFileTimestamp`, `NSPrivacyAccessedAPICategorySystemBootTime`, `NSPrivacyAccessedAPICategoryDiskSpace`).

### 1.2. Permission Purpose Strings (Guideline 5.1.1)
- Every system capability requested (Camera, Photo Library, Location, Microphone, Notifications) must include a detailed, user-facing explanation in `Info.plist` (or build settings `INFOPLIST_KEY_*`).
- **Rejection trigger**: Short or generic strings like `"Used for camera"`, `"Camera scanning"`, or `"Photo access"`.
- **Approved pattern**: `"App Name requires camera access to scan your physical paper receipts for automatic text recognition, expense logging, and return deadline tracking."`

---

## 2. App Completeness, Stability & Hardware Fallbacks (Guidelines 2.1 & 2.4)

### 2.1. Hardware Availability Guards
- Never assume physical hardware capabilities are available.
- For VisionKit document scanning:
  ```swift
  import VisionKit
  
  if VNDocumentCameraViewController.isSupported {
      // Present DocumentCameraView
  } else {
      // Display fallback alert or direct manual entry sheet
  }
  ```
- Protect against crashes or dead-ends when App Store reviewers test on iPad, older devices, or iOS Simulators.

### 2.2. Graceful AI & Offline Degradation
- If using on-device Apple Intelligence (`FoundationModels`, `SystemLanguageModel`):
  - Check availability via `SystemLanguageModel.default.availability`.
  - Always provide full manual fallback workflows if Apple Intelligence is unavailable, downloading, or restricted by region.

### 2.3. Supported Platforms & Device Families
- Ensure `TARGETED_DEVICE_FAMILY` in `project.pbxproj` aligns with intended platforms (`1` = iPhone, `2` = iPad, `7` = visionOS).
- In App Store Connect, ensure "Designed for iPad" or "Designed for Mac" is explicitly disabled if the UI has only been designed and tested for iPhone.

---

## 3. App Icon & Visual Asset Requirements (HIG)

### 3.1. Technical Icon Specifications
- **Master Size**: Exactly `1024 × 1024` pixels.
- **Transparency / Alpha**: **Strictly NO alpha channel** (`hasAlpha: no`, 100% opaque RGB PNG).
- **Corners**: **Perfect square bounding box**. Do NOT pre-round or mask corners (Apple's compositor applies the squircle mask automatically).
- **Appearances (iOS 18+)**:
  - `Default (Light)`: Universal 1024x1024 opaque full-color icon.
  - `Dark`: Universal 1024x1024 opaque dark-themed icon.
  - `Tinted`: Universal 1024x1024 opaque grayscale/monochrome template with clear contrast.

### 3.2. Content Guidelines
- No Apple hardware mockups (no device bezels or Home buttons).
- No Apple trademarks or copyrighted symbols.
- No promotional badges ("Free", "50% Off", "Best App").
- Keep iconography simple and legible down to 20pt notification sizes.

---

## 4. App Store Review Information & Notes (Guideline 2.3)

In App Store Connect's **App Review Information** (Review Notes):
1. **Explain Special Hardware / AI Requirements**: Clearly state if on-device Apple Intelligence is utilized and that manual fallback paths exist.
2. **Provide Test Credentials / Sample Media**: Attach a sample receipt PDF/image in the review attachments so reviewers on simulator or desktop test racks can scan or test OCR immediately.

---

## 5. Audit Checklist Before Upload

1. [ ] `PrivacyInfo.xcprivacy` present in target resources and passes `plutil -lint`.
2. [ ] All `*UsageDescription` strings explain *why* and *how* the data is used.
3. [ ] All hardware features (`VNDocumentCameraViewController.isSupported`) have non-blocking fallbacks.
4. [ ] App icon is 1024x1024, opaque, square, and includes Dark/Tinted variants.
5. [ ] Target device families match tested form factors.
6. [ ] Unit test suite passes 100% green without regressions.
