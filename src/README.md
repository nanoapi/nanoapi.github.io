# About the Nano Node API

The Node API exposes functionality to external processes over various interprocess mechanisms.

The long-term plan is to support most (but not all) of the current RPC actions, though using smaller and more composable messages.

The API currently offers:

* C, C++, Python and Go clients
* Two REST servers based on the Go and Python clients
* Transports over TCP and domain sockets

The following clients are planned:

* Node (Typescript and Javascript)
* Java, using Netty
* Rust, using Tokio

## Protocol Buffers

The API is based on exchanging protobuf messages. That said, the request/response protocol is agnostic about the serialization format. Hence, adding support for additional serialization formats, such as Cap'n'Proto, is possible in the future.

Protocol Buffers offers the following benefits:

* Relatively easy to support new programming languages and platforms.
* A single message definition enforces up-to-date documentation that's relevant to all language bindings.
* Compact on-wire binary representation.
* A canonical JSON representation makes it easy to write stuff like REST servers.

In theory, requests can be sent over any number of transports, such as TCP, domain sockets, pipes and shared memory. Currently, TCP and domain sockets are supported by the node.

### Message Definitions
The protobuffer definition is part of the node respository, and is documented at https://nanoapi.github.io/protobuf/index.html

## Repository Structure

All client code is located under the [nanoapi](https://github.com/nanoapi/) organization at GitHub.

* Each language binding is a separate repository, `api-<language>`.
* Each repository contains a script to generate source code from the node's protobuf definitions.

## Runtime Libraries

For each supported language, a runtime library is available. Please see the `api-<language>` repositories in https://github.com/nanoapi/ for more information.

In general, the runtime library provides:

* Generated Protobuf message types.
* Functionality to connect to the Nano node over various transports. The node must be configured to accept connections on the given transport. A node may accept connections on multiple transports at once.
* A request/response API

## Python API

Here's an example of using Python to connect to the node over domain sockets and query pending block hashes:

```python
from nanoapi import (Client, SocketConnection, Model)

# Connect using a domain socket. On multiuser systems, the directory can be protected to allow only specific users.
# To switch to tcp, use tcp://host:post as the connection string.
nano = Session(SocketConnection('local:///tmp/nano'))

# Account pending request
pending = Model.req_account_pending();
pending.threshold.value = "200000000000000000000000";
pending.accounts.append("xrb_16u1uufyoig8777y6r8iqjtrw8sg8maqrm36zzcm95jmbd9i9aj5i8abr8u5");
pending.accounts.append("xrb_3eff1rokrp4ryronxpjdhzijxt9oax117xtn3eaqcaxcemp6y6fkarpqq8wj");

# Print the request as JSON
print (nano.to_json(pending))

# Send request to the node
res = nano.request(pending)

# Print the response as JSON
print (nano.to_json(res))
```

## C API

The C API is fairly low level and requires manual memory management. It is only recommended to use this API to build bindings for new languages, using whatever FFI mechanisms are available.

[C99 Example](https://github.com/nanoapi/api-c/blob/master/examples/example-client.c)

Note that you can create clients for new languages without using the C API. This requires protobuf support for the language at hand (if not officially support, you're likely to find a plugin for the language).

As for communicating with the node, a new language binding can either reimplement the protocol, or it can delegate transport specifics to the C API using FFI bindings.

## C++ API

The C++ API is a high-level wrapper around the C API.

[C++ Example](https://github.com/nanoapi/api-c/blob/master/examples/example-client.cpp)

## Go API

The Go API is an implementation in pure Go, supporting domain sockets and TCP.

[Go Example](https://github.com/nanoapi/api-go/blob/master/examples/simple/main.go)

## REST servers

The Go and Python repositories each provide a REST server. As they employ protobuf reflection, there is nothing to maintain; new messages and changes to existing ones are picked up automatically. 

The Go version uses multiple concurrent node connections and is an order of magnitude faster than the Python version. It also scales to a larger number of clients.

Translation between JSON and protobuf happens automatically, and the message name is used as the endpoint.

Sample POST request to `http://localhost:8080/api/account_pending`

```
{
  "count" : 3,
  "source": true,
  "threshold": "1000000000000000000000000",
  "accounts": [
    "xrb_1111111111111111111111111111111111111111111111111111hifc8npp",
    "xrb_3t6k35gi95xu6tergt6p69ck76ogmitsa8mnijtpxm9fkcm736xtoncuohr3"
  ]
}
```

Response:

```
{
    "pending": [
        {
            "account": "xrb_1111111111111111111111111111111111111111111111111111hifc8npp",
            "block_info": [
                {
                    "hash": "8AD284236B8B595F532133BAFC880A7AD730DA7FAB228F0C1217CB0F5922078D",
                    "amount": "5000000000000000000000000000000",
                    "source": "xrb_3rraux9itg9ukc11jmeqxjdxyuxkgbipq3aq8bm51w1y9jxi75rbrbiesy16"
                },
                {
                    "hash": "C529AB93A289F8F89B964F4C970D9752089A4156E4C44F70761449B597997BDF",
                    "amount": "118657000000000000000000000000000000",
                    "source": "xrb_35jjmmmh81kydepzeuf9oec8hzkay7msr6yxagzxpcht7thwa5bus5tomgz9"
                },
                {
                    "hash": "C7764B37F04C74CF814B19C4DC6FFD53B5E999495C8E5C0D7EA1372A57E1E9C6",
                    "amount": "1238933000000000000000000000000000000",
                    "source": "xrb_13ezf4od79h1tgj9aiu4djzcmmguendtjfuhwfukhuucboua8cpoihmh8byo"
                }
            ]
        },
        {
            "account": "xrb_3t6k35gi95xu6tergt6p69ck76ogmitsa8mnijtpxm9fkcm736xtoncuohr3",
            "block_info": [
                {
                    "hash": "4C1FEEF0BEA7F50BE35489A1233FE002B212DEA554B55B1B470D78BD8F210C74",
                    "amount": "106370018000000000000000000000000",
                    "source": "xrb_13ezf4od79h1tgj9aiu4djzcmmguendtjfuhwfukhuucboua8cpoihmh8byo"
                },
                {
                    "hash": "5BE46EB2D80A147FE7F96CA43407496758900A31E7053A8A90683328A4A2BFFF",
                    "amount": "308757000000000000000000000000",
                    "source": "xrb_13ezf4od79h1tgj9aiu4djzcmmguendtjfuhwfukhuucboua8cpoihmh8byo"
                },
                {
                    "hash": "6003F679CBED0AC2384B2439FD1EA06003335871823E6BEFD37B833BE8AC6EDC",
                    "amount": "1408360000000000000000000000000",
                    "source": "xrb_13ezf4od79h1tgj9aiu4djzcmmguendtjfuhwfukhuucboua8cpoihmh8byo"
                }
            ]
        }
    ]
}
```