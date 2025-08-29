import gleam/int
import gleam/list
import gleam/order

pub type Tree(a) {
  Node(a, left: Tree(a), right: Tree(a), height: Int)
  Nil
}

pub fn empty() -> Tree(a) {
  Nil
}

fn height_of(t: Tree(a)) -> Int {
  case t {
    Nil -> 0
    Node(_, _, _, h) -> h
  }
}

fn mk_node(value: a, left: Tree(a), right: Tree(a)) -> Tree(a) {
  let hl = height_of(left)
  let hr = height_of(right)
  let h = 1 + int.max(hl, hr)
  Node(value, left, right, h)
}

fn balance_factor(t: Tree(a)) -> Int {
  case t {
    Nil -> 0
    Node(_, l, r, _) -> height_of(l) - height_of(r)
  }
}

fn rotate_right(y: Tree(a)) -> Tree(a) {
  case y {
    Node(yv, yl, yr, _) ->
      case yl {
        Nil -> y
        Node(xv, xl, xr, _) -> {
          let y_prime = mk_node(yv, xr, yr)
          mk_node(xv, xl, y_prime)
        }
      }
    Nil -> y
  }
}

fn rotate_left(x: Tree(a)) -> Tree(a) {
  case x {
    Node(xv, xl, xr, _) ->
      case xr {
        Nil -> x
        Node(yv, yl, yr, _) -> {
          let x_prime = mk_node(xv, xl, yl)
          mk_node(yv, x_prime, yr)
        }
      }
    Nil -> x
  }
}

fn rebalance(value: a, left: Tree(a), right: Tree(a)) -> Tree(a) {
  let node = mk_node(value, left, right)
  let bf = balance_factor(node)

  case bf > 1 {
    True -> {
      let left2 = case left {
        Nil -> left
        _ ->
          case balance_factor(left) < 0 {
            True -> rotate_left(left)
            False -> left
          }
      }
      rotate_right(mk_node(value, left2, right))
    }

    False ->
      case bf < -1 {
        True -> {
          let right2 = case right {
            Nil -> right
            _ ->
              case balance_factor(right) > 0 {
                True -> rotate_right(right)
                False -> right
              }
          }
          rotate_left(mk_node(value, left, right2))
        }
        False -> node
      }
  }
}

pub fn insert(
  tree: Tree(a),
  value: a,
  compare: fn(a, a) -> order.Order,
) -> Tree(a) {
  case tree {
    Nil -> Node(value, Nil, Nil, 1)
    Node(x, l, r, _) -> {
      case compare(value, x) {
        order.Lt -> {
          let l2 = insert(l, value, compare)
          rebalance(x, l2, r)
        }
        order.Gt -> {
          let r2 = insert(r, value, compare)
          rebalance(x, l, r2)
        }
        order.Eq -> tree
      }
    }
  }
}

pub fn find(tree: Tree(a), value: a, compare: fn(a, a) -> order.Order) -> Bool {
  case tree {
    Nil -> False
    Node(x, l, r, _) ->
      case compare(value, x) {
        order.Eq -> True
        order.Lt -> find(l, value, compare)
        order.Gt -> find(r, value, compare)
      }
  }
}

pub fn transform(
  xs: List(a),
  compare: fn(a, a) -> order.Order,
) -> #(Tree(a), Bool) {
  let tree =
    list.fold(xs, empty(), fn(acc, elem) { insert(acc, elem, compare) })
  #(tree, verify(xs, tree, compare))
}

pub fn verify(
  xs: List(a),
  tree: Tree(a),
  compare: fn(a, a) -> order.Order,
) -> Bool {
  case xs {
    [] -> True
    [x, ..rest] -> find(tree, x, compare) && verify(rest, tree, compare)
  }
}

pub fn inorder(t: Tree(a)) -> List(a) {
  case t {
    Nil -> []
    Node(v, l, r, _) -> {
      let left_mid = list.append(inorder(l), [v])
      list.append(left_mid, inorder(r))
    }
  }
}

pub fn is_avl(t: Tree(a)) -> Bool {
  case t {
    Nil -> True
    Node(_, l, r, h) -> {
      let hl = height_of(l)
      let hr = height_of(r)
      let ok_h = h == 1 + int.max(hl, hr)
      let ok_bf = int.absolute_value(hl - hr) <= 1
      ok_h && ok_bf && is_avl(l) && is_avl(r)
    }
  }
}
