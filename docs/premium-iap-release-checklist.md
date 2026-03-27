# Premium IAP Release Checklist

This checklist is for the `premium_lifetime` one-time purchase flow.

## 1) Store Product Setup

- Create a non-consumable product with ID `premium_lifetime` in Google Play Console.
- Create a non-consumable product with ID `premium_lifetime` in App Store Connect.
- Set the local price tier (target: 50 TL equivalent per store).
- Complete required store metadata and screenshots.

## 2) App Configuration

- Confirm `in_app_purchase` dependency is resolved (`flutter pub get`).
- Verify app bundle IDs/package names match the store products.
- Verify signed app builds are uploaded to internal tracks (Android) and TestFlight (iOS).

## 3) Backend Configuration

- Deploy Cloud Functions with `activatePremium` and `buyCosmetic`.
- Deploy Firestore rules with premium write restrictions.
- Validate `premiumPurchases` collection is writable by functions (admin context).

## 4) Sandbox Tests

- Android internal testing account:
  - Buy `premium_lifetime` successfully.
  - Confirm `users/{uid}.isPremium == true`.
  - Confirm `premiumSource == play_store`.
- iOS TestFlight sandbox account:
  - Buy `premium_lifetime` successfully.
  - Confirm `users/{uid}.isPremium == true`.
  - Confirm `premiumSource == app_store`.

## 5) Restore Tests

- Reinstall app and sign in with same account.
- Run restore purchases.
- Confirm premium re-activation without duplicate entitlement issues.

## 6) Access Control Tests

- Non-premium user:
  - Cannot create/update/delete `custom_tasks`.
  - Sees locked premium scenario CTA in store.
- Premium user:
  - Can create custom tasks.
  - Can access premium scenarios.

## 7) Security Regression Tests

- Attempt direct client write to `users/{uid}.isPremium` (must fail by rules).
- Attempt direct write to `users/{uid}/custom_tasks/{taskId}` as non-premium (must fail).
- Attempt replay using same purchase token for another user (must fail).

