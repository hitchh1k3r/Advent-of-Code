package main;

import "core:fmt";

import "../../aoc";

PART_2_TEST_A_EXPECT : aoc.Result = 1;
PART_2_TEST_B_EXPECT : aoc.Result = nil;
PART_2_TEST_C_EXPECT : aoc.Result = nil;

part_2 :: proc($mode : aoc.LogicMode) -> aoc.Result
{
  using aoc, fmt;

  input := getInput(mode);

  data : []int = ---;
  {
    PERF("Parse Input");
    data = int_arr(lines(input));
  }

  {
    PERF("Solve");

  }

  return nil;
}
