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

PART_1_TEST_A_EXPECT : aoc.Result = 17;
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
  all_groups := groups(input);
  all_points := lines(all_groups[0]);
  all_folds := lines(all_groups[1]);

  V2 :: [2]int;
  dots : map[V2]u8;

  for line, i in all_points
  {
    pt := int_arr(strings.split(line, ","));
    dots[{pt[0], pt[1]}] = 1;
  }

  for line, i in all_folds[:1]
  {
    bits := strings.split(line, "=");
    fold_place := int_val(bits[1]);
    if bits[0] == "fold along x"
    {
      for pt in slice.map_keys(dots)
      {
        if pt.x > fold_place
        {
          delete_key(&dots, pt);
          pt := [2]int{pt.x, pt.y};
          pt.x = fold_place - (pt.x - fold_place);
          dots[pt] = 1;
        }
      }
    }
    else
    {
      for pt in slice.map_keys(dots)
      {
        if pt.y > fold_place
        {
          delete_key(&dots, pt);
          pt := [2]int{pt.x, pt.y};
          pt.y = fold_place - (pt.y - fold_place);
          dots[pt] = 1;
        }
      }
    }
  }

  return len(dots);
}
