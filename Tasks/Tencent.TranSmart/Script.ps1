$Object = Invoke-RestMethod -Uri 'https://transmart.qq.com/api/resourcemanageserver/findAllClientVersion' -Method Post -Body (
  @{
    value = 'TranSmart'
  } | ConvertTo-Json -Compress
) -ContentType 'application/json'

# Version
$Task.CurrentState.Version = [regex]::Match($Object.value.windows[0].version, '(Alpha[\d\.]+)').Groups[1].Value

# Installer
$Task.CurrentState.Installer += [ordered]@{
  InstallerUrl = $Object.value.windows[0].url.Replace('dldir1.qq.com', 'dldir1v6.qq.com')
}

# ReleaseTime
$Task.CurrentState.ReleaseTime = $Object.value.windows[0].publish_time | Get-Date | ConvertTo-UtcDateTime -Id 'China Standard Time'

# ReleaseNotes (zh-CN)
$Task.CurrentState.Locale += [ordered]@{
  Locale = 'zh-CN'
  Key    = 'ReleaseNotes'
  Value  = $Object.value.windows[0].describe_content | Format-Text
}

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
