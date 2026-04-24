# Periodic Direct Proof Review

## Scope

This periodic review checks that the package still uses direct repo-owned proof for the typed public binding surface.

## Current Standard

The only accepted proof chain is:

- `npm run build`
- `npm test`
- `npm pack --dry-run`

The typed-path release claims must stay grounded in:

- live roundtrip tests on the public binding surface
- compile-shape rejection executed from Vitest
- current docs that name the remaining raw seams explicitly

## Review Questions

- Does any typed-path claim depend on package-local `%identity` support casts?
- Does any doc reintroduce recreated consumer harnesses as release proof?
- Does `docs/SOUNDNESS_MATRIX.md` still point typed-path rows at direct repo-owned tests?
- Do compile-shape rejection checks still run from `tests/CompileShape_test.res` inside `npm test`?

## Current Verdict

The typed public path remains grounded in direct repo-owned proof.

Reopen this review immediately if any future change:

- moves typed-path proof outside `npm test`
- reintroduces recreated consumer fixtures
- starts using support casts to make a typed public claim compile
