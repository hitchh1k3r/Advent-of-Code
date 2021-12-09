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

PART_2_TEST_A_EXPECT : aoc.Result = 1134;
PART_2_TEST_B_EXPECT : aoc.Result = nil;
PART_2_TEST_C_EXPECT : aoc.Result = nil;

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
  all_nums := int_arr(all_lines);

  height = len(all_lines);
  width = len(all_lines[0]);

  world = make([]int, width*height+1);
  world[width*height] = 10;

  V2 :: [2]int;

  for line, y in all_lines
  {
    for c, x in line
    {
      world[world_index(x, y)] = int(c-'0');
    }
  }

  basin_size :: proc(x, y : int) -> int
  {
    neighbor_offsets :: []V2{
      V2{-1,  0},
      V2{+1,  0},
      V2{ 0, -1},
      V2{ 0, +1},
     };

    try_fill :: proc(cells : ^map[V2]bool, pos : V2) -> bool
    {
      if pos not_in cells && world[world_index(pos.x, pos.y)] < 9
      {
        cells[pos] = true;
        return true;
      }
      return false;
    }

    cells : map[V2]bool;

    cells[{x,y}] = true;
    size := 1;

    new_cell := true;
    for new_cell
    {
      new_cell = false;
      for pos in cells
      {
        for offset in neighbor_offsets
        {
          if try_fill(&cells, pos + offset)
          {
            new_cell = true;
            size += 1;
          }
        }
      }
    }

    return size;
  }

  basins : [dynamic]int;

  for x in 0..<width
  {
    for y in 0..<height
    {
      me := world[world_index(x, y)];
      if me < world[world_index(x-1, y)] && me < world[world_index(x+1, y)] && me < world[world_index(x, y-1)] && me < world[world_index(x, y+1)]
      {
        append(&basins, basin_size(x, y));
      }
    }
  }

  slice.sort(basins[:]);
  return prod(basins[len(basins)-3:]);
}
