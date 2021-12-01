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

PART_2_TEST_A_EXPECT : aoc.Result = 3;
PART_2_TEST_B_EXPECT : aoc.Result = nil;
PART_2_TEST_C_EXPECT : aoc.Result = nil;

// SOLUTION ////////////////////////////////////////////////////////////////////////////////////////

part_2 :: proc($MODE : aoc.LogicMode) -> aoc.Result
{
  using aoc, fmt;

  DEBUG  :: false && MODE != .SOLUTION;
  TIMING :: false;

  input := get_input(MODE);
  all_lines := lines(input);
  containers := int_arr(all_lines);

  when MODE == .SOLUTION
  {
    target := 150;
  }
  else
  {
    target := 25;
  }

  min_containers :: proc(index : int, containers : []int, current : int, target : int, min := 10000000000) -> int
  {
    if current == target
    {
      return 1;
    }

    if current > target
    {
      return min;
    }

    smallest := min;
    for i in index..<len(containers)
    {
      check := min_containers(i+1, containers, current+containers[i], target, min) + 1;
      if check < smallest
      {
        smallest = check;
      }
    }
    return smallest;
  }

  fill_containers :: proc(index : int, containers : []int, current : int, target : int, depth : int) -> int
  {
    if depth <= 0
    {
      return 0;
    }

    if current == target
    {
      return 1;
    }

    if current > target
    {
      return 0;
    }

    total := 0;
    for i in index..<len(containers)
    {
      total += fill_containers(i+1, containers, current+containers[i], target, depth - 1);
    }
    return total;
  }

  return fill_containers(0, containers, 0, target, min_containers(0, containers, 0, target));
}
