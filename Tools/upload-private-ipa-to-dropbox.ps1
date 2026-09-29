param(
  [Parameter(Mandatory=$true)][string]$File,
  [Parameter(Mandatory=$true)][string]$Destination,
  [string]$Token = $env:DROPBOX_ACCESS_TOKEN
)
$ErrorActionPreference = "Stop"
if (!(Test-Path -LiteralPath $File -PathType Leaf)) { throw "IPA not found: $File" }
if ([string]::IsNullOrWhiteSpace($Token)) { throw "Set DROPBOX_ACCESS_TOKEN to a scoped Dropbox token." }
if (!$Destination.StartsWith("/")) { throw "Destination must be an absolute Dropbox path." }

$info = Get-Item -LiteralPath $File
$sha = (Get-FileHash -LiteralPath $File -Algorithm SHA256).Hash
$bytes = [IO.File]::ReadAllBytes($info.FullName)
$arg = @{ path=$Destination; mode="overwrite"; autorename=$false; mute=$false } | ConvertTo-Json -Compress

$headers = @{
  Authorization = "Bearer $Token"
  "Dropbox-API-Arg" = $arg
  "Content-Type" = "application/octet-stream"
}
$result = Invoke-RestMethod -Method Post -Uri "https://content.dropboxapi.com/2/files/upload" -Headers $headers -Body $bytes
if ([int64]$result.size -ne [int64]$info.Length) { throw "Remote size mismatch: local=$($info.Length) remote=$($result.size)" }

Write-Host "UPLOAD_OK"
Write-Host "PATH=$($result.path_display)"
Write-Host "BYTES=$($result.size)"
Write-Host "SHA256=$sha"
Write-Host "DROPBOX_CONTENT_HASH=$($result.content_hash)"
