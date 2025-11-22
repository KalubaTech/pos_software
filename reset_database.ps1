# Database Reset Script for POS Software
# Run this before testing fresh registration

Write-Host "🧹 Cleaning POS Software Databases..." -ForegroundColor Cyan
Write-Host ""

# Function to safely remove items
function Remove-SafeItem {
    param($Path)
    if (Test-Path $Path) {
        try {
            Remove-Item -Path $Path -Recurse -Force -ErrorAction Stop
            Write-Host "✅ Deleted: $Path" -ForegroundColor Green
            return $true
        } catch {
            Write-Host "❌ Failed to delete: $Path" -ForegroundColor Red
            Write-Host "   Error: $_" -ForegroundColor Yellow
            return $false
        }
    } else {
        Write-Host "⏭️  Not found: $Path" -ForegroundColor Gray
        return $true
    }
}

# 1. Clear SQLite Database
Write-Host "1️⃣  Clearing SQLite Database..." -ForegroundColor Yellow
$localAppData = $env:LOCALAPPDATA
$dbPath = "$localAppData\pos_software"

if (Test-Path $dbPath) {
    Get-ChildItem -Path $dbPath -Filter "*.db" | ForEach-Object {
        Remove-SafeItem -Path $_.FullName
    }
    Get-ChildItem -Path $dbPath -Filter "*.db-*" | ForEach-Object {
        Remove-SafeItem -Path $_.FullName
    }
} else {
    Write-Host "⏭️  Database folder not found: $dbPath" -ForegroundColor Gray
}

Write-Host ""

# 2. Clear GetStorage Cache
Write-Host "2️⃣  Clearing GetStorage Cache..." -ForegroundColor Yellow
Get-ChildItem -Path $localAppData -Filter "get_storage*" -Directory | ForEach-Object {
    if ($_.FullName -like "*pos_software*") {
        Remove-SafeItem -Path $_.FullName
    }
}

Write-Host ""

# 3. Search for any other database files
Write-Host "3️⃣  Searching for remaining database files..." -ForegroundColor Yellow
$foundFiles = Get-ChildItem -Path $localAppData -Recurse -Filter "*pos_software*.db" -ErrorAction SilentlyContinue

if ($foundFiles) {
    Write-Host "📋 Found additional database files:" -ForegroundColor Cyan
    $foundFiles | ForEach-Object {
        Write-Host "   📄 $($_.FullName)" -ForegroundColor White
        $confirm = Read-Host "   Delete this file? (Y/N)"
        if ($confirm -eq 'Y' -or $confirm -eq 'y') {
            Remove-SafeItem -Path $_.FullName
        }
    }
} else {
    Write-Host "✅ No additional database files found" -ForegroundColor Green
}

Write-Host ""
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host "🎉 Database cleanup complete!" -ForegroundColor Green
Write-Host ""
Write-Host "📝 Next Steps:" -ForegroundColor Yellow
Write-Host "   1. Restart the app: flutter run -d windows" -ForegroundColor White
Write-Host "   2. Register new business with all fields" -ForegroundColor White
Write-Host "   3. Set PIN: 1122" -ForegroundColor White
Write-Host "   4. Login with PIN: 1122" -ForegroundColor White
Write-Host ""
Write-Host "🔥 Don't forget to clear Firestore in Firebase Console!" -ForegroundColor Red
Write-Host "   Delete the 'businesses' collection for a completely fresh start" -ForegroundColor Yellow
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
