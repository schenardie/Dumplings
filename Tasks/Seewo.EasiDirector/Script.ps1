$Object1 = $LocalStorage.SeewoApps['EasiDirector']

# Version
$this.CurrentState.Version = $Object1.softInfos[0].softVersion

# RealVersion
$this.CurrentState.RealVersion = '1.0.0.0'

# Installer
$this.CurrentState.Installer += [ordered]@{
  InstallerUrl = $Object1.softInfos[0].downloadUrl
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
