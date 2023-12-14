$Object1 = Invoke-RestMethod -Uri 'https://www.foxit.com/portal/download/getdownloadform.html?retJson=1&platform=Windows&product=Foxit-Enterprise-Reader&formId=pdf-reader-enterprise-register'

# Version
$Task.CurrentState.Version = $Version = $Object1.package_info.version[0]

# Installer
$Task.CurrentState.Installer += [ordered]@{
  InstallerType = 'exe'
  InstallerUrl  = 'https://cdn01.foxitsoftware.com' + $Object1.package_info.down
}
$Task.CurrentState.Installer += [ordered]@{
  InstallerType = 'inno'
  InstallerUrl  = 'https://cdn01.foxitsoftware.com' + $Object1.package_info.down.Replace('.exe', '_Prom.exe')
}

# ReleaseTime
$Task.CurrentState.ReleaseTime = [datetime]::ParseExact($Object1.package_info.release, 'MM/dd/yy', $null).ToString('yyyy-MM-dd')

switch ($Task.Check()) {
  ({ $_ -ge 1 }) {
    $Object2 = Invoke-WebRequest -Uri 'https://www.foxit.com/pdf-reader/version-history.html' | ConvertFrom-Html

    try {
      # ReleaseNotes (en-US)
      $ReleaseNotesNode = $Object2.SelectSingleNode("//div[@id='version_${Version}_detail']")
      if ($ReleaseNotesNode) {
        $Task.CurrentState.Locale += [ordered]@{
          Locale = 'en-US'
          Key    = 'ReleaseNotes'
          Value  = $ReleaseNotesNode.SelectNodes('./*[position()>2]') | Get-TextContent | Format-Text
        }
      } else {
        $Task.Logging("No ReleaseNotes for version $($Task.CurrentState.Version)", 'Warning')
      }
    } catch {
      $Task.Logging($_, 'Warning')
    }

    # RealVersion
    $Task.CurrentState.RealVersion = Get-TempFile -Uri $Task.CurrentState.Installer[0].InstallerUrl | Read-ProductVersionFromExe

    $Task.Write()
  }
  ({ $_ -ge 2 }) {
    $Task.Message()
  }
  ({ $_ -ge 3 }) {
    $Task.Submit()
  }
}
