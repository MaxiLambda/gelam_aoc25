import gleam/list
import gleam/result
import gleam/string
import simplifile

pub fn read_file_lines(path: String) -> Result(List(String), String) {
  read_lines(path)
  |> result.map_error(fn(e) {
    e |> simplifile.describe_error
  })
}

fn read_lines(path: String) -> Result(List(String), simplifile.FileError) {
  use content <- result.map(simplifile.read(path))
  string.split(content, "\r\n")
  |> list.filter(fn(line) { line != "" })
}

pub fn read_file(path: String) -> Result(String, String) {
  simplifile.read(path)
  |> result.map_error(simplifile.describe_error)
}