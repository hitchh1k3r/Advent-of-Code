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

PART_1_TEST_A_EXPECT : aoc.Result = "67384529";
PART_1_TEST_B_EXPECT : aoc.Result = nil;
PART_1_TEST_C_EXPECT : aoc.Result = nil;

// SOLUTION ////////////////////////////////////////////////////////////////////////////////////////

part_1 :: proc($MODE : aoc.LogicMode) -> aoc.Result
{
  using aoc, fmt;

  DEBUG  :: false && MODE != .SOLUTION;
  TIMING :: false;

  input := get_input(MODE);

  Cup :: struct
  {
    val : int,
    prev : ^Cup,
    next : ^Cup,
  };

  size := len(input);
  cups := make([]Cup, size);
  oneCup : ^Cup;

  for i := 0; i < size; i += 1
  {
    cups[i].val = int_val(input[i:i+1]);
    cups[i].prev = &cups[(i-1)%%size];
    cups[i].next = &cups[(i+1)%%size];
    if cups[i].val == 1
    {
      oneCup = &cups[i];
    }
  }

  currentCup := &cups[0];

  pop_cup :: proc(cup : ^Cup) -> ^Cup
  {
    cup.prev.next = cup.next;
    cup.next.prev = cup.prev;
    return cup;
  }

  insert_after :: proc(before : ^Cup, cup : ^Cup)
  {
    cup.prev = before;
    cup.next = before.next;
    before.next = cup;
    cup.next.prev = cup;
  }

  for i in 1..100
  {
    cup := currentCup;
    for i in 1..size
    {
      cup = cup.next;
    }

    a := pop_cup(currentCup.next);
    b := pop_cup(currentCup.next);
    c := pop_cup(currentCup.next);
    d := currentCup.val - 1;
    if d == 0
    {
      d = size;
    }
    for (d == a.val) || (d == b.val) || (d == c.val)
    {
      d -= 1;
      if d == 0
      {
        d = size;
      }
    }

    cup = currentCup;
    for i in 1..size
    {
      if cup.val == d
      {
        insert_after(cup, c);
        insert_after(cup, b);
        insert_after(cup, a);
        break;
      }
      cup = cup.next;
    }

    currentCup = currentCup.next;
  }

  b := strings.make_builder_none();
  defer strings.destroy_builder(&b);

  cup := oneCup.next;
  for i in 1..<size
  {
    strings.write_int(&b, cup.val);
    cup = cup.next;
  }

  return transmute(string) b.buf[:];
}
