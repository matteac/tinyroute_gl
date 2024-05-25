import gleam/http
import gleam/http/elli
import gleam/http/request
import gleam/http/response
import router

// or what you want to use
import gleam/bytes_builder

fn index_handler(
  _req: request.Request(BitArray),
) -> response.Response(bytes_builder.BytesBuilder) {
  let body = bytes_builder.from_string("Hello, World!")
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
