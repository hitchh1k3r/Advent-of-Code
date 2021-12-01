package main;

import "core:fmt"
import "core:strconv"
import "core:strings"
import "core:mem"
import "core:os"
import "core:slice"
import "core:math"
import "core:time"
import "core:sys/windows"
import "core:sort"
import "core:unicode/utf8"

import "../../aoc";

// SOLUTION ////////////////////////////////////////////////////////////////////////////////////////

part_2_crt :: proc($MODE : aoc.LogicMode) -> aoc.Result
{
  using aoc, fmt;

  DEBUG  :: false && MODE != .SOLUTION;
  TIMING :: false;

  input := get_input(MODE);

  allLines := lines(input);

  Remainder :: struct
  {
    remainder : int,
    modulo : int,
  };

  buses := strings.split(allLines[1], ",");
  remainders : [dynamic]Remainder;
  for busInterval, busIndex in buses
  {
    if busInterval != "x"
    {
      modulo := int_val(busInterval);
      remainder := -busIndex %% modulo;
      append(&remainders, Remainder{ remainder, modulo });
    }
  }

  // Chinese Remainder Theorem:
  N := 1;
  for remainder in remainders
  {
    N *= remainder.modulo;
  }

  crt := 0;
  for remainder in remainders
  {
    Ni := N / remainder.modulo;
    Xi := 1;
    for Ni*Xi % remainder.modulo != 1
    {
      Xi += 1;
    }
    crt += remainder.remainder * Ni * Xi;
  }

  return crt % N;
}
