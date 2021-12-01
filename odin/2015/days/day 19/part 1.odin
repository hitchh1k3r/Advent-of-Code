package main;

import "core:fmt"
import "core:strconv"
import "core:strings"
import "core:mem"
import "core:os"
import "core:slice"
import "core:reflect"
import "core:math"
import "core:math/bits"
import "core:time"
import "core:sys/windows"
import "core:sort"
import "core:unicode/utf8"

import "../../../aoc";

// TEST ANSWERS ////////////////////////////////////////////////////////////////////////////////////

PART_1_TEST_A_EXPECT : aoc.Result = 4;
PART_1_TEST_B_EXPECT : aoc.Result = 7;
PART_1_TEST_C_EXPECT : aoc.Result = nil;

// SOLUTION ////////////////////////////////////////////////////////////////////////////////////////

part_1 :: proc($MODE : aoc.LogicMode) -> aoc.Result
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

  input := get_input(MODE);
  all_groups := groups(input);
  all_lines := lines(all_groups[0]);

  Replacement :: struct
  {
    key : string,
    value : string,
  }

  replacements := make([]Replacement, len(all_lines));

  for line, i in all_lines
  {
    all_words := words(line);
    replacements[i].key = all_words[0];
    replacements[i].value = all_words[2];
  }

  unique_strings : map[uint]bool;

  hash : uint = 5381;
  pre_str := all_groups[1];
  for _, i in pre_str
  {
    for rep in replacements
    {
      if len(pre_str) >= i+len(rep.key) && rep.key == pre_str[i:i+len(rep.key)]
      {
        rep_hash := hash;
        for letter in rep.value
        {
          rep_hash = 33 * rep_hash + uint(letter-'A');
        }
        for letter in pre_str[i+len(rep.key):]
        {
          rep_hash = 33 * rep_hash + uint(letter-'A');
        }
        unique_strings[rep_hash] = true;
        when DEBUG do printf("replacing at %v (%v) with %v hash is %v\n", rep.key, i, rep.value, rep_hash);
      }
    }
    hash = 33 * hash + uint(pre_str[i]-'A');
  }

  return len(unique_strings);
}
