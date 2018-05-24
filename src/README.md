# About the Nano Node API

The Node API exposes functionality to external processes over various interprocess mechanisms. Using the API, you'll be able to query account information, sign blocks, check for pending transactions, and much more.

The API currently offers:

* A C API
* A Python API
* A REST server based on the Python API
* Transports over TCP and domain sockets

The following bindings are planned:

* Node (Typescript and Javascript)
* Java
* Rust
* Go
* C++

## Protocol Buffers

The API is based on queries defined using Protocol Buffers (protobuf). The query/response protocol is agnostic about the serialization format. Hence, adding support for additional encodings, such as Cap'n'Proto, is possible in the future.

Protocol Buffers offers the following benefits: 

* Relatively easy to create new Node APIs for various programming languages.
* A single message definition enforces up-to-date documentation that's useful for all language bindings.
* A canonical JSON representation. This makes it easy to write stuff like writing REST servers in dynamic languages.

Queries can be sent over various transports, such as TCP, domain sockets, pipes and shared memory. Currently, TCP and domain sockets are supported by the node.

### Message Definitions
The protobuffer definition is available at https://github.com/nanoapi/ and is documented at https://nanoapi.github.io/protobuf/index.html

## Repository Structure

All API code is located under the `nanoapi` organization at GitHub.

* The `protobuf` repository contains the definition
* Each language binding is a separate repository, linking `protobuf` as a git submodule.
* Each language repository contains a script to generate code from the protobuf definition.

## Runtime Libraries

For each supported language, a runtime library is available. Please see the `api-<language>` repositories in https://github.com/nanoapi/ for more information about a specific language.

In general, the runtime library provides:

* Generated protobuf data types.
* Functionality to connect to the Nano node over various transports, such as TCP and domain sockets. The node must be configured to accept connections on the given transport. A node may accept connections on multiple transports at once.
* A query API, allowing protbuf-generated messages to be sent over the given transport.

## Python API

Here's an example of using Python to connect to the node over domain sockets and issue a pending query:

```python
from nanoapi import (Client, SocketConnection, Model)

# Connect using a domain socket. On multiuser systems, the directory can be protected to allow only specific users.
# To switch to tcp, simply use tcp://host:post as the connection string.
nano = Client(SocketConnection('local:///tmp/nano'))

# Account pending query
pending = Model.query_account_pending();
pending.threshold.value = "200000000000000000000000";
pending.accounts.append("xrb_16u1uufyoig8777y6r8iqjtrw8sg8maqrm36zzcm95jmbd9i9aj5i8abr8u5");
pending.accounts.append("xrb_3eff1rokrp4ryronxpjdhzijxt9oax117xtn3eaqcaxcemp6y6fkarpqq8wj");

# Print the query as JSON
print (nano.to_json(pending))

# Call the Node
res = nano.query(pending)

# Print the response as JSON
print (nano.to_json(res))

```

## C API

The C API is fairly low level and requires manual memory management. It is only recommended to use this API to build bindings for new languages, using whatever FFI mechanisms are available.

[C99 Example](https://github.com/nanoapi/api-c/blob/master/examples/example-socket-client.c)

Please note that you can create Nano API's for new languages without using the C API. This requires Protobuffer support for the language at hand. As for the node communication, a new language binding can either reimplement the (very simple) protocol for sending queries over various transports, or it can delegate transport specifics to the C API using FFI bindings. 

The Python API, for instance, is standalone. Reimplementing the TCP and domain socket transports is trivial in most languages.

## Query/Response Protocol

To communicate with the Node over a given transport, the Query/Response Protocol is used. This can be trivially implemented in most languages since almost all of the serialization and deserialization work is already done by protobuf.

## C++ Node Doxygen Documentation

The Node is written in C++ and documentation is currently being moved to Doxygen.

[Doxygen Documentation](https://nanoapi.github.io/doxygen/annotated.html)

