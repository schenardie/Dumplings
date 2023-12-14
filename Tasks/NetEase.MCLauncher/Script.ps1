$Content = (Invoke-WebRequest -Uri 'https://adl.netease.com/d/g/mc/c/pc?type=pc').Content

# Installer
$Task.CurrentState.Installer += [ordered]@{
  InstallerUrl = $InstallerUrl = [regex]::Match($Content, 'pc_link\s*=\s*"(.+?)"').Groups[1].Value
}

# Version
$Task.CurrentState.Version = [regex]::Match($InstallerUrl, '([\d\.]+)\.exe').Groups[1].Value

switch ($Task.Check()) {
  ({ $_ -ge 1 }) {
    $Task.Write()
  }
  ({ $_ -ge 2 }) {
    $Task.Message()
  }
  ({ $_ -ge 3 }) {
    $Task.Submit()
  }
}
