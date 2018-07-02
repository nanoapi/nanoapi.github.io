# Node configuration

To enable API access from external or remote processes, the desired IPC transport must be enabled.

If the "ipc" config node is not present in `config.json`, no IPC access is possible.

Here's a minimal config enabling "local" domain sockets:

```
"node": {
    ...
    "ipc": {
        "local": {
            "enable": "true",
        }
    }
}
```

Here's the complete config structure along with *default* values:

```
"node": {
    ...
    "ipc": {
        "local": {
            "enable": "false",
            "enable_control": "false",
            "path": "/tmp/nano",
            "io_timeout": "15"
            "io_threads": "<number of cores/HT, minimum 4>"
        },
        "tcp": {
            "enable": "false",
            "enable_control": "false",
            "host": "::1",
            "port": "7077",
            "io_timeout": "15"
            "io_threads": "<number of cores/HT, minimum 4>"
        }
    }
}
```

io_timeout is read/write timeout in seconds.

If io_threads is "0", the event dispatcher used by the node will also be used by the IPC server, in which case the node's "io_threads" applies. In some configurations, using a separate event dispatcher may yield better scalabilty and stability. There may also be performance issues using the same dispatcher on multiple socket types, such as domain + TLS.

io_threads can be set separately for each transport. For instance, if tcp is only used for occasional ping messages and domain sockets handles the primary query traffic, tcp threads can be set to 1, while domain threads can be default or set to a higher value.