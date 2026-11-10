import day/day1
import gleam/int
import gleam/io

pub fn main() -> Nil {
  case day1.run() {
    Ok(res) -> res |> int.to_string |> io.println
    Error(_) -> io.println("something went wrong")
  }
}
