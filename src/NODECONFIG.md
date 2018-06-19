# Node configuration

To enable API access from external or remote processes, the desired IPC transport must be enabled.

If the ipc config node is not present, no API access is possible.

Here's a minimal config enabling domain sockets:

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

Here's the complete config structure along with default values:

```
"node": {
    ...
    "ipc": {
        "local": {
            "enable": "false",
            "enable_control": "false",
            "io_timeout": "15"
        },
        "tcp": {
            "enable": "false",
            "enable_control": "false",
            "host": "::1",
            "port": "7077",
            "io_timeout": "15"
        }
    }
}
```

io_timeout is read/write timeout in seconds.
