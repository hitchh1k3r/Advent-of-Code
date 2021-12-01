package main;

import "core:fmt"
import "core:strconv"
import "core:strings"
import "core:mem"
import "core:os"
import "core:slice"
import "core:math"
import "core:time"
import "core:sys/windows"
import "core:sort"
import "core:unicode/utf8"

import "../../aoc";

// TEST ANSWERS ////////////////////////////////////////////////////////////////////////////////////

PART_2_TEST_A_EXPECT : aoc.Result = 1068781;
PART_2_TEST_B_EXPECT : aoc.Result = nil;
PART_2_TEST_C_EXPECT : aoc.Result = nil;

// SOLUTION ////////////////////////////////////////////////////////////////////////////////////////

part_2 :: proc($MODE : aoc.LogicMode) -> aoc.Result
{
  using aoc, fmt;

  DEBUG  :: false && MODE != .SOLUTION;
  TIMING :: false;

  input := get_input(MODE);

  allLines := lines(input);

  Remainder :: struct
  {
    remainder : int,
    modulo : int,
  };

  buses := strings.split(allLines[1], ",");
  remainders : [dynamic]Remainder;
  for busInterval, busIndex in buses
  {
    if busInterval != "x"
    {
      modulo := int_val(busInterval);
      remainder := -busIndex %% modulo;
      append(&remainders, Remainder{ remainder, modulo });
    }
  }

  solution := remainders[0].remainder;
  modulo := remainders[0].modulo;
  println(solution, modulo);
  for remainder in remainders[1:]
  {
    for ; (solution % remainder.modulo) != remainder.remainder; solution += modulo {}
    modulo *= remainder.modulo;
  }

  return solution;
}
