# Query/Response Protocol

Each language runtime implements a very simple query/response protocol to communicate with the node over supported IPC mechanisms. Instead of reimplementing the protocol, an implementation can delegate to the C API over FFI (or whatever existing API language is most suitable)

## Encoding
The protocol is a simple length-prefixed binary format with a header message for both the query and the response to indicate what type of query is being transmitted. The query type must be present in the response header as well, in anticipation of future callback/async features.

Query

```
[32-bit big-endian reserved]
[32-bit big-endian length]
[Query protobuf encoded message]
[32-bit big-endian length]
[Query<queryname> protobuf encoded message]
```

The initial reserved four bytes is currently unspecified, but will allow for additional serialization formats in the future.

Response

```
[32-bit big-endian length]
[Response protobuf encoded message]
[32-bit big-endian length]
[Response<queryname> protobuf encoded message]
```

## Protocol Buffers encoding
The query header is defined by the Query message type, and the response header is defined by the Response message type. Please see the [protobuf specification](https://nanoapi.github.io/protobuf/index.html) for more information.
