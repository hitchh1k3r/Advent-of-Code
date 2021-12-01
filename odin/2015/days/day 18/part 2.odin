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

PART_2_TEST_A_EXPECT : aoc.Result = 17;
PART_2_TEST_B_EXPECT : aoc.Result = nil;
PART_2_TEST_C_EXPECT : aoc.Result = nil;

// SOLUTION ////////////////////////////////////////////////////////////////////////////////////////

part_2 :: proc($MODE : aoc.LogicMode) -> aoc.Result
{
  using aoc, fmt;

  DEBUG  :: true && MODE != .SOLUTION;
  TIMING :: false;

  when MODE == .SOLUTION
  {
    size :: 100;
    steps :: 100;
  }
  else
  {
    size :: 6;
    steps :: 5;
  }

  gridA : [size*size]bool;
  gridB : [size*size]bool;
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

  get_cell :: proc(grid : ^[size*size]bool, r, c : int) -> bool
  {
    if r < 0 || r >= size || c < 0 || c >= size
    {
      return false;
    }
    return grid[r*size + c];
  }

  pretty :: proc(grid : ^[size*size]bool)
  {
    i := 0;
    for r in 0..<size
    {
      for c in 0..<size
      {
        if grid[i]
        {
          print("#");
        }
        else
        {
          print(".");
        }
        i += 1;
      }
      print("\n");
    }
    print("\n");
  }

  current[0] = true;
  current[size-1] = true;
  current[size*(size-1)] = true;
  current[size*size-1] = true;
  when DEBUG
  {
    pretty(current);
  }

  for s in 1..steps
  {
    last, current = current, last;
    i := 0;
    for r in 0..<size
    {
      for c in 0..<size
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
    current[0] = true;
    current[size-1] = true;
    current[size*(size-1)] = true;
    current[size*size-1] = true;
    when DEBUG
    {
      pretty(current);
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

  return count;
}
