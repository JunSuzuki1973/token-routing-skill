---
name: token-routing
description: "Route token-sensitive Codex work to context-mode, RTK, or pxpipe based on the model, input path, size, and fidelity needs. Use for requests involving long logs, CLI output, large documents, token budgets, or token-saving tools."
---

# Token Routing

Choose one compression path for each raw input before executing the task. The
user should not need to remember product switches.

## Route selection

Classify the raw information source and its fidelity requirement, then run:

```powershell
.\scripts\Get-TokenRoute.ps1 -Model <model> -Workload <kind> -StaticInputChars <n> [-RequiresExactText] [-DesktopSession]
```

Use these workload kinds:

- `direct-cli-output`: a command will produce the information to inspect.
- `local-file` or `unbounded-output`: a file, API response, browser snapshot,
  test report, or other non-prompt payload will be processed.
- `static-document`: a large, already-known text payload intended for summary
  or classification.
- `code-edit`, `exact-text`, `interactive`, or `ordinary`: source-sensitive,
  interactive, or normal work.

If a request contains multiple raw sources, classify and route each source
separately. Tell the user the selected path briefly when it changes execution.

The helper detects locally callable routes by default. An agent that already
knows its active tools should pass them explicitly with `-AvailableRoutes`.
If the selected fidelity-preserving route is unavailable, the result is `none`;
do not silently substitute another compressor.
Use `-DisableAutoDetect -AvailableRoutes @()` in tests that must represent an
environment with no available routes.

For GPT-5.6 Sol, use RTK automatically only for `high` reasoning and supported
direct CLI output. That decision has one positive project-scoped Gain
observation, not a full A/B benchmark. For long static Sol documents, pxpipe is
only a technical candidate because Sol accepts image input; keep it off until a
quality-gated Sol A/B result exists.

## Execution contract

- `context-mode`: process the raw payload once in its sandbox and return only
  the extracted result. Do not pass that same raw output through RTK.
- `rtk`: prefix only the supported direct shell command with the local RTK
  binary. Preserve the unfiltered result or rerun raw when exact full output is
  necessary.
- `pxpipe-cli`: use the dedicated pxpipe/Codex CLI child-process route. It
  cannot retrofit the running Codex desktop conversation. Do not use it for
  code edits, exact identifiers, verbatim quoting, or payloads requiring
  byte-for-byte fidelity.
- `none`: do not introduce a token tool merely because the selected model is
  capable. Run the ordinary task normally.

Never apply context-mode and RTK to the same raw output. Do not claim that
pxpipe and RTK were measured together: they have only been validated as
separate paths.

Read [the routing policy](references/routing-policy.md) when choosing a model
route or explaining the decision. Read [the benchmark evidence](references/benchmark-evidence.md)
when reporting expected savings or deciding whether an unvalidated route can
be enabled.
