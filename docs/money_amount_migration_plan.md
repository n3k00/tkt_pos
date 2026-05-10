# Money Amount Migration Plan

The app currently stores money as `REAL`/`double` in Drift. UI validation already limits new inputs to whole Kyat, but the database still allows floating point values. Long term, accounting totals should move to integer Kyat columns.

## Target

- Store all money amounts as whole Kyat integers.
- Keep display formatting in the UI layer only.
- Keep payout/report formulas using `PayoutCalculator`.

## Candidate Columns

- `transactions.charges`
- `transactions.cash_advance`
- `drivers.room_fee`
- `drivers.labor_fee`
- `drivers.delivery_fee`
- `drivers.paid_out_amount`
- `driver_payout_history.previous_paid_out_amount`
- `driver_payout_history.new_paid_out_amount`
- history/legacy tables with charge or cash advance snapshots

## Safe Migration Shape

1. Add new nullable integer columns alongside existing double columns, for example `charges_kyat`.
2. Backfill with rounded whole Kyat from existing values.
3. Update application writes to write both old and new columns during one release.
4. Update reads and calculations to prefer integer columns when present.
5. Add migration tests for old database upgrade and formula parity.
6. After at least one production release, remove old double reads.

Do not destructively replace existing money columns in one migration. Existing user data should be migrated with an automatic pre-migration backup.
