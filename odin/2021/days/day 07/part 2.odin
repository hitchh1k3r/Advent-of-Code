package main;

import "core:builtin"
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

PART_2_TEST_A_EXPECT : aoc.Result = 168;
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
  all_nums := int_arr(csv(input));

  when DEBUG do println(all_nums);

  min_fuel := 10000000000;
  for target in slice.min(all_nums)..slice.max(all_nums)
  {
    fuel := 0;
    for source in all_nums
    {
      d := abs(source - target);
      s := (d*(d+1))/2;
      fuel += s;
    }
    if fuel < min_fuel
    {
      min_fuel = fuel;
    }
  }

  return min_fuel;
}
