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
PART_2_TEST_B_EXPECT : aoc.Result = 4;
PART_2_TEST_C_EXPECT : aoc.Result = nil;

// SOLUTION ////////////////////////////////////////////////////////////////////////////////////////

part_2_original :: proc($MODE : aoc.LogicMode) -> aoc.Result
{
  using aoc, fmt;

  DEBUG  :: false && MODE != .SOLUTION;
  TIMING :: false;

  input := get_input(MODE);

  getElementValue :: proc(input : []rune, index : ^int) -> int
  {
    ignoreRed := (input[index^] == '{');
    index^ += 1;
    start := -1;
    count := 0;
    for ; index^ < len(input); index^ += 1
    {
      c := input[index^];
      if c == '[' || c == '{'
      {
        oldIndex := index^;
        add := getElementValue(input, index);
        count += add;
      }
      else
      {
        if ignoreRed && c == 'r' && input[index^+1] == 'e' && input[index^+2] == 'd' && input[index^-2] == ':'
        {
          depth := 0;
          index^ += 3;
          for ; index^ < len(input); index^ += 1
          {
            if input[index^] == '{'
            {
              depth += 1;
            }
            else if input[index^] == '}'
            {
              depth -= 1;
              if depth < 0
              {
                return 0;
              }
            }
          }
          return 0;
        }

        if c >= '0' && c <= '9'
        {
          if start < 0
          {
            start = index^;
          }
        }
        else if start >= 0
        {
          if input[start-1] == '-'
          {
            count -= int_val(temp_str(utf8.runes_to_string(input[start:index^])));
          }
          else
          {
            count += int_val(temp_str(utf8.runes_to_string(input[start:index^])));
          }
          start = -1;
        }

        if c == ']'
        {
          return count;
        }
        else if c == '}'
        {
          return count;
        }
      }
    }
    return count;
  }

  i := 0;
  return getElementValue(utf8.string_to_runes(input), &i);
}
