# Receipt Manager — Architecture, Plan & Version History

_Last updated: 2026-09-14_

Receipt Manager is a native iOS application built with SwiftUI, SwiftData, Vision OCR, and on-device Apple Intelligence (`FoundationModels`) that allows users to scan paper receipts, automatically extract purchase and return policy details, track return deadlines, search receipts, view and zoom scanned pages, and export receipt summaries.

---

## Version History & Milestones

### **v1.1.0 — App Store Acceptance & Native Feature Boosters (2026-09-14)**
- **Local Return Reminders (`UserNotifications`)**:
  - `NotificationManager` schedules local alerts for upcoming return deadlines (3 days and 1 day prior at 9:00 AM).
  - Automatically cancels or reschedules reminders when receipts are deleted, marked returned, or deadline dates are edited.
- **Search Across Store & OCR (`ManageView`)**:
  - Added `.searchable` support to `ManageView` allowing real-time search queries against both store name and recognized OCR text.
  - Automatically sorts search matches alphabetically by store name.
- **Full-Screen Interactive Zoom (`ZoomableImageView`)**:
  - Tapping any receipt scan in `ReceiptDetailView` presents a full-screen image viewer with smooth pinch-to-zoom, pan, and double-tap zoom gestures via `UIScrollView`.
- **Receipt Share & Export (`ShareLink`)**:
  - Added native iOS `ShareLink` toolbar action in `ReceiptDetailView` to share receipt images alongside formatted text summaries.
- **App Store Review Notes & Submission Documentation**:
  - Created [`APP_STORE_REVIEW_NOTES.md`](file:///Users/roncherian/workspace/receipt%20manager/APP_STORE_REVIEW_NOTES.md) outlining on-device AI architecture, hardware fallback procedures, and sample test receipts for Apple reviewers.

---

### **v1.0.1 — App Store Submission Readiness & Compliance (2026-09-14)**
- **Apple Privacy Manifest**:
  - Added [`PrivacyInfo.xcprivacy`](file:///Users/roncherian/workspace/receipt%20manager/receipt%20manager/PrivacyInfo.xcprivacy) declaring zero tracking (`NSPrivacyTracking: false`) and 100% on-device data processing.
- **Permission Purpose String**:
  - Expanded `INFOPLIST_KEY_NSCameraUsageDescription` to explicitly explain the purpose of camera access under Guideline 5.1.1.
- **Hardware Availability Guard**:
  - Added `VNDocumentCameraViewController.isSupported` check in `ScanView` with an alert fallback allowing manual receipt entry on simulators and unsupported devices (Guideline 2.1).
- **Submission Skill**:
  - Created `ios_app_submission` skill in [`skills/ios_app_submission/SKILL.md`](file:///Users/roncherian/workspace/receipt%20manager/skills/ios_app_submission/SKILL.md).

---

### **v1.0.0 — Core MVP (2026-08-28)**
- **Scan Flow** (`Scan/`):
  - `DocumentCameraView` wrapping `VNDocumentCameraViewController`.
  - `ScanProcessor` running Vision OCR with vertical proximity line clustering.
  - `ReceiptExtractor` / `ReceiptExtraction` on-device Apple Intelligence (`FoundationModels`, `@Generable`/`@Guide`).
  - `ReceiptConfirmSheet` prefilling extracted data with manual editing fallback.
- **Data Model** (`Models/`):
  - `Receipt` (SwiftData `@Model`): store name, purchase date, total amount + currency, return-by date, return completion status, raw OCR text.
  - `ReceiptPage`: ordered scanned page image data with external binary storage.
- **Manage Flow** (`Manage/`):
  - `ManageView`: status filtering (*All / Returns Due / Returned*), multi-field sorting, and store grouping.
  - `ReceiptDetailView`: receipt detail editing and multi-page receipt image carousel.
  - `ReceiptListLogic`: pure Swift filtering, sorting, and grouping engine.
- **Return Date Policy** (`Services/ReturnDatePolicy.swift`):
  - Natural date extraction from receipt text with automatic 30-day fallback.
- **Visual Assets**:
  - 1024x1024 App Icon supporting Light, Dark, and Tinted iOS 18 modes.

---

## Technical Specifications & Architecture

* **UI Framework**: SwiftUI (iOS 26.0+ target, iPhone optimized `TARGETED_DEVICE_FAMILY = 1`).
* **Persistence**: SwiftData with `@Attribute(.externalStorage)` for image data.
* **On-Device OCR**: `VisionKit` (`VNDocumentCameraViewController`) & `Vision` (`VNRecognizeTextRequest`).
* **On-Device LLM Extraction**: `FoundationModels` (`SystemLanguageModel.default`).
* **Notifications**: `UserNotifications` (`UNUserNotificationCenter`).
* **Sharing**: SwiftUI `ShareLink` and `Transferable`.
* **Testing**: Swift Testing framework (`ReceiptFilteringTests`, `ReturnDatePolicyTests`).
