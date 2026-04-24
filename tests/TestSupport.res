open NodeJs

let process = Process.process
let cwd = Process.cwd(process)
let execPath = Process.execPath(process)

@val external queueMicrotask: (unit => unit) => unit = "queueMicrotask"

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
  Promise.make((resolve, _reject) => {
    ignore(server->Http.Server.listen(~port=0, ~host="127.0.0.1", ~callback=() => resolve(server->serverAddress), ()))
  })

let closeHttpServer = server =>
  Promise.make((resolve, reject) => {
    ignore(
      server->Http.Server.close(~callback=error =>
        switch Nullable.toOption(error) {
        | Some(_) => reject(Failure("server close error"))
        | None => resolve()
        }
      ),
    )
  })

let closeIgnore = async promise => {
  try {
    let _ = await promise
    ()
  } catch {
  | _ => ()
  }
}

let nextMicrotask = () =>
  Promise.make((resolve, _reject) => {
    queueMicrotask(() => resolve(()))
  })

@val
@scope("Promise")
external allSettled: array<promise<'a>> => promise<array<unknown>> = "allSettled"

let settle = async promises => {
  let _ = await promises->allSettled
  ()
}
