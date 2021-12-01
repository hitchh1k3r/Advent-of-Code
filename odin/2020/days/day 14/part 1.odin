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

PART_1_TEST_A_EXPECT : aoc.Result = 165;
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

  mask :: proc(str : string) -> (oneMask : u64, zeroMask : u64)
  {
    ones, _ := strings.replace_all(str, "X", "0");
    zero, _ := strings.replace_all(str, "1", "X");
    zero, _ = strings.replace_all(zero, "0", "1");
    zero, _ = strings.replace_all(zero, "X", "0");
    oneMask, _ = strconv.parse_u64(ones, 2);
    zeroMask, _ = strconv.parse_u64(zero, 2);
    return;
  }

  oneMask, zeroMask : u64;

  memory : map[int]u64;

  for line in allLines
  {
    bits := strings.split(line, " = ");
    if bits[0] == "mask"
    {
      oneMask, zeroMask = mask(bits[1]);
    }
    else if strings.has_prefix(bits[0], "mem")
    {
      addr, _ := strconv.parse_int(bits[0][4:len(bits[0])]);
      val, _ := strconv.parse_u64(bits[1]);
      val |= oneMask;
      val &= ~zeroMask;
      memory[addr] = val;
    }
    else
    {
      no(bits[0]);
    }
  }

  runSum : u64 = 0;
  for k, v in memory
  {
    runSum += v;
  }

  return int(runSum);
}
