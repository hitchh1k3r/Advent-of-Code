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

PART_2_TEST_A_EXPECT : aoc.Result = 12;
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

  world := make([][1000]int, 1000);

  for line, i in all_lines
  {
    all_words := words(line);
    a := int_arr(csv(all_words[0]));
    b := int_arr(csv(all_words[2]));
    if a[0] == b[0]
    {
      for y in min(a[1],b[1])..max(a[1],b[1])
      {
        world[a[0]][y] += 1;
      }
    }
    else if a[1] == b[1]
    {
      for x in min(a[0],b[0])..max(a[0],b[0])
      {
        world[x][a[1]] += 1;
      }
    }
    else if a[0] < b[0]
    {
      y := a[1];
      yd := int(math.sign(f32(b[1]-a[1])));
      for x := a[0]; ; x += int(math.sign(f32(b[0]-a[0])))
      {
        world[x][y] += 1;
        y += yd;
        if x == b[0]
        {
          break;
        }
      }
    }
    else
    {
      x := a[0];
      xd := int(math.sign(f32(b[0]-a[0])));
      for y := a[1]; ; y += int(math.sign(f32(b[1]-a[1])))
      {
        world[x][y] += 1;
        x += xd;
        if y == b[1]
        {
          break;
        }
      }
    }
  }

  when DEBUG
  {
    for x in 0..<10
    {
      for y in 0..<10
      {
        print(world[y][x]);
      }
      print("\n");
    }
  }

  c := 0;

  for x in 0..<1000
  {
    for y in 0..<1000
    {
      if world[x][y] >= 2
      {
        c += 1;
      }
    }
  }

  return c; // 19148
}
