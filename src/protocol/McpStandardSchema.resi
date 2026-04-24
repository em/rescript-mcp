module Schema = RescriptSchema.S

type jsonSchema
type t<'output>

let jsonSchemaOfRescriptSchema: Schema.t<'output> => jsonSchema
let fromRescriptSchema: Schema.t<'output> => t<'output>
