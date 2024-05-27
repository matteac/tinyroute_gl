import gleam/bytes_builder
import gleam/dict
import gleam/http
import gleam/http/request
import gleam/http/response
import gleam/int
import gleam/io
import gleam/option
import gleam/string

import tinyroute/handler
import tinyroute/route

pub type Router {
  Router(
    routes: dict.Dict(
      route.Route,
      handler.Handler(BitArray, bytes_builder.BytesBuilder),
    ),
    not_found_handler: handler.Handler(BitArray, bytes_builder.BytesBuilder),
    log: Bool,
  )
}

/// Creates a new `Router`
pub fn new() -> Router {
  Router(dict.new(), not_found, True)
}

/// Adds a new handler to the routes with the given method and path
pub fn add(
  router: Router,
  method: http.Method,
  path: String,
  handler: handler.Handler(BitArray, bytes_builder.BytesBuilder),
) -> Router {
  router.routes
  |> dict.insert(route.new(method, path), handler)
  |> Router(router.not_found_handler, router.log)
}

/// Sets the not_found error handler to a custom one
pub fn set_not_found_handler(
  router: Router,
  not_found_handler: handler.Handler(BitArray, bytes_builder.BytesBuilder),
) -> Router {
  Router(router.routes, not_found_handler, router.log)
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

/// Gets the main handler that executes the respective handler for each route
pub fn get_handler(
  router: Router,
) -> handler.Handler(BitArray, bytes_builder.BytesBuilder) {
  fn(req: request.Request(BitArray)) -> response.Response(
    bytes_builder.BytesBuilder,
  ) {
    let route = route.new(req.method, req.path)

    case router.routes |> dict.get(route) {
      Ok(handler) -> log(router.log, req, handler(req))
      Error(_) -> log(router.log, req, router.not_found_handler(req))
    }
  }
}

/// Sets the log flag
pub fn set_log(router: Router, value: Bool) -> Router {
  Router(router.routes, router.not_found_handler, value)
}

fn log(
  log: Bool,
  req: request.Request(BitArray),
  response: response.Response(bytes_builder.BytesBuilder),
) -> response.Response(bytes_builder.BytesBuilder) {
  case log {
    True -> {
      let method = req.method |> http.method_to_string |> string.uppercase
      let query = case req.query {
        option.Some(query) -> query
        option.None -> ""
      }
      io.println(
        method
        <> " "
        <> req.path
        <> query
        <> " "
        <> response.status |> int.to_string,
      )
      response
    }
    _ -> response
  }
}
