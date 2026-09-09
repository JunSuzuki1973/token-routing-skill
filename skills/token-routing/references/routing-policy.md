# Token routing policy

## Architecture

The three tools act at different points. Select one for each raw payload.

| Route | Compresses | Best use | Never pair on the same payload with |
|---|---|---|---|
| context-mode | tool or file payload before it enters conversation context | files, API data, browser snapshots, test output, unknown-size output | RTK |
| RTK | supported shell-command stdout before the model reads it | direct logs, test/build output, git and package-manager commands | context-mode |
| pxpipe | static request text rendered to images in a dedicated CLI proxy | long document summary or classification where minor visual loss is acceptable | current desktop session; exact-text work |

RTK and pxpipe may be used in one overall task only when they handle distinct
raw payloads. The router must name each payload and selected route; it must not
enable both as a blanket model setting.

## Model defaults

| Model | Direct CLI output | Large file / unbounded output | Long static document | Normal, code, exact text, interactive work |
|---|---|---|---|---|
| GPT-6 Astra | RTK | context-mode | pxpipe CLI only at 8,000+ characters and no exact-fidelity requirement | context-mode |
| GPT-5.6 Sol `high` | RTK for supported direct CLI output; one 11.99% Gain observation | context-mode | context-mode; pxpipe is a technical candidate only | context-mode |
| GPT-5.6 Sol other reasoning levels | context-mode | context-mode | context-mode | context-mode |
| Terra, Luna, other | context-mode | context-mode | context-mode | context-mode |

The Sol High RTK route is based on one read-only repository review: its
project-scoped RTK Gain recorded 2,403 input tokens, 2,115 output tokens, and
288 saved (11.99%). That is a command-output observation, not model-turn usage
or a quality-gated A/B result. pxpipe is technically plausible for Sol because
Sol accepts image input, but neither quality nor savings have been measured.

## Fidelity overrides

Choose context-mode rather than pxpipe when any of these are required:

- source-code modification or review;
- exact paths, identifiers, numbers, whitespace, or verbatim quotations;
- visual inspection is not sufficient proof;
- the work must occur in the currently running Codex desktop session.

When RTK's filtered output cannot answer the task, rerun the one command raw or
read RTK's retained full output. Do not silently accept loss of required detail.

## Availability and exactness

Exact, code, and interactive work always take precedence over a model route.
The selector returns `none` when its safe required route is unavailable. It
does not treat the presence of another compressor as a substitute.
