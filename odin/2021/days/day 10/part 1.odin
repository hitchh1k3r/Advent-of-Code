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

PART_1_TEST_A_EXPECT : aoc.Result = 26397;
PART_1_TEST_B_EXPECT : aoc.Result = nil;
PART_1_TEST_C_EXPECT : aoc.Result = nil;

// SOLUTION ////////////////////////////////////////////////////////////////////////////////////////

part_1 :: proc($MODE : aoc.LogicMode) -> aoc.Result
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

  PAIRS  := map[rune]rune { '(' = ')',   '[' = ']',   '{' =  '}',   '<' =   '>' };
  POINTS := map[rune]int  { ')' =  3,    ']' =  57,   '}' = 1197,   '>' = 25137 };

  stack : [dynamic]rune;

  score := 0;
  for line in all_lines
  {
    clear(&stack);

    my_score := 0;
    for c in line
    {
      if c in PAIRS
      {
        append(&stack, PAIRS[c]);
      }
      if c in POINTS
      {
        s, ok := pop_safe(&stack);
        if !ok
        {
          break;
        }
        if c != s
        {
          my_score += POINTS[c];
          break;
        }
      }
    }
    score += my_score;
    when DEBUG do fmt.println(line, "\t", my_score);
  }

  return score;
}
