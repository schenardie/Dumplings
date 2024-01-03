$Object1 = Invoke-WebRequest -Uri 'https://servicewechat.com/wxa-dev-logic/checkupdate?force=1' | Read-ResponseContent | ConvertFrom-Json

# Version
$Version = $Object1.update_version.ToString()
$this.CurrentState.Version = $Version.SubString(0, 1) + '.' + $Version.SubString(1, 2) + '.' + $Version.SubString(3)

# Installer
$this.CurrentState.Installer += [ordered]@{
  Architecture = 'x86'
  InstallerUrl = (Get-RedirectedUrl -Uri "https://servicewechat.com/wxa-dev-logic/download_redirect?os=win&type=ia32&download_version=$($Object1.update_version)&version_type=1&pack_type=0").Replace('dldir1.qq.com', 'dldir1v6.qq.com')
}
$this.CurrentState.Installer += [ordered]@{
  Architecture = 'x64'
  InstallerUrl = (Get-RedirectedUrl -Uri "https://servicewechat.com/wxa-dev-logic/download_redirect?os=win&type=x64&download_version=$($Object1.update_version)&version_type=1&pack_type=0").Replace('dldir1.qq.com', 'dldir1v6.qq.com')
}

# ReleaseTime
$this.CurrentState.ReleaseTime = [datetime]::ParseExact($Version.SubString(3, 6), 'yyMMdd', $null).ToString('yyyy-MM-dd')

# ReleaseNotes (zh-CN)
$this.CurrentState.Locale += [ordered]@{
  Locale = 'zh-CN'
  Key    = 'ReleaseNotes'
  Value  = $Object1.changelog_desc | Format-Text
}

# ReleaseNotesUrl (zh-CN)
$this.CurrentState.Locale += [ordered]@{
  Locale = 'zh-CN'
  Key    = 'ReleaseNotesUrl'
  Value  = $Object1.changelog_url
}

switch ($this.Check()) {
  ({ $_ -ge 1 }) {
    $this.Write()
  }
  ({ $_ -ge 2 }) {
    $this.Message()
  }
  ({ $_ -ge 3 }) {
    $this.Submit()
  }
}
