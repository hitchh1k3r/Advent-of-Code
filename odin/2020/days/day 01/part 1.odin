package main;

import "core:fmt";
import "core:strings";

import "../../aoc";

// TEST ANSWERS ////////////////////////////////////////////////////////////////////////////////////

PART_1_TEST_A_EXPECT : aoc.Result = 514579;
PART_1_TEST_B_EXPECT : aoc.Result = nil;
PART_1_TEST_C_EXPECT : aoc.Result = nil;

// SOLUTION ////////////////////////////////////////////////////////////////////////////////////////

part_1 :: proc($mode : aoc.LogicMode) -> aoc.Result
{
  using aoc, fmt;

  input := get_input(mode);

  data := int_arr(lines(input));

  for set in perms(data, 2)
  {
    if sum(set) == 2020
    {
      return prod(set);
    }
  }

  return nil;
}
