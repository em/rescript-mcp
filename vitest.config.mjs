export default {
  test: {
    include: ["tests/**/*_test.mjs"],
    environment: "node",
    coverage: {
      provider: "v8",
      include: ["src/**/*.mjs"],
      thresholds: {
        branches: 80,
        functions: 80,
        lines: 80,
        statements: 80,
      },
    },
  },
}
