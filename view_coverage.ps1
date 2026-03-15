# Flutter Test Coverage Görüntüleme Script'i
# Kullanım: .\view_coverage.ps1

Write-Host "Test coverage hesaplanıyor..." -ForegroundColor Cyan
flutter test --coverage

if (Test-Path "coverage\lcov.info") {
    Write-Host "`nCoverage dosyası oluşturuldu: coverage\lcov.info" -ForegroundColor Green
    
    # LCOV dosyasını oku ve özet çıkar
    $lcovContent = Get-Content "coverage\lcov.info" -Raw
    
    # Toplam satır sayısı (LF: ile başlayan değerler)
    $totalLines = 0
    $lfPattern = "LF:(\d+)"
    $lfMatches = [regex]::Matches($lcovContent, $lfPattern)
    foreach ($match in $lfMatches) {
        if ($match.Success) {
            $capturedValue = $match.Groups[1].Value
            $totalLines += [int]$capturedValue
        }
    }
    
    # Test edilen satır sayısı (LH: ile başlayan değerler)
    $hitLines = 0
    $lhPattern = "LH:(\d+)"
    $lhMatches = [regex]::Matches($lcovContent, $lhPattern)
    foreach ($match in $lhMatches) {
        if ($match.Success) {
            $capturedValue = $match.Groups[1].Value
            $hitLines += [int]$capturedValue
        }
    }
    
    if ($totalLines -gt 0) {
        $coveragePercent = [math]::Round(($hitLines / $totalLines) * 100, 2)
        Write-Host "`n=== COVERAGE ÖZET ===" -ForegroundColor Yellow
        Write-Host "Toplam Satır: $totalLines" -ForegroundColor White
        Write-Host "Test Edilen: $hitLines" -ForegroundColor Green
        Write-Host "Coverage: $coveragePercent%" -ForegroundColor $(if ($coveragePercent -ge 70) { "Green" } else { "Red" })
        Write-Host "===================" -ForegroundColor Yellow
    } else {
        Write-Host "Coverage verisi bulunamadı!" -ForegroundColor Red
    }
    
    Write-Host "`nHTML raporu için:" -ForegroundColor Cyan
    Write-Host "1. https://htmlpreview.github.io/?https://raw.githubusercontent.com/your-repo/coverage/lcov-report/index.html" -ForegroundColor Gray
    Write-Host "2. Veya VS Code'da 'Coverage Gutters' extension'ını kullan" -ForegroundColor Gray
    Write-Host "3. Veya online: https://coveralls.io veya https://codecov.io" -ForegroundColor Gray
} else {
    Write-Host "Coverage dosyası oluşturulamadı!" -ForegroundColor Red
}
