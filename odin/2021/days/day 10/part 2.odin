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

PART_2_TEST_A_EXPECT : aoc.Result = 288957;
PART_2_TEST_B_EXPECT : aoc.Result = nil;
PART_2_TEST_C_EXPECT : aoc.Result = nil;

// SOLUTION ////////////////////////////////////////////////////////////////////////////////////////

part_2 :: proc($MODE : aoc.LogicMode) -> aoc.Result
{
  when MODE != .SOLUTION
  { // TESTS MODE
    DEBUG  :: true;
    TIMING :: false;
  }
  else
  { // SOLVE MODE
    DEBUG  :: false;
    TIMING :: false;
  }

  input := aoc.get_input(MODE);
  all_lines := aoc.lines(input);

  PAIRS  := map[rune]rune { '(' = ')',   '[' = ']',   '{' = '}',   '<' = '>' };
  POINTS := map[rune]int  { ')' =   1,   ']' =   2,   '}' =  3,    '>' =  4 };

  stack : [dynamic]rune;

  scores : [dynamic]int;
  for line in all_lines
  {
    for c in line
    {
      if c in PAIRS
      {
        append(&stack, PAIRS[c]);
      }
      if c in POINTS
      {
        s, ok := pop_safe(&stack);
        if !ok || c != s
        {
          clear(&stack);
          break;
        }
      }
    }
    my_score := 0;
    for len(stack) > 0
    {
      my_score *= 5;
      my_score += POINTS[pop(&stack)];
    }
    if my_score > 0
    {
      append(&scores, my_score);
    }
    when DEBUG do fmt.println(line, "\t", my_score);
  }

  slice.sort(scores[:]);
  return scores[len(scores)/2];
}
