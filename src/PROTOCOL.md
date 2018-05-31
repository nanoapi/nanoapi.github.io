# Request/Response Protocol

Each language runtime implements a very simple request/response protocol to communicate with the node over supported IPC mechanisms. Instead of reimplementing the protocol, an implementation can delegate to the C API over FFI (or whatever existing API language is most suitable)

## Encoding
The protocol is a simple length-prefixed binary format with a header message for both the request and the response to indicate what type of request is being transmitted. The request type must be present in the response header as well, in anticipation of future callback/async features.

### Request

```
[4 bytes preamble]
[32-bit big-endian length]
[Protobuf encoded request header message]
[32-bit big-endian length]
[Protobuf encoded request message]
```

The preamble has the following structure:

```
Byte 1: 'N'
Byte 2: 0x01
Byte 3: Major protocol version
Byte 4: Minor protocol version
```

The first two bytes serves as a magic header. If the message encoding changes
in the future (say, moving from Protobuf to Cap'N'Proto), the second byte is bumped.

The version numbers adhere to this scheme:

1. The major version is bumped if there is a breaking message definition change, such
as renaming a message or making changes that Protobuf deems incompatible.
2. This is bumped if a compatible change has been made. Message fields can usually
be added and removed without breaking existing clients.

Please see https://developers.google.com/protocol-buffers/docs/proto3#updating

### Response

```
[4 bytes preamble]
[32-bit big-endian length]
[Protobuf encoded response header message]
[32-bit big-endian length]
[Protobuf encoded response message]
```

The preamble is the same as with the request, but with version information from
the node.

## Protocol Buffers encoding
The request header is defined by the Request message type, and the response header is defined by the Response message type. Please see the [protobuf specification](https://nanoapi.github.io/protobuf/index.html) for more information.
