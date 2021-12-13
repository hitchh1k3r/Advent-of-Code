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

PART_2_TEST_A_EXPECT : aoc.Result = 36;
PART_2_TEST_B_EXPECT : aoc.Result = 103;
PART_2_TEST_C_EXPECT : aoc.Result = 3509;

// SOLUTION ////////////////////////////////////////////////////////////////////////////////////////

part_2 :: proc($MODE : aoc.LogicMode) -> aoc.Result
{
  using aoc, fmt;

  when MODE != .SOLUTION
  { // TESTS MODE
    DEBUG  :: true;
    TIMING :: false;
  }
  else
  { // SOLVE MODE
    DEBUG  :: false;
    TIMING :: false;
  }

  input := get_input(MODE);
  all_lines := lines(input);

  links : map[string][dynamic]string;

  for line, i in all_lines
  {
    all_words := strings.split(line, "-");
    if all_words[0] not_in links
    {
      links[all_words[0]] = {};
    }
    if all_words[1] not_in links
    {
      links[all_words[1]] = {};
    }
    append(&links[all_words[0]], all_words[1]);
    append(&links[all_words[1]], all_words[0]);
  }

  node_index : map[string]int;
  index_to_node := make([]string, len(links));
  i := 0;
  for node in links
  {
    index_to_node[i] = node;
    node_index[node] = i;
    i += 1;
  }

  NodeSet :: bit_set[0..20];

  traverse :: proc(links : map[string][dynamic]string, node_index : map[string]int, index_to_node : []string, node : string, visitedNodes : NodeSet, doubleVisit : bool, total : ^int)
  {
    if node == "start"
    {
      return;
    }
    if node == "end"
    {
      total^ += 1;
      return;
    }
    visitedNodes := visitedNodes;
    doubleVisit := doubleVisit;
    if node[0] >= 'a'
    {
      index := node_index[node];
      if index in visitedNodes
      {
        if doubleVisit
        {
          return;
        }
        doubleVisit = true;
      }
      visitedNodes += { index };
    }
    for goto in links[node]
    {
      traverse(links, node_index, index_to_node, goto, visitedNodes, doubleVisit, total);
    }
  }

  pathes := 0;

  for goto in links["start"]
  {
    traverse(links, node_index, index_to_node, goto, {}, false, &pathes);
  }

  return pathes;
}
