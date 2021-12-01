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

import "../../aoc";

// TEST ANSWERS ////////////////////////////////////////////////////////////////////////////////////

PART_2_TEST_A_EXPECT : aoc.Result = 231+51+46+1445+669060+23340;
PART_2_TEST_B_EXPECT : aoc.Result = nil;
PART_2_TEST_C_EXPECT : aoc.Result = nil;

// SOLUTION ////////////////////////////////////////////////////////////////////////////////////////

part_2 :: proc($MODE : aoc.LogicMode) -> aoc.Result
{
  using aoc, fmt;

  DEBUG  :: false && MODE != .SOLUTION;
  TIMING :: false;

  input := get_input(MODE);
  allLines := lines(input);

  ASTNodeType :: enum
  {
    NULL,
    OP_ADD,
    OP_MUL,
    PAREN,
    VAL_NUM,
  };

  ASTNode :: struct
  {
    type : ASTNodeType,
    val : int,
    lhs, rhs : ^ASTNode,
    parent : ^ASTNode,
  };

  insertNode :: proc(parent, child : ^ASTNode) -> ^ASTNode
  {
    newNode := new(ASTNode);
    if parent != nil
    {
      if parent.lhs == child
      {
        parent.lhs = newNode;
      }
      else if parent.rhs == child
      {
        parent.rhs = newNode;
      }
      else
      {
        assert(false, "cannot insert node between unrelated nodes");
      }
      newNode.parent = parent;
    }
    newNode.lhs = child;
    child.parent = newNode;
    return newNode;
  }

  insertLHS :: proc(parent : ^ASTNode) -> ^ASTNode
  {
    newNode := new(ASTNode);
    parent.lhs = newNode;
    newNode.parent = parent;
    return newNode;
  }

  insertRHS :: proc(parent : ^ASTNode) -> ^ASTNode
  {
    newNode := new(ASTNode);
    parent.rhs = newNode;
    newNode.parent = parent;
    return newNode;
  }

  parse_infix :: proc(str : string) -> ^ASTNode
  {
    using currentNode := new(ASTNode);

    for c, i in str
    {
      switch c
      {
        case '(':
          if type == .OP_ADD || type == .OP_MUL
          {
            currentNode = insertRHS(currentNode);
          }
          else
          {
            assert(type == .NULL, "parenthesis node must replace a null node, or follow an operation node");
          }
          type = .PAREN;
          currentNode = insertLHS(currentNode);
        case ')':
          currentNode = parent;
          for parent != nil && type != .PAREN
          {
            currentNode = parent;
          }
        case '+':
          currentNode = insertNode(parent, currentNode);
          type = .OP_ADD;
        case '*':
          // operator precedence:
          for parent != nil && parent.type == .OP_ADD
          {
            currentNode = parent;
          }

          currentNode = insertNode(parent, currentNode);
          type = .OP_MUL;
        case '0'..'9': // NOTE (hitch) 2020-12-18 All numbers are signless and single digit
          if type == .OP_ADD || type == .OP_MUL
          {
            currentNode = insertRHS(currentNode);
          }
          else
          {
            assert(type == .NULL, "numeric node must replace a null node, or follow an operation node");
          }
          type = .VAL_NUM;
          val = int_val(str[i:i+1]);
      }
    }

    return get_root(currentNode);
  }

  get_root :: proc(node : ^ASTNode) -> ^ASTNode
  {
    using root := node;
    for parent != nil
    {
      root = parent;
    }
    return root;
  }

  pretty_print :: proc(node : ^ASTNode) -> string
  {
    using aoc, fmt;
    if node != nil
    {
      using node;
      switch type
      {
        case .NULL:
          return aprint("NULL");
        case .OP_ADD:
          return aprintf("%v + %v", temp_str(pretty_print(lhs)), temp_str(pretty_print(rhs)));
        case .OP_MUL:
          return aprintf("%v * %v", temp_str(pretty_print(lhs)), temp_str(pretty_print(rhs)));
        case .PAREN:
          return aprintf("(%v)", temp_str(pretty_print(lhs)));
        case .VAL_NUM:
          return aprint(val);
      }
    }
    return aprint("nil");
  }

  evaluate_ast_node :: proc(using node : ^ASTNode) -> int
  {
    switch type
    {
      case .NULL:
        assert(false, "cannot evaluate an uninitialized node");
      case .OP_ADD:
        return evaluate_ast_node(lhs) + evaluate_ast_node(rhs);
      case .OP_MUL:
        return evaluate_ast_node(lhs) * evaluate_ast_node(rhs);
      case .PAREN:
        return evaluate_ast_node(lhs);
      case .VAL_NUM:
        return val;
    }
    return 0;
  }

  total := 0;
  for line in allLines
  {
    ast := parse_infix(line);
    val := evaluate_ast_node(ast);
    total += val;

    // find errors:
    pretty := temp_str(pretty_print(ast));
    if line != pretty
    {
      println(line, "  =>  ", pretty, "  =  ", val);
    }
  }

  return total;
}
