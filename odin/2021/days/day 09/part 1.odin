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

PART_1_TEST_A_EXPECT : aoc.Result = 15;
PART_1_TEST_B_EXPECT : aoc.Result = nil;
PART_1_TEST_C_EXPECT : aoc.Result = nil;

// SOLUTION ////////////////////////////////////////////////////////////////////////////////////////

height : int;
width : int;
world : []int;

world_index :: proc(x, y : int) -> int
{
  if x >= 0 && x < width && y >= 0 && y < height
  {
    return x + (y*width);
  }
  return width*height;
}

part_1 :: proc($MODE : aoc.LogicMode) -> aoc.Result
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
  all_nums := int_arr(all_lines);

  height = len(all_lines);
  width = len(all_lines[0]);

  world = make([]int, width*height+1);
  world[width*height] = 10;

  for line, y in all_lines
  {
    for c, x in line
    {
      world[world_index(x, y)] = int(c-'0');
    }
  }

  total := 0;
  for x in 0..<width
  {
    for y in 0..<height
    {
      me := world[world_index(x, y)];
      if me < world[world_index(x-1, y)] && me < world[world_index(x+1, y)] && me < world[world_index(x, y-1)] && me < world[world_index(x, y+1)]
      {
        total += me+1;
      }
    }
  }

  return total;
}
