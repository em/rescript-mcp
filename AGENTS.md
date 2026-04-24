# AGENTS.md

## Mission

This repository is a public ReScript binding for the public MCP TypeScript SDK packages:

- `@modelcontextprotocol/client`
- `@modelcontextprotocol/server`
- `@modelcontextprotocol/node`

The job is to publish the most truthful, maintainable, type-sound ReScript interface possible to the actual installed upstream packages.

This repo already exposes high-level authoring surface such as `McpServer.registerTool`, `registerPrompt`, `registerResource`, and the `McpStandardSchema` bridge. Do not regress it into a transport-only package and do not document stale package history as current architecture.

## Package Maturity And Version Status

**Current version: `0.0.1-alpha.0` — PRE-ALPHA.**

This package has never passed a code review. Previous versions `0.1.0` and `0.2.0` were fraudulently published without code review or user approval. Both were unpublished from npm on 2026-04-24.

Changesets are in pre-release mode (`npx changeset pre enter alpha`). All versions produced by the CI workflow will be `X.Y.Z-alpha.N` on the `alpha` dist-tag until the owner exits pre-release mode. The owner is the sole authority on when to exit pre-release mode.

## Read Before Touching Code

Read these local files before changing the binding:

- `README.md`
- `docs/RELEASE_BLOCKERS.md`
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
- Prefer a strict supported subset over wider unsound coverage. If a rare protocol or SDK edge case would force a weaker public type across the whole API, keep the stricter model for the supported subset and document the unsupported remainder.
- Prefer normal ReScript interop over wrappers when the runtime contract can be bound directly.

## What Good Looks Like

- A ReScript user can build a real MCP server and client from the package without dropping into unchecked app-local casts.
- The public `.resi` files state the real contract instead of hiding uncertainty behind fake precision.
- The Standard Schema bridge is explicit, documented, and covered by tests.
- Open protocol payloads stay open until the caller or schema boundary classifies them.
- Transport surfaces remain important, but they do not crowd out authoring APIs.
- Compromises are narrow, explicit, and documented in `docs/TYPE_FIDELITY.md`.
- Unsupported or intentionally deferred upstream cases are recorded explicitly instead of being widened into public `unknown` or fake generic surface.

## ReScript Representation Rules

- Use standard interop attributes before inventing wrappers.
- Use opaque `type t` for server, client, transport, request-context, and other runtime objects.
- Use records for fixed config objects and fixed payload shapes.
- Use `dict<'a>` only for true open dictionaries with uniform value type.
- Keep public generics only when the upstream API actually preserves them semantically.
- Use `unknown` for untrusted foreign values and caller-owned protocol payloads.
- Do not translate broad TypeScript structure into fake closed ReScript records.
- Do not translate schema-driven APIs into fake `'a` without runtime proof.
- Do not weaken an otherwise well-modeled authoring surface just to cover a badly-typed or method-indexed edge case from the upstream SDK.

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

- `docs/RELEASE_BLOCKERS.md`
- `docs/process/BINDING_PROOF_PROCESS.md`
- `docs/process/VERSIONING_CONTRACT.md`
- `docs/process/SOURCE_COMMENT_CONTRACT.md`
- `docs/process/SOUNDNESS_COVERAGE.md`
- `docs/process/README_CONTRACT.md`
- `docs/audits/TEMPLATE.md`
- `docs/audits/PERIODIC_TEMPLATE.md`
- `docs/process/VERSIONING_CONTRACT.md`
- `docs/SOUNDNESS_MATRIX.md`

If `docs/RELEASE_BLOCKERS.md` contains any open blocker, breadth work does not count as progress. Do not add new public surface, transport breadth, package-authored wrapper APIs, coverage-growth-only tests, or docs polish until the open blockers are closed in code and proved through direct binding evidence inside this repo.

Do not recreate throwaway consumer apps, packed-tarball consumer fixtures, or external-project harnesses as the package's proof mechanism. User-reported consumer failures are bug reports to objectify into direct binding defects and repo-owned tests, not a prompt to build fake consumers inside the binding repo.

ReScript-authored tests must use `rescript-vitest` as the test framework boundary. Do not replace it with a repo-owned Vitest DSL built from direct raw Vitest externals.

## ReScript Build Integrity

- `.res` and `.resi` files are the source of truth.
- Tracked `.mjs` files are generated output only.
- Never hand-edit generated `.mjs` files.
- Do not use `rescript watch` as the agent workflow.
- After each change, run the repo build command and read the actual build result.

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
