import gleam/list
import gleam/int

pub type RangeTree {
  Node(left: RangeTree, val: Int, right: RangeTree)
  Leaf(range: #(Int, Int))
}

pub fn add(tree: RangeTree, new: #(Int, Int)) -> RangeTree {
  case tree {
    Leaf(range) -> {
      case overlaps(range, new) {
        True -> Leaf(#(int.min(range.0, new.0), int.max(range.1, new.1)))
        False ->
          case range.0 < new.0 {
            True -> Node(Leaf(range), range.1, Leaf(new))
            False -> Node(Leaf(new), new.1, Leaf(range))
          }
      }
    }
    Node(left, val, right) -> {
      case new.0 <= val, new.1 >= 0 {
        // new.0 > val => handle right
        False, _ -> Node(left, val, add(right, new))
        // new.1 < val => handle left
        _, False -> Node(add(tree, new), val, right)
        // new.0 <= val && new.1 >= val => this tree must change
        True, True -> {
            //ranges which start before the new range
            let smaller = flatten(left) 
            |> list.filter(fn(r) {r.0 < new.0 })
            //ranges which end after the new range
            let bigger = flatten(right)
            |> list.filter(fn(r) {r.1 > new.1})
            //todo find out which ranges need to merge, rebuild the tree

            let small_contains = smaller |> list.find(range_contains(_, new.0))    
            let big_contains = bigger |> list.find(range_contains(_, new.1))

            case small_contains, big_contains {
                Error(_), Error(_) -> // build a new tree by reducing [..smaller, new, ..bigger] with add
                // else -> remove the sequences that contain the start/end of new, create a new range and reduce
            }

            todo
        }
      }
    }
  }
}


fn flatten(tree: RangeTree) -> List(#(Int, Int)) {
    case tree {
        Leaf(range) -> [range]
        Node(left, _ ,right) ->  list.flatten([flatten(left), flatten(right)])
    }
}

//3-5
//10-14
//16-20
//12-18


// 3-5

//      5
//  3-5   10-14


//Current
//      5
//             14 
//  3-5     9            20
//      9-9  10-14 16-20   31-35

//Final
//Current
//      5
//             14 
//  3-5     9         
//      9-9  10-20   31-35





//      5
//  3-5      14   
//       10-14  16-20
//         

fn overlaps(range1: #(Int, Int), range2: #(Int, Int)) -> Bool {
  range_contains(range1, range2.0)
  || range_contains(range1, range2.1)
  || range_contains(range2, range1.0)
  || range_contains(range2, range1.1)
}

pub fn range_contains(range: #(Int, Int), val: Int) -> Bool {
  range.0 <= val && range.1 >= val
}
