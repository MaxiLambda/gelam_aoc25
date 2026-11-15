import gleam/bool
import gleam/function
import gleam/int
import gleam/list
import gleam/result
import utils/parsing

const starting_point = 50

const modulus = 100

pub fn run() -> Result(Int, Nil) {
  use input <- result.try(parsing.read_file_lines("priv/day1.txt"))
  day1_task2(input)
}

//find how often 0 occurs exactly when turning the wheel
fn day1_task1(input: List(String)) -> Result(Int, Nil) {
  use moves <- result.try(
    input
    |> list.try_map(parse_line),
  )
  use positions <- result.try(
    moves
    |> list.scan(Ok(starting_point), plus_mod_res)
    |> result.all,
  )

  positions
  |> list.count(fn(x) { x == 0 })
  |> Ok
}

//find how often 0 is turned over/ended on when turning the wheel
fn day1_task2(input: List(String)) -> Result(Int, Nil) {
  use moves <- result.try(
    input
    |> list.try_map(parse_line),
  )
  //every number > modulus leads to at least (Int) number/modulus changes
  let count_full_turns =
    moves
    |> list.map(fn(val) { val / modulus })
    |> list.map(int.absolute_value)
    |> list.fold(0, int.add)

  use positions <- result.try(
    moves
    |> list.scan(Ok(starting_point), plus_mod_res)
    |> result.all,
  )
  let position_changes = list.window_by_2([starting_point, ..positions])

  let count_zero_crossings =
    list.map2(moves, position_changes, has_crossed_zero)
    |> list.count(function.identity)

  let count_zero_positions =
    positions
    |> list.count(fn(x) { x == 0 })

  Ok(count_full_turns + count_zero_positions + count_zero_crossings)
}

fn parse_line(line: String) -> Result(Int, Nil) {
  case line {
    "R" <> rest -> int.parse(rest)
    "L" <> rest -> int.parse(rest) |> result.map(int.negate)
    _ -> Error(Nil)
  }
}

fn plus_mod_res(val1: Result(Int, Nil), val2: Int) {
  use v1 <- result.try(val1)
  int.modulo(v1 + val2, modulus)
}

pub fn has_crossed_zero(move: Int, pos_change: #(Int, Int)) -> Bool {
  case pos_change {
    #(0, _) -> False
    #(_, 0) -> False
    #(old_pos, new_pos) -> !bool.exclusive_or(move > 0, old_pos - new_pos > 0)
  }
}
