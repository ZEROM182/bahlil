$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if (-not $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
 Write-Host "elevasi (UAC)..." -ForegroundColor Yellow
 
 $scriptPath = $MyInvocation.MyCommand.Definition
 
 try {

 Start-Process -FilePath "cmd.exe" -Verb RunAs
 
 Write-Host "a" -ForegroundColor Cyan
 Write-Host "Silakan jalankan perintah berikut secara manual di jendela CMD admin tersebut:" -ForegroundColor Cyan
 Write-Host "powershell -ExecutionPolicy Bypass -File"$scriptPath"" -ForegroundColor White
 
 exit
 }
 catch {
 Write-Host "a" -ForegroundColor Red
 Read-Host "aar"
 exit 1
 }
}