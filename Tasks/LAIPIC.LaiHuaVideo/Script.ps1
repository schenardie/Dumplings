$Object1 = (Invoke-RestMethod -Uri 'https://video.laihua.com/common/config?type=15').data.videoUpdate | ConvertFrom-Json

# Version
$this.CurrentState.Version = $Object1.versionCode

# Installer
$this.CurrentState.Installer += [ordered]@{
  InstallerUrl = $Object1.downloadUrl
}

# ReleaseNotes (zh-CN)
$this.CurrentState.Locale += [ordered]@{
  Locale = 'zh-CN'
  Key    = 'ReleaseNotes'
  Value  = $Object1.description | Format-Text
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
