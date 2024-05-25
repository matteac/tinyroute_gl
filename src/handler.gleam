import gleam/http/request
import gleam/http/response

pub type Handler(req, res) =
  fn(request.Request(req)) -> response.Response(res)
