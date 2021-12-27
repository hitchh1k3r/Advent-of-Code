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

PART_1_TEST_A_EXPECT : aoc.Result = 58
PART_1_TEST_B_EXPECT : aoc.Result = nil
PART_1_TEST_C_EXPECT : aoc.Result = nil

// SOLUTION ////////////////////////////////////////////////////////////////////////////////////////

part_1 :: proc($MODE : aoc.LogicMode) -> aoc.Result
{
  using aoc, fmt

  when MODE != .SOLUTION
  { // TESTS MODE
    DEBUG  :: true
    TIMING :: false
  }
  else
  { // SOLVE MODE
    DEBUG  :: false
    TIMING :: false
  }

  input := get_input(MODE)
  all_lines := lines(input)

  Tile :: enum { EMPTY, RIGHT, DOWN }

  V2 :: [2]int

  worldARight : map[V2]u8
  worldADown : map[V2]u8
  worldBRight : map[V2]u8
  worldBDown : map[V2]u8

  world_height := len(all_lines)
  world_width := len(all_lines[0])

  pos : V2
  for line, y in all_lines
  {
    pos.y = y
    for c, x in line
    {
      pos.x = x
      switch c {
        case '>':
          worldARight[pos] = 1
        case 'v':
          worldADown[pos] = 1
      }
    }
  }

  srcRight := &worldARight
  dstRight := &worldBRight

  srcDown := &worldADown
  dstDown := &worldBDown

  move := true
  step := 0
  for move {
    move = false
    step += 1

    clear(dstRight)
    clear(dstDown)

    for pos in srcRight {
      neigbor := pos
      neigbor.x = (neigbor.x + 1) % world_width
      if neigbor not_in srcRight && neigbor not_in srcDown {
        dstRight[neigbor] = 1
        move = true
      } else {
        dstRight[pos] = 1
      }
    }
    for pos in srcDown {
      neigbor := pos
      neigbor.y = (neigbor.y + 1) % world_height
      if neigbor not_in dstRight && neigbor not_in srcDown {
        dstDown[neigbor] = 1
        move = true
      } else {
        dstDown[pos] = 1
      }
    }

    dstRight, dstDown, srcRight, srcDown = srcRight, srcDown, dstRight, dstDown
  }

  return step
}
