# Audio Inventory (MVP)

Bu dosya Social Risk için uygulanacak minimum ses setini tanımlar.
Amaç: ilk entegrasyonda oyun akışını kapsayan ~20 SFX ile hızlıca canlıya çıkmak.

## MVP Ses Dosyaları

SFX klasörü: `assets/audio/sfx/`

1. `ui_tap_generic.mp3`
2. `ui_success.mp3`
3. `ui_error.mp3`
4. `lobby_game_start.mp3`
5. `task_card_reveal.mp3`
6. `wheel_spin_start.mp3`
7. `wheel_spin_stop.mp3`
8. `difficulty_confirm.mp3`
9. `performing_timer_warning.mp3`
10. `performing_timer_end.mp3`
11. `waiting_turn_chime.mp3`
12. `vote_like.mp3`
13. `vote_neutral.mp3`
14. `vote_dislike.mp3`
15. `vote_result_like.mp3`
16. `vote_result_neutral.mp3`
17. `vote_result_dislike.mp3`
18. `round_result_show.mp3`
19. `round_next_turn.mp3`
20. `game_over_fanfare.mp3`

## İsteğe Bağlı Müzik (sonraki faz)

Müzik klasörü: `assets/audio/music/`

- `music_menu_loop.mp3`
- `music_lobby_loop.mp3`
- `music_game_loop.mp3`

## Entegrasyon Notu

- Kod tarafında temel servis: `lib/core/audio/audio_service.dart`
- Bu dosyadaki asset isimleri servis enum'ı `AppSfx` ile birebir uyuşur.
- Asset'leri ekledikten sonra `flutter pub get` çalıştırıp hot restart yap.
