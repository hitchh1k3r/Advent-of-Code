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

PART_1_TEST_A_EXPECT : aoc.Result = 71;
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

  Rule :: struct {
    name : string,
    minA, maxA : int,
    minB, maxB : int,
  };

  rules : [dynamic]Rule;

  readIndex := 0;
  for line in allLines
  {
    if len(line) > 0
    {
      name := strings.split(line, ": ");
      ab := strings.split(name[1], " or ");
      a := strings.split(ab[0], "-");
      b := strings.split(ab[1], "-");
      append(&rules, Rule{ name[0], int_val(a[0]), int_val(a[1]), int_val(b[0]), int_val(b[1]) });
    }
    else
    {
      break;
    }
    readIndex += 1;
  }

  errorSum := 0;

  checkLines:
  for line in allLines[readIndex+5:]
  {
    vals := int_arr(strings.split(line, ","));
    checkVals:
    for val in vals
    {
      checkRules:
      for rule in rules
      {
        if (val >= rule.minA && val <= rule.maxA) ||
           (val >= rule.minB && val <= rule.maxB)
        {
          continue checkVals;
        }
      }
      errorSum += val;
    }
  }

  return errorSum;
}
