import day/day5
import gleam/int
import gleam/io

pub fn main() -> Nil {
  case day5.run() {
    Ok(res) -> res |> int.to_string |> io.println
    Error(e) -> io.println(e)
  }
}
