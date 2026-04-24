function makeEndpoint(sessionId) {
  return {
    sessionId: undefined,
    onclose: undefined,
    onerror: undefined,
    onmessage: undefined,
    _closed: false,
    _peer: undefined,
    async start() {},
    async close() {
      if (this._closed) {
        return
      }
      this._closed = true
      queueMicrotask(() => {
        this.onclose?.()
      })
    },
    async send(message) {
      if (this._closed || this._peer === undefined || this._peer._closed) {
        throw new Error("Loopback transport is closed")
      }
      queueMicrotask(() => {
        try {
          this._peer.onmessage?.(message)
        } catch (error) {
          this._peer.onerror?.(error instanceof Error ? error : new Error(String(error)))
        }
      })
    },
  }
}

export function makeLoopbackTransportPair(sessionId = "loopback-session") {
  const server = makeEndpoint(sessionId)
  const client = makeEndpoint(sessionId)
  server._peer = client
  client._peer = server
  return { server, client }
}
