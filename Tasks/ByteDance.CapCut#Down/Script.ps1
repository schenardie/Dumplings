$Object1 = Invoke-RestMethod -Uri 'https://editor-api-sg.capcut.com/service/settings/v3/?device_platform=windows&aid=359289&from_aid=359289&from_version=0.0.0'

# Installer
$this.CurrentState.Installer += [ordered]@{
  InstallerUrl = $InstallerUrl = $Object1.data.settings.installer_downloader_config.url
}

# Version
$this.CurrentState.Version = [regex]::Match($InstallerUrl, '(\d+_\d+_\d+_\d+)').Groups[1].Value.Replace('_', '.')

switch ($this.Check()) {
  ({ $_ -ge 1 }) {
    $this.Write()
  }
  ({ $_ -ge 2 }) {
    $this.Message()
  }
  ({ $_ -ge 3 }) {
    $ToSubmit = $false

    $Mutex = [System.Threading.Mutex]::new($false, 'DumplingsCapCut')
    $Mutex.WaitOne(30000) | Out-Null
    if (-not $LocalStorage.Contains("CapCutSubmitting-$($this.CurrentState.Version)")) {
      $LocalStorage["CapCutSubmitting-$($this.CurrentState.Version)"] = $ToSubmit = $true
    }
    $Mutex.ReleaseMutex()
    $Mutex.Dispose()

    if ($ToSubmit) {
      $this.Submit()
    } else {
      $this.Logging('Another task is submitting manifests for this package', 'Warning')
    }
  }
}
