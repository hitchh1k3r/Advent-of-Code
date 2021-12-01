package main;

import "core:fmt";

import "../../aoc";

PART_2_TEST_A_EXPECT : aoc.Result = 241861950;
PART_2_TEST_B_EXPECT : aoc.Result = nil;
PART_2_TEST_C_EXPECT : aoc.Result = nil;

part_2 :: proc($mode : aoc.LogicMode) -> aoc.Result
{
  using aoc, fmt;

  input := get_input(mode);

  data := int_arr(lines(input));

  for set in perms(data, 3)
  {
    if sum(set) == 2020
    {
      return prod(set);
    }
  }

  return nil;
}
