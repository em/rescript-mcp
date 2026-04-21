import { Server } from "@modelcontextprotocol/sdk/server"
import { StdioServerTransport } from "../../node_modules/@modelcontextprotocol/sdk/dist/esm/server/stdio.js"

const server = new Server(
  { name: "stdio-test-server", version: "1.0.0" },
  { instructions: "stdio test server" },
)

const transport = new StdioServerTransport()

await server.connect(transport)
