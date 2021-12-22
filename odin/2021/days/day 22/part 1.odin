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

PART_1_TEST_A_EXPECT : aoc.Result = 590784;
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
  }
  else
  { // SOLVE MODE
    DEBUG  :: false;
    TIMING :: false;
  }

  input := get_input(MODE);
  all_lines := lines(input)

  State :: enum { on, off }
  V3 :: [3]int

  world : map[V3]State

  for line in all_lines {
    state : State
    min_pos, max_pos : V3
    if _, ok := aoc.parse_input(line, capture_enum(&state), " x=", &min_pos.x, "..", &max_pos.x, ",y=", &min_pos.y, "..", &max_pos.y, ",z=", &min_pos.z, "..", &max_pos.z); ok {
      if !((min_pos.x < -50 && max_pos.x < -50) ||
           (min_pos.x >  50 && max_pos.x >  50) ||
           (min_pos.y < -50 && max_pos.y < -50) ||
           (min_pos.y >  50 && max_pos.y >  50) ||
           (min_pos.z < -50 && max_pos.z < -50) ||
           (min_pos.z >  50 && max_pos.z >  50))
      {
        for x in max(-50, min_pos.x)..min(50, max_pos.x) do for y in max(-50, min_pos.y)..min(50, max_pos.y) do for z in max(-50, min_pos.z)..min(50, max_pos.z) {
          world[{x,y,z}] = state
        }
      }

/*
      c := 0
      for x in -50..50 do for y in -50..50 do for z in -50..50 {
        pos := V3{x,y,z}
        if pos in world && world[pos] == .on {
          println(pos)
          c += 1
        }
      }
      println(c)*/
    } else {
      assert(false)
    }
  }

  count := 0

  for x in -50..50 do for y in -50..50 do for z in -50..50 {
    if world[{x,y,z}] == .on {
      pos := V3{x,y,z}
      if pos in world && world[pos] == .on {
        count += 1
      }
    }
  }

  return count
}
