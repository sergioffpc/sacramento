$ErrorActionPreference = "Stop"

$output = @(& "$PSScriptRoot\falcor_vulkan_smoke.exe" 2>&1)
$exitCode = $LASTEXITCODE
$outputLines = @($output | ForEach-Object { $_.ToString() })
if ($exitCode -ne 0) {
    throw "Falcor smoke exited with code $exitCode`:`n$($outputLines -join "`n")"
}
$json = $outputLines | Where-Object { $_ -match '^\s*\{.*\}\s*$' } | Select-Object -Last 1
if ($null -eq $json) {
    throw "Falcor smoke did not emit a JSON result:`n$($outputLines -join "`n")"
}
$result = $json | ConvertFrom-Json
if ($result.status -ne "pass") {
    throw "Falcor smoke did not pass: $json"
}
if ($result.api -ne "Vulkan") {
    throw "Falcor selected '$($result.api)' instead of Vulkan"
}
if ($result.aftermath -ne $true) {
    throw "Falcor smoke did not enable Aftermath"
}
if ([string]::IsNullOrWhiteSpace($result.adapter)) {
    throw "Falcor smoke did not report an adapter"
}
$json
