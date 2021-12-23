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
    if a.valid && b.valid {
      result.min_pos.x = max(a.min_pos.x, b.min_pos.x)
      result.min_pos.y = max(a.min_pos.y, b.min_pos.y)
      result.min_pos.z = max(a.min_pos.z, b.min_pos.z)
      result.max_pos.x = min(a.max_pos.x, b.max_pos.x)
      result.max_pos.y = min(a.max_pos.y, b.max_pos.y)
      result.max_pos.z = min(a.max_pos.z, b.max_pos.z)
      if result.max_pos.x >= result.min_pos.x &&
         result.max_pos.y >= result.min_pos.y &&
         result.max_pos.z >= result.min_pos.z
      {
        result.valid = true
      }
    }
    return result
  }

  area_excluding :: proc(cube : Cuboid, exclude : []Cuboid) -> int {
    if !cube.valid {
      return 0
    }

    if len(exclude) == 0 {
      diff := cube.max_pos - cube.min_pos + {1, 1, 1}
      return prod(diff[:])
    }

    diff := cube.max_pos - cube.min_pos + {1, 1, 1}
    area := prod(diff[:])
    for ex_cube, idx in exclude {
      ex_cube := overlap(ex_cube, cube)
      if ex_cube.valid {
        area -= area_excluding(ex_cube, exclude[:idx])
      }
    }
    return area
  }

  on_area := 0

  for i := len(all_lines)-1; i >= 0; i -= 1 {
    line := all_lines[i]
    state : State
    cuboid : Cuboid
    cuboid.valid = true
    if _, ok := aoc.parse_input(line, capture_enum(&state), " x=", &cuboid.min_pos.x, "..", &cuboid.max_pos.x, ",y=", &cuboid.min_pos.y, "..", &cuboid.max_pos.y, ",z=", &cuboid.min_pos.z, "..", &cuboid.max_pos.z); ok {
      if state == .on {
        on_area += area_excluding(cuboid, prev_cuboids[:])
      }
      append(&prev_cuboids, cuboid)
    } else {
      assert(false)
    }
  }

  return on_area
}
