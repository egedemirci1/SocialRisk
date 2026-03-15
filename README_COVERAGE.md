# Test Coverage Görüntüleme Rehberi

## Hızlı Başlangıç

### 1. Coverage Dosyası Oluştur
```bash
flutter test --coverage
```

Bu komut `coverage/lcov.info` dosyasını oluşturur.

### 2. Coverage Yüzdesini Görüntüle

#### Yöntem A: PowerShell Script (Windows)
```powershell
.\view_coverage.ps1
```

#### Yöntem B: Manuel Hesaplama
```powershell
# LCOV dosyasını oku
$lcov = Get-Content coverage\lcov.info -Raw

# Toplam satır sayısı
$total = ([regex]::Matches($lcov, "LF:(\d+)")).Groups | ForEach-Object { [int]$_.Value } | Measure-Object -Sum | Select-Object -ExpandProperty Sum

# Test edilen satır sayısı
$hit = ([regex]::Matches($lcov, "LH:(\d+)")).Groups | ForEach-Object { [int]$_.Value } | Measure-Object -Sum | Select-Object -ExpandProperty Sum

# Yüzde hesapla
$percent = [math]::Round(($hit / $total) * 100, 2)
Write-Host "Coverage: $percent%"
```

### 3. HTML Raporu Oluşturma

#### Linux/Mac (genhtml ile)
```bash
# genhtml yükle (lcov paketi ile gelir)
sudo apt-get install lcov  # Ubuntu/Debian
brew install lcov          # macOS

# HTML raporu oluştur
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html  # macOS
xdg-open coverage/html/index.html  # Linux
```

#### Windows (Online Araçlar)
1. **Coverage Gutters (VS Code Extension)**
   - VS Code'da "Coverage Gutters" extension'ını yükle
   - `coverage/lcov.info` dosyasını aç
   - Coverage yüzdesi kod satırlarının yanında görünür

2. **Online Araçlar**
   - https://coveralls.io
   - https://codecov.io
   - https://codeclimate.com

3. **GitHub Actions ile Otomatik**
   ```yaml
   - name: Generate Coverage
     run: flutter test --coverage
   
   - name: Upload Coverage
     uses: codecov/codecov-action@v3
     with:
       file: ./coverage/lcov.info
   ```

## Coverage Hedefleri

Proje standartlarına göre:
- **Minimum Coverage:** %70
- **Kritik Oyun Mantığı:** %90

## Coverage Dosyası Yapısı

```
coverage/
├── lcov.info          # Ana coverage dosyası
└── html/              # HTML raporu (genhtml ile oluşturulur)
    └── index.html     # Ana rapor sayfası
```

## VS Code Extension Önerileri

1. **Coverage Gutters** - Kod satırlarında coverage gösterir
2. **Coverage Report** - Coverage raporunu görüntüler

## CI/CD Entegrasyonu

GitHub Actions örneği:
```yaml
- name: Run Tests with Coverage
  run: flutter test --coverage

- name: Upload Coverage
  uses: codecov/codecov-action@v3
  with:
    file: ./coverage/lcov.info
    flags: unittests
    name: codecov-umbrella
```
