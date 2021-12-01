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

PART_2_TEST_A_EXPECT : aoc.Result = 149245887792;
PART_2_TEST_B_EXPECT : aoc.Result = nil;
PART_2_TEST_C_EXPECT : aoc.Result = nil;

// SOLUTION ////////////////////////////////////////////////////////////////////////////////////////

part_2 :: proc($MODE : aoc.LogicMode) -> aoc.Result
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

  size := 1_000_000;
  cups := make([]Cup, size);
  currentCup : ^Cup;

  for i := 0; i < size; i += 1
  {
    cups[i].val = i+1;
    cups[i].prev = &cups[(i-1)%%size];
    cups[i].next = &cups[(i+1)%%size];
  }

  for i := 0; i < len(input); i += 1
  {
    me := int_val(input[i:i+1])-1;
    if i > 0
    {
      prev := int_val(input[i-1:i])-1;
      cups[me].prev = &cups[prev];
      cups[prev].next = &cups[me];
    }
    else
    {
      cups[me].prev = &cups[size-1];
      cups[size-1].next = &cups[me];
    }
    if i < len(input)-1
    {
      next := int_val(input[i+1:i+2])-1;
      cups[me].next = &cups[next];
      cups[next].prev = &cups[me];
    }
    else
    {
      cups[me].next = &cups[len(input)];
      cups[len(input)].prev = &cups[me];
    }
    if i == 0
    {
      currentCup = &cups[me];
    }
  }

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

  for i in 1..10_000_000
  {
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

    insert_after(&cups[d-1], c);
    insert_after(&cups[d-1], b);
    insert_after(&cups[d-1], a);

    currentCup = currentCup.next;
  }

  return cups[0].next.val * cups[0].next.next.val;
}
