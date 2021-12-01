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

  DEBUG  :: false && MODE != .SOLUTION;
  TIMING :: false;

  input := get_input(MODE);

  password := utf8.string_to_runes(input);

  validatePass :: proc(password : []rune) -> bool
  {
    doubles := 0;
    straight := 0;
    last := ' ';
    inc := ' ';
    for c, i in password
    {
      if c == last
      {
        doubles += 1;
        last = ' ';
      }
      else
      {
        last = c;
      }
      if straight >= 0
      {
        if c == inc + 1
        {
          straight += 1;
          if straight >= 2
          {
            straight = -1;
          }
        }
        else
        {
          straight = 0;
        }
        inc = c;
      }
      if c == 'i' || c == 'o' || c == 'l'
      {
        return false;
      }
    }
    return doubles >= 2 && straight == -1;
  }

  for i in 1..2
  {
    isValid := false;
    for !isValid
    {
      for i := len(password)-1; i >= 0; i -= 1
      {
        if password[i] == 'z'
        {
          password[i] = 'a';
        }
        else
        {
          password[i] += 1;
          if password[i] == 'i' || password[i] == 'l' || password[i] == 'o'
          {
            password[i] += 1;
          }
          break;
        }
      }
      isValid = validatePass(password);
    }
  }

  return utf8.runes_to_string(password);
}
