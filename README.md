# ERP Mobile — Customers, Vendors & Invoices

Includes the original Splash, Login, Dashboard, Modules and module placeholders.

## New features
- Add customer form with validation and local persistence
- Customer list
- Add vendor form with validation and local persistence
- Vendor list
- Create invoice with customer picker, multiple items, tax, due date, and calculated totals
- Invoice list
- Dashboard quick action buttons navigate to the new forms, View All opens invoices

## Install into your existing Flutter project
1. Back up your existing `lib/` and `pubspec.yaml`.
2. Replace them with the `lib/` folder and `pubspec.yaml` from this archive.
3. In Android Studio terminal: `flutter pub get` then `flutter run`.
4. Add at least one customer before creating an invoice.

## Data warning
This uses `shared_preferences` for **local demonstration only**. It is not secure multiuser ERP storage. Data stays on this device and may be lost if the app is removed or its data is cleared. Production will require an authenticated backend and transactional database.

## Technical notes
- No live authentication or server invoices yet.
- Dashboard totals and charts remain illustrative sample data.
- All new screens and services are in separate Dart files.
