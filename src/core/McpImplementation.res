// src/core/McpImplementation.res
// Concern: construct the SDK implementation object passed to server and client constructors.
type t

@obj
external make: (~name: string, ~version: string) => t = ""
