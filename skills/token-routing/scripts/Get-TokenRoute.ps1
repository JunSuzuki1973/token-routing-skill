[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [ValidateSet('gpt-6-astra', 'gpt-5.6-sol', 'gpt-5.6-terra', 'gpt-5.6-luna', 'other')]
    [string]$Model,
    [ValidateSet('none', 'low', 'medium', 'high', 'xhigh', 'max', 'ultra')]
    [string]$ReasoningEffort = 'medium',
    [ValidateSet('direct-cli-output', 'local-file', 'unbounded-output', 'static-document', 'code-edit', 'exact-text', 'interactive', 'ordinary')]
    [string]$Workload = 'ordinary',
    [ValidateRange(0, 100000000)]
    [int]$StaticInputChars = 0,
    [switch]$RequiresExactText,
    [switch]$DesktopSession,
    [switch]$DisableAutoDetect,
    [ValidateSet('context-mode', 'rtk', 'pxpipe-cli')]
    [string[]]$AvailableRoutes = @()
)

function Test-ContextModeAvailable {
    if ($env:CODEX_HOME) {
        return Test-Path (Join-Path $env:CODEX_HOME 'plugins\\cache\\context-mode')
    }
    return $false
}

function Get-DetectedRoutes {
    $routes = [System.Collections.Generic.List[string]]::new()
    if (Test-ContextModeAvailable) { $routes.Add('context-mode') }
    if (Get-Command rtk -ErrorAction SilentlyContinue) { $routes.Add('rtk') }
    if (Get-Command pxpipe -ErrorAction SilentlyContinue) { $routes.Add('pxpipe-cli') }
    return @($routes)
}

if ($AvailableRoutes.Count -eq 0 -and -not $DisableAutoDetect) {
    $AvailableRoutes = Get-DetectedRoutes
}

$route = [ordered]@{
    model = $Model
    reasoning_effort = $ReasoningEffort
    workload = $Workload
    route = 'none'
    context_mode = $false
    rtk = $false
    pxpipe = $false
    pxpipe_candidate = $false
    execution = 'current-session'
    evidence_level = 'none'
    available_routes = @($AvailableRoutes)
    rationale = ''
    guardrails = @()
}

function Set-ContextRoute([string]$reason) {
    if ($AvailableRoutes -contains 'context-mode') {
        $route.route = 'context-mode'
        $route.context_mode = $true
        $route.rationale = $reason
        $route.guardrails = @('Do not combine RTK with context-mode on the same raw output.')
    } else {
        $route.route = 'none'
        $route.rationale = 'context-mode is unavailable; do not silently substitute a token-saving tool.'
        $route.guardrails = @('Install or enable the required route, then run selection again.')
    }
}

# Fidelity safety always wins over model-specific optimizations.
if ($RequiresExactText -or $Workload -in @('code-edit', 'exact-text', 'interactive')) {
    Set-ContextRoute 'Exact, code, or interactive work requires the fidelity-preserving path.'
} elseif ($Model -eq 'gpt-6-astra' -and $Workload -eq 'direct-cli-output' -and $AvailableRoutes -contains 'rtk') {
    $route.route = 'rtk'
    $route.rtk = $true
    $route.evidence_level = 'quality-gated-a-b: direct 180-line log level counts'
    $route.rationale = 'Astra has a quality-passing RTK A/B result for the measured direct-log workload.'
    $route.guardrails = @('Do not also send this raw output through context-mode.', 'Rerun without RTK if full exact output is required.')
} elseif ($Model -eq 'gpt-6-astra' -and $Workload -eq 'static-document' -and $StaticInputChars -ge 8000 -and -not $DesktopSession -and $AvailableRoutes -contains 'pxpipe-cli') {
    $route.route = 'pxpipe-cli'
    $route.pxpipe = $true
    $route.execution = 'dedicated-cli-child'
    $route.evidence_level = 'quality-gated-a-b: deterministic log aggregation'
    $route.rationale = 'Astra has a quality-passing pxpipe A/B result for the measured static-input workload.'
    $route.guardrails = @('Do not use for code edits, verbatim output, or exact identifiers.', 'Do not enable in the current desktop session; dispatch through the pxpipe CLI route.')
} elseif ($Model -eq 'gpt-5.6-sol' -and $ReasoningEffort -eq 'high' -and $Workload -eq 'direct-cli-output' -and $AvailableRoutes -contains 'rtk') {
    $route.route = 'rtk'
    $route.rtk = $true
    $route.evidence_level = 'observed-single-run: Sol High repository review, RTK Gain 11.99%'
    $route.rationale = 'Sol High completed a read-only repository review using RTK-filtered CLI output with a positive, project-scoped Gain measurement.'
    $route.guardrails = @('This is not an end-to-end A/B result.', 'Do not also send this raw output through context-mode.', 'Rerun without RTK if full exact output is required.')
} elseif ($Model -eq 'gpt-5.6-sol' -and $Workload -eq 'static-document' -and $StaticInputChars -ge 8000 -and -not $DesktopSession) {
    $route.pxpipe_candidate = $true
    Set-ContextRoute 'Sol can accept image input, so pxpipe is technically a candidate for long non-exact static documents; no Sol quality or savings result authorizes automatic pxpipe use.'
    $route.guardrails += 'Keep pxpipe disabled for Sol until a quality-gated Sol A/B benchmark passes.'
} else {
    Set-ContextRoute 'Use context-mode for unbounded, file, normal, or unvalidated model work.'
}

[pscustomobject]$route | ConvertTo-Json -Depth 5
