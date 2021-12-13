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

PART_1_TEST_A_EXPECT : aoc.Result = 1656;
PART_1_TEST_B_EXPECT : aoc.Result = nil;
PART_1_TEST_C_EXPECT : aoc.Result = nil;

// SOLUTION ////////////////////////////////////////////////////////////////////////////////////////

world : [10][10]int;
flashes := 0;

part_1 :: proc($MODE : aoc.LogicMode) -> aoc.Result
{
  using aoc, fmt;

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

  input := get_input(MODE);
  all_lines := lines(input);

  for line, y in all_lines
  {
    for c, x in line
    {
      world[x][y] = int(c-'0')
    }
  }

  energize :: proc(pos : [2]int)
  {
    offsets :: [][2]int{
      {-1, -1},
      {-1, 0},
      {-1, 1},
      {0, -1},
      {0, 1},
      {1, -1},
      {1, 0},
      {1, 1},
    };
    world[pos.x][pos.y] += 1;
    if world[pos.x][pos.y] == 10
    {
      flashes += 1;
      for offset in offsets
      {
        new_pos := pos + offset;
        if new_pos.x >= 0 && new_pos.x < 10 && new_pos.y >= 0 && new_pos.y < 10
        {
          energize(new_pos);
        }
      }
    }
  }

  flashes = 0;

  for step in 1..100
  {
    for x in 0..<10
    {
      for y in 0..<10
      {
        energize({x, y});
      }
    }

    for y in 0..<10
    {
      for x in 0..<10
      {
        if world[x][y] > 9
        {
          world[x][y] = 0;
        }
        when DEBUG do print(world[x][y]);
      }
      when DEBUG do print("\n");
    }
    when DEBUG do print("\n");
  }

  return flashes;
}
