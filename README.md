TKT POS — Inventory Demo (Flutter + Drift + GetX)

Overview

- Purpose: Desktop‑first POS/inventory sample focused on drivers and parcel transactions with local persistence.
- Platform: Flutter (Windows desktop optimized; runs on other Flutter desktop targets with minor tweaks).
- State: GetX for routing and state, Drift/SQLite for local DB, GetStorage for simple key‑value storage.

Highlights

- GetX navigation and bindings: `lib/app/router/app_pages.dart`, `lib/features/**/bindings`.
- Local database with Drift/SQLite and migrations: `lib/data/local/app_database.dart` (+ tables under `tables/`).
- Inventory UI with driver sections and per‑driver transaction tables: `lib/features/inventory/presentation/pages/inventory_page.dart`.
- Extracted, reusable dialogs and menus: `lib/features/inventory/presentation/dialogs/*`, `lib/features/inventory/presentation/widgets/*`.
- Theming + design tokens: `lib/resources/colors.dart`, `lib/resources/dimens.dart`, `lib/resources/table_widths.dart`.

Getting Started

- Prereqs: Flutter >= 3.22, Dart >= 3.8 (see `pubspec.yaml`).
- Install deps: `flutter pub get`
- Generate code (Drift): `dart run build_runner build --delete-conflicting-outputs`
- Run (Windows desktop): `flutter run -d windows`

Project Structure

- App entry: `lib/main.dart` — sets theme, routes, initializes `window_manager` (desktop), `GetStorage`.
- Routing: `lib/app/router/` — `AppPages` and `Routes` (GetX).
- Data layer: `lib/data/local/`
  - `app_database.dart` — Drift database with schema version and migrations.
  - `tables/` — `app_settings.dart`, `drivers.dart`, `transactions.dart`.
- Features: `lib/features/`
  - `inventory/` — pages, controllers (GetX), bindings, dialogs, widgets.
  - `home/` — home page + binding (entry route).
- Resources: `lib/resources/` — colors, spacing (`dimens.dart`), table column widths.

Database Schema (Drift)

- `drivers` — id (PK), date (DateTime), name (Text).
- `transactions` — id (PK), customer_name (Text? nullable), phone (Text), parcel_type (Text), number (Text),
  charges (Real, default 0.0), payment_status (Text), cash_advance (Real, default 0.0), picked_up (Bool, default false),
  comment (Text? nullable), driver_id (FK -> drivers.id), created_at, updated_at.
- `app_settings` — key (PK, Text), value (Text? nullable).

Key UX Flows

- Drivers: add/edit/delete with confirm‑to‑delete safeguard.
- Transactions: add/edit/delete per driver, live filtering via search box.
- Validation: phone is required when adding/editing a transaction (inline error + SnackBar).

Desktop Window Behavior

- Uses `window_manager` to maximize window and disable minimize/resize (see `lib/main.dart`).

Development Notes

- Codegen: Run build_runner after schema changes.
- Migrations: `schemaVersion` and `MigrationStrategy` in `app_database.dart` handle rebuilds for breaking changes.
- Styling: Use `Dimens` for spacing/paddings and `TableWidths` for DataTable column sizing.
- State: `InventoryController` exposes reactive lists and maps for drivers/transactions and search filtering.

Common Commands

- Get deps: `flutter pub get`
- Generate drift code: `dart run build_runner build --delete-conflicting-outputs`
- Run (desktop): `flutter run -d windows`
- Format (optional): `dart format .`

License

- This repository does not declare a license. Add one if you plan to distribute.

