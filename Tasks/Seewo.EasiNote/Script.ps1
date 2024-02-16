$Object1 = Invoke-RestMethod -Uri 'https://easinote.seewo.com/com/softinfo?softCode=EasiNote5'

# Version
$this.CurrentState.Version = $Object1.data[0].softVersion

# Installer
$this.CurrentState.Installer += [ordered]@{
  InstallerUrl = $Object1.data[0].downloadUrl
}

# ReleaseTime
$this.CurrentState.ReleaseTime = $Object1.data[0].softPublishtime | ConvertFrom-UnixTimeMilliseconds

switch ($this.Check()) {
  ({ $_ -ge 1 }) {
    $Object2 = (Invoke-RestMethod -Uri 'https://easinote.seewo.com/com/apis?api=GET_LOG').data.Where({ $_.version -eq $this.CurrentState.Version }, 'First')

    try {
      if ($Object2) {
        # ReleaseNotes (zh-CN)
        $this.CurrentState.Locale += [ordered]@{
          Locale = 'zh-CN'
          Key    = 'ReleaseNotes'
          Value  = $Object2[0].description | ConvertFrom-Html | Get-TextContent | Format-Text
        }
      } else {
        $this.Log("No ReleaseNotes (zh-CN) for version $($this.CurrentState.Version)", 'Warning')
      }
    } catch {
      $_ | Out-Host
      $this.Log($_, 'Warning')
    }

    $this.Write()
  }
  ({ $_ -ge 2 }) {
    $this.Message()
  }
  ({ $_ -ge 3 }) {
    $this.Submit()
  }
}
