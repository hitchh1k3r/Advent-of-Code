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
import "core:container"

import "../../../aoc";

// TEST ANSWERS ////////////////////////////////////////////////////////////////////////////////////

PART_2_TEST_A_EXPECT : aoc.Result = 3;
PART_2_TEST_B_EXPECT : aoc.Result = 6;
PART_2_TEST_C_EXPECT : aoc.Result = nil;

// SOLUTION ////////////////////////////////////////////////////////////////////////////////////////

part_2 :: proc($MODE : aoc.LogicMode) -> aoc.Result
{
  using aoc, fmt, container;

  when MODE != .SOLUTION
  { // TESTS MODE
    DEBUG  :: true;
    TIMING :: false;
  }
  else
  { // SOLVE MODE
    DEBUG  :: true;
    TIMING :: false;
  }

  input := get_input(MODE);
  all_groups := groups(input);
  all_lines := lines(all_groups[0]);
  target := all_groups[1];

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

  State :: struct
  {
    depth : int,
    txt : string,
  }

  unique_strings : map[string]bool;
  all_states : Queue(State);
  queue_reserve(&all_states, 10000000);
  queue_push_back(&all_states, State{ 0, target });

  for queue_len(all_states) > 0
  {
    using state := queue_pop_front(&all_states);
    for rep, q in replacements
    {
      using rep;
      if key != "e"
      {
        i := strings.index(txt, value);
        for i >= 0
        {
          a := []string{txt[:i], key, txt[i+len(value):]};
          str := strings.concatenate(a);
          if str not_in unique_strings
          {
            unique_strings[str] = true;
            queue_push_back(&all_states, State{ depth+1, str });
            when DEBUG do printf("%v -> %v at %v\n", txt, str, depth+1);
          }
          index_offset := strings.index(txt[i+1:], value);
          if index_offset >= 0
          {
            i = index_offset + i + 1;
          }
          else
          {
            i = -1;
          }
        }
      }
      else
      {
        if txt == value
        {
          return depth+1;
        }
      }
    }

    if depth > 4
    {
      return -1;
    }
    if depth > 0
    {
      delete(txt);
    }
  }
  return nil;
}
