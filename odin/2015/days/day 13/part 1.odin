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

PART_1_TEST_A_EXPECT : aoc.Result = 330;
PART_1_TEST_B_EXPECT : aoc.Result = nil;
PART_1_TEST_C_EXPECT : aoc.Result = nil;

// SOLUTION ////////////////////////////////////////////////////////////////////////////////////////

part_1 :: proc($MODE : aoc.LogicMode) -> aoc.Result
{
  using aoc, fmt;

  DEBUG  :: false && MODE != .SOLUTION;
  TIMING :: false;

  input := get_input(MODE);

  names : [dynamic]string;
  relations : map[[2]string]int;

  allLines := lines(input);
  for line in allLines
  {
    words := strings.split(line, " ");
    defer delete(words);
    source := words[0];
    target := words[10];
    target = target[:len(target)-1];
    amount := int_val(words[3]);
    if words[2] == "lose"
    {
      amount = -amount;
    }
    if slice.contains(names[:], source)
    {}
    else
    {
      append(&names, source);
    }
    relations[{source, target}] = amount;
  }

  when MODE == .TEST_A
  {
    arrangements := perms(names[:], 4);
  }
  else // .SOLUTION
  {
    arrangements := perms(names[:], 8);
  }

  maxScore := 0;
  for table in arrangements
  {
    score := 0;
    for p, i in table
    {
      score += relations[{p, table[(i-1)%%len(table)]}];
      score += relations[{p, table[(i+1)%%len(table)]}];
    }
    if score > maxScore
    {
      maxScore = score;
    }
  }

  return maxScore;
}
