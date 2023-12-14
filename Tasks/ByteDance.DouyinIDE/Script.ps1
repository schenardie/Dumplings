$Object1 = Invoke-RestMethod -Uri 'https://tron.jiyunhudong.com/api/sdk/check_update?pid=6898629266087352589&branch=master&buildId=&uid='

# Version
$Task.CurrentState.Version = $Object1.data.manifest.win32.version

# Installer
$Task.CurrentState.Installer += [ordered]@{
  InstallerUrl = $Object1.data.manifest.win32.urls[0]
}

# ReleaseNotes (zh-CN)
$Task.CurrentState.Locale += [ordered]@{
  Locale = 'zh-CN'
  Key    = 'ReleaseNotes'
  Value  = $Object1.data.releaseNote | Format-Text
}

switch ($Task.Check()) {
  ({ $_ -ge 1 }) {
    $EdgeDriver = Get-EdgeDriver
    $EdgeDriver.Navigate().GoToUrl('https://developer.open-douyin.com/docs/resource/zh-CN/mini-app/develop/developer-instrument/download/developer-instrument-update-and-download/')
    Start-Sleep -Seconds 10

    try {
      # ReleaseTime
      $Task.CurrentState.ReleaseTime = [regex]::Match(
        $EdgeDriver.FindElement([OpenQA.Selenium.By]::XPath("//*[contains(@class, 'zone-container')]/div[contains(@class, 'heading-h1') and contains(.//text(), '$($Task.CurrentState.Version)')]")).Text,
        '(\d{4}-\d{1,2}-\d{1,2})'
      ).Groups[1].Value | Get-Date -Format 'yyyy-MM-dd'
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
