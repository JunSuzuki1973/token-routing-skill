[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [ValidateSet('gpt-6-astra', 'gpt-5.6-sol', 'gpt-5.6-terra', 'gpt-5.6-luna', 'other')]
    [string]$Model,
    [ValidateSet('none', 'low', 'medium', 'high', 'xhigh', 'max')]
    [string]$ReasoningEffort = 'medium',
    [ValidateSet('direct-cli-output', 'local-file', 'unbounded-output', 'static-document', 'code-edit', 'exact-text', 'interactive', 'ordinary')]
    [string]$Workload = 'ordinary',
    [ValidateRange(0, 100000000)]
    [int]$StaticInputChars = 0,
    [switch]$RequiresExactText,
    [switch]$DesktopSession
)

$route = [ordered]@{
    model = $Model
    reasoning_effort = $ReasoningEffort
    workload = $Workload
    route = 'context-mode'
    context_mode = $true
    rtk = $false
    pxpipe = $false
    execution = 'current-session'
    measured = $false
    rationale = ''
    guardrails = @()
}

if ($Model -eq 'gpt-6-astra' -and $Workload -eq 'direct-cli-output') {
    $route.route = 'rtk'
    $route.context_mode = $false
    $route.rtk = $true
    $route.measured = $true
    $route.rationale = 'Astra has a quality-passing RTK A/B result for direct log output.'
    $route.guardrails = @('Do not also send this raw output through context-mode.', 'Rerun without RTK if full exact output is required.')
} elseif ($Model -eq 'gpt-6-astra' -and $Workload -eq 'static-document' -and $StaticInputChars -ge 8000 -and -not $RequiresExactText -and -not $DesktopSession) {
    $route.route = 'pxpipe-cli'
    $route.context_mode = $false
    $route.pxpipe = $true
    $route.execution = 'dedicated-cli-child'
    $route.measured = $true
    $route.rationale = 'Astra has a quality-passing pxpipe A/B result for large static input.'
    $route.guardrails = @('Do not use for code edits, verbatim output, or exact identifiers.', 'Do not enable in the current desktop session; dispatch through the pxpipe CLI route.')
} elseif ($Model -eq 'gpt-6-astra') {
    $route.rationale = 'Use context-mode for normal, exact-text, interactive, file, or unbounded-output work.'
    $route.guardrails = @('Do not combine RTK with context-mode on the same raw output.')
} elseif ($Model -eq 'gpt-5.6-sol') {
    $route.rationale = 'Sol supports the required modalities, but RTK/pxpipe end-to-end savings have not been benchmarked for this model.'
    $route.guardrails = @('Keep RTK and pxpipe off until a Sol A/B benchmark passes.', 'Use context-mode only.')
} else {
    $route.rationale = 'Use context-mode only; this model and route have no RTK or pxpipe A/B evidence.'
    $route.guardrails = @('Keep RTK and pxpipe off.')
}

[pscustomobject]$route | ConvertTo-Json -Depth 5
