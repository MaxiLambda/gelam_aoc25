import gleam/io
import gleam/int
import gleam/list
import gleam/result
import gleam/string
import utils/parsing

pub type Range {
  Range(start: Int, end: Int)
}

// total_length is the length of the pattern NOT the prefix
// slice_size descibes in how many parts the pattern is split 
// total_length % divsor == 0
pub type SymPattern {
  SymPattern(prefix: String, total_length: Int, slice_size: Int)
}

pub fn run() -> Result(Int, String) {
  use input <- result.try(parsing.read_file("priv/day2.txt"))
  use ranges <- result.try(
    input
    |> string.trim
    |> string.split(",")
    |> list.map(parse_range)
    |> result.all,
  )
  task2(ranges)
}

// fn task1(ranges: List(Range)) -> Result(Int, String) {
//   use candidate_ranges <- result.try(
//     ranges
//     |> list.flat_map(split_range)
//     |> list.filter(is_even_digit_range)
//     |> list.map(symmetic_bounds)
//     |> result.all
//     |> result.replace_error("invalid range given"),
//   )

//   use candidate_values <- result.try(
//     candidate_ranges
//     |> list.map(possible_values_in_range(_, 2))
//     |> result.all,
//   )

//   let mirror_numbers =
//     candidate_values
//     |> list.flat_map(function.identity)
//     |> list.filter(is_mirror_number)

//   mirror_numbers
//   |> list.filter(fn(i) { list.any(ranges, in_range(i, _)) |> bool.negate })
//   |> echo

//   mirror_numbers
//   |> list.fold(0, int.add)
//   |> Ok
// }

fn task2(ranges: List(Range)) -> Result(Int, String) {
  use values_by_range_and_divisor <- result.try(
    ranges
    |> list.flat_map(split_range)
    |> list.filter(fn(r) { digit_count(r) != 1 })
    |> list.map(fn(r) {
      echo r
      digit_count(r)
      |> divisors
      |> list.try_map(fn(d) {
        echo d
        use candidate_values <- result.map(possible_values_in_range(r, d))
        candidate_values
        |> echo
        |> list.filter(fn(n) { is_repeating_number(n, d) })
        |> echo
      })
    })
    |> result.all,
  )

  let values_by_range =
    values_by_range_and_divisor
    //dedupe: 2222 would fit twice, as a sequence of 4 * '2' or 2 * '22'
    |> list.map(fn(l) { list.flatten(l) |> list.unique })

  values_by_range
  |> list.flatten
  |> list.map(int.to_string)
  |> list.each(io.println)

  values_by_range
  |> list.flatten
  |> list.fold(0, int.add)
  |> Ok
}

//divisors dosent return the value itself
pub fn divisors(number: Int) -> List(Int) {
  divisors_rec(1, number)
}

fn divisors_rec(current: Int, number: Int) -> List(Int) {
  case current > number / 2 {
    True -> []
    False ->
      case number % current == 0 {
        True -> [current, ..divisors_rec(current + 1, number)]
        False -> divisors_rec(current + 1, number)
      }
  }
}

///splits ranges into ranges with the same numbre of digits in start/end: 23-1003 -> 23-99,100-999,1000-1003
pub fn split_range(range: Range) -> List(Range) {
  let digits_start = range.start |> int.to_string |> string.length
  let digits_end = range.end |> int.to_string |> string.length
  split_range_rec(digits_start, digits_end, range.start, range.end)
}

fn split_range_rec(
  current_digits: Int,
  max_digits: Int,
  lower_bound: Int,
  upper_bound: Int,
) -> List(Range) {
  case current_digits == max_digits {
    True -> [Range(lower_bound, upper_bound)]
    False -> {
      let max = list.repeat(10, current_digits) |> int.product
      [
        Range(lower_bound, max - 1),
        ..split_range_rec(current_digits + 1, max_digits, max, upper_bound)
      ]
    }
  }
}

fn to_prefix(range: Range) -> String {
  let to_list = fn(i: Int) {
    i
    |> int.to_string
    |> string.split("")
  }
  list.zip(to_list(range.start), to_list(range.end))
  |> list.take_while(fn(t) { t.0 == t.1 })
  |> list.map(fn(t) { t.0 })
  |> string.concat
}

pub fn symmetic_bounds(range: Range) -> Result(Range, Nil) {
  let bound = fn(i) {
    i
    |> int.to_string
    |> fn(s) { string.drop_end(s, string.length(s) / 2) }
    |> fn(s) { s <> s }
    |> int.parse
  }
  use lower <- result.try(bound(range.start))
  use upper <- result.map(bound(range.end))
  Range(int.max(range.start, lower), int.min(range.end, upper))
}

pub fn free_spaces(pattern: SymPattern) -> Int {
  let count_slices = pattern.total_length / pattern.slice_size
  int.max(
    0,
    pattern.total_length - { string.length(pattern.prefix) *  count_slices },
  )
}

pub fn possible_values_in_range(
  range: Range,
  slice_size: Int,
) -> Result(List(Int), String) {
  let pattern = sym_pattern(range, slice_size)
  let cropped_prefix =
    string.slice(pattern.prefix, 0, pattern.slice_size)
  let slice_count = pattern.total_length / pattern.slice_size
  let free_variables = free_spaces(pattern) / slice_count

  let lower_bound_candidate =
    string.slice(
      int.to_string(range.start),
      string.length(cropped_prefix),
      free_variables,
    )

  use lower_bound <- result.try(case lower_bound_candidate {
    "" -> Ok(0)
    n -> int.parse(n) |> result.replace_error("unable to determine lower bound")
  })

  case free_variables == 0 {
    True ->
      cropped_prefix
      |> string.repeat(slice_count)
      |> int.parse
      |> result.map(fn(i) { list.filter([i], in_range(_, range)) })
      |> result.replace_error("unable to parse value")
    False ->
      result.all(possible_values_in_range_rec(
        cropped_prefix,
        lower_bound,
        free_variables,
        range,
        slice_count,
      ))
  }
}

fn possible_values_in_range_rec(
  prefix: String,
  counter: Int,
  varible_length: Int,
  range: Range,
  slice_count: Int,
) -> List(Result(Int, String)) {
  let counter_string = int.to_string(counter)
  let padding =
    string.repeat("0", varible_length - string.length(counter_string))
  let number_res =
    { prefix <> padding <> counter_string }
    |> string.repeat(slice_count)
    |> int.parse
    |> result.replace_error("unable to parse number")

  case number_res {
    Error(e) -> [Error(e)]
    Ok(n) ->
      case n > range.end {
        True -> []
        False ->
          case n < range.start {
            True ->
              possible_values_in_range_rec(
                prefix,
                counter + 1,
                varible_length,
                range,
                slice_count,
              )
            False -> [
              number_res,
              ..possible_values_in_range_rec(
                prefix,
                counter + 1,
                varible_length,
                range,
                slice_count,
              )
            ]
          }
      }
  }
}

fn digit_count(range: Range) -> Int {
  range.start |> int.to_string |> string.length
}

// independent utility

//only ranges with an even number of digits can contain self repeating numbers
// fn is_even_digit_range(range: Range) -> Bool {
//   range |> digit_count |> int.is_even
// }

// fn is_mirror_number(number: Int) {
//   let s = int.to_string(number)
//   let half = string.length(s) / 2
//   let first_half = string.drop_end(s, half)
//   let second_half = string.drop_start(s, half)
//   first_half == second_half
// }

pub fn is_repeating_number(number: Int, segment_size: Int) {
  let s = int.to_string(number)
  s
  |> string.slice(0, segment_size)
  |> string.repeat(string.length(s) / segment_size)
  |> fn(seq) { seq == s }
}

fn in_range(number: Int, range: Range) {
  range.start <= number && range.end >= number
}

pub fn sym_pattern(range: Range, slice_size: Int) {
  let prefix = to_prefix(range)
  SymPattern(prefix, range.start |> int.to_string |> string.length, slice_size)
}

fn parse_range(input: String) -> Result(Range, String) {
  case string.split(input, "-") {
    [start, end] -> {
      use start_num <- result.try(
        int.parse(start)
        |> result.map_error(fn(_) { "Can't parse Int from: '" <> start <> "'" }),
      )
      use end_num <- result.map(
        int.parse(end)
        |> result.map_error(fn(_) { "Can't parse Int from: '" <> end <> "'" }),
      )
      Range(start_num, end_num)
    }
    _ -> Error("Can't parse range from: '" <> input <> "'")
  }
}
// fn digit_at_pos(number: Int, pos: Int) -> Result(Int, String) {
//   let symbolic = int.to_string(number)
//   case pos >= string.length(symbolic) {
//     True -> Ok(0)
//     False ->
//       symbolic
//       |> string.slice(-1 - pos, 1)
//       |> int.parse
//       |> result.replace_error("Invalid number given")
//   }
// }
