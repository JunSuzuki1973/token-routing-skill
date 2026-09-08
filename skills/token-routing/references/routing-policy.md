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
| GPT-5.6 Sol, including `high` | context-mode | context-mode | context-mode | context-mode |
| Terra, Luna, other | context-mode | context-mode | context-mode | context-mode |

The Sol and mid-tier defaults are conservative, not a claim that RTK or pxpipe
cannot work there. They lack this installation's end-to-end A/B evidence.

## Fidelity overrides

Choose context-mode rather than pxpipe when any of these are required:

- source-code modification or review;
- exact paths, identifiers, numbers, whitespace, or verbatim quotations;
- visual inspection is not sufficient proof;
- the work must occur in the currently running Codex desktop session.

When RTK's filtered output cannot answer the task, rerun the one command raw or
read RTK's retained full output. Do not silently accept loss of required detail.
