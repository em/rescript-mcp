export default {
  test: {
    include: ["tests/**/*_test.mjs"],
    environment: "node",
    coverage: {
      provider: "v8",
      include: ["src/**/*.mjs"],
      exclude: ["src/Mcp.mjs", "src/**/Mcp*.mjs"],
    },
  },
}
