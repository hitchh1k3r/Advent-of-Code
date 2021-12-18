package main

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

import "../../../aoc"

// TEST ANSWERS ////////////////////////////////////////////////////////////////////////////////////

PART_2_TEST_A_EXPECT : aoc.Result = 112
PART_2_TEST_B_EXPECT : aoc.Result = nil
PART_2_TEST_C_EXPECT : aoc.Result = nil

// SOLUTION ////////////////////////////////////////////////////////////////////////////////////////

part_2 :: proc($MODE : aoc.LogicMode) -> aoc.Result {
  DEBUG :: (MODE != .SOLUTION)

  printf :: fmt.printf
  println :: fmt.println
  eprintf :: fmt.eprintf
  eprintln :: fmt.eprintln

  Rect :: struct {
    left : int,
    bottom : int,
    right : int,
    top : int,
  }

  input := aoc.get_input(MODE)

  target : Rect = ---
  if _, ok := aoc.parse_input(input, "target area: x=", &target.left, "..", &target.right, ", y=", &target.bottom, "..", &target.top); ok
  {} else {
    eprintln("could not parse")
    return nil
  }

  x_span := target.right-target.left+1
  y_span := target.top-target.bottom+1

  triangle :: proc(v : int) -> int
  {
    return (v*(v+1))/2
  }

  inv_triangle :: proc(v : int) -> f32
  {
    return (math.sqrt(f32(8*v + 1)) - 1) / 2
  }

  extra := 0
  check_min_x := int(inv_triangle(target.left))
  check_max_x_full := int(math.ceil(inv_triangle(target.right)))
  check_max_x := target.left-1
  check_y_max := -target.top
  check_y_max_full := triangle(-target.bottom-1)
  for x in check_min_x..check_max_x
  {
    max_y := -target.top
    if x <= check_max_x_full
    {
      max_y = check_y_max_full
    }
    for y in target.top+1..max_y
    {
      vx := x
      vy := y
      pos := [?]int{ 0, 0 }
      for pos.y >= target.bottom
      {
        pos += { vx, vy }
        vx = max(0, vx-1)
        vy -= 1
        if pos.x >= target.left && pos.x <= target.right && pos.y >= target.bottom && pos.y <= target.top
        {
          extra += 1
          break
        }
      }
    }
  }

  return (x_span * y_span) + extra
}
