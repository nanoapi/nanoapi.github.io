# Overview

In this tutorial, we'll add a new API feature to the node. The request takes an xrb/nano address and the response indicates whether or not it's valid.

## Updating protobuf

We'll update `core.proto` and `util.proto`, which you'll find under the node's `protobuf` directory. For more complex tasks, you may want to create new proto files.

### The request type

First of all, we need to add the request type enum to `core.proto`. 

This uniquely identifies the request with an integer. This is what makes the clients know what message has arrived over the protocol (protobuf is not self describing in its serialized form)

```
enum RequestType
{
    ...
    ADDRESS_VALID = 1000;
}
```

The numeric value is arbitrary, but must be unique and must never be changed or reused. We set it to 1000 in anticipation of other address related APIs, just to group them together.

### The request message

Next we define the request message in `util.proto`. 

```
/** Check if the supplied address is correct */
message req_address_valid {
    /** Address to check, such as xrb_... and nano_...  */
    string address = 1;
}
```

The message name **must** be the same as the request type enum, but with a `req_` prefix, short for request. We also lowercase message names.

This naming convention allows reflective techniques, such as building a generic REST server.

Having `req_` and `res_` prefixes is also helpful for editor completion, grepping, etc.

### The response message

Our final protobuf change is adding the response message to `util.proto`

```
/** Result of address validation */
message res_address_valid {
    /** True if the address is valid */
    bool valid = 1;
}
```

We use the same naming convention here, but with a `res_` prefix, short for response.

## Implementing the functionality

In the C++ node, open `api.hpp` an add this declaration to `api_handler`:

```c++
auto request (req_address_valid request) -> maybe_unique_ptr<nano::api::res_address_valid>;
```

Note that `maybe_unique_ptr` is just a convenient `std::expected` alias. It means we're going to return either a `std::unique_ptr<res_address_valid>` or a `std::error_code`.

Next, let's actually implement the address-checking functionality in `api.cpp`

```c++
auto nano::api::api_handler::request (req_address_valid request_a) -> maybe_unique_ptr<nano::api::res_address_valid>
{
	auto res = std::make_unique<nano::api::res_address_valid> ();
	res->set_valid (xrb_valid_address (request_a.address ().c_str ()) == 0);
	return std::move (res);
}
```

Finally, make sure the request gets called when the node sees the `ADDRESS_VALID` request type in the parse method:

```c++
    case RequestType::ADDRESS_VALID:
    {
        msg = parse_and_request<req_address_valid> (buffer_a);
        break;
    }
```

Rebuild and commit.

## Updating clients

Old clients will continue to work with this updated node, but nobody knows about the new message yet.

Generally, all that's needed is running `ci/protobuf-gen.sh` in the respective client repository. Rebuilding is obviously needed for compiled languages.

## Recommended reading

https://developers.google.com/protocol-buffers/docs/proto3
