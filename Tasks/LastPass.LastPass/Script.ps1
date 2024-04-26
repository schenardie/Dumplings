$Object1 = Invoke-RestMethod -Uri 'https://lastpass.com/lmiapi/check-win-installer-version' -Method Post -Body (
  @{
    version  = $this.LastState.Contains('Version') ? $this.LastState.Version : '4.0.0.0'
    isManual = $true
  } | ConvertTo-Json -Compress
)

if ($Object1.isUpdateAvailable -eq $false) {
  $this.Log("The last version $($this.LastState.Version) is the latest, skip checking", 'Info')
  return
}

# Installer
$this.CurrentState.Installer += [ordered]@{
  InstallerUrl = $Object1.url
}

$InstallerFile = Get-TempFile -Uri $this.CurrentState.Installer[0].InstallerUrl

# Version
$this.CurrentState.Version = $InstallerFile | Read-ProductVersionFromMsi
# InstallerSha256
$this.CurrentState.Installer[0]['InstallerSha256'] = (Get-FileHash -Path $InstallerFile -Algorithm SHA256).Hash
# AppsAndFeaturesEntries + ProductCode
$this.CurrentState.Installer[0]['AppsAndFeaturesEntries'] = @(
  [ordered]@{
    ProductCode = $this.CurrentState.Installer[0]['ProductCode'] = $InstallerFile | Read-ProductCodeFromMsi
    UpgradeCode = $InstallerFile | Read-UpgradeCodeFromMsi
  }
)

switch -Regex ($this.Check()) {
  'New|Changed|Updated' {
    try {
      $Object2 = Invoke-WebRequest -Uri 'https://lastpass.com/upgrade.php' | ConvertFrom-Html

      $ReleaseNotesTitleNode = $Object2.SelectSingleNode("//div[@class='relnotes']/table/tr/td[1]/h3[contains(text(), '$($this.CurrentState.Version.Split('.')[0..2] -join '.')')]")
      if ($ReleaseNotesTitleNode) {
        # ReleaseTime
        $this.CurrentState.ReleaseTime = [datetime]::ParseExact(
          [regex]::Match($ReleaseNotesTitleNode.InnerText, '([a-zA-Z]+\s+\d{1,2}[a-zA-Z]+\s+\d{4})').Groups[1].Value,
          # "[string[]]" is needed here to convert "array" object to string array
          [string[]]@(
            "MMMM d'st' yyyy",
            "MMMM d'nd' yyyy",
            "MMMM d'rd' yyyy",
            "MMMM d'th' yyyy"
          ),
          (Get-Culture -Name 'en-US'),
          [System.Globalization.DateTimeStyles]::None
        ).ToString('yyyy-MM-dd')

        $ReleaseNotesNodes = for ($Node = $ReleaseNotesTitleNode.NextSibling; $Node -and $Node.Name -ne 'h3'; $Node = $Node.NextSibling) { $Node }
        # ReleaseNotes (en-US)
        $this.CurrentState.Locale += [ordered]@{
          Locale = 'en-US'
          Key    = 'ReleaseNotes'
          Value  = $ReleaseNotesNodes | Get-TextContent | Format-Text
        }
      } else {
        $this.Log("No ReleaseNotes (en-US) for version $($this.CurrentState.Version)", 'Warning')
      }
    } catch {
      $_ | Out-Host
      $this.Log($_, 'Warning')
    }

    $this.Print()
    $this.Write()
  }
  'Changed|Updated' {
    $this.Message()
  }
  'Updated' {
    $this.Submit()
  }
}
