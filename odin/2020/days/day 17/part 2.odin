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

// SOLUTION ////////////////////////////////////////////////////////////////////////////////////////

part_2 :: proc($MODE : aoc.LogicMode) -> aoc.Result
{
  using aoc, fmt;

  DEBUG  :: false && MODE != .SOLUTION;
  TIMING :: false;

  input := get_input(MODE);
  allLines := lines(input);

  INVALID  :: ' ';
  INACTIVE :: '.';
  ACTIVE   :: '#';

  CellPos :: [4]int;

  worldA : map[CellPos]rune;
  worldB : map[CellPos]rune;

  {
    pos := CellPos(0);
    for line in allLines
    {
      pos.x = 0;
      for c in line
      {
        worldA[pos] = c;
        if c == ACTIVE
        {
          populate_neighbors(&worldA, pos, INACTIVE);
        }
        pos.x += 1;
      }
      pos.y += 1;
    }
  }

  pretty_print :: proc(source : ^map[$K/[$N]int]rune)
  {
    mn : K;
    mx : K;
    for i in 0..<N
    {
      mn = max(int);
      mx = min(int);
    }
    for pos in source
    {
      if get_cell_value(source, pos) == ACTIVE
      {
        for i in 0..<N
        {
          mn[i] = min(pos[i], mn[i]);
          mx[i] = max(pos[i], mx[i]);
        }
      }
    }
    it := make_multi_d_iterator(mn, mx);
    for pos in multi_d_iterate(&it)
    {
      if pos[0] == mn[0]
      {
        for i in 1..<N
        {
          if pos[i] > mn[i]
          {
            print("\n");
            break;
          }
        }
        when N > 2
        {
          if pos[1] == mn[1]
          {
            when N == 3
            {
              println("Z =", pos[2]);
            }
            else when N == 4
            {
              println("Z =", pos[2], "  W =", pos[3]);
            }
          }
        }
      }
      print(get_cell_value(source, pos));
    }
    print("\n");
  }

  populate_neighbors :: proc(source : ^map[CellPos]rune, pos : CellPos, defaultState : rune)
  {
    it := make_multi_d_iterator(CellPos(-1), CellPos(1));
    for offset in multi_d_iterate(&it)
    {
      if _, ok := source[pos+offset]; !ok
      {
        source[pos+offset] = defaultState;
      }
    }
  }

  get_cell_value :: proc(source : ^map[CellPos]rune, pos : CellPos) -> rune
  {
    if val, ok := source[pos]; ok
    {
      return val;
    }
    return INVALID;
  }

  count_neighbors :: proc(source : ^map[CellPos]rune, pos : CellPos, countState : rune) -> int
  {
    count := 0;
    it := make_multi_d_iterator(CellPos(-1), CellPos(1));
    for offset in multi_d_iterate(&it)
    {
      if offset != 0
      {
        if get_cell_value(source, pos+offset) == countState
        {
          count += 1;
        }
      }
    }
    return count;
  }

  target := &worldA;
  source := &worldB;

  for step in 1..6
  {
    if MODE != .SOLUTION && step <= 3
    {
      println("STEP", step);
      println();
      pretty_print(target);
      println();
    }
    source, target = target, source;
    for pos, cell in source
    {
      newCell := cell;
      switch cell
      {
        case INACTIVE:
          neighbor := count_neighbors(source, pos, ACTIVE);
          if neighbor == 3
          {
            newCell = ACTIVE;
          }
        case ACTIVE:
          neighbor := count_neighbors(source, pos, ACTIVE);
          if neighbor < 2 || neighbor > 3
          {
            newCell = INACTIVE;
          }
      }
      if newCell == ACTIVE
      {
        populate_neighbors(target, pos, INACTIVE);
      }
      target[pos] = newCell;
    }
  }

  count := 0;
  for _, cell in target
  {
    if cell == ACTIVE
    {
      count += 1;
    }
  }

  return count;
}
