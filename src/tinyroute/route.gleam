import gleam/http

pub type Route {
  Route(path: String, method: http.Method)
}

pub fn new(method: http.Method, path: String) {
  Route(path, method)
}
