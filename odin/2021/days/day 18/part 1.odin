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

PART_1_TEST_A_EXPECT : aoc.Result = 3488;
PART_1_TEST_B_EXPECT : aoc.Result = 4140;
PART_1_TEST_C_EXPECT : aoc.Result = nil;

// SOLUTION ////////////////////////////////////////////////////////////////////////////////////////

NodeElement :: union { int, ^Node }
Node :: struct
{
  parent : ^Node,
  left, right : NodeElement,
  left_is_set : bool,
}

all_nodes := make([dynamic]Node, 0, 10000000)

part_1 :: proc($MODE : aoc.LogicMode) -> aoc.Result
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

  reparent :: proc(node : ^Node)
  {
    if v, ok := node.left.(^Node); ok
    {
      v.parent = node
      reparent(v)
    }
    if v, ok := node.right.(^Node); ok
    {
      v.parent = node
      reparent(v)
    }
  }

  append(&all_nodes, Node{})
  sum := &all_nodes[len(all_nodes)-1]
  sum.left = root_nodes[0]
  root_nodes[0].parent = sum
  for i in 1..<len(all_lines)
  {
    sum.right = root_nodes[i]
    root_nodes[i].parent = sum
    root_node = sum

    for
    {
      for explode_pairs(sum) {}
      if split_pairs(sum)
      {
        continue
      }
      break
    }

    append(&all_nodes, Node{})
    node := &all_nodes[len(all_nodes)-1]
    node.left = sum
    sum.parent = node
    sum = node
  }

  pretty_print(sum.left.(^Node))

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

  return node_magnitude(sum.left.(^Node));
}
