import gleam/bytes_builder
import gleam/dict
import gleam/http
import gleam/http/request
import gleam/http/response
import gleam/string

import tinyroute/handler
import tinyroute/route

pub type Router {
  Router(
    routes: dict.Dict(
      route.Route,
      handler.Handler(BitArray, bytes_builder.BytesBuilder),
    ),
  )
}

pub fn new() -> Router {
  Router(dict.new())
}

pub fn add(
  router: Router,
  method: http.Method,
  path: String,
  handler: handler.Handler(BitArray, bytes_builder.BytesBuilder),
) -> Router {
  router.routes
  |> dict.insert(route.new(method, path), handler)
  |> Router
}

fn not_found(
  req: request.Request(BitArray),
) -> response.Response(bytes_builder.BytesBuilder) {
  404
  |> response.new
  |> response.set_body(bytes_builder.from_string(
    "Cannot "
    <> req.method |> http.method_to_string |> string.uppercase
    <> " "
    <> req.path,
  ))
}

pub fn get_handler(
  router: Router,
) -> handler.Handler(BitArray, bytes_builder.BytesBuilder) {
  fn(req: request.Request(BitArray)) -> response.Response(
    bytes_builder.BytesBuilder,
  ) {
    let route = route.new(req.method, req.path)
    case router.routes |> dict.get(route) {
      Ok(handler) -> handler(req)
      Error(_) -> not_found(req)
    }
  }
}
