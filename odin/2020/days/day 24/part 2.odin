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

PART_2_TEST_A_EXPECT : aoc.Result = 2208;
PART_2_TEST_B_EXPECT : aoc.Result = nil;
PART_2_TEST_C_EXPECT : aoc.Result = nil;

// SOLUTION ////////////////////////////////////////////////////////////////////////////////////////

part_2 :: proc($MODE : aoc.LogicMode) -> aoc.Result
{
  using aoc, fmt;

  DEBUG  :: false && MODE != .SOLUTION;
  TIMING :: false;

  input := get_input(MODE);

  allLines := lines(input);

  Coord :: [3]int;

   e :: Coord { +1, -1,  0 };
  se :: Coord {  0, -1, +1 };
  sw :: Coord { -1,  0, +1 };
   w :: Coord { -1, +1,  0 };
  nw :: Coord {  0, +1, -1 };
  ne :: Coord { +1,  0, -1 };

  blackTiles : map[Coord]bool;

  get_tile :: proc(blackTiles : ^map[Coord]bool, coord : Coord) -> bool
  {
    if coord in blackTiles^
    {
      return blackTiles[coord];
    }
    return false;
  }

  black_neigbors :: proc(blackTiles : ^map[Coord]bool, coord : Coord) -> int
  {
    count := 0;
    @static allDir := [?]Coord{ e, se, sw, w, nw, ne };
    for offset in allDir
    {
      if get_tile(blackTiles, coord + offset)
      {
        count += 1;
      }
    }
    return count;
  }

  add_neigbors :: proc(blackTiles : ^map[Coord]bool, coord : Coord)
  {
    @static allDir := [?]Coord{ e, se, sw, w, nw, ne };
    for offset in allDir
    {
      if !get_tile(blackTiles, coord + offset)
      {
        blackTiles[coord + offset] = false;
      }
    }
  }

  for line in allLines
  {
    coord : Coord;
    for i := 0; i < len(line); i += 1
    {
      switch line[i:i+1]
      {
        case "e":
          coord += e;
        case "w":
          coord += w;
        case:
          switch line[i:i+2]
          {
            case "se":
              coord += se;
            case "sw":
              coord += sw;
            case "nw":
              coord += nw;
            case "ne":
              coord += ne;
          }
          i += 1;
      }
    }
    if coord in blackTiles
    {
      blackTiles[coord] = !blackTiles[coord];
    }
    else
    {
      blackTiles[coord] = true;
    }
  }

  otherBuffer : map[Coord]bool;
  source, target : ^map[Coord]bool;
  target = &blackTiles;
  source = &otherBuffer;

  for i in 1..100
  {
    source, target = target, source;

    for k, v in source
    {
      if v
      {
        add_neigbors(source, k);
      }
    }

    for k, v in source
    {
      t := v;
      if v
      {
        if black_neigbors(source, k) == 0 || black_neigbors(source, k) > 2
        {
          t = false;
        }
      }
      else
      {
        if black_neigbors(source, k) == 2
        {
          t = true;
        }
      }
      target[k] = t;
    }

    count := 0;
    for k, v in target
    {
      if v
      {
        count += 1;
      }
    }
  }

  count := 0;
  for k, v in target
  {
    if v
    {
      count += 1;
    }
  }

  return count;
}
