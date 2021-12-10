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

PART_1_TEST_A_EXPECT : aoc.Result = 2;
PART_1_TEST_B_EXPECT : aoc.Result = nil;
PART_1_TEST_C_EXPECT : aoc.Result = nil;

// SOLUTION ////////////////////////////////////////////////////////////////////////////////////////

part_1 :: proc($MODE : aoc.LogicMode) -> aoc.Result
{
  using aoc, fmt;

  when MODE != .SOLUTION
  { // TESTS MODE
    DEBUG  :: true;
    TIMING :: false;
  }
  else
  { // SOLVE MODE
    DEBUG  :: false;
    TIMING :: false;
  }

  input, _ := strings.replace_all(get_input(MODE), ",", "");
  all_lines := lines(input);

  when DEBUG do println(all_lines);

  registers : map[string]uint;
  registers["a"] = 0;
  registers["b"] = 0;

  for inst_ptr := 0; inst_ptr < len(all_lines); inst_ptr += 1
  {
    line := all_lines[inst_ptr];
    all_words := words(line);
    switch all_words[0]
    {
      case "hlf":
        registers[all_words[1]] /= 2;
      case "tpl":
        registers[all_words[1]] *= 3;
      case "inc":
        registers[all_words[1]] += 1;
      case "jmp":
        inst_ptr += int_val(all_words[1])-1;
      case "jie":
        if registers[all_words[1]] % 2 == 0
        {
          inst_ptr += int_val(all_words[2])-1;
        }
      case "jio":
        if registers[all_words[1]] == 1
        {
          inst_ptr += int_val(all_words[2])-1;
        }
    }
  }

  return int(registers["b"]);
}
