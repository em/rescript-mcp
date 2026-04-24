# Bootstrap Maintenance Reset Audit

## Claim

- subsystem: repository maintenance process
- change: prepare `rescript-mcp` for agent-driven binding work with the same process, audit, README, and root-cleanup contract used in the SurrealDB binding repo
- boundary class: process, documentation, publish payload, audit trail
- exact public surface affected:
  - `README.md`
  - `AGENTS.md`
  - `package.json`
  - `docs/process/*`
  - `docs/audits/*`
  - `docs/TYPE_FIDELITY.md`
  - `docs/TYPE_SOUNDNESS_AUDIT.md`
  - `docs/SOUNDNESS_MATRIX.md`

## Upstream Evidence

### Official Docs

- URL: not applicable for the maintenance reset itself
- relevant excerpt or summary: this audit is anchored to the observable repo state and current command results

### Declaration Evidence

- file: `package.json`
- relevant signature:
  - the package currently targets `@modelcontextprotocol/client`, `@modelcontextprotocol/server`, and `@modelcontextprotocol/node` at `2.0.0-alpha.2`
  - the old README and root audit docs still described `@modelcontextprotocol/sdk@1.29.0`

### Runtime Evidence

- command or probe:
  - `npm run build`
  - `npm test`
  - `npm pack --dry-run`
- result:
  - build passes
  - test command passes
  - pack dry-run passes

## Local Representation

- affected files:
  - repo root docs and package metadata
  - new process docs and audit templates
- chosen ReScript shape:
  - no binding implementation changes
  - root scratch audits moved into structured bootstrap audit records
  - human README separated from maintainer process docs
  - fidelity and soundness docs moved under `docs/`
  - package publish payload reduced to shipped library assets

## Alternatives Considered

### Alternative 1

- representation: leave `AUDIT-2026-04-22.md`, `FRAUD-2026-04-22.md`, and `TYPE_FIDELITY.md` in the repo root
- why rejected: root scratch notes are not a durable process and they drift away from the current codebase

### Alternative 2

- representation: patch README only and leave the repo without AGENTS, audits, process docs, or soundness artifacts
- why rejected: that does not prepare the next agent to work with proof obligations or adversarial review

## Adversarial Questions

- question: did this work take over the MCP implementation instead of preparing it
- evidence-based answer: no binding logic or public `.resi` was changed. The patch is process-only and documents the current repo state for the next agent.

- question: are the old root audit claims still trustworthy
- evidence-based answer: no. They were stale against the actual current source tree, which already binds high-level authoring and Standard Schema. They were replaced by bootstrap audit records tied to current files and commands.

- question: does the npm package still ship maintainer docs and examples
- evidence-based answer: no after this reset. `package.json` now ships README, LICENSE, `rescript.json`, and `src/**/*` only.

## Failure Modes Targeted

- failure mode: the next agent inherits stale architecture and version claims
- how the current design prevents or exposes it: README, design, research, and AGENTS now point at the actual split-package MCP line
- test or probe covering it: `npm pack --dry-run`, manual doc inspection

- failure mode: process and audit obligations remain informal and easy to skip
- how the current design prevents or exposes it: AGENTS, process docs, audit templates, soundness matrix, and type-soundness audit are now explicit repo artifacts
- test or probe covering it: file presence and cross-links in the docs set

- failure mode: npm tarball keeps shipping internal maintainer docs
- how the current design prevents or exposes it: `package.json` publish `files` list now excludes docs and examples
- test or probe covering it: `npm pack --dry-run`

## Evidence

### Build

- command: `npm run build`
- result: passes

### Tests

- command: `npm test`
- result: fifteen test files and twenty tests pass

### Pack

- command: `npm pack --dry-run`
- result: passes

### Soundness Matrix Update

- affected row:
  - `Packaging / published entrypoint resolution`
- update made: linked the package-entrypoint row to this bootstrap maintenance audit

## Residual Risk

- remaining open boundary: the actual binding surfaces still need implementation work to raise coverage and narrow public `unknown` seams
- why it remains open: later binding work superseded the implementation gaps this reset left open, so current open boundaries now live in `docs/TYPE_SOUNDNESS_AUDIT.md` and `docs/SOUNDNESS_MATRIX.md`
- where it is documented: `docs/TYPE_SOUNDNESS_AUDIT.md`, `docs/SOUNDNESS_MATRIX.md`

## Verdict

- status:
  - acceptable with documented fidelity gap
- reviewer: Codex
- date: 2026-04-22
