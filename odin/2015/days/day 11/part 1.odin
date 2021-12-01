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

PART_1_TEST_A_EXPECT : aoc.Result = 3;
PART_1_TEST_B_EXPECT : aoc.Result = nil;
PART_1_TEST_C_EXPECT : aoc.Result = nil;

// SOLUTION ////////////////////////////////////////////////////////////////////////////////////////

part_1 :: proc($MODE : aoc.LogicMode) -> aoc.Result
{
  using aoc, fmt;

  DEBUG  :: false && MODE != .SOLUTION;
  TIMING :: false;

  input := get_input(MODE);

  count := 0;

  start := -1;
  for c, i in input
  {
    if c >= '0' && c <= '9'
    {
      if start < 0
      {
        start = i;
      }
    }
    else if start >= 0
    {
      if input[start-1] == '-'
      {
        count -= int_val(input[start:i]);
      }
      else
      {
        count += int_val(input[start:i]);
      }
      start = -1;
    }
  }

  return count;
}
