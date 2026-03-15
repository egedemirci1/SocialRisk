# Firebase Cloud Functions – Kurulum ve Deploy

Bu dokümanda Social Risk projesine Cloud Functions ekleyip canlıya almak için **terminalde izleyeceğin adımlar** özetleniyor.

---

## Ön koşul

- Node.js 18+ yüklü olsun (`node -v`).
- Firebase CLI yüklü olsun:  
  `npm install -g firebase-tools`  
  Giriş: `firebase login`

---

## 1. Proje kökünde Firebase’i bağla (henüz yapmadıysan)

```bash
cd c:\SocialRisk
firebase use socialrisk-9840e
```

(Farklı bir proje kullanıyorsan `firebase use <project-id>` ile seç.)

---

## 2. Functions bağımlılıklarını yükle ve derle

```bash
cd c:\SocialRisk\functions
npm install
npm run build
```

`lib/` altında `index.js` çıkıyorsa derleme tamamdır.

---

## 3. Emülatörde test (isteğe bağlı)

```bash
cd c:\SocialRisk
firebase emulators:start --only functions,firestore
```

Başka bir terminalde Flutter uygulamasını çalıştırıp oyun bitişini dene; emülatörde `onGameUpdated` log’ları görünür.

---

## 4. Canlıya deploy

```bash
cd c:\SocialRisk
firebase deploy --only functions
```

İlk seferde Firebase tarafında Functions’ı etkinleştirmen istenebilir; onayla. Deploy bitince çıktıda şuna benzer bir satır görürsün:

```
✔  functions[onGameUpdated(us-central1)]: Successful create operation.
```

---

## 5. Log’ları izleme

```bash
firebase functions:log
```

Veya [Firebase Console](https://console.firebase.google.com) → Proje → Functions → Logs.

---

## Kısa komut özeti

| Amaç              | Komut |
|-------------------|--------|
| Bağımlılık + build | `cd functions && npm install && npm run build` |
| Sadece deploy     | `firebase deploy --only functions` |
| Emülatör          | `firebase emulators:start --only functions,firestore` |
| Log               | `firebase functions:log` |

---

## Notlar

- **firebase.json** içinde `functions.source` zaten `functions` olarak ayarlı; ekstra `firebase init` gerekmez.
- İlk deploy’da Blaze (ödeme) plana geçmen gerekebilir; Cloud Functions ücretsiz kotası var ama proje Blaze’de olmalı.
- Flutter tarafı artık sadece `status: 'results'` yazıyor; bitiş ve ödül dağıtımı tamamen bu fonksiyonda.
