Add-Type -AssemblyName System.Windows.Forms, System.Drawing
$NotifyIcon = New-Object System.Windows.Forms.NotifyIcon
$NotifyIcon.Icon = [System.Drawing.SystemIcons]::Information
$NotifyIcon.Visible = $true

$StartupLnk = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup\Spicetify AutoUpdate.lnk"
if (-not (Test-Path $StartupLnk)) {
    $Shell = New-Object -ComObject WScript.Shell
    $Shortcut = $Shell.CreateShortcut($StartupLnk)
    $Shortcut.TargetPath = "$PSScriptRoot\Spicetify AutoUpdate.bat"
    $Shortcut.WorkingDirectory = $PSScriptRoot
    $Shortcut.Save()
}

if (-not (Get-Command spicetify -ErrorAction SilentlyContinue)) {
    Invoke-WebRequest "https://raw.githubusercontent.com/spicetify/cli/main/install.ps1" -UseBasicParsing | Invoke-Expression
}

spicetify backup   *> $null
spicetify upgrade  *> $null
spicetify backup apply *> $null

$SpicetifyVersion = (spicetify -v 2>$null).Trim()
$NotifyIcon.BalloonTipTitle = "Spicetify AutoUpdate"
$NotifyIcon.BalloonTipText = "Updated to $SpicetifyVersion"
$NotifyIcon.ShowBalloonTip(3000)
$NotifyIcon.Dispose()