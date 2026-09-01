param(
    [Parameter(Mandatory = $false)]
    [string] $ArtifactDirectory = "."
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$artifactRoot = (Resolve-Path $ArtifactDirectory).Path

function Assert-ExitCode {
    param(
        [Parameter(Mandatory = $true)]
        [string] $Executable,
        [Parameter(Mandatory = $true)]
        [int] $Expected
    )

    & (Join-Path $artifactRoot $Executable)
    if ($LASTEXITCODE -ne $Expected) {
        throw "$Executable returned $LASTEXITCODE; expected $Expected"
    }
}

Get-Content (Join-Path $artifactRoot "SHA256SUMS") | ForEach-Object {
    $expected, $name = $_ -split "  ", 2
    $actual = (Get-FileHash -Algorithm SHA256 (Join-Path $artifactRoot $name)).Hash.ToLowerInvariant()
    if ($actual -ne $expected) {
        throw "SHA-256 mismatch for $name"
    }
}

Assert-ExitCode -Executable "proof_app.exe" -Expected 0
Assert-ExitCode -Executable "proof_tests.exe" -Expected 0

$env:ASAN_OPTIONS = "exitcode=3"
Assert-ExitCode -Executable "expected_asan.exe" -Expected 0

$previousErrorPreference = $ErrorActionPreference
$ErrorActionPreference = "Continue"
$asanOutput = & (Join-Path $artifactRoot "asan_fault.exe") 2>&1 | Out-String
$asanExit = $LASTEXITCODE
$ErrorActionPreference = $previousErrorPreference
Write-Output $asanOutput

if ($asanExit -eq 0 -or $asanOutput -notmatch "heap-buffer-overflow") {
    throw "Windows ASan negative probe did not fail as expected"
}

[ordered]@{
    status = "pass"
    application_exit = 0
    tests_exit = 0
    asan_clean_exit = 0
    asan_negative_exit = $asanExit
    asan_diagnostic = "heap-buffer-overflow"
} | ConvertTo-Json | Set-Content (Join-Path $artifactRoot "windows-runtime-evidence.json")

Write-Output "native Windows gates: PASS"
