# Coverage: unit + widget testleri çalıştırır, sonra özet yüzde gösterir.
# Kullanım: .\tool\coverage.ps1   veya   pwsh -File tool/coverage.ps1
Set-Location $PSScriptRoot\..

Write-Host "Running: flutter test --coverage ..." -ForegroundColor Cyan
flutter test --coverage
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

if (Test-Path "coverage\lcov.info") {
  Write-Host "`nCoverage summary:" -ForegroundColor Cyan
  dart run tool/coverage_summary.dart
} else {
  Write-Host "coverage/lcov.info bulunamadi." -ForegroundColor Yellow
}
