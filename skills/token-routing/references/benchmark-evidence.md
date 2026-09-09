# Benchmark evidence and limits

## Quality-passing GPT-6 Astra results

One repeat per arm was used to protect the five-hour allowance.

| Tool | Task profile | OFF input tokens | ON input tokens | Reduction | Quality |
|---|---|---:|---:|---:|---|
| RTK | 180-line log level counts | 110,344 | 61,869 | 43.93% | pass / pass |
| pxpipe | seven-field deterministic log aggregation | 151,168 | 85,923 | 43.16% | pass / pass |

The RTK test and pxpipe test used different task profiles. Their percentages
are paired ON/OFF effects, not a product ranking. RTK locally reduced its log
fixture from 26,765 bytes to 1,751 bytes (93.46%) before model input.

## Not established

- RTK plus pxpipe together;
- GPT-5.6 Sol end-to-end A/B savings or quality, at any reasoning level;
- medium-tier model routes;
- pxpipe for code, exact-text, or current Codex desktop-session work;
- automated context-mode A/B savings. The custom context arm reached a
  timeout before any context-mode tool call.

Do not convert these untested cases into automatic defaults. Add a matching
quality-gated A/B result before changing the routing policy.

On 2026-09-09, a Sol High A/B attempt stopped before any arm returned usage
data because the local Codex CLI child-process harness did not complete. This
is not evidence for or against either token-saving tool.

## Sol High RTK observation

On 2026-09-09, GPT-5.6 Sol with `high` reasoning reviewed this repository
read-only through RTK-filtered CLI output. Its project-scoped `rtk gain`
recorded one command, 2,403 input tokens, 2,115 output tokens, 288 saved, and
11.99% average savings. The final review produced seven actionable findings.

This establishes that RTK can reduce one supported direct CLI payload while Sol
High still completes a useful review. It does **not** establish end-to-end
Codex input reduction, general repository-review quality, pxpipe performance,
or a quality-gated A/B result. The retained local run includes the prompt,
model/effort, final response, and RTK Gain record; it is not packaged here
because this distributable Skill contains no local logs or user environment
data.
