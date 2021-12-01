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

PART_1_TEST_A_EXPECT : aoc.Result = 112;
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

  worldA : [25][25][25]rune;
  worldB : [25][25][25]rune;

  for z in 0..<25
  {
    for y in 0..<25
    {
      for x in 0..<25
      {
        worldA[z][y][x] = INACTIVE;
      }
    }
  }


  {
    y := 7;
    z := 13;
    for line in allLines
    {
      x := 7;
      for c in line
      {
        worldA[z][y][x] = c;
        x += 1;
      }
      y += 1;
    }
  }

  WALL :: ' ';
  INACTIVE :: '.';
  ACTIVE :: '#';

  getCell :: proc(source : ^[25][25][25]rune, x, y, z : int) -> rune
  {
    if x < 0 || x >= 25 || y < 0 || y >= 25 || z < 0 || z >= 25
    {
      return WALL;
    }
    return source[z][y][x];
  }

  getNeigbors :: proc(source : ^[25][25][25]rune, x, y, z : int) -> int
  {
    count := 0;
    for zO in -1..1
    {
      for yO in -1..1
      {
        for xO in -1..1
        {
          if zO != 0 || xO != 0 || yO != 0
          {
            if getCell(source, x+xO, y+yO, z+zO) == ACTIVE
            {
              count += 1;
            }
          }
        }
      }
    }
    return count;
  }

  source := &worldA;
  target := &worldB;

  for step in 0..6
  {
    for z in 0..<25
    {
      for y in 0..<25
      {
        for x in 0..<25
        {
          cell := getCell(source, x, y, z);
          switch cell
          {
            case INACTIVE:
              neigbor := getNeigbors(source, x, y, z);
              if neigbor == 3
              {
                cell = ACTIVE;
              }
            case ACTIVE:
              neigbor := getNeigbors(source, x, y, z);
              if neigbor < 2 || neigbor > 3
              {
                cell = INACTIVE;
              }
          }
          target[z][y][x] = cell;
        }
      }
    }
    source, target = target, source;
  }

  count := 0;
  for z in 0..<25
  {
    for y in 0..<25
    {
      for x in 0..<25
      {
        cell := getCell(target, x, y, z);
        if cell == ACTIVE
        {
          count += 1;
        }
      }
    }
  }

  return count;
}
