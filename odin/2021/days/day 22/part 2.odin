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

PART_2_TEST_A_EXPECT : aoc.Result = nil;
PART_2_TEST_B_EXPECT : aoc.Result = 2758514936282235;
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
  all_lines := lines(input)

  State :: enum { on, off }

  Cuboid :: struct {
    valid : bool,
    min_pos : [3]int,
    max_pos : [3]int,
  }

  prev_cuboids : [dynamic]Cuboid

  overlap :: proc(a, b : Cuboid) -> Cuboid {
    result : Cuboid
    result.min_pos := max(a.min_pos, b.min_pos)
    result.max_pos := min(a.max_pos, b.max_pos)
    if result.max_pos.x >= result.min_pos.x &&
       result.max_pos.y >= result.min_pos.y &&
       result.max_pos.z >= result.min_pos.z
    {
      result.valid = true
    }
    return result
  }

  for i := len(all_lines); i >= 0; i -= 1 {
    line := all_lines[i]
    state : State
    cuboid : Cuboid
    if _, ok := aoc.parse_input(line, capture_enum(&state), " x=", &cuboid.min_pos.x, "..", &cuboid.max_pos.x, ",y=", &cuboid.min_pos.y, "..", &cuboid.max_pos.y, ",z=", &cuboid.min_pos.z, "..", &cuboid.max_pos.z); ok {
      if state == .on {
        area := prod((cuboid.max_pos - cuboid.min_pos)[:])
        for prev in prev_cuboids {
          min_overlap := max(cuboid.min_pos, prev.min_pos)
          max_overlap := min(cuboid.max_pos, prev.max_pos)
          if max_overlap.x >= min_overlap.x &&
             max_overlap.y >= min_overlap.y &&
             max_overlap.z >= min_overlap.z
          {
            min_area := 
          }
        }
      }
      append(&prev_cuboids, cuboid)
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
