$Object1 = Invoke-RestMethod -Uri 'https://api.reqable.com/version/check?platform=windows&arch=x86_64'

# Version
$Task.CurrentState.Version = $Object1.name

# Installer
$Task.CurrentState.Installer += [ordered]@{
  InstallerUrl = Get-RedirectedUrl1st -Uri 'https://api.reqable.com/download?platform=windows&arch=x86_64' -Headers @{ 'Accept-Language' = 'en' }
}
$Task.CurrentState.Installer += [ordered]@{
  InstallerLocale = 'zh-CN'
  InstallerUrl    = $Object1.url
}

# ReleaseNotes (en-US)
$Task.CurrentState.Locale += [ordered]@{
  Locale = 'en-US'
  Key    = 'ReleaseNotes'
  Value  = $Object1.changelogs.'en-US' | Format-Text
}
# ReleaseNotes (zh-CN)
$Task.CurrentState.Locale += [ordered]@{
  Locale = 'zh-CN'
  Key    = 'ReleaseNotes'
  Value  = $Object1.changelogs.'zh-CN' | Format-Text
}


switch ($Task.Check()) {
  ({ $_ -ge 1 }) {
    try {
      $Object2 = Invoke-RestMethod -Uri "https://api.github.com/repos/reqable/reqable-app/releases/tags/$($Task.CurrentState.Version)"

      # ReleaseTime
      $Task.CurrentState.ReleaseTime = ($Object2.assets | Where-Object -Property name -CMatch '\.exe$').updated_at
    } catch {
      $Task.Logging($_, 'Warning')
    }

    $Task.Write()
  }
  ({ $_ -ge 2 }) {
    $Task.Message()
  }
  ({ $_ -ge 3 }) {
    $Task.Submit()
  }
}
