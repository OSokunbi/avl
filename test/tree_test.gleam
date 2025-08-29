import gleeunit
import gleeunit/should
import gleam/int
import avl

pub fn main() -> Nil {
  gleeunit.main()
}

fn sorted(xs: List(Int)) -> Bool {
  case xs {
    [] -> True
    [_] -> True
    [a, b, ..rest] -> a <= b && sorted([b, ..rest])
  }
}

pub fn inserts_balance_ll_tesr() {
  let inputs = [30, 20, 10] 
  let #(tree, ok) = avl.transform(inputs, int.compare)
  should.be_true(ok)
  should.be_true(avl.is_avl(tree))
  should.equal([10, 20, 30], avl.inorder(tree))
}

pub fn inserts_balance_rr_test() {
  let inputs = [10, 20, 30]
  let #(tree, ok) = avl.transform(inputs, int.compare)
  should.be_true(ok)
  should.be_true(avl.is_avl(tree))
  should.equal([10, 20, 30], avl.inorder(tree))
}

pub fn inserts_balance_lr_test() {
  let inputs = [30, 10, 20]
  let #(tree, ok) = avl.transform(inputs, int.compare)
  should.be_true(ok)
  should.be_true(avl.is_avl(tree))
  should.equal([10, 20, 30], avl.inorder(tree))
}

pub fn inserts_balance_rl_test() {
  let inputs = [10, 30, 20] 
  let #(tree, ok) = avl.transform(inputs, int.compare)
  should.be_true(ok)
  should.be_true(avl.is_avl(tree))
  should.equal([10, 20, 30], avl.inorder(tree))
}

pub fn inorder_is_sorted_for_randomish_test() {
  let inputs = [8, -1, 10, 600, 4, 10, 90, 50, 70, 1000, -111, -5, 0]
  let #(tree, ok) = avl.transform(inputs, int.compare)
  should.be_true(ok)
  should.be_true(avl.is_avl(tree))
  should.be_true(sorted(avl.inorder(tree)))
}

pub fn duplicates_are_ignored_test() {
  let inputs = [5, 3, 7, 3, 5, 7, 5]
  let #(tree, _ok) = avl.transform(inputs, int.compare)
  let values = avl.inorder(tree)
  should.equal([3, 5, 7], values)
}

pub fn verify_checks_membership_test() {
  let inputs = [1, 2, 3, 4]
  let #(tree, ok) = avl.transform(inputs, int.compare)
  should.be_true(ok)
  should.be_true(avl.verify([2, 4], tree, int.compare))
  should.be_false(avl.verify([2, 9], tree, int.compare))
}
