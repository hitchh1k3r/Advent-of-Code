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

PART_1_TEST_A_EXPECT : aoc.Result = 1588;
PART_1_TEST_B_EXPECT : aoc.Result = nil;
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
  all_lines := lines(all_groups[1]);

  Element :: struct {
    c : u8,
    next : ^Element,
  }

  backing := make([]Element, 100000000);
  backing_index := 0;
  first := &backing[0];
  last := first;

  first.c = all_groups[0][0];
  backing_index += 1;
  for c in all_groups[0][1:]
  {
    element := &backing[backing_index];
    backing_index += 1;
    element.c = u8(c);
    last.next = element;
    last = element;
  }

  for q in 1..10
  {
    inserts : map[^Element]u8;
    defer delete(inserts);
    for line, i in all_lines
    {
      all_words := words(line);
      left := all_words[0][0];
      right := all_words[0][1];
      it := first;
      for it != nil && it.next != nil
      {
        if it.c == left && it.next.c == right
        {
          inserts[it] = all_words[2][0];
        }
        it = it.next;
      }
    }
    for after, c in inserts
    {
      element := &backing[backing_index];
      backing_index += 1;
      element.c = c;
      element.next = after.next;
      after.next = element;
    }
    when DEBUG do println(q, backing_index);
  }

  counts : map[u8]int;
  it := first;
  for it != nil
  {
    if it.c in counts
    {
      counts[it.c] += 1
    }
    else
    {
      counts[it.c] = 1
    }
    it = it.next;
  }
  low := max(int);
  high := min(int);
  for c, num in counts
  {
    low = min(low, num);
    high = max(high, num);
  }

  return high - low;
}
