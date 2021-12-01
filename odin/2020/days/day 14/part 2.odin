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

PART_2_TEST_A_EXPECT : aoc.Result = nil;
PART_2_TEST_B_EXPECT : aoc.Result = 208;
PART_2_TEST_C_EXPECT : aoc.Result = nil;

// SOLUTION ////////////////////////////////////////////////////////////////////////////////////////

part_2 :: proc($MODE : aoc.LogicMode) -> aoc.Result
{
  using aoc, fmt;

  DEBUG  :: false && MODE != .SOLUTION;
  TIMING :: false;

  input := get_input(MODE);

  allLines := lines(input);

  mask :: proc(str : string) -> (oneMask : u64, zeroMask : u64, floatMask : [dynamic]uint)
  {
    ones, _ := strings.replace_all(str, "X", "0");
    zero, _ := strings.replace_all(str, "1", "X");
    zero, _ = strings.replace_all(zero, "0", "1");
    zero, _ = strings.replace_all(zero, "X", "0");
    oneMask, _ = strconv.parse_u64(ones, 2);
    zeroMask, _ = strconv.parse_u64(zero, 2);
    for c, i in str
    {
      if c == 'X'
      {
        append_elem(&floatMask, uint(35-i));
      }
    }
    return;
  }

  oneMask, zeroMask : u64;
  floatMask : [dynamic]uint;

  memory : map[int]u64;

  for line in allLines
  {
    bits := strings.split(line, " = ");
    if bits[0] == "mask"
    {
      oneMask, zeroMask, floatMask = mask(bits[1]);
    }
    else if strings.has_prefix(bits[0], "mem")
    {
      val, _ := strconv.parse_u64(bits[1]);

      addr, _ := strconv.parse_int(bits[0][4:len(bits[0])]);
      addr |= int(oneMask);
      floatBits(addr, val, &memory, floatMask, 0);
      floatBits :: proc(addr : int, val : u64, memory : ^map[int]u64, floatMask : [dynamic]uint, index : int)
      {
        if index >= len(floatMask)
        {
          memory[addr] = val;
          return;
        }
        bit := floatMask[index];
        addrPrime := addr;
        addrPrime &= ~(1 << bit);
        floatBits(addrPrime, val, memory, floatMask, index+1);
        addrPrime = addr;
        addrPrime |= 1 << bit;
        floatBits(addrPrime, val, memory, floatMask, index+1);
      }
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
