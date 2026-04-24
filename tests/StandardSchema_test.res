open Vitest
module S = RescriptSchema.S

@schema
type profile = {
  name: string,
  nickname: option<string>,
  rating: @s.matches(S.floatMax(S.floatMin(S.float, 1.0), 5.0)) float,
}

@schema
type wrapped = {
  topic: string,
  count: @s.matches(S.port(S.int)) int,
}

type standardJsonField

@get external standardProps: McpStandardSchema.t<'a> => dict<unknown> = "~standard"
@get external standardVendor: dict<unknown> => string = "vendor"
@get external standardVersion: dict<unknown> => int = "version"
@get external standardJsonSchema: dict<unknown> => standardJsonField = "jsonSchema"
@send external standardInputSchema: standardJsonField => McpStandardSchema.jsonSchema = "input"
@send external standardOutputSchema: standardJsonField => McpStandardSchema.jsonSchema = "output"

let expectSchema = (~expect, schema, expectedText) =>
  schema
  ->McpStandardSchema.jsonSchemaOfRescriptSchema
  ->McpTestBindings.jsonSchemaToDict
  ->JSON.Encode.object
  ->expect
  ->Expect.toEqual(JSON.parseOrThrow(expectedText))

describe("standard schema bridge", () => {
  test("converts primitive and refined schemas into JSON Schema", t => {
    let expect = value => t->expect(value)
    expectSchema(~expect, S.unknown, "{}")
    expectSchema(~expect, S.never, "{\"not\":{}}")
    expectSchema(~expect, S.bool, "{\"type\":\"boolean\"}")
    expectSchema(~expect, S.bigint, "{\"type\":\"integer\"}")
    expectSchema(~expect, S.port(S.int), "{\"type\":\"integer\",\"minimum\":0,\"maximum\":65535}")
    expectSchema(
      ~expect,
      S.floatMax(S.floatMin(S.float, 1.5), 2.5),
      "{\"type\":\"number\",\"minimum\":1.5,\"maximum\":2.5}",
    )
    expectSchema(
      ~expect,
      S.describe(S.stringMaxLength(S.stringMinLength(S.string, 2), 5), "display name"),
      "{\"type\":\"string\",\"minLength\":2,\"maxLength\":5,\"description\":\"display name\"}",
    )
    expectSchema(~expect, S.stringLength(S.string, 4), "{\"type\":\"string\",\"minLength\":4,\"maxLength\":4}")
    expectSchema(~expect, S.email(S.string), "{\"type\":\"string\",\"format\":\"email\"}")
    expectSchema(~expect, S.uuid(S.string), "{\"type\":\"string\",\"format\":\"uuid\"}")
    expectSchema(~expect, S.cuid(S.string), "{\"type\":\"string\",\"pattern\":\"^c[a-z0-9]+$\"}")
    expectSchema(~expect, S.url(S.string), "{\"type\":\"string\",\"format\":\"uri\"}")
    expectSchema(~expect, S.datetime(S.string), "{\"type\":\"string\",\"format\":\"date-time\"}")
    expectSchema(~expect, S.pattern(S.string, %re("/^[a-z-]+$/")), "{\"type\":\"string\",\"pattern\":\"^[a-z-]+$\"}")
    expectSchema(
      ~expect,
      S.arrayLength(S.array(S.string), 2),
      "{\"type\":\"array\",\"items\":{\"type\":\"string\"},\"minItems\":2,\"maxItems\":2}",
    )
  })

  test("converts object, tuple, union, dict, nullable, optional, and literal schemas", t => {
    let expect = value => t->expect(value)
    let objectSchema = profileSchema
    let strictObjectSchema = S.strict(objectSchema)
    let tupleSchema = S.tuple(s => (s.item(0, S.string), s.item(1, S.int)))
    let unionSchema = S.union([S.string, S.email(S.string), S.url(S.string)])

    expectSchema(
      ~expect,
      objectSchema,
      "{\"type\":\"object\",\"properties\":{\"name\":{\"type\":\"string\"},\"nickname\":{\"type\":\"string\"},\"rating\":{\"type\":\"number\",\"minimum\":1,\"maximum\":5}},\"required\":[\"name\",\"rating\"]}",
    )
    expectSchema(
      ~expect,
      strictObjectSchema,
      "{\"type\":\"object\",\"properties\":{\"name\":{\"type\":\"string\"},\"nickname\":{\"type\":\"string\"},\"rating\":{\"type\":\"number\",\"minimum\":1,\"maximum\":5}},\"required\":[\"name\",\"rating\"],\"additionalProperties\":false}",
    )
    expectSchema(
      ~expect,
      tupleSchema,
      "{\"type\":\"array\",\"items\":[{\"type\":\"string\"},{\"type\":\"integer\"}],\"minItems\":2,\"maxItems\":2}",
    )
    expectSchema(
      ~expect,
      unionSchema,
      "{\"anyOf\":[{\"type\":\"string\"},{\"type\":\"string\",\"format\":\"email\"},{\"type\":\"string\",\"format\":\"uri\"}]}",
    )
    expectSchema(~expect, S.dict(S.string), "{\"type\":\"object\",\"additionalProperties\":{\"type\":\"string\"}}")
    expectSchema(~expect, S.option(S.string), "{\"type\":\"string\"}")
    expectSchema(~expect, S.nullable(S.string), "{\"anyOf\":[{\"type\":\"string\"},{\"type\":\"null\"}]}")
    expectSchema(~expect, S.literal("fixed"), "{\"type\":\"string\",\"const\":\"fixed\"}")
    expectSchema(~expect, S.literal(3.5), "{\"type\":\"number\",\"const\":3.5}")
    expectSchema(~expect, S.literal(true), "{\"type\":\"boolean\",\"const\":true}")
    expectSchema(~expect, S.literal(null), "{\"type\":\"null\",\"const\":null}")
  })

  test("adds JSON Schema converters onto the Standard Schema wrapper", t => {
    let expect = value => t->expect(value)
    let schema = wrappedSchema
    let expectedText =
      schema
      ->McpStandardSchema.jsonSchemaOfRescriptSchema
      ->McpTestBindings.jsonSchemaToDict
      ->JSON.Encode.object
      ->JSON.stringifyAny
      ->Option.getOr("")
    let standard = schema->McpStandardSchema.fromRescriptSchema
    let props = standard->standardProps

    (
      props->standardVendor,
      props->standardVersion,
      props
      ->standardJsonSchema
      ->standardInputSchema
      ->McpTestBindings.jsonSchemaToDict
      ->JSON.Encode.object
      ->JSON.stringifyAny
      ->Option.getOr(""),
      props
      ->standardJsonSchema
      ->standardOutputSchema
      ->McpTestBindings.jsonSchemaToDict
      ->JSON.Encode.object
      ->JSON.stringifyAny
      ->Option.getOr(""),
    )
    ->expect
    ->Expect.toEqual(("rescript-schema", 1, expectedText, expectedText))
  })
})
