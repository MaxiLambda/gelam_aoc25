import gleeunit

pub fn main() -> Nil {
  gleeunit.main()
}

// gleeunit test functions end in `_test`
pub fn hello_world_test() {
  let p = 1
  let np = 1

  //there a no real tests here
  assert p == np
}
