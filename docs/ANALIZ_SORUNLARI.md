# Flutter Analyze — Tespit Edilen Sorunlar

**Tarih:** 7 Mart 2025  
**Komut:** `flutter analyze --no-pub`  
**Toplam:** 66 sorun (1 lib error, 4 test error, 24 warning, 37 info)

---

## Kritik: Hatalar (error) — 5 adet

Bu sorunlar derlemeyi/analizi kırmaz ama “error” seviyesinde işaretlenmiş; düzeltilmesi gerekir.

### 1. Lib — Web splash kaldırıcı

| Dosya | Satır | Mesaj |
|-------|-------|--------|
| `lib/core/utils/splash_remover_web.dart` | 1 | `dart:html` deprecated; `package:web` ve `dart:js_interop` kullanılmalı |
| `lib/core/utils/splash_remover_web.dart` | 1 | Web-only kütüphane Flutter web eklentisi dışında kullanılmamalı |
| `lib/core/utils/splash_remover_web.dart` | 6 | **error:** `Window` tipinde `callMethod` metodu yok (undefined_method) |

**Özet:** Web’de native splash’ı kaldırmak için `dart:html` ve `callMethod` kullanılıyor; Dart 3 / yeni web API’de bu kaldırıldı. `package:web` + `dart:js_interop` ile yeniden yazılmalı.

---

### 2. Test — Integration test

| Dosya | Satır | Mesaj |
|-------|-------|--------|
| `test/integration/app_flow_test.dart` | 3 | `integration_test` paketi proje bağımlılığı değil (depend_on_referenced_packages) |
| `test/integration/app_flow_test.dart` | 3 | **error:** `package:integration_test/integration_test.dart` bulunamadı (uri_does_not_exist) |
| `test/integration/app_flow_test.dart` | 7 | **error:** `IntegrationTestWidgetsFlutterBinding` tanımsız (undefined_identifier) |
| `test/integration/app_flow_test.dart` | 20 | **error:** `Finder` tipinde `or` metodu yok (undefined_method) |
| `test/integration/app_flow_test.dart` | 20 | **error:** `find.byType(MaterialApp).or(...)` argüman tipi uyumsuz (argument_type_not_assignable) |

**Özet:** Integration testi `integration_test` paketine ve eski Finder API’sine dayanıyor. Ya `pubspec.yaml`’a `integration_test` eklenip test güncellenecek ya da bu test devre dışı bırakılacak / silinecek.

---

## Uyarılar (warning) — 24 adet

### Kullanılmayan import (unused_import) — 16 adet

| Dosya | Import |
|-------|--------|
| `lib/features/admin/presentation/admin_dashboard_screen.dart` | `../../../shared/utils/toast_utils.dart` |
| `lib/features/auth/presentation/profile_screen.dart` | `toast_utils.dart` (ayrıca **duplicate**: 9 ve 10. satırda iki kez) |
| `lib/features/game/presentation/economy_pick_screen.dart` | `package:google_fonts/google_fonts.dart` |
| `lib/features/game/presentation/game_over_screen.dart` | `package:google_fonts/google_fonts.dart` |
| `lib/features/game/presentation/performing_screen.dart` | `package:google_fonts/google_fonts.dart` |
| `lib/features/game/presentation/round_result_screen.dart` | `package:google_fonts/google_fonts.dart` |
| `lib/features/game/presentation/widgets/turn_counter_badge.dart` | `package:google_fonts/google_fonts.dart` |
| `lib/features/room/presentation/lobby_screen.dart` | `package:google_fonts/google_fonts.dart` |
| `lib/shared/widgets/buttons/exit_room_button.dart` | `package:google_fonts/google_fonts.dart` |
| `lib/shared/widgets/buttons/stage_button.dart` | `../../../core/constants/app_colors.dart` |
| `lib/shared/widgets/common/custom_frame_painter.dart` | `../../../core/constants/app_colors.dart` |
| `lib/shared/widgets/common/player_avatar.dart` | `dart:math` |
| `lib/shared/widgets/common/theater_loading_screen.dart` | `package:google_fonts/google_fonts.dart` |
| `lib/shared/widgets/common/themed_background.dart` | `../../../core/constants/app_colors.dart` |
| `lib/shared/widgets/guards/active_game_guard.dart` | `../../../core/constants/app_colors.dart` |
| `lib/shared/widgets/voting/voting_panel.dart` | `package:google_fonts/google_fonts.dart` |
| `test/unit/user_model_test.dart` | `package:social_risk/features/auth/domain/user_entity.dart` |

### Duplicate import — 1 adet

| Dosya | Açıklama |
|-------|----------|
| `lib/features/auth/presentation/profile_screen.dart` | `toast_utils.dart` 9 ve 10. satırda iki kez import edilmiş |

### Kullanılmayan alan / eleman — 3 adet

| Dosya | Satır | Açıklama |
|-------|-------|----------|
| `lib/features/auth/presentation/profile_screen.dart` | 612 | `_handleSignOut` hiçbir yerde kullanılmıyor (unused_element) |
| `lib/features/room/presentation/join_room_screen.dart` | 27 | `_controllers` alanı kullanılmıyor (unused_field) |
| `lib/features/room/presentation/join_room_screen.dart` | 31 | `_focusNodes` alanı kullanılmıyor (unused_field) |

### Gereksiz null kontrolü / operatör — 3 adet

| Dosya | Satır | Açıklama |
|-------|-------|----------|
| `lib/features/auth/presentation/login_screen.dart` | 142 | Operand zaten null olamaz; koşul her zaman true (unnecessary_null_comparison) |
| `lib/features/auth/presentation/login_screen.dart` | 142 | Alıcı null olamayacağı için `!` etkisiz (unnecessary_non_null_assertion) |
| `lib/features/room/presentation/home_screen.dart` | 206 | Alıcı null olamayacağı için `?.` gereksiz (invalid_null_aware_operator) |

### Gereksiz cast — 1 adet

| Dosya | Satır |
|-------|--------|
| `lib/features/room/presentation/lobby_screen.dart` | 167 |

---

## Bilgi (info) — 37 adet

### Deprecated: `withOpacity` → `.withValues()`

**Mesaj:** `withOpacity` kullanılmamalı; hassasiyet kaybını önlemek için `.withValues()` kullanılmalı.

| Dosya | Satırlar |
|-------|----------|
| `lib/core/theme/app_theme.dart` | 58, 79, 99 |
| `lib/shared/widgets/common/custom_frame_painter.dart` | 61, 66, 70, 101, 126, 128, 133, 162, 184, 218, 223, 311 |
| `lib/shared/widgets/common/loading_overlay.dart` | 24 |

### Deprecated: Diğer

| Dosya | Satır | Açıklama |
|-------|-------|----------|
| `lib/features/profile/presentation/custom_deck_editor_screen.dart` | 116 | Form alanında `value` deprecated; `initialValue` kullanılmalı (v3.33.0+). |

### Stil / kalite

| Kural | Dosya | Açıklama |
|-------|--------|----------|
| `dangling_library_doc_comments` | `lib/core/data/seeded_tasks/seeded_tasks.dart` | 1 | Sarkan kütüphane doc yorumu |
| `unnecessary_nullable_for_final_variable_declarations` | `lib/features/auth/constants/auth_constants.dart` | 5 | Tip non-nullable olabilir |
| `unnecessary_string_interpolations` | `lib/features/auth/presentation/login_screen.dart` | 141 | Gereksiz string interpolasyonu |
| `prefer_final_fields` | `lib/features/room/presentation/create_room_screen.dart` | 33 | `_selectedCategories` final yapılabilir |
| `use_super_parameters` | `lib/shared/widgets/common/loading_overlay.dart` | 10 | `key` super parametre olabilir |

### BuildContext / async

| Dosya | Satırlar | Açıklama |
|-------|----------|----------|
| `lib/features/room/presentation/lobby_screen.dart` | 175, 178 | Async boşluktan sonra `BuildContext` kullanımı; “mounted” ile korunmuş olsa da ilgili bağlamla eşleşmiyor (use_build_context_synchronously). |

### Akış kontrolü: süslü parantez (curly_braces_in_flow_control_structures)

**Mesaj:** `if` gövdesi blok (süslü parantez) içinde olmalı.

| Dosya | Satırlar |
|-------|----------|
| `lib/shared/widgets/common/custom_frame_painter.dart` | 84, 85, 145, 146, 202, 203, 242, 243, 324, 325 |

---

## Özet tablo

| Tür | Sayı | Öncelik |
|-----|------|---------|
| **error** (lib) | 1 | Yüksek — Web splash |
| **error** (test) | 4 | Orta — Integration test |
| **warning** | 24 | Orta — Import/alan/null/cast |
| **info** | 37 | Düşük — Deprecated, stil, context |

---

## Önerilen sıra

1. **Hemen:** `lib/core/utils/splash_remover_web.dart` — `dart:html` / `callMethod` yerine `package:web` + `dart:js_interop` kullanımı.
2. **Kısa vadede:** Tüm **unused_import** ve **duplicate import** temizliği; **unused_element** / **unused_field** kaldırma veya kullanma; **login_screen** ve **home_screen** null/`!`/`?.` düzeltmeleri.
3. **Integration test:** Ya `integration_test` eklenip test güncellenir ya da test kaldırılır / skip edilir.
4. **İsteğe bağlı:** `withOpacity` → `.withValues()`, form `value` → `initialValue`, `curly_braces`, `prefer_final_fields`, `use_super_parameters`, `use_build_context_synchronously` (lobby_screen).

Bu liste `flutter analyze` çıktısına göre hazırlanmıştır; düzeltmeleri yaptıkça tekrar `flutter analyze` çalıştırarak ilerleyebilirsin.
