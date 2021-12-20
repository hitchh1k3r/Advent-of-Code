package main;

import "core:fmt"
import "core:strconv"
import "core:strings"
import "core:mem"
import "core:os"
import "core:slice"
import "core:reflect"
import "core:math"
import "core:time"
import "core:sys/windows"
import "core:sort"
import "core:unicode/utf8"

import "../../../aoc";

// TEST ANSWERS ////////////////////////////////////////////////////////////////////////////////////

PART_2_TEST_A_EXPECT : aoc.Result = nil;
PART_2_TEST_B_EXPECT : aoc.Result = 3993;
PART_2_TEST_C_EXPECT : aoc.Result = nil;

// SOLUTION ////////////////////////////////////////////////////////////////////////////////////////

part_2 :: proc($MODE : aoc.LogicMode) -> aoc.Result
{
  using fmt;

  when MODE != .SOLUTION
  { // TESTS MODE
    DEBUG  :: false;
    TIMING :: false;
  }
  else
  { // SOLVE MODE
    DEBUG  :: false;
    TIMING :: false;
  }

  input := aoc.get_input(MODE);
  all_lines := aoc.lines(input);

  clear(&all_nodes)

  stack : [100]^Node
  root_nodes : [100]^Node
  stack_count := 0

  for line, i in all_lines
  {
    stack_count = 0
    for c in line
    {
      if c == '['
      {
        append(&all_nodes, Node{})
        node := &all_nodes[len(all_nodes)-1]
        if stack_count > 0
        {
          parent := stack[stack_count-1]
          if parent.left_is_set
          {
            parent.right = node
            node.parent = parent
          }
          else
          {
            parent.left = node
            node.parent = parent
          }
        }
        else
        {
          root_nodes[i] = node
        }
        stack[stack_count] = node
        stack_count += 1
      }
      else if c == ']'
      {
        stack_count -= 1
      }
      else if c == ','
      {
        stack[stack_count-1].left_is_set = true
      }
      else
      {
        node := stack[stack_count-1]
        if node.left_is_set
        {
          node.right = int(c)-'0'
        }
        else
        {
          node.left = int(c)-'0'
        }
      }
    }
  }

  explode_pairs :: proc(node : ^Node, depth := 1) -> bool
  {
    if left, ok := node.left.(^Node); ok
    {
      if explode_pairs(left, depth+1)
      {
        return true
      }
    }

    if depth > 4
    {
      when DEBUG do print("   Node To Explode: ")
      when DEBUG do pretty_print(node)
      assert(reflect.union_variant_typeid(node.left) == typeid_of(int) && reflect.union_variant_typeid(node.right) == typeid_of(int))
      left, _ := node.left.(int)
      right, _ := node.right.(int)
      gone_left := false
      gone_right := false
      parent := node.parent
      original_parent := parent
      prev_parent := node
      did_split := false
      for (!gone_left || !gone_right) && parent != nil
      {
        if !gone_right && parent.left == prev_parent
        {
          gone_right = true
          child := &parent.right
          child_parent := parent
          for reflect.union_variant_typeid(child^) == typeid_of(^Node)
          {
            child_parent = child.(^Node)
            child = &child.(^Node).left
          }
          child^ = child.(int) + right
        }
        if !gone_left && parent.right == prev_parent
        {
          gone_left = true
          child := &parent.left
          child_parent := parent
          for reflect.union_variant_typeid(child^) == typeid_of(^Node)
          {
            child_parent = child.(^Node)
            child = &child.(^Node).right
          }
          child^ = child.(int) + left
        }
        prev_parent = parent
        parent = parent.parent
      }
      if node == original_parent.left
      {
        original_parent.left = 0
      }
      else if node == original_parent.right
      {
        original_parent.right = 0
      }

      when DEBUG do pretty_print(root_node)
      return true
    }

    if right, ok := node.right.(^Node); ok
    {
      if explode_pairs(right, depth+1)
      {
        return true
      }
    }

    return false
  }

  split_pairs :: proc(node : ^Node, depth := 1) -> bool
  {
    if left, ok := node.left.(^Node); ok
    {
      if split_pairs(left, depth+1)
      {
        return true
      }
    }

    if v, ok := node.left.(int); v >= 10
    {
      when DEBUG do print("   Node To Split (left): ")
      when DEBUG do pretty_print(node)
      append(&all_nodes, Node{})
      split_node := &all_nodes[len(all_nodes)-1]
      split_node.parent = node
      split_node.left = node.left.(int)/2
      split_node.right = (node.left.(int)+1)/2
      node.left = split_node
      // if depth+1 > 4
      {
        return true
      }
    }
    if v, ok := node.right.(int); v >= 10
    {
      when DEBUG do print("   Node To Split (right): ")
      when DEBUG do pretty_print(node)
      when DEBUG do println(len(all_nodes))
      append(&all_nodes, Node{})
      split_node := &all_nodes[len(all_nodes)-1]
      split_node.parent = node
      split_node.left = node.right.(int)/2
      split_node.right = (node.right.(int)+1)/2
      node.right = split_node
      // if depth+1 > 4
      {
        return true
      }
    }

    if right, ok := node.right.(^Node); ok
    {
      if split_pairs(right, depth+1)
      {
        return true
      }
    }

    return false
  }

  @static root_node : ^Node

  sum_nodes :: proc(left, right : ^Node) -> ^Node
  {
    append(&all_nodes, Node{})
    sum := &all_nodes[len(all_nodes)-1]
    sum.left = left
    left.parent = sum
    sum.right = right
    right.parent = sum

    for
    {
      for explode_pairs(sum) {}
      if split_pairs(sum)
      {
        continue
      }
      break
    }

    return sum
  }


  pretty_print :: proc(root : ^Node)
  {
    print_node :: proc(node : ^Node)
    {
      print("[")
      switch v in node.left
      {
        case int:
          print(v)
        case ^Node:
          print_node(v)
      }
      print(",")
      switch v in node.right
      {
        case int:
          print(v)
        case ^Node:
          print_node(v)
      }
      print("]")
    }
    print_node(root)
    print("\n")
  }

  node_magnitude :: proc(node : ^Node) -> int
  {
    sum := 0
    switch v in node.left
    {
      case int:
        sum += 3*v
      case ^Node:
        sum += 3*node_magnitude(v)
    }
    switch v in node.right
    {
      case int:
        sum += 2*v
      case ^Node:
        sum += 2*node_magnitude(v)
    }
    return sum
  }

  clone_tree :: proc(node : ^Node) -> ^Node
  {
    append(&all_nodes, Node{})
    new_node := &all_nodes[len(all_nodes)-1]
    switch left in node.left
    {
      case int:
        new_node.left = left
      case ^Node:
        new_node.left = clone_tree(left)
        new_node.left.(^Node).parent = new_node
    }
    switch right in node.right
    {
      case int:
        new_node.right = right
      case ^Node:
        new_node.right = clone_tree(right)
        new_node.right.(^Node).parent = new_node
    }
    return new_node
  }

  max_mag := 0

  for l in 0..<len(all_lines)
  {
    for r in 0..<len(all_lines)
    {
      if l != r
      {
        // print("L: ")
        // pretty_print(root_nodes[l])
        // print("R: ")
        // pretty_print(root_nodes[r])

        sum := sum_nodes(clone_tree(root_nodes[l]), clone_tree(root_nodes[r]))
        // print("     Sum: ")
        // pretty_print(sum)
        // println("        ", node_magnitude(sum))
        max_mag = max(max_mag, node_magnitude(sum))
      }
    }
  }

  return max_mag
}
