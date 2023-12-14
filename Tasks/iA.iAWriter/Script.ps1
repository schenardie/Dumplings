$Object1 = Invoke-RestMethod -Uri 'https://iawriter.s3-eu-west-1.amazonaws.com/windows/update.xml'

# Version
$Task.CurrentState.Version = $Object1.item.version

# Installer
$Task.CurrentState.Installer += [ordered]@{
  InstallerUrl = $Object1.item.url.Trim()
}

switch ($Task.Check()) {
  ({ $_ -ge 1 }) {
    $Object2 = Invoke-WebRequest -Uri $Object1.item.changelog.Trim() | ConvertFrom-Html

    try {
      # ReleaseNotes (en-US)
      $Task.CurrentState.Locale += [ordered]@{
        Locale = 'en-US'
        Key    = 'ReleaseNotes'
        Value  = $Object2.SelectSingleNode('/html/body') | Get-TextContent | Format-Text
      }
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
