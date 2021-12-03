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

PART_1_TEST_A_EXPECT : aoc.Result = 198;
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
    SIZE :: 5;
  }
  else
  { // SOLVE MODE
    DEBUG  :: false;
    TIMING :: false;
    SIZE :: 12;
  }

  input := get_input(MODE);
  all_lines := lines(input);
  all_nums := int_arr(all_lines, 2);

  c : [SIZE]int;

  for num in all_nums
  {
    for i in 0..<SIZE
    {
      if (num & (1 << uint(i))) > 0
      {
        c[i] += 1;
      }
    }
  }

  gamma : uint = 0;
  for i in 0..<SIZE
  {
    if c[i] > (len(all_nums)/2)
    {
      gamma |= 1 << uint(i);
    }
  }

  bitmask : uint = (1 << SIZE) - 1;
  epsilon := (~gamma & bitmask);

  when DEBUG do printf("gamma:   %5b  %v\n", gamma, gamma);
  when DEBUG do printf("epsilon: %5b  %v\n", epsilon, epsilon);

  return int(gamma * epsilon);
}
