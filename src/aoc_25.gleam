import day/day4
import gleam/int
import gleam/io

pub fn main() -> Nil {
  case day4.run() {
    Ok(res) -> res |> int.to_string |> io.println
    Error(e) -> io.println(e)
  }
}
