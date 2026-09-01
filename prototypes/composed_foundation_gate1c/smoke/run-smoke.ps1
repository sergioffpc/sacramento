$ErrorActionPreference = "Stop"

$output = & "$PSScriptRoot\falcor_vulkan_smoke.exe"
if ($LASTEXITCODE -ne 0) {
    throw "Falcor smoke exited with code $LASTEXITCODE`: $output"
}
$result = $output | ConvertFrom-Json
if ($result.status -ne "pass") {
    throw "Falcor smoke did not pass: $output"
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
$output
