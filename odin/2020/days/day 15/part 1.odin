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

import "../../aoc";

// TEST ANSWERS ////////////////////////////////////////////////////////////////////////////////////

PART_1_TEST_A_EXPECT : aoc.Result = 436;
PART_1_TEST_B_EXPECT : aoc.Result = nil;
PART_1_TEST_C_EXPECT : aoc.Result = nil;

// SOLUTION ////////////////////////////////////////////////////////////////////////////////////////

part_1 :: proc($MODE : aoc.LogicMode) -> aoc.Result
{
  using aoc, fmt;

  DEBUG  :: false && MODE != .SOLUTION;
  TIMING :: false;

  input := get_input(MODE);

  start := int_arr(strings.split(input, ","));

  Pair :: struct
  {
    a : int,
    b : int,
  };

  ages : map[int]Pair;
  last : int;

  for num, i in start
  {
    ages[num] = {i+1, ages[num].a};
    last = num;
  }

  for i in len(start)..<2020
  {
    num := 0;
    if ages[last].b != 0
    {
      num = ages[last].a - ages[last].b;
    }

    ages[num] = {i+1, ages[num].a};
    last = num;
  }

  return last;
}
