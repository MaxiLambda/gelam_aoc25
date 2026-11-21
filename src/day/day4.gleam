import gleam/dict.{type Dict}
import gleam/list
import gleam/result
import gleam/string
import utils/parsing

pub fn run() -> Result(Int, String) {
  use input <- result.try(parsing.read_file_lines("priv/day4.txt"))
  let bound_x = list.length(input)
  use bound_y <- result.try(
    list.first(input)
    |> result.map(string.length)
    |> result.replace_error("empty input file"),
  )

  list.index_map(input, fn(line, idx_y) {
    string.split(line, "")
    |> list.index_map(fn(char, idx_x) { #(#(idx_x, idx_y), char) })
  })
  |> list.flatten
  |> dict.from_list
  |> task1(bound_x, bound_y)
}

fn task1(
  input: Dict(#(Int, Int), String),
  bound_x: Int,
  bound_y: Int,
) -> Result(Int, String) {
  echo bound_x
  echo bound_y
  echo input
  Ok(0)
}
