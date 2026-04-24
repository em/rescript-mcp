// src/protocol/McpStandardSchema.res
// Concern: bridge `rescript-schema` into the public MCP Standard Schema surface used by typed tools, tasks, and client result classification.
// Source: `rescript-schema` plus the installed MCP SDK Standard Schema contract.
// Boundary: this module owns JSON Schema emission and stores the original `rescript-schema` value for later runtime classification.
// Why this shape: the MCP SDK expects Standard Schema objects, but the typed public path also needs a reproducible runtime parser for structured tool output.
// Coverage: tests/StandardSchema_test.res, tests/ClientProtocolRoundtrip_test.res, tests/ExperimentalTasksRoundtrip_test.res, tests/CompileShape_test.res
module Schema = RescriptSchema.S

type jsonSchema = dict<JSON.t>
type jsonSchemaOptions
type jsonSchemaConverter
type standardSchema<'input, 'output>
type standardProps<'input, 'output>
type standardJsonField<'input, 'output>
type standardPropsWithJson<'input, 'output>
type t<'output>

@module("rescript-schema/src/S_Core.mjs")
external standard: Schema.t<'output> => standardSchema<unknown, 'output> = "standard"

@get
external standardProps: standardSchema<'input, 'output> => standardProps<'input, 'output> =
  "~standard"

@obj
external makeJsonSchemaConverter: (
  ~input: jsonSchemaOptions => jsonSchema,
  ~output: jsonSchemaOptions => jsonSchema,
  (),
) => jsonSchemaConverter = ""

@obj
external makeJsonSchemaField: (~jsonSchema: jsonSchemaConverter, ()) => standardJsonField<'input, 'output> =
  ""

@val
@scope("Object")
external assignJsonSchema: (
  standardProps<'input, 'output>,
  standardJsonField<'input, 'output>,
) => standardPropsWithJson<'input, 'output> = "assign"

@obj
external makeStandardSchema: (
  @as("~standard") ~standard: standardPropsWithJson<'input, 'output>,
  (),
) => t<'output> = ""

@set
external setRescriptSchema: (t<'output>, Schema.t<'output>) => unit = "__rescriptSchema"

@val
@scope("Number")
external isInteger: float => bool = "isInteger"

@get
external regexSource: RegExp.t => string = "source"

let jsonString = JSON.Encode.string
let jsonNumber = JSON.Encode.float
let jsonBoolean = JSON.Encode.bool
let jsonArray = JSON.Encode.array
let jsonObject = JSON.Encode.object
let jsonNull = JSON.Encode.null

let set = (schema: jsonSchema, key, value: JSON.t) => Dict.set(schema, key, value)
let setString = (schema, key, value) => set(schema, key, jsonString(value))
let setNumber = (schema, key, value) => set(schema, key, jsonNumber(value))
let setBool = (schema, key, value) => set(schema, key, jsonBoolean(value))

let addDescription = (jsonSchema, schema) => {
  switch schema->Schema.description {
  | Some(description) => setString(jsonSchema, "description", description)
  | None => ()
  }
}

let addStringRefinements = (jsonSchema, schema) =>
  schema->Schema.String.refinements->Belt.Array.forEach(refinement =>
    switch refinement.kind {
    | Schema.String.Refinement.Min({length}) => setNumber(jsonSchema, "minLength", Int.toFloat(length))
    | Max({length}) => setNumber(jsonSchema, "maxLength", Int.toFloat(length))
    | Length({length}) => {
        let length = Int.toFloat(length)
        setNumber(jsonSchema, "minLength", length)
        setNumber(jsonSchema, "maxLength", length)
      }
    | Email => setString(jsonSchema, "format", "email")
    | Uuid => setString(jsonSchema, "format", "uuid")
    | Cuid => setString(jsonSchema, "pattern", "^c[a-z0-9]+$")
    | Url => setString(jsonSchema, "format", "uri")
    | Pattern({re}) => setString(jsonSchema, "pattern", regexSource(re))
    | Datetime => setString(jsonSchema, "format", "date-time")
    },
  )

let addIntRefinements = (jsonSchema, schema) =>
  schema->Schema.Int.refinements->Belt.Array.forEach(refinement =>
    switch refinement.kind {
    | Schema.Int.Refinement.Min({value}) => setNumber(jsonSchema, "minimum", Int.toFloat(value))
    | Max({value}) => setNumber(jsonSchema, "maximum", Int.toFloat(value))
    | Port => {
        setNumber(jsonSchema, "minimum", 0.)
        setNumber(jsonSchema, "maximum", 65535.)
      }
    },
  )

let addFloatRefinements = (jsonSchema, schema) =>
  schema->Schema.Float.refinements->Belt.Array.forEach(refinement =>
    switch refinement.kind {
    | Schema.Float.Refinement.Min({value}) => setNumber(jsonSchema, "minimum", value)
    | Max({value}) => setNumber(jsonSchema, "maximum", value)
    },
  )

let addArrayRefinements = (jsonSchema, schema) =>
  schema->Schema.Array.refinements->Belt.Array.forEach(refinement =>
    switch refinement.kind {
    | Schema.Array.Refinement.Min({length}) => setNumber(jsonSchema, "minItems", Int.toFloat(length))
    | Max({length}) => setNumber(jsonSchema, "maxItems", Int.toFloat(length))
    | Length({length}) => {
        let length = Int.toFloat(length)
        setNumber(jsonSchema, "minItems", length)
        setNumber(jsonSchema, "maxItems", length)
      }
    },
  )

let isOptionalSchema = schema =>
  switch schema->Schema.classify {
  | Schema.Option(_) => true
  | _ => false
  }

let rec jsonValueOfLiteral = (literal: Schema.literal) =>
  switch literal {
  | Schema.String({value}) => jsonString(value)
  | Number({value}) => jsonNumber(value)
  | Boolean({value}) => jsonBoolean(value)
  | Null(_) => jsonNull
  | Array({items, _}) => jsonArray(items->Belt.Array.map(jsonValueOfLiteral))
  | Dict({items, _}) => {
      let objectSchema = Dict.make()
      Dict.toArray(items)->Belt.Array.forEach(((key, value)) => Dict.set(objectSchema, key, jsonValueOfLiteral(value)))
      jsonObject(objectSchema)
    }
  | _ => jsonNull
  }

let jsonSchemaOfLiteral = (literal: Schema.literal) => {
  let schema = Dict.make()

  switch literal {
  | Schema.String({value}) => {
      setString(schema, "type", "string")
      set(schema, "const", jsonString(value))
    }
  | Number({value}) => {
      setString(schema, "type", isInteger(value) ? "integer" : "number")
      set(schema, "const", jsonNumber(value))
    }
  | Boolean({value}) => {
      setString(schema, "type", "boolean")
      set(schema, "const", jsonBoolean(value))
    }
  | Null(_) => {
      setString(schema, "type", "null")
      set(schema, "const", jsonNull)
    }
  | Array(_) | Dict(_) =>
      set(schema, "const", jsonValueOfLiteral(literal))
  | _ => ()
  }

  schema
}

let nullJsonSchema = (): jsonSchema => {
  let schema = Dict.make()
  setString(schema, "type", "null")
  schema
}

let rec jsonSchemaOfUnknownSchema = (schema: Schema.t<unknown>): jsonSchema => {
  let jsonSchema = Dict.make()

  switch schema->Schema.classify {
  | Schema.Never =>
    set(jsonSchema, "not", jsonObject(Dict.make()))
  | Schema.Unknown =>
    ()
  | Schema.String =>
    setString(jsonSchema, "type", "string")
    addStringRefinements(jsonSchema, schema)
  | Schema.Int =>
    setString(jsonSchema, "type", "integer")
    addIntRefinements(jsonSchema, schema)
  | Schema.Float =>
    setString(jsonSchema, "type", "number")
    addFloatRefinements(jsonSchema, schema)
  | Schema.BigInt =>
    setString(jsonSchema, "type", "integer")
  | Schema.Bool =>
    setString(jsonSchema, "type", "boolean")
  | Schema.Literal(literal) =>
    if literal->Schema.Literal.isJsonable {
      Dict.toArray(jsonSchemaOfLiteral(literal))->Belt.Array.forEach(((key, value)) =>
        Dict.set(jsonSchema, key, value)
      )
    }
  | Schema.Option(innerSchema) =>
    Dict.toArray(jsonSchemaOfUnknownSchema(innerSchema))->Belt.Array.forEach(((key, value)) =>
      Dict.set(jsonSchema, key, value)
    )
  | Schema.Null(innerSchema) =>
    set(
      jsonSchema,
      "anyOf",
      jsonArray([
        jsonObject(jsonSchemaOfUnknownSchema(innerSchema)),
        jsonObject(nullJsonSchema()),
      ]),
    )
  | Schema.Array(itemSchema) =>
    setString(jsonSchema, "type", "array")
    set(jsonSchema, "items", jsonObject(jsonSchemaOfUnknownSchema(itemSchema)))
    addArrayRefinements(jsonSchema, schema)
  | Schema.Object({fields, unknownKeys, _}) =>
    let properties = Dict.make()
    let requiredFields =
      Dict.toArray(fields)->Belt.Array.keepMap(((fieldName, item)) => {
        Dict.set(properties, fieldName, jsonObject(jsonSchemaOfUnknownSchema(item.schema)))
        isOptionalSchema(item.schema) ? None : Some(fieldName)
      })

    setString(jsonSchema, "type", "object")
    set(jsonSchema, "properties", jsonObject(properties))

    if requiredFields->Belt.Array.length > 0 {
      set(jsonSchema, "required", jsonArray(requiredFields->Belt.Array.map(jsonString)))
    }

    switch unknownKeys {
    | Schema.Strict => setBool(jsonSchema, "additionalProperties", false)
    | Schema.Strip => ()
    }
  | Schema.Tuple({items}) =>
    setString(jsonSchema, "type", "array")
    set(
      jsonSchema,
      "items",
      jsonArray(items->Belt.Array.map(item => jsonObject(jsonSchemaOfUnknownSchema(item.schema)))),
    )
    let length = Int.toFloat(items->Belt.Array.length)
    setNumber(jsonSchema, "minItems", length)
    setNumber(jsonSchema, "maxItems", length)
  | Schema.Union(schemas) =>
    set(
      jsonSchema,
      "anyOf",
      jsonArray(schemas->Belt.Array.map(schema => jsonObject(jsonSchemaOfUnknownSchema(schema)))),
    )
  | Schema.Dict(valueSchema) =>
    setString(jsonSchema, "type", "object")
    set(
      jsonSchema,
      "additionalProperties",
      jsonObject(jsonSchemaOfUnknownSchema(valueSchema)),
    )
  | Schema.JSON(_) =>
    ()
  }

  addDescription(jsonSchema, schema)
  jsonSchema
}

let jsonSchemaOfRescriptSchema = schema => jsonSchemaOfUnknownSchema(schema->Schema.toUnknown)

let fromRescriptSchema = schema => {
  let standardProps = schema->standard->standardProps
  let jsonSchema = jsonSchemaOfRescriptSchema(schema)
  let jsonSchemaConverter = makeJsonSchemaConverter(~input=_ => jsonSchema, ~output=_ => jsonSchema, ())
  let standardSchema =
    makeStandardSchema(
      ~standard=assignJsonSchema(standardProps, makeJsonSchemaField(~jsonSchema=jsonSchemaConverter, ())),
      (),
    )
  standardSchema->setRescriptSchema(schema)
  standardSchema
}
