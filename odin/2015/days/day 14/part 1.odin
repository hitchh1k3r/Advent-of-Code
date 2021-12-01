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

PART_1_TEST_A_EXPECT : aoc.Result = 1120;
PART_1_TEST_B_EXPECT : aoc.Result = nil;
PART_1_TEST_C_EXPECT : aoc.Result = nil;

// SOLUTION ////////////////////////////////////////////////////////////////////////////////////////

part_1 :: proc($MODE : aoc.LogicMode) -> aoc.Result
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
      using runner := &runners[i];
      timer += 1;
      if !is_resting
      {
        distance += speed;
        if timer >= duration
        {
          timer = 0;
          is_resting = true;
        }
      }
      else
      {
        if timer >= rest
        {
          timer = 0;
          is_resting = false;
        }
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

  return max;
}
