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

PART_1_TEST_A_EXPECT : aoc.Result = 10;
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

  Coord :: [3]int;

   e :: Coord { +1, -1,  0 };
  se :: Coord {  0, -1, +1 };
  sw :: Coord { -1,  0, +1 };
   w :: Coord { -1, +1,  0 };
  nw :: Coord {  0, +1, -1 };
  ne :: Coord { +1,  0, -1 };

  blackTiles : map[Coord]bool;

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

  count := 0;
  for k, v in blackTiles
  {
    if v
    {
      count += 1;
    }
  }

  return count;
}
