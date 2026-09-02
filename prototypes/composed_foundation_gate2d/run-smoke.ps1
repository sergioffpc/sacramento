$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$client = Join-Path $root "sacramento_gate2d_client.exe"
$event = Join-Path $root "event.txt"
$pcm = Join-Path $root "gate2d-output.pcm"

$lines = & $client $event $pcm
if ($LASTEXITCODE -ne 0) {
    throw "Gate 2D client exited with $LASTEXITCODE"
}
$result = $lines[-1] | ConvertFrom-Json
if ($result.status -ne "pass" -or
    $result.authoritative_arrival_timestamp_ns -ne 4034985423 -or
    $result.scheduled_arrival_sample -ne 1680 -or
    $result.distance_attenuation_per_mille -ne 83 -or
    $result.direct_occlusion_per_mille -ne 0 -or
    $result.low_band_transmission_per_mille -ne 350 -or
    !(Test-Path $pcm)) {
    throw "Gate 2D native Windows result did not satisfy the acoustic seam"
}
$result | ConvertTo-Json -Compress
