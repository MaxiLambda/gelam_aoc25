import gleam/int
import gleam/list
import gleam/result
import gleam/string
import utils/parsing

pub fn run() -> Result(Int, String) {
  use lines <- result.try(parsing.read_file_lines("priv/day5.txt"))

  let #(ranges_strings, values_strings) =
    list.split_while(lines, string.contains(_, "-"))

  use ranges <- result.try(
    ranges_strings |> list.map(parse_range) |> result.all,
  )
  use values <- result.map(
    values_strings
    |> list.map(fn(s) {
      s |> int.parse |> result.replace_error("unable to parse number")
    })
    |> result.all,
  )

  values
  |> list.count(fn(val) { list.any(ranges, range_contains(_, val)) })
}

fn range_contains(range: #(Int, Int), val: Int) -> Bool {
  range.0 <= val && range.1 >= val
}

fn parse_range(line: String) -> Result(#(Int, Int), String) {
  use #(start, end) <- result.try(
    string.split_once(line, "-")
    |> result.replace_error("'" <> line <> "' is not a range"),
  )
  use s <- result.try(
    int.parse(start)
    |> result.replace_error("unable to parse " <> start <> " into an int"),
  )
  use e <- result.map(
    int.parse(end)
    |> result.replace_error("unable to parse " <> end <> " into an int"),
  )
  #(s, e)
}
//     3-5
//        10-20
//
//
// 3-5    10-20
//
// 3-5  10-14 16-20
//         12-18
//
//
//
//
//
//
//
//
//          6
//     3        8
//  1     4   7    9
//
//
//
//
//
//
