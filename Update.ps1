Add-Type -AssemblyName System.Windows.Forms, System.Drawing
$NotifyIcon = New-Object System.Windows.Forms.NotifyIcon -Property @{
    Icon = [System.Drawing.SystemIcons]::Information
    Visible = $true
}

$StartupLnk = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup\Spicetify AutoUpdate.lnk"
if (-not (Test-Path $StartupLnk)) {
    $Shortcut = (New-Object -ComObject WScript.Shell).CreateShortcut($StartupLnk)
    $Shortcut.TargetPath = "$PSScriptRoot\Spicetify AutoUpdate.bat"
    $Shortcut.WorkingDirectory = $PSScriptRoot
    $Shortcut.Save()
}

if (-not (Get-Command spicetify -ErrorAction SilentlyContinue)) {
    iwr "https://raw.githubusercontent.com/spicetify/cli/main/install.ps1" -UseBasicParsing | iex
}

spicetify backup; spicetify upgrade; spicetify 'backup apply'

$SpicetifyVersion = spicetify -v 2>&1
@('BalloonTipTitle', 'BalloonTipText') | %{ $NotifyIcon.$_ = @('Spicetify AutoUpdate', "Updated to $SpicetifyVersion")[[int]($_ -eq 'BalloonTipText')] }
$NotifyIcon.ShowBalloonTip(3000)
$NotifyIcon.Dispose()