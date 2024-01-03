$this.CurrentState = Invoke-WondershareJsonUpgradeApi -ProductId 846 -Version '10.0.0.0' -Locale 'en-US'

# Installer
$this.CurrentState.Installer += $Installer = [ordered]@{
  InstallerUrl = "https://download.wondershare.com/cbs_down/filmora_64bit_$($this.CurrentState.Version)_full846.exe"
  ProductCode  = "Wondershare Filmora $($this.CurrentState.Version.Split('.')[0])_is1"
}

switch ($this.Check()) {
  ({ $_ -ge 1 }) {
    $InstallerFile = Get-TempFile -Uri $Installer.InstallerUrl

    # InstallerSha256
    $Installer['InstallerSha256'] = (Get-FileHash -Path $InstallerFile -Algorithm SHA256).Hash
    # RealVersion
    $this.CurrentState.RealVersion = $InstallerFile | Read-ProductVersionFromExe
    # AppsAndFeaturesEntries
    $Installer['AppsAndFeaturesEntries'] = @(
      [ordered]@{
        DisplayName = "Wondershare Filmora $($this.CurrentState.Version.Split('.')[0])(Build $($this.CurrentState.RealVersion))"
        ProductCode = "Wondershare Filmora $($this.CurrentState.Version.Split('.')[0])_is1"
      }
    )

    $this.Write()
  }
  ({ $_ -ge 2 }) {
    $this.Message()
  }
  ({ $_ -ge 3 }) {
    $this.Submit()
  }
}
