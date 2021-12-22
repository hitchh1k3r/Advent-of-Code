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

PART_1_TEST_A_EXPECT : aoc.Result = 739785;
PART_1_TEST_B_EXPECT : aoc.Result = nil;
PART_1_TEST_C_EXPECT : aoc.Result = nil;

// SOLUTION ////////////////////////////////////////////////////////////////////////////////////////

part_1 :: proc($MODE : aoc.LogicMode) -> aoc.Result
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

  p1_pos, p2_pos : int

  if _, ok := aoc.parse_input(input, "Player 1 starting position: ", &p1_pos, "\nPlayer 2 starting position: ", &p2_pos); ok {
  } else {
    assert(false)
  }

  die := 0
  p1_pos -= 1
  p2_pos -= 1
  rolls := 0
  p1_score, p2_score : int

  for
  {
    p1_roll := (die)+1 + ((die+1)%100)+1 + ((die+2)%100)+1
    die += 3
    die %= 100
    rolls += 3
    p1_pos = (p1_pos + p1_roll) % 10
    p1_score += p1_pos + 1
    if p1_score >= 1000 do break

    p2_roll := (die)+1 + ((die+1)%100)+1 + ((die+2)%100)+1
    die += 3
    die %= 100
    rolls += 3
    p2_pos = (p2_pos + p2_roll) % 10
    p2_score += p2_pos + 1
    if p2_score >= 1000 do break
  }

  println(p1_score, p2_score, rolls)

  return min(p1_score, p2_score) * rolls
}
