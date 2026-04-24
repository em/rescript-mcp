open Vitest
open NodeJs

let cwd = Process.cwd(Process.process)
let bscBinary = Path.join([cwd, "node_modules", ".bin", "bsc"])
let runtimePath = Path.join([cwd, "node_modules", "@rescript", "runtime"])
let fixtureDir = Path.join([cwd, "tests", "support", "type-shape"])
let outputDir = Path.join([cwd, "lib", "type-shape"])

let utf8 = StringEncoding.utf8

let commandOutput = (result: ChildProcess.spawnSyncResult<unknown>) =>
  result.stdout->Buffer.toStringWithEncoding(utf8) ++ result.stderr->Buffer.toStringWithEncoding(utf8)

let expectSuccess = (t, label, result: ChildProcess.spawnSyncResult<unknown>) => {
  let expectStatus = value => t->expect(value)
  result.status->expectStatus->Expect.toBe(0)
  switch result.error->Nullable.toOption {
  | Some(_) => JsError.throwWithMessage(label)
  | None => ()
  }
}

let fixtureSource = fixtureName =>
  Fs.readFileSync(Path.join([fixtureDir, `${fixtureName}.res.txt`]))->Buffer.toStringWithEncoding(utf8)

let parserArgs = (sourcePath, astPath) => [
  "-warn-error",
  "+8",
  "-absname",
  "-bs-ast",
  "-o",
  astPath,
  sourcePath,
]

let compilerArgs = astPath => [
  "-I",
  "lib/ocaml",
  "-I",
  "node_modules/rescript-schema/lib/ocaml",
  "-I",
  "node_modules/rescript-nodejs/lib/ocaml",
  "-I",
  "node_modules/rescript-webapi/lib/ocaml",
  "-runtime-path",
  runtimePath,
  "-warn-error",
  "+8",
  "-bs-package-name",
  "rescript-mcp",
  "-bs-package-output",
  "esmodule:lib/type-shape:.mjs",
  astPath,
]

let compileFixture = fixtureName => {
  Fs.mkdirSyncWith(outputDir, {recursive: true})
  let sourcePath = Path.join([outputDir, `${fixtureName}.res`])
  let astPath = Path.join([outputDir, `${fixtureName}.ast`])
  Fs.writeFileSync(sourcePath, Buffer.fromString(fixtureName->fixtureSource))
  let parseResult = ChildProcess.spawnSync(bscBinary, parserArgs(sourcePath, astPath), {cwd, stdio: "pipe"})
  let compileResult =
    if parseResult.status == 0 {
      Some(ChildProcess.spawnSync(bscBinary, compilerArgs(astPath), {cwd, stdio: "pipe"}))
    } else {
      None
    }
  (parseResult, compileResult)
}

describe("type-shape coverage", () => {
  test("typed public path compiles inside the repo build graph", t => {
    let (parseResult, compileResult) = compileFixture("TypedPublicPath")

    expectSuccess(t, "parse typed public path", parseResult)
    switch compileResult {
    | Some(result) => expectSuccess(t, "compile typed public path", result)
    | None => JsError.throwWithMessage("Expected compiler result for typed public path")
    }
  })

  test("tool output mismatch is rejected by the typed server path", t => {
    let expect = value => t->expect(value)
    let (parseResult, compileResult) = compileFixture("ToolOutputMismatch")

    expectSuccess(t, "parse tool output mismatch", parseResult)
    switch compileResult {
    | Some(result) =>
      let output = result->commandOutput
      (result.status == 0)->expect->Expect.toBe(false)
      output->expect->Expect.String.toContain("wrongOutput")
      output->expect->Expect.String.toContain("echoOutput")
    | None => JsError.throwWithMessage("Expected compiler result for tool output mismatch")
    }
  })

  test("task tool output mismatch is rejected by the typed task path", t => {
    let expect = value => t->expect(value)
    let (parseResult, compileResult) = compileFixture("TaskToolOutputMismatch")

    expectSuccess(t, "parse task output mismatch", parseResult)
    switch compileResult {
    | Some(result) =>
      let output = result->commandOutput
      (result.status == 0)->expect->Expect.toBe(false)
      output->expect->Expect.String.toContain("wrongOutput")
      output->expect->Expect.String.toContain("echoOutput")
    | None => JsError.throwWithMessage("Expected compiler result for task output mismatch")
    }
  })
})
