$Object1 = Invoke-RestMethod -Uri 'https://downloads.sparkmailapp.com/Spark3/win/dist/appcast.xml'

# Version
$Task.CurrentState.Version = $Object1.enclosure.version

# RealVersion
$Task.CurrentState.RealVersion = [regex]::Match($Task.CurrentState.Version, '^(\d+\.\d+\.\d+)').Groups[1].Value

# Installer
$Task.CurrentState.Installer += [ordered]@{
  InstallerUrl = $Object1.enclosure.url
}

# ReleaseTime
$Task.CurrentState.ReleaseTime = $Object1.pubDate | Get-Date -AsUTC

# ReleaseNotesUrl
$ReleaseNotesUrl = $Object1.releaseNotesLink

switch ($Task.Check()) {
  ({ $_ -ge 1 }) {
    $Object2 = Invoke-WebRequest -Uri $ReleaseNotesUrl | ConvertFrom-Html

    try {
      if ($Object2.SelectSingleNode('/html/body/p[1]/strong').InnerText.Contains($Task.CurrentState.RealVersion)) {
        # ReleaseNotes (en-US)
        $Task.CurrentState.Locale += [ordered]@{
          Locale = 'en-US'
          Key    = 'ReleaseNotes'
          Value  = $Object2.SelectNodes('/html/body/text()[2]/following-sibling::node()[count(.|/html/body/p[2]/preceding-sibling::node())=count(/html/body/p[2]/preceding-sibling::node())]') | Get-TextContent | Format-Text
        }
      } else {
        $Task.Logging("No ReleaseNotes for version $($Task.CurrentState.Version)", 'Warning')
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
