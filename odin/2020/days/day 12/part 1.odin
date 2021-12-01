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

PART_1_TEST_A_EXPECT : aoc.Result = 25;
PART_1_TEST_B_EXPECT : aoc.Result = nil;
PART_1_TEST_C_EXPECT : aoc.Result = nil;

// SOLUTION ////////////////////////////////////////////////////////////////////////////////////////

part_1 :: proc($MODE : aoc.LogicMode) -> aoc.Result
{
  using aoc, fmt;

  DEBUG  :: false && MODE != .SOLUTION;
  TIMING :: false;

  input := get_input(MODE);

  V2 :: [2]int;

  rot :: proc(angle : int, dir : ^V2)
  {
    using fmt;
    switch angle
    {
      case 90:
        dir.x, dir.y = dir.y, -dir.x;
      case 180:
        dir.x, dir.y = -dir.x, -dir.y;
      case 270:
        dir.x, dir.y = -dir.y, dir.x;
      case:
        println("Angle", angle, "not do!");
    }
  }

  heading := V2{1, 0};
  pos : V2;

  for line in lines(input)
  {
    val := int_val(line[1:]);
    switch line[0]
    {
      case 'N':
        pos.y += val;
      case 'E':
        pos.x += val;
      case 'S':
        pos.y -= val;
      case 'W':
        pos.x -= val;
      case 'L':
        rot(360-val, &heading);
      case 'R':
        rot(val, &heading);
      case 'F':
        pos += val * heading;
    }
  }

  return abs(pos.x)+abs(pos.y);
}
