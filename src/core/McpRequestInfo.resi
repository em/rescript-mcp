type t

let make: (~headers: dict<unknown>, ~url: Webapi.Url.t=?, unit) => t
let headers: t => dict<unknown>
let url: t => option<Webapi.Url.t>
