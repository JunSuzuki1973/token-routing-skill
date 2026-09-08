# Token Routing Skill

`token-routing` is a portable agent skill that chooses the least-lossy
token-saving route for each raw payload:

- **context-mode** for files, API output, browser snapshots, test output, and
  other unbounded payloads;
- **RTK** for supported direct shell-command output;
- **pxpipe** for long static documents sent through a dedicated CLI proxy.

It is a router, not a blanket compression switch. The skill prevents applying
RTK and context-mode to the same raw output and preserves exact-fidelity work
from pxpipe's image transformation.

日本語版は [README.ja.md](README.ja.md) を参照してください。

## Install in Codex

Ask Codex to install the skill from this repository, or use the bundled skill
installer:

```powershell
python <path-to-skill-installer>/install-skill-from-github.py `
  --repo JunSuzuki1973/token-routing-skill `
  --path skills/token-routing
```

Restart or begin a new Codex turn after installation. The skill is eligible for
automatic selection when a request involves token budgets, long logs, CLI
output, large documents, RTK, pxpipe, or context-mode.

## Default routing policy

| Situation | Route |
|---|---|
| GPT-6 Astra, supported direct CLI output | RTK |
| GPT-6 Astra, static document summary/classification, 8,000+ characters | pxpipe via a dedicated CLI child process |
| Files, API results, browser snapshots, tests, and unknown-size output | context-mode |
| Code edits, exact identifiers, verbatim text, or interactive desktop work | context-mode |
| GPT-5.6 Sol (including `high`), Terra, Luna, and other models | context-mode only |

The model default is deliberately conservative. GPT-5.6 Sol accepts image input
and supports `high` reasoning, but this project does not yet have a
quality-passing RTK or pxpipe end-to-end A/B measurement for Sol.

## Requirements and limits

- `context-mode`, RTK, and pxpipe are separate products; this repository does
  not bundle their binaries, packages, credentials, or configuration.
- RTK must be installed and available to the shell for an RTK route.
- pxpipe requires its own configured proxy/child-process route. It cannot be
  attached retrospectively to the already-running Codex desktop conversation.
- Do not use pxpipe for source-code edits, exact paths or identifiers, numeric
  fidelity, whitespace-sensitive work, or verbatim quotation.
- If RTK's filtered output lacks required detail, rerun only that command raw
  or use RTK's retained full output.

## Measured evidence

Quality-gated, single-repeat GPT-6 Astra measurements produced:

| Tool | Workload | OFF input tokens | ON input tokens | Input reduction |
|---|---|---:|---:|---:|
| RTK | 180-line log level counts | 110,344 | 61,869 | 43.93% |
| pxpipe | seven-field deterministic log aggregation | 151,168 | 85,923 | 43.16% |

These are separate paired comparisons, not a product ranking or an assurance
that RTK and pxpipe should be combined. Read
[benchmark evidence](skills/token-routing/references/benchmark-evidence.md)
before changing automatic model defaults.

## Third-party projects

This skill can route work to the following independently maintained projects:

- [context-mode](https://github.com/mksglu/context-mode)
- [RTK — Rust Token Killer](https://github.com/rtk-ai/rtk) (Apache-2.0)
- [pxpipe](https://github.com/teamchong/pxpipe) (MIT)

Their licenses and terms apply to their own software. This repository contains
only the routing instructions and helper script, under the MIT License.

## License

[MIT](LICENSE)
