$env:TEMP = "D:\Temp"
$env:TMP = "D:\Temp"
$env:Path += ";D:\UNI\Tools\Flutter\flutter\bin"

$adb = "C:\Users\Dell\AppData\Local\Android\Sdk\platform-tools\adb.exe"
Write-Host "Restarting ADB..." -ForegroundColor Cyan
& $adb kill-server | Out-Null
Start-Sleep -Seconds 3
& $adb start-server | Out-Null
Start-Sleep -Seconds 2

Write-Host "Running Flutter app..." -ForegroundColor Green
Set-Location $PSScriptRoot
flutter run
