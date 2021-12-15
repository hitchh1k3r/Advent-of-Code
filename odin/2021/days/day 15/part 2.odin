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

PART_2_TEST_A_EXPECT : aoc.Result = 315;
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

  maze := make([][]u8, len(all_lines)*5);
  cost := make([][]int, len(all_lines)*5);

  c_stride := len(all_lines);
  r_stride := len(all_lines[0]);

  for line, c in all_lines
  {
    for y in u8(0)..<u8(5)
    {
      maze[c+int(y)*c_stride] = make([]u8, len(line)*5);
      cost[c+int(y)*c_stride] = make([]int, len(line)*5);
    }
    for ch, r in line
    {
      val := u8(ch-'0');
      for y in u8(0)..<u8(5)
      {
        for x in u8(0)..<u8(5)
        {
          maze[c+int(y)*c_stride][r+int(x)*r_stride] = (val+x+y-1)%9 + 1;
          cost[c+int(y)*c_stride][r+int(x)*r_stride] = 100000000;
        }
      }
    }
  }

  when DEBUG do pretty_print(maze)

  pretty_print :: proc(maze : [][]$E)
  {
    for c in 0..<len(maze)
    {
      for r in 0..<len(maze[c])
      {
        print(maze[c][r]);
      }
      print("\n");
    }
    print("\n");
  }

  cost[0][0] = 0;
  better := true;
  for better
  {
    better = false;
    for c in 0..<len(maze)
    {
      for r in 0..<len(maze[c])
      {
        get_maze :: proc(maze : [][]$E, c, r : int) -> int
        {
          if c < 0 || c >= len(maze[0]) || r < 0 || r >= len(maze)
          {
            return 100000000;
          }
          return int(maze[c][r]);
        }

        current := cost[c][r];
        min_neig := min(get_maze(cost, c-1, r), get_maze(cost, c, r-1), get_maze(cost, c+1, r), get_maze(cost, c, r+1)) + get_maze(maze, c, r);
        if min_neig < current || current < 0
        {
          cost[c][r] = min_neig;
          better = true;
        }
      }
    }
  }

  return cost[len(maze)-1][len(maze[0])-1];
}
