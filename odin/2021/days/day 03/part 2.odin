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

PART_2_TEST_A_EXPECT : aoc.Result = 230;
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
    SIZE :: 5;
  }
  else
  { // SOLVE MODE
    DEBUG  :: false;
    TIMING :: false;
    SIZE :: 12;
  }

  input := get_input(MODE);
  all_lines := lines(input);
  all_nums := int_arr(all_lines, 2);

  oxy := 0;
  co2 := 0;

  {
    count : [SIZE]int;
    nums_enabled : [1001]bool = true;
    bitmask := 0;
    total := len(all_nums);
    ox: for i in 0..<SIZE
    {
      for num, n in all_nums
      {
        if nums_enabled[n] && (num & (1 << uint(SIZE-1-i))) > 0
        {
          count[i] += 1;
        }
      }
      when DEBUG do println(count[i], "of", total);
      if count[i]+count[i] >= total
      {
        oxy |= 1 << uint(SIZE-1-i);
      }
      bitmask |= 1 << uint(SIZE-1-i);
      for num, n in all_nums
      {
        if nums_enabled[n] && (num & bitmask) != oxy
        {
          nums_enabled[n] = false;
          total -= 1;
        }
      }
      if total == 1
      {
        for num, n in all_nums
        {
          if nums_enabled[n]
          {
            oxy = num;
            break ox;
          }
        }
      }
    }
  }
  when DEBUG do printf("%v (%5b)\n\n", oxy, oxy);

  {
    count : [SIZE]int;
    nums_enabled : [1001]bool = true;
    bitmask := 0;
    total := len(all_nums);
    co: for i in 0..<SIZE
    {
      for num, n in all_nums
      {
        if nums_enabled[n] && (num & (1 << uint(SIZE-1-i))) > 0
        {
          count[i] += 1;
        }
      }
      when DEBUG do println(count[i], "of", total);
      if count[i]+count[i] < total
      {
        co2 |= 1 << uint(SIZE-1-i);
      }
      bitmask |= 1 << uint(SIZE-1-i);
      for num, n in all_nums
      {
        if nums_enabled[n] && (num & bitmask) != co2
        {
          nums_enabled[n] = false;
          total -= 1;
        }
      }
      if total == 1
      {
        for num, n in all_nums
        {
          if nums_enabled[n]
          {
            co2 = num;
            break co;
          }
        }
      }
    }
  }
  when DEBUG do printf("%v (%5b)\n", co2, co2);

  return oxy * co2;
}
