open NodeJs

let process = Process.process
let cwd = Process.cwd(process)
let execPath = Process.execPath(process)

@new external makePromise: (('a => unit, exn => unit) => unit) => promise<'a> = "Promise"

type httpAddress = {
  port: int,
  family: string,
  address: string,
}

@send external serverAddress: Http.Server.t => httpAddress = "address"

let fixturePath = name => Path.join([cwd, "tests", "fixtures", name])

let importWithNode = path => {
  let quotedPath = path->JSON.stringifyAny->Option.getOr("\"\"")
  ignore(ChildProcess.execFileSync(execPath, ["--input-type=module", "-e", `await import(${quotedPath});`]))
}

let listenHttpServer = server =>
  makePromise((resolve, _reject) => {
    ignore(server->Http.Server.listen(~port=0, ~host="127.0.0.1", ~callback=() => resolve(server->serverAddress), ()))
  })

let closeHttpServer = server =>
  makePromise((resolve, reject) => {
    ignore(
      server->Http.Server.close(~callback=error =>
        switch Nullable.toOption(error) {
        | Some(_) => reject(Failure("server close error"))
        | None => resolve()
        }
      ),
    )
  })

let closeIgnore = promise =>
  promise
  ->Promise.then(_ => Promise.resolve())
  ->Promise.catch(_ => Promise.resolve())

@val
@scope("Promise")
external allSettled: array<promise<'a>> => promise<array<unknown>> = "allSettled"

let settle = promises =>
  promises->allSettled->Promise.then(_ => Promise.resolve())
