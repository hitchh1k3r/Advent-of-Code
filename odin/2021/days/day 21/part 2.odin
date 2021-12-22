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

PART_2_TEST_A_EXPECT : aoc.Result = 444356092776315;
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

  p1_start_pos, p2_start_pos : int

  if _, ok := aoc.parse_input(input, "Player 1 starting position: ", &p1_start_pos, "\nPlayer 2 starting position: ", &p2_start_pos); ok {
  } else {
    assert(false)
  }

  GameState :: struct {
    p1_pos, p1_score, p2_pos, p2_score : int,
  }

  q1 : map[GameState]int
  q1[GameState{ p1_start_pos-1, 0, p2_start_pos-1, 0 }] = 1
  q2 : map[GameState]int

  src := &q1
  dst := &q2

  @static p1_win := 0
  @static p2_win := 0

  for {
    clear(dst)
    for state, num in src {
      if num > 0 {
        dst[state] = num
      }
    }
    if len(dst) <= 0 do break
    for state, num in src {
      if num <= 0 do continue

      dst[state] -= num

      p1_3 := state
      p1_3.p1_pos = (p1_3.p1_pos+3) % 10
      p1_3.p1_score += p1_3.p1_pos+1
      if p1_3.p1_score >= 21 {
        p1_win += 1*num
      } else {
        dst[p1_3] += 1*num
      }

      p1_4 := state
      p1_4.p1_pos = (p1_4.p1_pos+4) % 10
      p1_4.p1_score += p1_4.p1_pos+1
      if p1_4.p1_score >= 21 {
        p1_win += 3*num
      } else {
        dst[p1_4] += 3*num
      }

      p1_5 := state
      p1_5.p1_pos = (p1_5.p1_pos+5) % 10
      p1_5.p1_score += p1_5.p1_pos+1
      if p1_5.p1_score >= 21 {
        p1_win += 6*num
      } else {
        dst[p1_5] += 6*num
      }

      p1_6 := state
      p1_6.p1_pos = (p1_6.p1_pos+6) % 10
      p1_6.p1_score += p1_6.p1_pos+1
      if p1_6.p1_score >= 21 {
        p1_win += 7*num
      } else {
        dst[p1_6] += 7*num
      }

      p1_7 := state
      p1_7.p1_pos = (p1_7.p1_pos+7) % 10
      p1_7.p1_score += p1_7.p1_pos+1
      if p1_7.p1_score >= 21 {
        p1_win += 6*num
      } else {
        dst[p1_7] += 6*num
      }

      p1_8 := state
      p1_8.p1_pos = (p1_8.p1_pos+8) % 10
      p1_8.p1_score += p1_8.p1_pos+1
      if p1_8.p1_score >= 21 {
        p1_win += 3*num
      } else {
        dst[p1_8] += 3*num
      }

      p1_9 := state
      p1_9.p1_pos = (p1_9.p1_pos+9) % 10
      p1_9.p1_score += p1_9.p1_pos+1
      if p1_9.p1_score >= 21 {
        p1_win += 1*num
      } else {
        dst[p1_9] += 1*num
      }
    }
    src, dst = dst, src

    clear(dst)
    for state, num in src {
      if num > 0 {
        dst[state] = num
      }
    }
    if len(dst) <= 0 do break
    for state, num in src {
      if num <= 0 do continue

      dst[state] -= num

      p2_3 := state
      p2_3.p2_pos = (p2_3.p2_pos+3) % 10
      p2_3.p2_score += p2_3.p2_pos+1
      if p2_3.p2_score >= 21 {
        p2_win += 1*num
      } else {
        dst[p2_3] += 1*num
      }

      p2_4 := state
      p2_4.p2_pos = (p2_4.p2_pos+4) % 10
      p2_4.p2_score += p2_4.p2_pos+1
      if p2_4.p2_score >= 21 {
        p2_win += 3*num
      } else {
        dst[p2_4] += 3*num
      }

      p2_5 := state
      p2_5.p2_pos = (p2_5.p2_pos+5) % 10
      p2_5.p2_score += p2_5.p2_pos+1
      if p2_5.p2_score >= 21 {
        p2_win += 6*num
      } else {
        dst[p2_5] += 6*num
      }

      p2_6 := state
      p2_6.p2_pos = (p2_6.p2_pos+6) % 10
      p2_6.p2_score += p2_6.p2_pos+1
      if p2_6.p2_score >= 21 {
        p2_win += 7*num
      } else {
        dst[p2_6] += 7*num
      }

      p2_7 := state
      p2_7.p2_pos = (p2_7.p2_pos+7) % 10
      p2_7.p2_score += p2_7.p2_pos+1
      if p2_7.p2_score >= 21 {
        p2_win += 6*num
      } else {
        dst[p2_7] += 6*num
      }

      p2_8 := state
      p2_8.p2_pos = (p2_8.p2_pos+8) % 10
      p2_8.p2_score += p2_8.p2_pos+1
      if p2_8.p2_score >= 21 {
        p2_win += 3*num
      } else {
        dst[p2_8] += 3*num
      }

      p2_9 := state
      p2_9.p2_pos = (p2_9.p2_pos+9) % 10
      p2_9.p2_score += p2_9.p2_pos+1
      if p2_9.p2_score >= 21 {
        p2_win += 1*num
      } else {
        dst[p2_9] += 1*num
      }
    }
    src, dst = dst, src
  }

  return max(p1_win, p2_win)
}
