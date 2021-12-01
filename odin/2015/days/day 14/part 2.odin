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
import "core:encoding/json"

import "../../../aoc";

// TEST ANSWERS ////////////////////////////////////////////////////////////////////////////////////

PART_2_TEST_A_EXPECT : aoc.Result = 689;
PART_2_TEST_B_EXPECT : aoc.Result = nil;
PART_2_TEST_C_EXPECT : aoc.Result = nil;

// SOLUTION ////////////////////////////////////////////////////////////////////////////////////////

part_2 :: proc($MODE : aoc.LogicMode) -> aoc.Result
{
  using aoc, fmt;

  DEBUG  :: false && MODE != .SOLUTION;
  TIMING :: false;

  Runner :: struct
  {
    speed, duration, rest : int,
    is_resting : bool,
    timer : int,
    distance : int,
    score : int,
  };

  input := get_input(MODE);
  allLines := lines(input);
  runners := make([]Runner, len(allLines));
  for line, i in allLines
  {
    data := words(line);
    runners[i].speed = int_val(data[3]);
    runners[i].duration = int_val(data[6]);
    runners[i].rest = int_val(data[13]);
  }

  when (MODE == .TEST_A)
  {
    seconds :: 1000;
  }
  else
  {
    seconds :: 2503;
  }

  for _ in 1..seconds
  {
    for _, i in runners
    {
      runners[i].timer += 1;
      if !runners[i].is_resting
      {
        runners[i].distance += runners[i].speed;
        if runners[i].timer >= runners[i].duration
        {
          runners[i].timer = 0;
          runners[i].is_resting = true;
        }
      }
      else
      {
        if runners[i].timer >= runners[i].rest
        {
          runners[i].timer = 0;
          runners[i].is_resting = false;
        }
      }
    }

    max := 0;
    for runner in runners
    {
      if runner.distance > max
      {
        max = runner.distance;
      }
    }
    for runner, i in runners
    {
      if runner.distance == max
      {
        runners[i].score += 1;
      }
    }
  }

  total := 0;
  for runner in runners
  {
    if runner.score > total
    {
      total = runner.score;
    }
  }

  return total;
}
