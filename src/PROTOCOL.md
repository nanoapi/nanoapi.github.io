# Request/Response Protocol
Each language binding implements a very simple request/response protocol to communicate with the node over the IPC mechanisms the clients wants to support. An implementation can alternatively delegate to an existing API binding, such as C FFI.

## Protocol layout
The protocol is a length-prefixed binary format with a header message for both the request and the response to indicate what type of request is being transmitted. The request type must be present in the response header as well, in anticipation of future callback/async features.

### Request

```
[4 bytes preamble]
[32-bit big-endian length]
[Protobuf encoded request header]
[32-bit big-endian length]
[Protobuf encoded request]
```

The preamble has the following structure:

```
Byte 1: 'N' (magic)
Byte 2: 0x00 (encoding type)
Byte 3: Major protocol version
Byte 4: Minor protocol version
```

If the message encoding changes in the future (say, moving from Protobuf to Cap'N'Proto, possibly supporting both), the encoding type is changed accordingly.

If a node doesn't support the requested encoding, it will respond with a preamble containing a different encoding byte. The client API should report this as an unsupported-encoding error in a language idiomatic way (e.g. throwing an exception)

The version numbers adhere to this scheme:

1. The major version is bumped if there is a breaking change, such as renaming a message or making changes that Protobuf deems incompatible [1]
2. The minor version is bumped if a compatible change has been made [1]. Message fields can usually be added and removed without breaking existing clients.

[1] Please see https://developers.google.com/protocol-buffers/docs/proto3#updating

### Response

```
[4 bytes preamble]
[32-bit big-endian length]
[Protobuf encoded response header]
[32-bit big-endian length]
[Protobuf encoded response]
```

The preamble is the same as with the request, but with version information from the node.

## Protocol Buffers
The request header is defined by the `Request` message type, and the response header is defined by the `Response` message type. Please see the [protobuf specification](https://nanoapi.github.io/protobuf/index.html) for more information.
