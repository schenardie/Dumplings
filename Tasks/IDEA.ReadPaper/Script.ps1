$Object = Invoke-RestMethod -Uri 'https://readpaper.com/api/microService-app-aiKnowledge/aiKnowledge/client/v1/getDownloadUrls' -Method Post -ContentType 'application/json' -Body '{}'

$Prefix = [uri]::new([uri]$Object.data.urls.windowsClient, '.').OriginalString

$Task.CurrentState = Invoke-RestMethod -Uri "${Prefix}latest.yml?noCache=$((New-Guid).Guid.Split('-')[0])" | ConvertFrom-Yaml | ConvertFrom-ElectronUpdater -Prefix $Prefix -Locale 'zh-CN'

switch ($Task.Check()) {
  ({ $_ -ge 1 }) {
    $Task.Write()
  }
  ({ $_ -ge 2 }) {
    $Task.Message()
  }
  ({ $_ -ge 3 }) {
    $Task.Submit()
  }
}
