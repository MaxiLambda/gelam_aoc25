import gleam/io
import gleam/list
import gleam/result
import gleam/string
import simplifile

pub fn read_file(path: String) -> Result(List(String), Nil) {
  read(path)
  |> result.map_error(fn(e) {
    e |> simplifile.describe_error |> io.println_error
  })
}

fn read(path: String) -> Result(List(String), simplifile.FileError) {
  use content <- result.map(simplifile.read(path))
  string.split(content, "\r\n")
  |> list.filter(fn(line) { line != "" })
}
