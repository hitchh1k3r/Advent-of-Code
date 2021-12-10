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

PART_2_TEST_A_EXPECT : aoc.Result = nil;
PART_2_TEST_B_EXPECT : aoc.Result = nil;
PART_2_TEST_C_EXPECT : aoc.Result = nil;

// SOLUTION ////////////////////////////////////////////////////////////////////////////////////////

part_2 :: proc($MODE : aoc.LogicMode) -> aoc.Result
{
  using aoc, fmt;

  when MODE != .SOLUTION
  { // TESTS MODE
    DEBUG  :: false;
    TIMING :: false;
  }
  else
  { // SOLVE MODE
    DEBUG  :: false;
    TIMING :: false;
  }

  input := int_val(get_input(MODE));

  for house in 1..input
  {
    dividend := house;
    primes : [100]int;

    pi := 0;
    primes[pi] = 1;
    pi += 1;

    max := int(math.sqrt(f32(dividend)));
    elf := 2;
    for elf <= max
    {
      if (dividend % elf) == 0
      {
        primes[pi] = elf;
        pi += 1;
        dividend /= elf;
        max = int(math.sqrt(f32(dividend)));
      }
      else
      {
        elf += 1;
      }
    }
    if dividend > 1
    {
      primes[pi] = dividend;
      pi += 1;
    }

    find_factors :: proc(factors : ^map[int]u8, divisor : int, primes : []int, dividend, index : int)
    {
      if dividend > divisor || dividend == 0
      {
        return
      }

      factors[dividend] = 1;

      for i in index..len(primes)-1
      {
        find_factors(factors, divisor, primes, primes[i]*dividend, i+1);
      }
    }

    factors : map[int]u8;
    defer delete(factors);
    find_factors(&factors, house, primes[:pi], 1, 0);

    sum := 0;
    for f in factors
    {
      if 50*f >= house
      {
        sum += 11*f;
      }
    }

    if (house % 100000 == 0)
    {
      println("House", house, "got", sum, "presents.");
    }
    if sum > input
    {
      return house;
    }
  }

  return nil;
}
