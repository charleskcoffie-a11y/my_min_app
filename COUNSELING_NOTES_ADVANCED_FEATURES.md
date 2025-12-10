# Counseling Notes: Advanced Features Guide

This document describes the advanced features added to the Confidential Counseling Notes tool: client-side encryption, role-based access control, PDF export, advanced filtering, and integration with the Counselling Screen.

---

## 1. Client-Side Encryption

### Overview
All sensitive counseling case data (summary, key issues, and notes) is encrypted on your device using AES-256 encryption before being sent to Supabase. This ensures maximum privacy even if your database is compromised.

### How It Works

#### EncryptionService (`lib/core/encryption_service.dart`)
- **Initialization**: On first app launch, a 256-bit AES key and 16-byte initialization vector (IV) are generated and stored securely using `flutter_secure_storage`.
- **Encryption**: When a case is created or updated, the sensitive fields (`summary`, `key_issues`, `notes`) are encrypted using AES-CBC mode before being sent to Supabase.
- **Decryption**: When cases are retrieved, encrypted fields are decrypted on-device for display. Unencrypted fields (initials, case type, dates, status) remain visible and searchable.

#### Secure Key Storage
- The encryption key and IV are stored in the device's secure storage:
  - **Android**: Uses Android Keystore
  - **iOS**: Uses Keychain
- Keys are never logged or exposed in plain text.

### Usage

In the repository, use the EncryptionService to encrypt/decrypt case data:

```dart
final encryption = EncryptionService();
await encryption.init(); // Call once at app startup

// Encrypt case data before sending to DB
final encryptedData = encryption.encryptCaseData(caseMap);

// Decrypt case data when retrieving from DB
final decryptedData = encryption.decryptCaseData(retrievedMap);
```

### When to Enable Client-Side Encryption

**Recommended for:**
- Highly sensitive counseling cases
- Cases involving abuse, mental health, or safeguarding concerns
- Cases with explicit consent from the individual

**Optional for:**
- Administrative/tracking purposes
- Cases with general pastoral guidance

### Limitations & Considerations

- **Search**: Once encrypted, sensitive fields cannot be searched directly in Supabase. You must decrypt all cases in-app to search.
- **Performance**: Encryption/decryption adds a small computational overhead (typically <100ms per case).
- **Key Loss**: If you reset your device or uninstall the app without backing up your encryption key, encrypted data becomes unreadable. Export important cases before resetting.

### Implementation in Code

To enable encryption in the repository:

```dart
// In CounselingRepository.createCase()
if (followUpReminder != null) {
  final encryptedData = EncryptionService().encryptCaseData({
    'summary': summary,
    'key_issues': keyIssues,
    'notes': notes,
  });
  // Insert encryptedData into DB
}
```

---

## 2. Role-Based Access Control (RBAC)

### Overview
Multiple staff members can manage counseling cases with different permission levels. Each user has a role that determines what they can view, create, edit, delete, and export.

### Roles & Permissions

| Role      | Permissions                                                  |
| --------- | ------------------------------------------------------------ |
| Admin     | All permissions + manage staff + view all cases             |
| Supervisor| View, create, edit, delete, export, view all cases         |
| Counselor | View own cases, create, edit, export                        |

### User & Role Models (`lib/models/user_role.dart`)

```dart
class UserRole {
  final String id;         // 'admin', 'supervisor', 'counselor'
  final String name;       // Display name
  final List<String> permissions; // e.g., ['view', 'create', 'edit']
  
  bool hasPermission(String permission) => permissions.contains(permission);
}

class StaffMember {
  final String id;
  final String name;
  final String email;
  final UserRole role;
  final DateTime createdAt;
  final bool isActive;
  // ...
}
```

### Staff Management Screen (`lib/features/counseling_notes/staff_management_screen.dart`)

**Access**: Tap the staff icon (👥) in the Counseling Notes header.

**Features:**
- Add new staff members with name, email, and role
- View all active staff
- Deactivate staff (soft delete, not permanent)
- Edit staff member details (placeholder for extension)

### Supabase Schema for Staff

```sql
CREATE TABLE staff_members (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  email text NOT NULL,
  role text DEFAULT 'counselor', -- 'admin', 'supervisor', 'counselor'
  created_at timestamp DEFAULT now(),
  is_active boolean DEFAULT true
);
```

### Implementation Notes

- **Current Auth**: The app currently assumes the logged-in user is the only accessor. To enforce RBAC, integrate Supabase Auth and Row-Level Security (RLS) policies.
- **Future Enhancement**: Add RLS policies to Supabase to restrict case visibility by role:
  - Counselors see only their own cases
  - Supervisors see all cases
  - Admins manage staff and audit logs

---

## 3. PDF Export Functionality

### Overview
Export individual cases or filtered case reports to PDF with professional formatting, timestamps, and confidentiality warnings.

### PDF Export Service (`lib/core/pdf_export_service.dart`)

```dart
class PdfExportService {
  static Future<pw.Document> generateCaseReport(CounselingCase case_) async {
    // Generates a formatted PDF document for a single case
  }
}
```

### PDF Contents
- Case header with initials and case type
- Confidentiality warning
- All case details (summary, key issues, scriptures, action steps, prayer points, notes)
- Timeline (created, follow-up, closed dates)
- Footer with page numbers and generation timestamp

### How to Export

#### Export Single Case
1. Open a counseling case detail
2. Tap menu → "Export PDF"
3. Choose to print, save, or email the PDF

#### Export Filtered Cases
1. Open "Advanced Filters & Analytics"
2. Apply filters (case type, status, date range)
3. Click "Export PDF"
4. All filtered cases are merged into a single PDF document

#### From Counseling Notes List
- (Planned) Add "Export All" button to export all cases at once

### Using the `printing` Package

The app uses the `printing` package to handle PDF generation and platform-specific printing/saving:

```dart
import 'package:printing/printing.dart';

final doc = await PdfExportService.generateCaseReport(case_);
await Printing.layoutPdf(onLayout: (_) async => doc.save());
// User can then print, save to file, or email
```

### PDF Security Considerations

- **File Storage**: PDFs exported to your device are saved in your Downloads or Documents folder. Ensure your device is password-protected.
- **Email**: If emailing PDFs, use encrypted email (S/MIME) or password-protected archives.
- **Sharing**: Do not share PDFs with unauthorized parties. Clearly mark as "CONFIDENTIAL".
- **Deletion**: Regularly delete exported PDFs from your device after archiving securely.

### Customizing PDF Layout

To customize the PDF template, edit `PdfExportService`:

```dart
// Add your church letterhead, logo, footer, etc.
doc.addPage(
  pw.Page(
    build: (context) => pw.Column(children: [
      pw.Image(imageBytes), // Add your logo
      pw.Text('Your Church Name'),
      // ... rest of content
    ]),
  ),
);
```

---

## 4. Advanced Filtering & Analytics

### Overview
Filter counseling cases by multiple criteria (case type, status, date range) and view analytics/statistics across your caseload.

### Advanced Filter Screen (`lib/features/counseling_notes/advanced_filter_screen.dart`)

**Access**: Tap the filter icon (🔽) in the Counseling Notes header.

**Features:**
- Filter by case type (Marriage, Family, Addiction, etc.)
- Filter by status (Open, In Progress, Closed)
- Filter by follow-up date range
- Reset filters
- View results sorted by follow-up date

### Analytics Dashboard

Displays key metrics:
- **Total Cases**: Count of all cases in database
- **Open**: Count of open cases
- **In Progress**: Count of cases in progress
- **Closed**: Count of closed cases
- **Due for Follow-up**: Cases past their follow-up date
- **Cases by Type**: Breakdown of cases by case type (Marriage, Family, etc.)

### Advanced Filter Service (`lib/core/advanced_filter_service.dart`)

Core filtering and analysis functions:

```dart
class AdvancedFilterService {
  static List<CounselingCase> applyFilters(
    List<CounselingCase> cases,
    AdvancedFilterOptions options,
  ) => /* filtered list */;

  static Map<String, List<CounselingCase>> groupByCaseType(cases) => /* grouped map */;
  static Map<String, List<CounselingCase>> groupByStatus(cases) => /* grouped map */;
  static List<CounselingCase> getDueForFollowUp(cases) => /* overdue cases */;
  static CounselingCase? getOldestOpenCase(cases) => /* oldest case */;
  // ... more utilities
}
```

### Filter Options

```dart
class AdvancedFilterOptions {
  final String? caseType;      // e.g., 'Marriage'
  final String? status;        // e.g., 'Open'
  final DateRange? dateRange;  // e.g., Dec 1 - Dec 31, 2025
}

class DateRange {
  final DateTime start;
  final DateTime end;
  bool isInRange(DateTime date) => /* true if date is within range */;
}
```

### Use Cases

**Example 1: Review all overdue follow-ups**
- Filter: Status = "Open"
- View: "Due for Follow-up" metric
- Action: Create action plan for pending cases

**Example 2: Analyze case type distribution**
- No filters (show all cases)
- View: "Cases by Type" breakdown
- Action: Identify resource gaps (e.g., if addiction cases are high, add support)

**Example 3: Export cases closed this month**
- Filter: Status = "Closed", Date Range = This month
- Action: Export to PDF for monthly reporting

---

## 5. Integration with Counselling Screen

### Overview
The Counselling Screen now links directly to the Confidential Counseling Notes tool, making it easy to access structured case management from the main Counselling tab.

### Integration Points

#### In Counselling Screen (`lib/features/counselling/counselling_screen.dart`)

The screen now displays:
- A button labeled "Open Counseling Notes"
- A brief description of the tool
- Navigation to the full Counseling Notes screen

```dart
ElevatedButton.icon(
  onPressed: () {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const CounselingNotesScreen()),
    );
  },
  icon: const Icon(Icons.note_outlined),
  label: const Text('Open Counseling Notes'),
)
```

#### Bi-Directional Flow

1. **From Counselling tab** → Open Counseling Notes tool
2. **From Notes tool** → (Planned) Link to related counselling resources or AI-powered suggestions from `GeminiService`

### Future Enhancement Ideas

- **AI Case Summaries**: Use GeminiService to generate AI-powered summaries of case notes (with user review/approval)
- **Suggested Prayer Points**: AI suggests prayer focuses based on case description
- **Pastoral Recommendations**: AI suggests relevant scriptures or pastoral interventions
- **Follow-up Reminders**: Integrate with notification system for automatic reminders

---

## Deployment Checklist

### Required Dependencies
Add to `pubspec.yaml`:
```yaml
flutter_secure_storage: ^9.0.0
encrypt: ^5.0.0
pdf: ^3.10.0
printing: ^5.11.0
```

### Supabase Schema
Create these tables:

```sql
-- Counseling cases (already created)
CREATE TABLE counseling_cases (
  id uuid PRIMARY KEY,
  person_initials text,
  case_type text,
  summary text,
  key_issues text,
  scriptures_used text,
  action_steps text,
  prayer_points text,
  follow_up_date timestamp,
  follow_up_reminder timestamp,
  status text,
  is_encrypted boolean DEFAULT false,
  created_at timestamp,
  closed_at timestamp,
  notes text
);

-- Staff management
CREATE TABLE staff_members (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  email text NOT NULL,
  role text DEFAULT 'counselor',
  created_at timestamp DEFAULT now(),
  is_active boolean DEFAULT true
);
```

### Platform-Specific Setup

#### Android
- Add to `AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" /> <!-- for PDF export on some printers -->
```

#### iOS
- Ensure `Info.plist` includes:
```xml
<key>NSLocalNetworkUsageDescription</key>
<string>This app uses local network for printing.</string>
<key>NSBonjourServices</key>
<array>
  <string>_ipp._tcp</string>
</array>
```

### Testing Checklist

- [ ] Encryption: Create a case, verify it's encrypted in Supabase
- [ ] Decryption: Retrieve case in app, verify decryption works
- [ ] PDF Export: Export a case to PDF, verify formatting
- [ ] Advanced Filters: Apply filters, verify correct results
- [ ] Role-Based Access: Add staff member, verify permissions
- [ ] Integration: Navigate from Counselling tab to Notes, verify flow

---

## Security Best Practices

1. **Encryption Keys**: Back up your device's encryption key somewhere safe (e.g., password-protected external drive).
2. **Device Security**: Always use a strong password/biometric lock on your device.
3. **Network Security**: Avoid public Wi-Fi when accessing counseling records.
4. **Data Retention**: Delete closed cases annually per your church policy.
5. **Audit Logs**: (Planned) Enable Supabase audit logging to track all access.
6. **Staff Training**: Ensure all staff are trained on confidentiality and data handling.

---

## Troubleshooting

### Encryption Errors
- **"Decryption failed"**: The encrypted data may be corrupted or encrypted with a different key. Export the raw data from Supabase and attempt manual recovery.
- **"Key not found"**: Your secure storage may have been reset. Restore from a backup if available.

### PDF Export Issues
- **"Print not available on this device"**: Ensure the `printing` package is properly initialized. Check device print services settings.
- **"PDF too large"**: Exporting many large cases may exceed memory limits. Export in smaller batches.

### Role-Based Access Issues
- **"Staff member not added"**: Verify the Supabase table exists and you have insert permissions.
- **"Role not recognized"**: Check that the role value ('admin', 'supervisor', 'counselor') is correct.

---

## Future Enhancements

1. **Audit Logging**: Track who accessed/modified each case
2. **Case Templates**: Pre-built templates for common case types
3. **Bulk Export**: Export all cases in Supabase to encrypted backup
4. **Case Linking**: Link related cases (e.g., marriage counseling + family counseling for same person)
5. **Workflow Automation**: Automatically move cases from "Open" to "In Progress" after first follow-up
6. **Analytics Dashboard**: Monthly/yearly reports on case volume, outcomes, resolution times
7. **Mobile Notifications**: Push notifications for upcoming follow-ups
8. **Offline Mode**: Sync counseling cases when network becomes available

---

## Support & Questions

For technical support or to report security issues, contact the development team. For pastoral guidance on case management, consult your superintendent or pastoral supervisor.

**Last Updated**: December 2025  
**Version**: 2.0 (Advanced Features)
