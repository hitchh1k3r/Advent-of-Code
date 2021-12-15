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

PART_2_TEST_A_EXPECT : aoc.Result = 2188189693529;
PART_2_TEST_B_EXPECT : aoc.Result = nil;
PART_2_TEST_C_EXPECT : aoc.Result = nil;

// SOLUTION ////////////////////////////////////////////////////////////////////////////////////////

part_2 :: proc($MODE : aoc.LogicMode) -> aoc.Result
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

  Pair :: struct {
    left, right : u8,
  }
  double_buffer : [2]map[Pair]int;
  count := &double_buffer[0];
  back_buffer := &double_buffer[1];
  last := all_groups[0][0];
  for c in all_groups[0][1:]
  {
    pair := Pair{ last, u8(c) };
    last = u8(c);
    back_buffer[pair] += 1;
  }

  when DEBUG
  {
    println("Initial");
    for p, n in back_buffer
    {
      println(rune(p.left), rune(p.right), "=", n);
    }
    println();
  }

  for q in 1..40
  {
    for p in count
    {
      count[p] = 0;
    }
    for line, i in all_lines
    {
      target := Pair{ line[0], line[1] };
      insert := line[6];
      num := back_buffer[target];
      target.right = insert;
      count[target] += num;
      target.left = insert;
      target.right = line[1];
      count[target] += num;
    }
    when DEBUG
    {
      println("After", q);
      for p, n in count
      {
        println(rune(p.left), rune(p.right), "=", n);
      }
      println();
    }
    count, back_buffer = back_buffer, count;
  }

  char_count : map[u8]int;
  for pair, num in back_buffer
  {
    char_count[pair.left] += num;
    char_count[pair.right] += num;
  }
  char_count[all_groups[0][0]] += 1;
  char_count[all_groups[0][len(all_groups[0])-1]] += 1;
  when DEBUG
  {
    println("Character Counts");
    for c, n in char_count
    {
      println(rune(c), "=", n/2);
    }
    println();
  }

  count_vals := slice.map_values(char_count);
  return (slice.max(count_vals) - slice.min(count_vals)) / 2;

  // WARNING :: This will use all of your systems memory very quickly, and could crash your computer
  //            The final sequence is about 21 trillion characters long (105TB in linked list mem.)
  /*
  Element :: struct {
    c : u8,
    next : ^Element,
  }

  Replacement :: struct {
    left : u8,
    right : u8,
    middle : u8,
  }

  ReplacementSet :: struct {
    left : u8,
    right : u8,
    middle : []u8,
  }

  backing := make([]Element, 1000000000);

  basic_reps := make([]Replacement, len(all_lines));

  for line, i in all_lines
  {
    basic_reps[i].left = line[0];
    basic_reps[i].right = line[1];
    basic_reps[i].middle = line[6];
  }

  set_reps := make([]ReplacementSet, len(all_lines));

  for _, i in basic_reps
  {
    set_reps[i].left = basic_reps[i].left;
    set_reps[i].right = basic_reps[i].right;
    first := &backing[0];
    first.c = basic_reps[i].left;
    first.next = &backing[1];
    first.next.c = basic_reps[i].right;
    backing_index := 2;

    for q in 1..10
    {
      inserts : map[^Element]u8;
      defer delete(inserts);
      it := first;
      for it != nil && it.next != nil
      {
        for rep in basic_reps
        {
          if it.c == rep.left && it.next.c == rep.right
          {
            inserts[it] = rep.middle;
          }
        }
        it = it.next;
      }
      for after, c in inserts
      {
        element := &backing[backing_index];
        backing_index += 1;
        element.c = c;
        element.next = after.next;
        after.next = element;
      }
    }

    set_reps[i].middle = make([]u8, backing_index);

    it := first;
    q := 0;
    for it != nil
    {
      old := it;
      it = it.next;
      old.next = nil;
      set_reps[i].middle[q] = old.c;
      q += 1;
    }
    println("pre-processing", all_lines[i], len(set_reps[i].middle));
  }

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

  for q in 1..4
  {
    inserts : map[^Element][]u8;
    defer delete(inserts);
    it := &backing[0];
    for it != nil && it.next != nil
    {
      for rep in set_reps
      {
        if it.c == rep.left && it.next.c == rep.right
        {
          inserts[it] = rep.middle;
        }
      }
      it = it.next;
    }
    for after, str in inserts
    {
      after := after;
      last := after.next;
      for c in str
      {
        element := &backing[backing_index];
        backing_index += 1;
        element.c = c;
        after.next = element;
        after = element;
      }
      after.next = last;
    }
    println(q, backing_index);
  }

  counts : map[u8]int;
  it := &backing[0];
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
  */
}
