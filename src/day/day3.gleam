import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import utils/parsing

pub fn run() -> Result(Int, String) {
  use input <- result.try(parsing.read_file_lines("priv/day3.txt"))
  task2(input)
}

// fn task1(input: List(String)) -> Result(Int, String) {
//   use number_lists <- result.try(
//     input
//     |> list.map(line_to_numbers)
//     |> result.all,
//   )

//   use highest_numbers <- result.map(
//     number_lists
//     |> list.map(find_highest_number)
//     |> list.map(to_highest)
//     |> result.all,
//   )

//   highest_numbers
//   |> list.fold(0, int.add)
// }

fn task2(input: List(String)) -> Result(Int, String) {
  use number_lists <- result.try(
    input
    |> list.map(line_to_numbers)
    |> result.all,
  )

  use highest_from_lists <- result.map(
    number_lists
    |> list.map(highest_in(_, 11))
    |> list.map(fn(high_list) {
      high_list
      |> list.map(int.to_string)
      |> string.concat
      |> int.parse
    })
    |> result.all
    |> result.replace_error("unable to parse number"),
  )

  highest_from_lists
  |> list.fold(0, int.add)
}

pub fn highest_in(l: List(Int), x_behind: Int) -> List(Int) {
  case list.length(l) < x_behind {
    True ->
      io.print_error(
        "list is shorter than x_behind: "
        <> string.inspect(x_behind)
        <> " "
        <> string.inspect(l),
      )
    False -> Nil
  }
  case x_behind < 0, l {
    True, _ -> []
    False, [] -> []
    False, [x, ..xs] -> {
      let #(highest, rest) = highest_with_tail(xs, x_behind, #(x, xs))
      [highest, ..highest_in(rest, x_behind - 1)]
    }
  }
}

fn highest_with_tail(
  l: List(Int),
  x_behind: Int,
  current_highest: #(Int, List(Int)),
) -> #(Int, List(Int)) {
  case l, list.length(l) <= x_behind {
    //this can only ever happen if x_behind == 0
    [], _ -> current_highest
    _, True -> current_highest
    [x, ..xs], False ->
      case x > current_highest.0 {
        True -> highest_with_tail(xs, x_behind, #(x, xs))
        False -> highest_with_tail(xs, x_behind, current_highest)
      }
  }
}

// type Holder {
//   Holder(highest_left: Option(Int), highest: Int, highest_right: Option(Int))
// }

fn line_to_numbers(line: String) -> Result(List(Int), String) {
  line
  |> string.split("")
  |> list.map(int.parse)
  |> result.all
  |> result.replace_error("Unable to turn '" <> line <> "' into numbers")
}
// fn find_highest_number(sequence: List(Int)) -> Holder {
//   let assert [head, ..tail] = sequence
//   list.fold(tail, Holder(None, head, None), fn(acc, n) {
//     case acc.highest < n {
//       // a new highest value was found
//       True -> Holder(Some(acc.highest), n, None)
//       False ->
//         acc.highest_right
//         |> option.or(Some(0))
//         |> option.map(int.max(_, n))
//         |> Holder(acc.highest_left, acc.highest, _)
//     }
//   })
// }

// fn to_highest(holder: Holder) -> Result(Int, String) {
//   case holder.highest_right {
//     Some(n) -> Ok(holder.highest * 10 + n)
//     None ->
//       case holder.highest_left {
//         Some(n) -> Ok(n * 10 + holder.highest)
//         None ->
//           Error(
//             "Holder contains only highest number "
//             <> int.to_string(holder.highest),
//           )
//       }
//   }
// }
