# About the Nano Node API

The Node API exposes functionality to external processes over various interprocess mechanisms. Using the API, you'll be able to query account information, sign blocks, check for pending transactions, etc.

The API currently offers:

* C and C++ API
* Python API
* Go API
* REST server based on the Python API
* Transports over TCP and domain sockets

The following bindings are planned:

* Node (Typescript and Javascript)
* Java
* Rust

## Protocol Buffers

The API is based on exchanging messages defined using Protocol Buffers (protobuf). The request/response protocol is agnostic about the serialization format. Hence, adding support for additional serialization formats, such as Cap'n'Proto, is possible in the future.

Protocol Buffers offers the following benefits:

* Relatively easy to support new programming languages and platforms.
* A single message definition enforces up-to-date documentation that's relevant to all language bindings.
* Efficient on-wire binary representation.
* A canonical JSON representation makes it easy to write stuff like REST servers in dynamic languages.

Request can theorectically be sent over any number of transports, such as TCP, domain sockets, pipes and shared memory. Currently, TCP and domain sockets are supported by the node.

### Message Definitions
The protobuffer definition is part of the node respository (see the protobuf directory) and is documented at https://nanoapi.github.io/protobuf/index.html

## Repository Structure

All code is located under the [nanoapi](https://github.com/nanoapi/) organization at GitHub.

* The `protobuf` repository contains the definition
* Each language binding is a separate repository, `api-<language>`.
* Each language repository contains a script to generate code from the protobuf definition.

## Runtime Libraries

For each supported language, a runtime library is available. Please see the `api-<language>` repositories in https://github.com/nanoapi/ for more information.

In general, the runtime library provides:

* Generated Protobuf message types.
* Functionality to connect to the Nano node over various transports. The node must be configured to accept connections on the given transport. A node may accept connections on multiple transports at once.
* A request/response API, allowing Protbuf-generated messages to be exchanged over the given transport.

## Python API

Here's an example of using Python to connect to the node over domain sockets and query pending accounts:

```python
from nanoapi import (Client, SocketConnection, Model)

# Connect using a domain socket. On multiuser systems, the directory can be protected to allow only specific users.
# To switch to tcp, simply use tcp://host:post as the connection string.
nano = Client(SocketConnection('local:///tmp/nano'))

# Account pending request
pending = Model.req_account_pending();
pending.threshold.value = "200000000000000000000000";
pending.accounts.append("xrb_16u1uufyoig8777y6r8iqjtrw8sg8maqrm36zzcm95jmbd9i9aj5i8abr8u5");
pending.accounts.append("xrb_3eff1rokrp4ryronxpjdhzijxt9oax117xtn3eaqcaxcemp6y6fkarpqq8wj");

# Print the request as JSON
print (nano.to_json(pending))

# Call the Node
res = nano.request(pending)

# Print the response as JSON
print (nano.to_json(res))
```

## C API

The C API is fairly low level and requires manual memory management. It is only recommended to use this API to build bindings for new languages, using whatever FFI mechanisms are available.

[C99 Example](https://github.com/nanoapi/api-c/blob/master/examples/example-client.c)

Note that you can create clients for new languages without using the C API. This requires Protobuffer support for the language at hand (if not officially support, you'll likely to find a plugin for the language).

As for communicating with the node, a new language binding can either reimplement the (very simple) protocol for sending requests over various transports, or it can delegate transport specifics to the C API using FFI bindings.

## C++ API

The C++ API is a high-level wrapper around the C API.

[C++ Example](https://github.com/nanoapi/api-c/blob/master/examples/example-client.cpp)

## Go API

The Go API is an implementation in pure Go, supporting domain sockets and TCP.

[Go Example](https://github.com/nanoapi/api-go/blob/master/examples/simple/main.go)

## Request/Response Protocol

To communicate with the Node over a given transport, the Request/Response Protocol is used. Implementation in most languages is straightforward, since almost all of the serialization and deserialization work is already done by the Protobuf runtime.

## C++ Node Doxygen Documentation

The Node is written in C++ and documentation is currently being moved to Doxygen.

[Doxygen Documentation](https://nanoapi.github.io/doxygen/annotated.html)
