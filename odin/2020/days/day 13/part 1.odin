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

PART_1_TEST_A_EXPECT : aoc.Result = 295;
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
  startTime := int_val(allLines[0]);

  buses := strings.split(allLines[1], ",");
  minOff := 1000000000;
  id := 0;
  for bus in buses
  {
    if bus != "x"
    {
      time := int_val(bus);
      offset := time - (startTime % time);
      if offset < minOff
      {
        println(startTime, time, offset);
        minOff = offset;
        id = time;
      }
    }
  }

  return minOff * id;
}
