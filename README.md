# tinyroute

[![Package Version](https://img.shields.io/hexpm/v/tinyroute)](https://hex.pm/packages/tinyroute)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/tinyroute/)

```sh
gleam add tinyroute
```
```gleam
import gleam/http
import gleam/http/elli // or what you want to use
import gleam/http/request
import gleam/http/response
import gleam/bytes_tree
import tinyroute/router

fn index_handler(
  _req: request.Request(BitArray),
) -> response.Response(bytes_tree.BytesTree) {
  let body = bytes_tree.from_string("Hello, World!")
  200
  |> response.new
  |> response.set_body(body)
}

pub fn main() {
  router.new()
  |> router.add(http.Get, "/", index_handler)
  |> router.get_handler
  |> elli.become(on_port: 3000)
}
```

Further documentation can be found at <https://hexdocs.pm/tinyroute>.

