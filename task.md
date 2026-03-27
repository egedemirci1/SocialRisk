# SocialRisk Project Enhancements & Bug Fixes

## 🛠 Module 1: UI/UX & Onboarding (Focus: Layout, Responsiveness, New Flow)
- [ ] **Voting Screen Typography**
  - [ ] Increase font size of "Critique" and "Voting" labels.
  - [ ] Adjust layout with round numbers for better spacing.
- [ ] **Round Result Screen Layout**
  - [ ] Fix logo positioning (it stays at the top/scrolled).
  - [ ] Remove outer scroll behavior; use internal scrolling for content if needed.
- [ ] **iPhone SE Responsiveness**
  - [ ] Fix task content overflow on "Performing" screen when it's someone else's turn and the question is long.
- [ ] **Onboarding & Terms of Use**
  - [ ] Implement `TermsOfUsePopup` (Premium look).
  - [ ] Add `FirstLaunchGuard` using `SharedPreferences`.
  - [ ] Show toaster after evaluating/liking a scenario ("Scenario liked!").

## 🌎 Module 2: Localization & Economy Mode (Focus: Data, Logic, i18n)
- [ ] **Localization Audit & Fixes**
  - [ ] Translate "Special Content" to English in all relevant screens.
  - [ ] Localize `ExitRoomButton` dialogs and toasters.
  - [ ] Localize "Get Premium" screen and error toasters.
- [ ] **Economy Mode Enhancements**
  - [ ] Fix English localization for questions in Economy mode (ensure `taskPool` and `TaskTranslationMap` work correctly).
  - [ ] Debug category value decrease logic: ensure it works for < 3 categories if requested, or clarify logic.
  - [ ] Fix game freeze in Economy mode when playing with a single category.
- [ ] **Lobby & Store UI**
  - [ ] Rename "Özel" category to "Custom Content" (EN) / "Özel İçerik" (TR).
  - [ ] Lock "Custom Content" for non-premium users with a lock icon.
  - [ ] Show premium toaster when trying to select locked category.

## ⚙️ Module 3: Backend, Admin & Integration (Focus: Cloud Functions, Assets, Protection)
- [ ] **Host Exit Logic Fix**
  - [ ] Update `leaveRoom` to correctly delete the room document and players when the host leaves.
  - [ ] Ensure all players receive the "Host left" toaster (verify `LobbyScreen` and `ActiveGameGuard`).
- [ ] **Premium User Protection**
  - [ ] Create `premium_users` Firestore collection.
  - [ ] Update `FirebaseUserSource` to sync premium status to this collection.
  - [ ] Implement restoration logic (check `premium_users` if profile is missing/corrupted).
- [ ] **Admin Panel Update**
  - [ ] Add a section/table to view and manage Premium Users separately.
- [ ] **`buyCosmetic` 404 Fix**
  - [ ] Verify Firestore `cosmetics` collection exists and contains matching IDs.
  - [ ] Add error handling for missing cosmetic documents in Cloud Functions.
- [ ] **Audio Assets Audit**
  - [ ] Check `assets/audio/sfx/` for missing files mentioned in `AudioService`.
  - [ ] Implement fallbacks for missing audio to prevent errors.
- [ ] **General Stability**
  - [ ] Test the full loop for Custom Deck integration.
  - [ ] Ensure all premium-related toasters are consistent.
  - [ ] Audit and test all game sounds; identify and report missing assets.
- [ ] **Integration & Feature Testing**
  - [ ] Test "Special Scenarios" integration.
  - [ ] Test "Custom Deck" content addition functionality.
