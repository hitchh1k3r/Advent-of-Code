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

PART_1_TEST_A_EXPECT : aoc.Result = 14897079;
PART_1_TEST_B_EXPECT : aoc.Result = nil;
PART_1_TEST_C_EXPECT : aoc.Result = nil;

// SOLUTION ////////////////////////////////////////////////////////////////////////////////////////

part_1 :: proc($MODE : aoc.LogicMode) -> aoc.Result
{
  using aoc, fmt;

  DEBUG  :: false && MODE != .SOLUTION;
  TIMING :: false;

  input := get_input(MODE);

  allLines := lines(input);

  keyKey := int_val(allLines[0]);
  doorKey := int_val(allLines[1]);

  subj := 7;
  val := 1;
  count := 0;
  for val != keyKey && val != doorKey
  {
    val = val * subj;
    val = val % 20201227;
    count += 1;
  }

  if val == keyKey
  {
    subj = doorKey;
  }
  else
  {
    subj = keyKey;
  }
  val = 1;
  for i in 1..count
  {
    val = val * subj;
    val = val % 20201227;
  }

  return val;
}
