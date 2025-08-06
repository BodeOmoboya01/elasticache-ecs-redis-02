# Clean up corrupted package-lock.json before committing

Set-Location -Path "app"

# Remove the corrupted package-lock.json
if (Test-Path "package-lock.json") {
    Write-Host "Removing corrupted package-lock.json..." -ForegroundColor Yellow
    Remove-Item "package-lock.json" -Force
}

# Remove backup file if it exists
if (Test-Path "package-lock.json.backup") {
    Write-Host "Removing package-lock.json.backup..." -ForegroundColor Yellow
    Remove-Item "package-lock.json.backup" -Force
}

Write-Host "Cleanup complete!" -ForegroundColor Green
Write-Host ""
Write-Host "Now you can commit the changes:" -ForegroundColor Cyan
Write-Host "git add app/" -ForegroundColor Yellow
Write-Host "git commit -m 'Fix Docker build: use npm install with cache cleanup'" -ForegroundColor Yellow
Write-Host "git push origin main" -ForegroundColor Yellow

Set-Location -Path ".."
