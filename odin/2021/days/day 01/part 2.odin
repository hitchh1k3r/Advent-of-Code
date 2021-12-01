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

PART_2_TEST_A_EXPECT : aoc.Result = 5;
PART_2_TEST_B_EXPECT : aoc.Result = nil;
PART_2_TEST_C_EXPECT : aoc.Result = nil;

// SOLUTION ////////////////////////////////////////////////////////////////////////////////////////

part_2 :: proc($MODE : aoc.LogicMode) -> aoc.Result
{
  using aoc, fmt;

  when MODE != .SOLUTION
  { // TESTS MODE
    DEBUG  :: false;
    TIMING :: false;
  }
  else
  { // SOLVE MODE
    DEBUG  :: false;
    TIMING :: false;
  }

  input := get_input(MODE);
  all_lines := lines(input);
  all_nums := int_arr(all_lines);

  when DEBUG do println(all_nums);

  count := 0;

  for n, i in all_nums[3:]
  {
    when DEBUG do println(all_nums[i], n);
    if n > all_nums[i]
    {
      count += 1;
    }
  }

  return count;
}
