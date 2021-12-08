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

PART_1_TEST_A_EXPECT : aoc.Result = 5934;
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
  all_nums := int_arr(csv(input));

  fish : [dynamic]int;
  for n in all_nums
  {
    append(&fish, n);
  }

  for day in 1..80
  {
    for i := len(fish)-1; i >= 0; i -= 1
    {
      switch fish[i]
      {
        case 0:
          fish[i] = 6;
          append(&fish, 8);
        case:
          fish[i] -= 1;
      }
    }
    when DEBUG do println(day, fish);
  }

  return len(fish);
}
