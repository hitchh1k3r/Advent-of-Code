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

PART_1_TEST_A_EXPECT : aoc.Result = 4;
PART_1_TEST_B_EXPECT : aoc.Result = nil;
PART_1_TEST_C_EXPECT : aoc.Result = nil;

// SOLUTION ////////////////////////////////////////////////////////////////////////////////////////

part_1 :: proc($MODE : aoc.LogicMode) -> aoc.Result
{
  using aoc, fmt;

  when MODE != .SOLUTION
  { // TESTS MODE
    DEBUG  :: true;
    TIMING :: false;
    SIZE :: 6;
    STEPS :: 4;
  }
  else
  { // SOLVE MODE
    DEBUG  :: false;
    TIMING :: false;
    SIZE :: 100;
    STEPS :: 100;
  }

  gridA : [SIZE*SIZE]bool;
  gridB : [SIZE*SIZE]bool;
  last := &gridA;
  current := &gridB;

  input := get_input(MODE);
  all_lines := lines(input);

  i := 0;
  for line, r in all_lines
  {
    for char, c in line
    {
      current[i] = (char == '#');
      i += 1;
    }
  }

  get_cell :: proc(grid : ^[SIZE*SIZE]bool, r, c : int) -> bool
  {
    if r < 0 || r >= SIZE || c < 0 || c >= SIZE
    {
      return false;
    }
    return grid[r*SIZE + c];
  }

  for s in 1..STEPS
  {
    last, current = current, last;
    i := 0;
    for r in 0..<SIZE
    {
      for c in 0..<SIZE
      {
        neigbors := (get_cell(last, r-1, c-1) ? 1 : 0) +
                    (get_cell(last, r-1, c) ? 1 : 0) +
                    (get_cell(last, r-1, c+1) ? 1 : 0) +
                    (get_cell(last, r, c-1) ? 1 : 0) +
                    (get_cell(last, r, c+1) ? 1 : 0) +
                    (get_cell(last, r+1, c-1) ? 1 : 0) +
                    (get_cell(last, r+1, c) ? 1 : 0) +
                    (get_cell(last, r+1, c+1) ? 1 : 0);
        if last[i]
        {
          current[i] = (neigbors >= 2 && neigbors <= 3);
        }
        else
        {
          current[i] = (neigbors == 3);
        }
        i += 1;
      }
    }
    when DEBUG
    {
      println(current);
    }
  }

  count := 0;
  for cell in current
  {
    if cell
    {
      count += 1;
    }
  }

  return count; // >799
}
