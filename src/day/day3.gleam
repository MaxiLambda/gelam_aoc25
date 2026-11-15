import gleam/int
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/result
import gleam/string
import utils/parsing

pub fn run() -> Result(Int, String) {
  use input <- result.try(parsing.read_file_lines("priv/day3.txt"))
  task1(input)
}

fn task1(input: List(String)) -> Result(Int, String) {
  use number_lists <- result.try(
    input
    |> list.map(line_to_numbers)
    |> result.all,
  )

  use highest_numbers <- result.map(
    number_lists
    |> list.map(find_highest_number)
    |> list.map(to_highest)
    |> result.all,
  )

  highest_numbers
  |> list.fold(0, int.add)
}

type Holder {
  Holder(highest_left: Option(Int), highest: Int, highest_right: Option(Int))
}

fn line_to_numbers(line: String) -> Result(List(Int), String) {
  line
  |> string.split("")
  |> list.map(int.parse)
  |> result.all
  |> result.replace_error("Unable to turn '" <> line <> "' into numbers")
}

fn find_highest_number(sequence: List(Int)) -> Holder {
  let assert [head, ..tail] = sequence
  list.fold(tail, Holder(None, head, None), fn(acc, n) {
    case acc.highest < n {
      // a new highest value was found
      True -> Holder(Some(acc.highest), n, None)
      False ->
        acc.highest_right
        |> option.or(Some(0))
        |> option.map(int.max(_, n))
        |> Holder(acc.highest_left, acc.highest, _)
    }
  })
}

fn to_highest(holder: Holder) -> Result(Int, String) {
  case holder.highest_right {
    Some(n) -> Ok(holder.highest * 10 + n)
    None ->
      case holder.highest_left {
        Some(n) -> Ok(n * 10 + holder.highest)
        None ->
          Error(
            "Holder contains only highest number "
            <> int.to_string(holder.highest),
          )
      }
  }
}
