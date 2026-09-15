# App Store Review Notes

**App Name**: Receipt Manager  
**Bundle Identifier**: `racllc.receipt-manager`  
**Version**: 1.1.0  
**Target Platform**: iOS 26.0+ (iPhone)

---

## 1. On-Device Privacy & Architecture Overview

* **100% On-Device Processing**: Receipt Manager processes all scanned receipts, optical character recognition (OCR), and structured data extraction **strictly on-device**.
* **Frameworks Used**:
  * **Vision & VisionKit**: Uses `VNDocumentCameraViewController` and `VNRecognizeTextRequest` (.accurate) directly on the device.
  * **Apple Intelligence (`FoundationModels`)**: Structured extraction (`ReceiptExtraction`, `@Generable`, `@Guide`) runs locally using `SystemLanguageModel.default`.
  * **SwiftData**: Local persistence with external binary storage for receipt images (`@Attribute(.externalStorage)`).
* **Zero Cloud Infrastructure**: No user accounts, logins, telemetry, advertising SDKs, or cloud servers are required or utilized.
* **Privacy Manifest**: A complete Apple Privacy Manifest (`PrivacyInfo.xcprivacy`) is included in the application bundle declaring zero tracking (`NSPrivacyTracking: false`).

---

## 2. Reviewer Test Instructions

### Flow A: Physical Receipt Scanning (Camera Supported)
1. Launch **Receipt Manager**.
2. Tap **"Scan Receipt"** on the **Scan** tab.
3. Align the camera over any printed paper receipt (or the sample receipt below) and tap capture / save.
4. The on-device OCR extracts the store name, date, total amount, and return policy automatically into the **Confirm Receipt** sheet.
5. Tap **Save** to store the receipt and schedule local return reminders (3 days and 1 day prior to deadline at 9:00 AM).

### Flow B: Simulator / Unsupported Hardware Fallback
1. If testing on an environment without document camera hardware, tap **"Scan Receipt"**.
2. An alert will appear stating *"Scanner Unavailable — Document scanning is not supported on this device or simulator."*
3. Tap **"Enter Manually"** to open the **Confirm Receipt** sheet directly, enter test data (e.g. Store: *Apple Store*, Total: *$99.00*), and tap **Save**.

### Flow C: Manage, Search, Full-Screen Zoom & Share
1. Navigate to the **Manage** tab.
2. **Search**: Type in the search bar (e.g., *"Apple"* or an item name) to filter receipts in real time.
3. **Filter & Sort**: Use the segmented control (*All / Returns Due / Returned*) and the Sort menu (*Newest / Oldest / Store / Amount*).
4. **Detail & Zoom**: Tap any receipt row to open `ReceiptDetailView`. Tap on the receipt image preview to open the interactive **full-screen pinch-to-zoom** viewer.
5. **Share**: Tap the **Share** button in the top-right toolbar to export the receipt image and formatted summary via `ShareLink`.
6. **Actions**: Swipe leading to mark as returned or swipe trailing to delete.

---

## 3. Sample Test Receipt

You may point your camera at the text below to test automatic recognition:

```text
=======================================
              APPLE STORE
           5th Avenue, New York
             Tel: (212) 555-0199
=======================================
Date: 09/15/2026               14:32:10

1  AirPods Pro (2nd Gen)        $249.00
1  USB-C Woven Cable (1m)        $19.00
---------------------------------------
Subtotal:                       $268.00
Sales Tax (8.875%):              $23.79
=======================================
TOTAL:                          $291.79
=======================================

RETURN POLICY:
Returns and exchanges accepted within
14 days of purchase with original receipt.
Return deadline: 09/29/2026.

Thank you for shopping at Apple!
=======================================
```

---

## 4. Contact & Support
* **Developer Contact**: Ron Abraham Cherian
* **Email**: support@racllc.com
