# AGENTS.md

## Mission

This repository is a public ReScript binding for the public MCP TypeScript SDK packages:

- `@modelcontextprotocol/client`
- `@modelcontextprotocol/server`
- `@modelcontextprotocol/node`

The job is to publish the most truthful, maintainable, type-sound ReScript interface possible to the actual installed upstream packages.

This repo already exposes high-level authoring surface such as `McpServer.registerTool`, `registerPrompt`, `registerResource`, and the `McpStandardSchema` bridge. Do not regress it into a transport-only package and do not document stale package history as current architecture.

## Read Before Touching Code

Read these local files before changing the binding:

- `README.md`
- `docs/TYPE_FIDELITY.md`
- `docs/TYPE_SOUNDNESS_AUDIT.md`
- `docs/process/BINDING_PROOF_PROCESS.md`
- `docs/process/VERSIONING_CONTRACT.md`
- `docs/process/SOURCE_COMMENT_CONTRACT.md`
- `docs/process/SOUNDNESS_COVERAGE.md`
- `docs/process/README_CONTRACT.md`
- `docs/process/FRAUD_RESPONSE_PROCESS.md`
- the relevant files in `docs/audits/`
- `package.json`
- the relevant `.resi` and `.res` modules
- the relevant installed `.d.ts` files under `node_modules/@modelcontextprotocol/{client,server,node}`

## Source Of Truth Order

Use this order when deciding what the public binding should be:

1. Actual installed upstream package behavior and declarations in `node_modules/@modelcontextprotocol/{client,server,node}`
2. Official upstream docs and examples for the installed package line
3. Existing repo policy in `docs/TYPE_FIDELITY.md` and `docs/TYPE_SOUNDNESS_AUDIT.md`
4. Benchmark ReScript bindings and forum discussions

When README, docs, declarations, tests, and runtime differ, verify the runtime and declarations and then update the repo docs.

## Core Binding Contract

- Bind real public upstream exports first.
- Preserve the high-level MCP authoring surface already present in the repo.
- Preserve the Standard Schema bridge as a first-class package boundary.
- Keep package entrypoints and subpath exports thin and recognizable to MCP users.
- Separate exact upstream surface from package-authored convenience layers.
- Prefer smaller honest APIs over larger unsound ones.
- Prefer normal ReScript interop over wrappers when the runtime contract can be bound directly.

## What Good Looks Like

- A ReScript user can build a real MCP server and client from the package without dropping into unchecked app-local casts.
- The public `.resi` files state the real contract instead of hiding uncertainty behind fake precision.
- The Standard Schema bridge is explicit, documented, and covered by tests.
- Open protocol payloads stay open until the caller or schema boundary classifies them.
- Transport surfaces remain important, but they do not crowd out authoring APIs.
- Compromises are narrow, explicit, and documented in `docs/TYPE_FIDELITY.md`.

## ReScript Representation Rules

- Use standard interop attributes before inventing wrappers.
- Use opaque `type t` for server, client, transport, request-context, and other runtime objects.
- Use records for fixed config objects and fixed payload shapes.
- Use `dict<'a>` only for true open dictionaries with uniform value type.
- Keep public generics only when the upstream API actually preserves them semantically.
- Use `unknown` for untrusted foreign values and caller-owned protocol payloads.
- Do not translate broad TypeScript structure into fake closed ReScript records.
- Do not translate schema-driven APIs into fake `'a` without runtime proof.

## MCP-Specific Boundary Rules

- `McpStandardSchema` is a critical package boundary. Changes to it require direct audit coverage.
- Low-level raw seams such as `setRequestHandlerRaw`, `McpTransport.send`, and raw client request/result methods must stay explicitly documented until they are narrowed.
- Capability maps, metadata dictionaries, task metadata, logger payloads, auth-provider hooks, fetch hooks, event stores, and request-option objects are open boundaries until the upstream contract proves more structure.
- Do not claim protocol-level exactness for JSON-RPC message and request-id surfaces unless the package actually classifies them structurally.
- Do not reintroduce the old stale architecture story that omitted authoring APIs; the current repo already binds them.

## Public Boundary Rules

- Every public value in a `.resi` file must be either exact, explicitly checked, or explicitly documented as open.
- Every public `unknown` must be intentional and justified in `docs/TYPE_FIDELITY.md` or `docs/TYPE_SOUNDNESS_AUDIT.md`.
- Every new public `unknown` must name its owning boundary class:
  - protocol message
  - request payload
  - result payload
  - schema seam
  - transport hook
  - metadata dictionary
- Do not widen a public API to `unknown` when the real problem is one missing record, union, or typed result wrapper.

## AI Fraud And Failure Modes

The following are fraud in this repository:

- Claiming the package is on one MCP SDK line while `package.json` and source imports target another.
- Claiming authoring support is missing when the current public `.resi` already exposes `registerTool`, `registerPrompt`, `registerResource`, and `McpStandardSchema`.
- Claiming authoring support is complete while leaving raw request/result and transport seams undocumented.
- Translating schema-driven APIs into fake closed types without proving the runtime contract.
- Exporting unchecked casts or vague `unknown` catch-alls where the upstream declaration is materially narrower.
- Verifying only compilation while ignoring runtime roundtrips, package entrypoint loading, or the coverage gate that currently fails `npm test`.
- Leaving README, research, design, fidelity, and audit docs stale after a public binding change.

## Workflow And Acceptance Gates

Follow the detailed process docs:

- `docs/process/BINDING_PROOF_PROCESS.md`
- `docs/process/VERSIONING_CONTRACT.md`
- `docs/process/SOURCE_COMMENT_CONTRACT.md`
- `docs/process/SOUNDNESS_COVERAGE.md`
- `docs/process/README_CONTRACT.md`
- `docs/audits/TEMPLATE.md`
- `docs/audits/PERIODIC_TEMPLATE.md`
- `docs/process/VERSIONING_CONTRACT.md`
- `docs/SOUNDNESS_MATRIX.md`

Do not consider binding work complete until all applicable items below are true:

- `npm run build` passes.
- `npm test` passes unless the user explicitly limited the work to docs-only changes.
- `npm pack --dry-run` passes for release-facing work.
- Any new or changed public `unknown` is justified in `docs/TYPE_FIDELITY.md` or `docs/TYPE_SOUNDNESS_AUDIT.md`.
- Any public `.resi` change has a matching soundness-matrix update and targeted test or audit note.
- A current audit report exists for every non-trivial public binding change.
- The evidence chain is sufficient for a later maintainer to reproduce the reasoning.

## Repo-Specific Maintenance Checklist

- Keep `src/Mcp.res` and subpath export modules thin.
- Keep README aligned with the actual package line from `package.json`.
- When a compromise changes, update `docs/TYPE_FIDELITY.md`.
- When public `unknown` surfaces or soundness boundaries change, update `docs/TYPE_SOUNDNESS_AUDIT.md`.
- Keep `docs/SOUNDNESS_MATRIX.md` aligned with current tests and current public `.resi`.
- Keep `docs/audits/` current for non-trivial binding changes.
- Keep `README.md` aligned with `docs/process/README_CONTRACT.md`.

