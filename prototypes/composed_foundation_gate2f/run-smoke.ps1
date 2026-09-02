param(
    [string] $AuthorityHost = "127.0.0.1",
    [Parameter(Mandatory = $true)] [ValidateRange(1, 65535)] [int] $Port,
    [Parameter(Mandatory = $true)] [string] $Script,
    [string] $OutputRoot = (Join-Path $PSScriptRoot "gate2f-output")
)

$ErrorActionPreference = "Stop"
$client = Join-Path $PSScriptRoot "sacramento_gate2f_rendered_client.exe"
if (-not (Test-Path $client)) { throw "missing rendered client: $client" }
if (-not (Test-Path $Script)) { throw "missing input script: $Script" }

& $client $AuthorityHost $Port $Script $OutputRoot
if ($LASTEXITCODE -ne 0) { throw "Gate 2F rendered client failed" }
