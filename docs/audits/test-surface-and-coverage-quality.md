# Test Surface And Coverage Quality Audit

## Scope

This audit reviews whether the current test suite exercises the real public binding boundaries and whether the coverage story is being interpreted honestly.

## Strong Evidence

These files are the strongest direct proofs because they exercise live runtime boundaries:

- `tests/AuthoringRoundtrip_test.res`
- `tests/AuthoringLifecycleRoundtrip_test.res`
- `tests/ClientProtocolRoundtrip_test.res`
- `tests/HttpRoundtrip_test.res`
- `tests/StdioRoundtrip_test.res`
- `tests/WebStandardRequestResponse_test.res`
- `tests/ExperimentalTasksRoundtrip_test.res`
- `tests/ExperimentalServerTasksRoundtrip_test.res`
- `tests/CompileShape_test.res`

Why they matter:

- they run the public bindings against the installed SDK
- they cover typed-path success and typed-path rejection
- they go through real transport, lifecycle, and task-runtime behavior

## Supplemental Evidence

These files remain useful, but they are not sufficient release proof by themselves:

- `tests/BindingObjectSurface_test.res`
- `tests/BindingSurface_test.res`
- `tests/PublicWrapperCoverage_test.res`
- `tests/TaskStorageSurface_test.res`

Why they are supplemental:

- some assertions inspect constructed objects rather than full live roundtrips
- some raw seams still require support casts from `tests/support/McpTestBindings.res`

## Coverage Interpretation

The Vitest coverage threshold is a smoke gate.

It helps detect a broadly untested tree. It does not by itself prove:

- typed public-path soundness
- compile-shape rejection
- live transport behavior
- truthful raw-seam documentation

Those claims must keep pointing back to targeted test files in `docs/SOUNDNESS_MATRIX.md`.

## Residual Risk

The remaining risk is over-interpreting support-cast tests.

Support casts remain acceptable for intentionally raw seams. They are not proof for typed public claims.

## Verdict

The suite now has a credible direct-proof core inside `npm test`.

Object-surface checks and support-cast tests remain supplemental and must stay documented that way.
