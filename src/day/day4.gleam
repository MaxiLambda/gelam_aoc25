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
  |> list.filter(fn(entry) { entry.1 == "@" })
  |> dict.from_list
  |> task2
  |> Ok
}

// fn task1(input: Dict(#(Int, Int), String)) -> Int {
//   dict.filter(input, fn(pos, symbol) {
//     let paper = symbol == "@"
//     let enough_space = has_space(input, pos)
//     paper && enough_space
//   })
//   |> dict.size
// }

fn task2(input: Dict(#(Int, Int), String)) -> Int {
  let initial_size = dict.size(input)
  let leftover = remove_all_possible(input) |> dict.size
  initial_size - leftover
}

fn remove_all_possible(
  input: Dict(#(Int, Int), String),
) -> Dict(#(Int, Int), String) {
  let after_removal = dict.filter(input, fn(pos, _) { !has_space(input, pos) })
  case dict.size(after_removal) == dict.size(input) {
    True -> after_removal
    False -> remove_all_possible(after_removal)
  }
}

fn has_space(input: Dict(#(Int, Int), String), pos: #(Int, Int)) -> Bool {
  offsets
  |> list.map(apply_offset(pos, _))
  |> list.count(is_paper(input, _))
  < 4
}

fn is_paper(input: Dict(#(Int, Int), String), pos: #(Int, Int)) -> Bool {
  dict.get(input, pos)
  |> result.map(fn(_) { True })
  |> result.unwrap(False)
}

fn apply_offset(pos: #(Int, Int), offset: #(Int, Int)) {
  #(pos.0 + offset.0, pos.1 + offset.1)
}
