# Overview

The Node API changes the C++ node in the following ways:

* `ipc.cpp` implements the IPC mechanisms, currently domain sockets and TCP.
* `api.cpp` implements the API messages. This can be broken into multiple files as the API grows.
* The `protobuf` directory contains the protobuf definitions. Whenever these are changed, the corresponding C++ files are generated when the project is built. The generated files ends up in the api-c directory. These files
should not be checked in.
* `std::expected` and `std::error_code` is used for error handling. These are mapped to protobuf error responses. This means error codes and messages are consistent across clients, as well as the node.

# Expanding the API

**Step 1:** Define the request and response messages in one of the existing `.proto` files in the protobuf directory, or create a new proto file (a large number of proto files is preferred over a few large ones)

If you add new proto-files, make sure you add the corresponding source files to the `rai_protobuf` library in `CMakeLists.txt`

**Step 2:** Implement the message in `api.cpp`. Add new error codes as necessary along with a descriptive error message.

Existing clients **do not** need to be updated unless breaking changes are made. See Versioning below.

# Building

If you have the node repository cloned already, make sure you update submodules:

`git submodule update --init --recursive`

Build as usual.

Protobuf is distributed as a submodule, just like cryptopp and lmdb. This is a reliable way to include protobuf on all operating systems using CMake (an alternative is using Hunter or Conan, which the node is currently not using, while FindProtobuf is too flakey to use)

# Versioning

Protocol Buffers is a pretty lenient encoding, and many changes can be made without breaking old clients. Please see the [protobuf docs](https://developers.google.com/protocol-buffers/docs/proto3#updating) regarding rules for adding, changing and removing fields.

The `core` protobuf definition contains API _major_ and _minor_ version numbers. These are written as part of the preamble in every request and response.

The rules are as follows:

* If the major version is bumped, the API contains breaking changes. Breaking changes MUST be documented in the protocol definition.
* If the minor version is bumped, the API contain non-breaking changes. New message types may be added, and fields may be added to existing messages.

The API versions are NOT bumped if the node makes backwards compatible bugfixes. Thus, there is no need for a patch version. If a bugfix breaks existing clients, the major version must be bumped.

Since the node knows the version of the client, it can adapt the implementation accordingly rather than bumping the major version. For instance, "account_pending" can be coded to behave differently if the client version is >= 1.2.

# Message variations

Let's say a complete rewrite of the `req_account_history` message is required, with many new and changed query parameters and additional response fields.

Instead of making a very flexible message, but with complicated semantics, consider making one or more `req_account_history_<postfix>` messages, with a descriptive postfix.

# Updating clients

Every client has a `ci\protobuf-gen.sh` script which grabs the latest protobuf files from the Node repository and generates new language specific files. 

Additional steps might be necessary (such as rebuilding for C/C++) - see the respective repository.

No kind of API maintenance is required, as there's just a single generic "request" function.
