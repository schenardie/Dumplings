$Object = Invoke-WebRequest -Uri "https://fanyiapp.cdn.bcebos.com/fanyi-client/update/latest.yml?noCache=$((New-Guid).Guid.Split('-')[0])" | Read-ResponseContent | ConvertFrom-Yaml

# Version
$Task.CurrentState.Version = $Object.version

# Installer
$Task.CurrentState.Installer += [ordered]@{
  InstallerUrl = $Object.files[0].url
}

# ReleaseTime
$Task.CurrentState.ReleaseTime = [datetime]::ParseExact(
  $Object.releaseDate,
  "ddd MMM dd yyyy HH:mm:ss 'GMT'K '(GMT'K')'",
  [cultureinfo]::GetCultureInfo('en-US')
).ToUniversalTime()

# ReleaseNotes (zh-CN)
$Task.CurrentState.Locale += [ordered]@{
  Locale = 'zh-CN'
  Key    = 'ReleaseNotes'
  Value  = $Object.detail | Format-Text | ConvertTo-UnorderedList
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
