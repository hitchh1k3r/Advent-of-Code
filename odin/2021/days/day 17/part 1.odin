package main

import "core:fmt"
import "core:strconv"
import "core:strings"
import "core:mem"
import "core:os"
import "core:slice"
import "core:math"
import "core:time"
import "core:sys/windows"
import "core:sort"
import "core:unicode/utf8"

import "../../../aoc"

// TEST ANSWERS ////////////////////////////////////////////////////////////////////////////////////

PART_1_TEST_A_EXPECT : aoc.Result = 45
PART_1_TEST_B_EXPECT : aoc.Result = nil
PART_1_TEST_C_EXPECT : aoc.Result = nil

// SOLUTION ////////////////////////////////////////////////////////////////////////////////////////

part_1 :: proc($MODE : aoc.LogicMode) -> aoc.Result {
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

  triangle :: proc(v : int) -> int
  {
    return (v*(v+1))/2
  }

  when DEBUG do printf("target area: x=%v..%v, y=%v..%v\n", target.left, target.right, target.bottom, target.top)

  return triangle(-target.bottom-1)
}
