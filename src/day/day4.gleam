import gleam/dict.{type Dict}
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import utils/parsing

const offsets = [
  #(0, -1),
  #(0, 1),
  #(-1, 0),
  #(-1, -1),
  #(-1, 1),
  #(1, 0),
  #(1, -1),
  #(1, 1),
]

pub fn run() -> Result(Int, String) {
  use input <- result.try(parsing.read_file_lines("priv/day4.txt"))

  input |> list.map(io.println)

  list.index_map(input, fn(line, idx_y) {
    string.split(line, "")
    |> list.index_map(fn(char, idx_x) { #(#(idx_x, idx_y), char) })
  })
  |> list.flatten
  |> dict.from_list
  |> task1
  |> Ok
}

fn task1(input: Dict(#(Int, Int), String)) -> Int {
  dict.filter(input, fn(pos, symbol) {
    let paper = symbol == "@"
    let enough_space = has_space(input, pos)
    paper && enough_space
  })
  |> dict.size
}

fn has_space(dict: Dict(#(Int, Int), String), pos: #(Int, Int)) -> Bool {
  offsets
  |> list.map(apply_offset(pos, _))
  |> list.count(is_paper(dict, _))
  < 4
}

fn is_paper(dict: Dict(#(Int, Int), String), pos: #(Int, Int)) -> Bool {
  dict.get(dict, pos)
  |> result.map(fn(symbol) { symbol == "@" })
  |> result.unwrap(False)
}

fn apply_offset(pos: #(Int, Int), offset: #(Int, Int)) {
  #(pos.0 + offset.0, pos.1 + offset.1)
}
