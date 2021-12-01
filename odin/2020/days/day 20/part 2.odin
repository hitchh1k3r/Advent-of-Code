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

PART_2_TEST_A_EXPECT : aoc.Result = 273;
PART_2_TEST_B_EXPECT : aoc.Result = nil;
PART_2_TEST_C_EXPECT : aoc.Result = nil;

// SOLUTION ////////////////////////////////////////////////////////////////////////////////////////

part_2 :: proc($MODE : aoc.LogicMode) -> aoc.Result
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
    tileID : int,
    side : Side,
    flipped : bool,
  };

  Tile :: struct
  {
    id : int,
    data : [100]bool,
    top : Connection,
    left : Connection,
    right : Connection,
    bottom : Connection,
  };

  tileData : map[int]Tile;

  totalSea := 0;

  for tile in allTiles
  {
    tileLines := lines(tile);
    defer delete(tileLines);
    tileID := int_val(tileLines[0][5:len(tileLines[0])-1]);
    newTile : Tile;
    newTile.id = tileID;
    writeIndex := 0;
    row := 0;
    for line in tileLines[1:]
    {
      col := 0;
      for c in line
      {
        if c == '.'
        {
          newTile.data[writeIndex] = false;
        }
        else
        {
          if col > 0 && col < 9
          {
            if row > 0 && row < 9
            {
              totalSea += 1;
            }
          }
          newTile.data[writeIndex] = true;
        }
        writeIndex += 1;
        col += 1;
      }
      row += 1;
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

  get_strip :: proc(tile : ^Tile, side : Side, flip : bool, offset : int) -> u128
  {
    result : u128;
    switch side
    {
      case .TOP:
        for i in 1..8
        {
          if tile.data[i+10+offset*10]
          {
            if flip
            {
              result |= u128(1) << u32(i-1);
            }
            else
            {
              result |= u128(1) << u32((8-i));
            }
          }
        }
      case .RIGHT:
        for i in 1..8
        {
          if tile.data[i*10+8-offset]
          {
            if flip
            {
              result |= u128(1) << u32(i-1);
            }
            else
            {
              result |= u128(1) << u32((8-i));
            }
          }
        }
      case .BOTTOM:
        for i in 1..8
        {
          if tile.data[i+80-offset*10]
          {
            if flip
            {
              result |= u128(1) << u32((8-i));
            }
            else
            {
              result |= u128(1) << u32(i-1);
            }
          }
        }
      case .LEFT:
        for i in 1..8
        {
          if tile.data[i*10+offset+1]
          {
            if flip
            {
              result |= u128(1) << u32((8-i));
            }
            else
            {
              result |= u128(1) << u32(i-1);
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
            tileA.top = Connection { tileBId, .TOP, true };
          case leftB:
            tileA.top = Connection { tileBId, .LEFT, true };
          case rightB:
            tileA.top = Connection { tileBId, .RIGHT, true };
          case bottomB:
            tileA.top = Connection { tileBId, .BOTTOM, true };
        }
        switch topAF
        {
          case topB:
            tileA.top = Connection { tileBId, .TOP, false };
          case leftB:
            tileA.top = Connection { tileBId, .LEFT, false };
          case rightB:
            tileA.top = Connection { tileBId, .RIGHT, false };
          case bottomB:
            tileA.top = Connection { tileBId, .BOTTOM, false };
        }

        switch leftA
        {
          case topB:
            tileA.left = Connection { tileBId, .TOP, true };
          case leftB:
            tileA.left = Connection { tileBId, .LEFT, true };
          case rightB:
            tileA.left = Connection { tileBId, .RIGHT, true };
          case bottomB:
            tileA.left = Connection { tileBId, .BOTTOM, true };
        }
        switch leftAF
        {
          case topB:
            tileA.left = Connection { tileBId, .TOP, false };
          case leftB:
            tileA.left = Connection { tileBId, .LEFT, false };
          case rightB:
            tileA.left = Connection { tileBId, .RIGHT, false };
          case bottomB:
            tileA.left = Connection { tileBId, .BOTTOM, false };
        }

        switch rightA
        {
          case topB:
            tileA.right = Connection { tileBId, .TOP, true };
          case leftB:
            tileA.right = Connection { tileBId, .LEFT, true };
          case rightB:
            tileA.right = Connection { tileBId, .RIGHT, true };
          case bottomB:
            tileA.right = Connection { tileBId, .BOTTOM, true };
        }
        switch rightAF
        {
          case topB:
            tileA.right = Connection { tileBId, .TOP, false };
          case leftB:
            tileA.right = Connection { tileBId, .LEFT, false };
          case rightB:
            tileA.right = Connection { tileBId, .RIGHT, false };
          case bottomB:
            tileA.right = Connection { tileBId, .BOTTOM, false };
        }

        switch bottomA
        {
          case topB:
            tileA.bottom = Connection { tileBId, .TOP, true };
          case leftB:
            tileA.bottom = Connection { tileBId, .LEFT, true };
          case rightB:
            tileA.bottom = Connection { tileBId, .RIGHT, true };
          case bottomB:
            tileA.bottom = Connection { tileBId, .BOTTOM, true };
        }
        switch bottomAF
        {
          case topB:
            tileA.bottom = Connection { tileBId, .TOP, false };
          case leftB:
            tileA.bottom = Connection { tileBId, .LEFT, false };
          case rightB:
            tileA.bottom = Connection { tileBId, .RIGHT, false };
          case bottomB:
            tileA.bottom = Connection { tileBId, .BOTTOM, false };
        }
      }
    }
  }

  monster := [3]u128{ 0b01001001001001001000,
                      0b10000110000110000111,
                      0b00000000000000000010 };

  length := int(math.sqrt(f32(len(tileData))));

  next_side_ds :: proc(side : Side) -> Side
  {
    switch side
    {
      case .TOP:
        return .RIGHT;
      case .RIGHT:
        return .BOTTOM;
      case .BOTTOM:
        return .LEFT;
      case .LEFT:
        return .TOP;
    }
    no(side);
    return .TOP;
  }

  next_side_ws :: proc(side : Side) -> Side
  {
    switch side
    {
      case .TOP:
        return .LEFT;
      case .LEFT:
        return .BOTTOM;
      case .BOTTOM:
        return .RIGHT;
      case .RIGHT:
        return .TOP;
    }
    no(side);
    return .TOP;
  }

  cornerIDs : [4]int;
  {
    cornerIndex := 0;
    for tileID, tile in tileData
    {
      sides := 0;
      if tile.top.tileID != 0
      {
        sides += 1;
      }
      if tile.left.tileID != 0
      {
        sides += 1;
      }
      if tile.right.tileID != 0
      {
        sides += 1;
      }
      if tile.bottom.tileID != 0
      {
        sides += 1;
      }
      if sides == 2
      {
        cornerIDs[cornerIndex] = tileID;
        cornerIndex += 1;
      }
    }
  }

  for startTileID in cornerIDs
  {
    for flipIt in 0..1
    {
      currentTile := &tileData[startTileID];
      flip := (flipIt==1) ? true : false;
      up := Side.TOP;
      if flip
      {
        if currentTile.top.tileID == 0
        {
          if currentTile.right.tileID == 0
          {
            up = .TOP;
          }
          else // left == 0
          {
            up = .LEFT;
          }
        }
        else // bottom == 0
        {
          if currentTile.right.tileID == 0
          {
            up = .RIGHT;
          }
          else // left == 0
          {
            up = .BOTTOM;
          }
        }
      }
      else // !flip
      {
        if currentTile.top.tileID == 0
        {
          if currentTile.right.tileID == 0
          {
            up = .RIGHT;
          }
          else // left == 0
          {
            up = .TOP;
          }
        }
        else // bottom == 0
        {
          if currentTile.right.tileID == 0
          {
            up = .BOTTOM;
          }
          else // left == 0
          {
            up = .LEFT;
          }
        }
      }

      image := make([]u128, length*8);
      for y in 0..<length
      {
        leftTile := currentTile;
        leftUp := up;
        leftFlip := flip;
        for q in 0..<8
        {
          image[8*y + q] |= get_strip(currentTile, up, flip, q) << u32((length-1)*8);
        }
        for x in 1..<length
        {
          connection : Connection;
          if flip
          {
            switch up
            {
              case .TOP:
                connection = currentTile.left;
              case .RIGHT:
                connection = currentTile.top;
              case .BOTTOM:
                connection = currentTile.right;
              case .LEFT:
                connection = currentTile.bottom;
            }
          }
          else
          {
            switch up
            {
              case .TOP:
                connection = currentTile.right;
              case .RIGHT:
                connection = currentTile.bottom;
              case .BOTTOM:
                connection = currentTile.left;
              case .LEFT:
                connection = currentTile.top;
            }
          }
          currentTile = &tileData[connection.tileID];
          if connection.flipped
          {
            flip = !flip;
          }
          if flip
          {
            up = next_side_ws(connection.side);
          }
          else
          {
            up = next_side_ds(connection.side);
          }
          for q in 0..<8
          {
            image[8*y + q] |= get_strip(currentTile, up, flip, q) << u32((length-1-x)*8);
          }
        }

        if y < length-1
        {
          connection : Connection;
          switch leftUp
          {
            case .TOP:
              connection = leftTile.bottom;
            case .RIGHT:
              connection = leftTile.left;
            case .BOTTOM:
              connection = leftTile.top;
            case .LEFT:
              connection = leftTile.right;
          }
          currentTile = &tileData[connection.tileID];
          flip = leftFlip;
          if connection.flipped
          {
            flip = !flip;
          }
          up = connection.side;
        }
      }

      bin_to_sea :: proc(b : u128, width : int) -> string
      {
        str := aprintf("%0128b", b)[128-width:];
        str, _ = strings.replace_all(str, "0", ".");
        str, _ = strings.replace_all(str, "1", "#");
        return str;
      }

      for i := len(image)-1; i >= 0; i -= 1
      {
        b := image[i];
        println(bin_to_sea(b, (8*length)));
      }

      monsterCount := 0;

      searchImage:
      for r := 0; r < len(image)-2; r += 1
      {
        searchRow:
        for c : u32 = 0; c <= u32(8*length)-20; c += 1
        {
          searchMonster:
          for monsterChunk, m in monster
          {
            imageChunk := image[r+m] >> c;
            if (imageChunk & monsterChunk) != monsterChunk
            {
              continue searchRow;
            }
          }
          monsterCount += 1;
        }
      }

      println();

      if monsterCount > 0
      {
        return totalSea - (15*monsterCount);
      }
    }
  }

  return 0;
}
