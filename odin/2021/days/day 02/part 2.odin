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

PART_2_TEST_A_EXPECT : aoc.Result = 900;
PART_2_TEST_B_EXPECT : aoc.Result = nil;
PART_2_TEST_C_EXPECT : aoc.Result = nil;

// SOLUTION ////////////////////////////////////////////////////////////////////////////////////////

part_2 :: proc($MODE : aoc.LogicMode) -> aoc.Result
{
  using aoc, fmt;

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

  input := get_input(MODE);
  all_lines := lines(input);

  x := 0;
  a := 0;
  d := 0;

  for line, i in all_lines
  {
    all_words := words(line);
    val := int_val(all_words[1]);
    switch all_words[0]
    {
      case "forward":
        x += val;
        d += a * val;
      case "down":
        a += val;
      case "up":
        a -= val;
    }
    when DEBUG do println(line, x, d);
  }

  return x * d;
}
