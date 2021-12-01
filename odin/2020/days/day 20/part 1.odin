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

PART_1_TEST_A_EXPECT : aoc.Result = 20899048083289;
PART_1_TEST_B_EXPECT : aoc.Result = nil;
PART_1_TEST_C_EXPECT : aoc.Result = nil;

// SOLUTION ////////////////////////////////////////////////////////////////////////////////////////

part_1 :: proc($MODE : aoc.LogicMode) -> aoc.Result
{
  using aoc, fmt;

  DEBUG  :: false && MODE != .SOLUTION;
  TIMING :: false;

  input := get_input(MODE);
  allTiles := strings.split(input, "\n\n");

  Side :: enum
  {
    TOP,
    LEFT,
    RIGHT,
    BOTTOM,
  };

  Connection :: struct
  {
    tileId : int,
    side : Side,
    flipped : bool,
  };

  Tile :: struct
  {
    data : [100]bool,
    top : [dynamic]Connection,
    left : [dynamic]Connection,
    right : [dynamic]Connection,
    bottom : [dynamic]Connection,
  };

  tileData : map[int]Tile;

  for tile in allTiles
  {
    tileLines := lines(tile);
    defer delete(tileLines);
    tileID := int_val(tileLines[0][5:len(tileLines[0])-1]);
    newTile : Tile;
    writeIndex := 0;
    for line in tileLines[1:]
    {
      for c in line
      {
        if c == '.'
        {
          newTile.data[writeIndex] = false;
        }
        else
        {
          newTile.data[writeIndex] = true;
        }
        writeIndex += 1;
      }
    }
    tileData[tileID] = newTile;
  }

  get_side :: proc(tile : ^Tile, side : Side, flip : bool) -> int
  {
    result : int;
    switch side
    {
      case .TOP:
        for i in 0..9
        {
          if tile.data[i]
          {
            if flip
            {
              result |= 1 << u32((9-i));
            }
            else
            {
              result |= 1 << u32(i);
            }
          }
        }
      case .RIGHT:
        for i in 0..9
        {
          if tile.data[i*10+9]
          {
            if flip
            {
              result |= 1 << u32((9-i));
            }
            else
            {
              result |= 1 << u32(i);
            }
          }
        }
      case .BOTTOM:
        for i in 0..9
        {
          if tile.data[i+90]
          {
            if flip
            {
              result |= 1 << u32(i);
            }
            else
            {
              result |= 1 << u32((9-i));
            }
          }
        }
      case .LEFT:
        for i in 0..9
        {
          if tile.data[i*10]
          {
            if flip
            {
              result |= 1 << u32(i);
            }
            else
            {
              result |= 1 << u32((9-i));
            }
          }
        }
    }
    return result;
  }

  for tileAId in tileData
  {
    tileA := &tileData[tileAId];
    topA := get_side(tileA, .TOP, false);
    topAF := get_side(tileA, .TOP, true);
    leftA := get_side(tileA, .LEFT, false);
    leftAF := get_side(tileA, .LEFT, true);
    rightA := get_side(tileA, .RIGHT, false);
    rightAF := get_side(tileA, .RIGHT, true);
    bottomA := get_side(tileA, .BOTTOM, false);
    bottomAF := get_side(tileA, .BOTTOM, true);
    for tileBId in tileData
    {
      tileB := &tileData[tileBId];
      topB := get_side(tileB, .TOP, false);
      leftB := get_side(tileB, .LEFT, false);
      rightB := get_side(tileB, .RIGHT, false);
      bottomB := get_side(tileB, .BOTTOM, false);
      if tileAId != tileBId
      {
        switch topA
        {
          case topB:
            append_elem(&tileA.top, Connection { tileBId, .TOP, true });
          case leftB:
            append_elem(&tileA.top, Connection { tileBId, .LEFT, true });
          case rightB:
            append_elem(&tileA.top, Connection { tileBId, .RIGHT, true });
          case bottomB:
            append_elem(&tileA.top, Connection { tileBId, .BOTTOM, true });
        }
        switch topAF
        {
          case topB:
            append_elem(&tileA.top, Connection { tileBId, .TOP, false });
          case leftB:
            append_elem(&tileA.top, Connection { tileBId, .LEFT, false });
          case rightB:
            append_elem(&tileA.top, Connection { tileBId, .RIGHT, false });
          case bottomB:
            append_elem(&tileA.top, Connection { tileBId, .BOTTOM, false });
        }

        switch leftA
        {
          case topB:
            append_elem(&tileA.left, Connection { tileBId, .TOP, true });
          case leftB:
            append_elem(&tileA.left, Connection { tileBId, .LEFT, true });
          case rightB:
            append_elem(&tileA.left, Connection { tileBId, .RIGHT, true });
          case bottomB:
            append_elem(&tileA.left, Connection { tileBId, .BOTTOM, true });
        }
        switch leftAF
        {
          case topB:
            append_elem(&tileA.left, Connection { tileBId, .TOP, false });
          case leftB:
            append_elem(&tileA.left, Connection { tileBId, .LEFT, false });
          case rightB:
            append_elem(&tileA.left, Connection { tileBId, .RIGHT, false });
          case bottomB:
            append_elem(&tileA.left, Connection { tileBId, .BOTTOM, false });
        }

        switch rightA
        {
          case topB:
            append_elem(&tileA.right, Connection { tileBId, .TOP, true });
          case leftB:
            append_elem(&tileA.right, Connection { tileBId, .LEFT, true });
          case rightB:
            append_elem(&tileA.right, Connection { tileBId, .RIGHT, true });
          case bottomB:
            append_elem(&tileA.right, Connection { tileBId, .BOTTOM, true });
        }
        switch rightAF
        {
          case topB:
            append_elem(&tileA.right, Connection { tileBId, .TOP, false });
          case leftB:
            append_elem(&tileA.right, Connection { tileBId, .LEFT, false });
          case rightB:
            append_elem(&tileA.right, Connection { tileBId, .RIGHT, false });
          case bottomB:
            append_elem(&tileA.right, Connection { tileBId, .BOTTOM, false });
        }

        switch bottomA
        {
          case topB:
            append_elem(&tileA.bottom, Connection { tileBId, .TOP, true });
          case leftB:
            append_elem(&tileA.bottom, Connection { tileBId, .LEFT, true });
          case rightB:
            append_elem(&tileA.bottom, Connection { tileBId, .RIGHT, true });
          case bottomB:
            append_elem(&tileA.bottom, Connection { tileBId, .BOTTOM, true });
        }
        switch bottomAF
        {
          case topB:
            append_elem(&tileA.bottom, Connection { tileBId, .TOP, false });
          case leftB:
            append_elem(&tileA.bottom, Connection { tileBId, .LEFT, false });
          case rightB:
            append_elem(&tileA.bottom, Connection { tileBId, .RIGHT, false });
          case bottomB:
            append_elem(&tileA.bottom, Connection { tileBId, .BOTTOM, false });
        }
      }
    }
  }

  Arrangment :: struct
  {
    tileID : int,
    flipH : bool,
    flipV : bool,
    rightRot : int,
  };

  product := 1;

  for tileId, tile in tileData
  {
    sides := 0;
    if len(tile.top) > 0
    {
      sides += 1;
    }
    if len(tile.left) > 0
    {
      sides += 1;
    }
    if len(tile.right) > 0
    {
      sides += 1;
    }
    if len(tile.bottom) > 0
    {
      sides += 1;
    }
    if sides == 2
    {
      product *= tileId;
    }
  }

  length := int(math.sqrt(f32(len(tileData))));
  tilePos := make([]Arrangment, length*length);

  return product;
}
