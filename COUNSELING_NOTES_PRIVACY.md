# Confidential Counseling Notes — Privacy & Security Guide

## Overview

The Confidential Counseling Notes tool is designed for Methodist ministers to securely store and manage pastoral counseling records. This tool prioritizes **privacy, confidentiality, and secure storage** of sensitive pastoral information.

## Privacy & Confidentiality Principles

### 1. **Identity Protection**
- **Initials only**: Client names are never stored in full. Only initials (e.g., "J.S.") are recorded.
- **No identifying metadata**: Phone numbers, email addresses, or other personal identifiers are not collected.
- **Anonymity in backup**: Even if backups are accessed, individual identities cannot be easily determined.

### 2. **Data Minimization**
- Only essential pastoral information is stored:
  - Case type and summary
  - Key issues and scriptural references
  - Action steps and prayer points
  - Follow-up dates
  - Status and personal notes
- No extraneous personal details are required.

### 3. **Access Control**
- **Local device storage**: Notes are stored on your device by default (via Supabase, which encrypts data in transit).
- **Personal use only**: This tool is intended for the minister's sole use. Do not share access credentials.
- **Secure device required**: Keep your device locked and password-protected.

## Security Practices

### Best Practices for Using Counseling Notes

1. **Keep your device secure**
   - Use a strong password or biometric lock.
   - Enable automatic screen lock (e.g., after 5 minutes of inactivity).
   - Use a secure Wi-Fi network (avoid public/open networks).

2. **Manage your Supabase credentials**
   - Counseling data is stored in Supabase, which provides encryption in transit (HTTPS/TLS).
   - Your Supabase credentials (URL, anon key) are stored in `lib/secrets.dart` (gitignored).
   - **Do not commit secrets to git** — use local environment variables or `.gitignore` for sensitive files.
   - If credentials are compromised, regenerate them in your Supabase project settings.

3. **Backup and Data Retention**
   - Supabase automatically backs up your data in a secure, encrypted database.
   - For local backups, export notes periodically to an encrypted external drive.
   - Implement a data retention policy: close cases after pastoral work is complete and delete closed cases after a set period (e.g., 1-2 years) per your church's guidelines.

4. **Handling Sensitive Information**
   - **Scriptures & prayer points**: These are appropriate to record and provide pastoral foundation for your work.
   - **Personal details**: Avoid recording unnecessary personal information (addresses, phone numbers, family member names).
   - **Abuse or safeguarding concerns**: If a case involves abuse or safeguarding risks, follow your church's reporting procedures and consult your superintendent or safeguarding officer. Do not rely solely on these notes for mandatory reporting.

5. **Audit Trail & Monitoring**
   - The app logs when cases are created, updated, and closed.
   - Review the case timestamps to monitor activity.
   - If you suspect unauthorized access, immediately change your Supabase credentials.

## Compliance & Legal Considerations

### Church Data Protection
- **GDPR / Data Protection Laws**: If you operate in jurisdictions with data protection laws (e.g., GDPR in the UK), ensure you comply:
  - Obtain informed consent from individuals about pastoral notes.
  - Allow individuals to request their data (subject access request).
  - Implement data retention schedules and securely delete notes when no longer needed.
- **Church Policies**: Follow your denomination's guidelines (e.g., Methodist Church polity) on pastoral record-keeping.

### Pastoral Privilege
- In some jurisdictions, pastoral communications may be legally privileged.
- Consult your church's legal advisor regarding confidentiality obligations and privilege.
- **Note**: This app provides privacy tools, but does not guarantee legal privilege. Legal privilege depends on jurisdiction and specific circumstances.

### Mandatory Reporting
- If counseling reveals abuse, neglect, or safeguarding concerns, mandatory reporting laws may apply.
- Do not let the confidentiality of these notes delay your response to safeguarding issues.
- Contact your superintendent, safeguarding officer, or relevant authorities immediately.

## Technical Security Details

### Data in Transit
- Supabase uses HTTPS/TLS encryption for all data transmitted between your device and the database.
- Your Supabase credentials (URL, anon key) are sent securely.

### Data at Rest
- Supabase stores data in encrypted databases (PostgreSQL with encryption options).
- Backups are encrypted by Supabase's infrastructure.

### Local App Storage
- Reminders and notifications are stored locally using `flutter_local_notifications`.
- Notification schedules do not contain sensitive counseling details (only the case ID).

### What Is NOT Encrypted in This Version
- **Supabase database**: The current app does not apply client-side encryption on top of Supabase encryption. For highly sensitive environments, you may want to:
  - Add client-side AES encryption for counseling notes (using a package like `encrypt`).
  - Encrypt sensitive fields before sending to Supabase.
  - Manage encryption keys securely (e.g., using Flutter Secure Storage).

## Recommendations for Enhanced Security

1. **Client-Side Encryption** (Optional)
   - If you require maximum confidentiality, implement client-side encryption of notes before sending to Supabase.
   - Use `flutter_secure_storage` to manage encryption keys on your device.
   - Example: encrypt the `summary`, `keyIssues`, `notes` fields with a device-specific or master key.

2. **Access Logs**
   - Enable Supabase audit logs to monitor who accesses the database.
   - Periodically review logs for unauthorized access.

3. **Device Management**
   - Use Mobile Device Management (MDM) if the app is deployed to church staff devices.
   - Enforce screen lock and automatic timeout policies.

4. **Secure Deletion**
   - When deleting a case, Supabase performs soft or hard deletes depending on configuration.
   - For highly sensitive cases, request a manual deletion from Supabase backups (contact Supabase support).

5. **Role-Based Access Control** (Future Feature)
   - Currently, the app assumes solo use by a single minister.
   - If multiple staff members need access, implement role-based access control (e.g., only view closed cases, only edit own cases).

## What to Do If You Suspect a Breach

1. **Immediate Steps**
   - Stop using the app immediately.
   - Change your Supabase credentials (regenerate the anon key in your Supabase dashboard).
   - Change any other passwords associated with your account.

2. **Investigation**
   - Review Supabase audit logs for unauthorized access.
   - Check your device for malware (run antivirus scan).
   - Review your network for suspicious activity.

3. **Notification**
   - Inform your church leadership and superintendent.
   - If individuals' data was compromised, consider notifying affected individuals in accordance with data protection laws.
   - Report to relevant authorities if required by law.

4. **Remediation**
   - Update the app to the latest version.
   - Reset your device if malware is suspected.
   - Restore from a clean backup.

## User Responsibilities

By using the Confidential Counseling Notes tool, you agree to:

- **Keep your device secure**: Maintain a password, enable screen lock, and avoid public Wi-Fi.
- **Protect your credentials**: Do not share your Supabase URL or anon key.
- **Use for legitimate pastoral purposes only**: Store only counseling notes relevant to your ministry.
- **Respect confidentiality**: Do not disclose or share notes with unauthorized parties.
- **Follow church policies**: Adhere to your church's data protection and pastoral care policies.
- **Comply with laws**: Follow mandatory reporting and data protection laws in your jurisdiction.
- **Delete sensitive data**: Regularly review and delete closed cases in accordance with your retention policy.

## Support & Questions

- For technical support (app issues, bugs): Contact the development team or open an issue in the app's repository.
- For pastoral guidance on confidentiality: Consult your superintendent, pastoral supervisor, or church legal advisor.
- For security concerns: Report immediately to your church leadership and the app development team.

---

**Last Updated**: December 2025  
**Version**: 1.0

This guide is provided for informational purposes. It does not constitute legal advice. Consult your church's legal advisor and relevant authorities for jurisdiction-specific guidance on pastoral confidentiality and data protection.
