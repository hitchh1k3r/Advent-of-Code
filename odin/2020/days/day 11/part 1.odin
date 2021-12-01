package main;

import "core:fmt"
import "core:strconv"
import "core:strings"
import "core:mem"
import "core:os"
import "core:slice"
import "core:math"
import "core:time"
import "core:sys/windows"
import "core:sort"
import "core:unicode/utf8"

import "../../aoc";

// TEST ANSWERS ////////////////////////////////////////////////////////////////////////////////////

PART_1_TEST_A_EXPECT : aoc.Result = 37;
PART_1_TEST_B_EXPECT : aoc.Result = nil;
PART_1_TEST_C_EXPECT : aoc.Result = nil;

// SOLUTION ////////////////////////////////////////////////////////////////////////////////////////

part_1 :: proc($MODE : aoc.LogicMode) -> aoc.Result
{
  using aoc, fmt;

  DEBUG  :: false && MODE != .SOLUTION;
  TIMING :: false;

  input := get_input(MODE);

  World :: struct
  {
    data          : [2][]rune,
    current, next : ^[]rune,
    width, height : int,
  };

  world : World;
  counts : []int;
  {
    when TIMING do PERF(PT_PROCESS_INPUT);
    singleString, _ := strings.replace_all(input, "\n", "");
    world.data[0] = utf8.string_to_runes(singleString);
    world.data[1] = utf8.string_to_runes(singleString);
    world.width = strings.index(input, "\n");
    world.height = len(world.data[0])/world.width;
    world.current = &world.data[0];
    world.next = &world.data[1];
    counts = make([]int, world.width*world.height);
    when TIMING do END_PERF();
  }

  V2 :: [2]int;

  INVALID :: ' ';
  FLOOR   :: '.';
  SEAT    :: 'L';
  PERSON  :: '#';

  get_cell :: proc(using world : World, pos : V2) -> rune
  {
    when TIMING do PERF(PT_GET_CELL);
    if pos.x < 0 ||
       pos.x >= width ||
       pos.y < 0 ||
       pos.y >= height
    {
      return INVALID;
    }
    return current[pos.x + pos.y*width];
  }

  set_cell :: proc(using world : World, pos : V2, val : rune)
  {
    when TIMING do PERF(PT_SET_CELL);
    if pos.x >= 0 &&
       pos.x < width &&
       pos.y >= 0 &&
       pos.y < height
    {
      next[pos.x + pos.y*width] = val;
    }
  }

  count_neigbors :: proc(using world : World, pos : V2) -> int
  {
    when TIMING do PERF(PT_COUNT_NEIGBORS);
    count := 0;
    directions :: []V2{ { -1,  1}, {  0,  1}, {  1,  1},
                        { -1,  0},            {  1,  0},
                        { -1, -1}, {  0, -1}, {  1, -1}, };
    for offset in directions
    {
      if get_cell(world, pos + offset) == PERSON
      {
        count += 1;
      }
    }
    return count;
  }

  simulate :: proc(using world : ^World) -> int
  {
    when TIMING do PERF(PT_SIMULATE);
    changes := 0;

    for y in 0..<height
    {
      for x in 0..<width
      {
        pos := V2{x, y};
        cell := get_cell(world^, pos);
        switch get_cell(world^, pos)
        {
          case SEAT:
            if count_neigbors(world^, pos) == 0
            {
              changes += 1;
              cell = PERSON;
            }
          case PERSON:
            if count_neigbors(world^, pos) >= 4
            {
              changes += 1;
              cell = SEAT;
            }
        }
        set_cell(world^, pos, cell);
      }
    }

    current, next = next, current;
    return changes;
  }

  when TIMING do PERF(PT_DO_SIMULATION);
  changed := simulate(&world);
  for changed > 0
  {
    changed = simulate(&world);

    when DEBUG
    {
      using world;
      when TIMING do PERF(PT_PRINT_DEBUG_STATE);
      for i := 0; i < len(current^); i += width
      {
        println(current^[i:i+width]);
      }
      print("\n");
      for i := 0; i < len(counts); i += width
      {
        println(counts[i:i+width]);
      }
      println(width);
      for i := 0; i < len(counts); i += width
      {
        for c in i..i+width-1
        {
          printf("% 3d  ", c%width);
        }
        print("\n");
      }
      print("\n");
      when TIMING do END_PERF();
    }
  }

  lastCount := 0;
  when TIMING do PERF(PT_COUNT_RESULTS);
  for c in world.current
  {
    if c == PERSON
    {
      lastCount += 1;
    }
  }
  when TIMING do END_PERF();

  return lastCount;
}
