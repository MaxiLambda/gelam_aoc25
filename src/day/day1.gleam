import gleam/int
import gleam/list
import gleam/result
import utils/parsing

const starting_point = 50

const modulus = 100

pub fn run() -> Result(Int, Nil) {
  use input <- result.try(parsing.read_file("priv/day1.txt"))
  use solution <- result.map(day1_task1(input))
  solution
}

fn day1_task1(input: List(String)) -> Result(Int, Nil) {
  use parsed <- result.try(
    input
    |> list.try_map(parse_line),
  )
  use positions <- result.try(
    parsed
    |> list.scan(Ok(starting_point), plus_mod_res)
    |> result.all,
  )
  echo positions
  positions
  |> list.count(fn(x) { x == 0 })
  |> Ok
}

fn parse_line(line: String) -> Result(Int, Nil) {
  case line {
    "R" <> rest -> int.parse(rest)
    "L" <> rest -> int.parse(rest) |> result.map(int.negate)
    _ -> Error(Nil)
  }
}

fn plus_mod(val1: Int, val2: Int) -> Result(Int, Nil) {
  int.modulo(val1 + val2, modulus)
}

fn plus_mod_res(val1: Result(Int, Nil), val2: Int) {
  use v1 <- result.try(val1)
  plus_mod(v1, val2)
}
