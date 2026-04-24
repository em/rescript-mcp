# URI Template Variable Algebra Audit

## Claim

- subsystem: resource-template variables and URI-template surface
- change: `McpUriTemplate` models the installed `Variables` union exactly, and `McpResourceTemplate.readCallback` receives that typed variable map on the public path
- boundary class:
  - exact binding
  - package-authored algebraic representation

## Upstream Evidence

### Declaration Evidence

- file: `node_modules/@modelcontextprotocol/server/dist/index-Bhfkexnj.d.mts`
- relevant signatures:
  - `type Variables = Record<string, string | string[]>;`
  - `expand(variables: Variables): string;`
  - `match(uri: string): Variables | null;`
- file: `node_modules/@modelcontextprotocol/server/dist/index.d.mts`
- relevant signature:
  - `type ReadResourceTemplateCallback = (uri: URL, variables: Variables, ctx: ServerContext) => ReadResourceResult | Promise<ReadResourceResult>;`

### Runtime Evidence

- `tests/BindingObjectSurface_test.res`
- `tests/AuthoringLifecycleRoundtrip_test.res`

## Local Representation

- `@unboxed type value = Single(string) | Multiple(array<string>)`
- `type variables = dict<value>`
- `match` is the typed primary accessor
- `matchRaw` remains a secondary alias to the same typed runtime call

## Alternatives Considered

### Alternative 1

- representation: keep `variables` at `dict<unknown>`
- why rejected: the installed declaration is materially narrower than `unknown`, and both `expand` and `readCallback` use the same exact scalar-or-array union

### Alternative 2

- representation: wrap each variable in a package-authored record
- why rejected: wrapper objects would lie about the runtime shape and force conversion work at every exact binding site

## Failure Modes Targeted

- failure mode: the package widens `Variables` back to `unknown`
- test covering it: `tests/BindingObjectSurface_test.res`

- failure mode: the binding introduces wrapper objects that drift from the SDK runtime shape
- test covering it: `tests/BindingObjectSurface_test.res`

- failure mode: registered resource-template callbacks still receive an open dictionary
- test covering it: `tests/AuthoringLifecycleRoundtrip_test.res`

## Verdict

The public URI-template surface now keeps the exact installed `string | string[]` algebra on the typed path.
