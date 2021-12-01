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

PART_1_TEST_A_EXPECT : aoc.Result = 71+51+26+437+12240+13632;
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

  getVal :: proc(str : string) -> int
  {
    words := strings.split(str, " ");
    index := 0;
    last := 0;
    op := '+';
    for index < len(str)
    {
      word := strings.split(str[index:], " ")[0];
      val := 0;
      if word[0] == '('
      {
        depth := 1;
        for c, i in str[index+1:]
        {
          if c == '('
          {
            depth += 1;
          }
          else if c == ')'
          {
            depth -= 1;
            if depth <= 0
            {
              val = getVal(str[index+1:index+1+i]);
              index += 2+i+1;
              break;
            }
          }
        }
        switch op
        {
          case '+':
            last += val;
          case '*':
            last *= val;
        }
      }
      else
      {
        v, ok := strconv.parse_int(word);
        if ok
        {
          val = v;
          switch op
          {
            case '+':
              last += val;
            case '*':
              last *= val;
          }
        }
        else
        {
          op = auto_cast word[0];
        }
        index += len(word)+1;
      }
    }
    return last;
  }

  total := 0;
  for line in allLines
  {
    total += getVal(line);
  }

  return total;
}
