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

PART_2_TEST_A_EXPECT : aoc.Result = 3351;
PART_2_TEST_B_EXPECT : aoc.Result = nil;
PART_2_TEST_C_EXPECT : aoc.Result = nil;

// SOLUTION ////////////////////////////////////////////////////////////////////////////////////////

part_2 :: proc($MODE : aoc.LogicMode) -> aoc.Result
{
  using aoc, fmt;

  when MODE != .SOLUTION
  { // TESTS MODE
    DEBUG  :: true;
    TIMING :: false;
  }
  else
  { // SOLVE MODE
    DEBUG  :: false;
    TIMING :: false;
  }

  input := get_input(MODE);
  all_groups := groups(input);
  lookup := all_groups[0]

  V2 :: [2]int
  Image :: map[V2]u8
  img_0 : Image
  img_1 : Image

  img_min := V2{ max(int), max(int) }
  img_max := V2{ min(int), min(int) }

  all_lines := lines(all_groups[1])
  for line, y in all_lines {
    for c, x in line {
      if c == '#' {
        img_min.x = min(img_min.x, x-200)
        img_min.y = min(img_min.y, y-200)
        img_max.x = max(img_max.x, x+200)
        img_max.y = max(img_max.y, y+200)
        img_0[{ x, y }] = 1
      }
    }
  }

  enhance :: proc(in_img, out_img : ^Image, img_min, img_max : ^V2, lookup : string) {
    for x in img_min.x..img_max.x do for y in img_min.y..img_max.y {
      index := 0
      key : V2
      key = V2{ x-1, y-1 }
      if key in in_img^ {
        index |= 1 << 8
      }
      key = V2{ x, y-1 }
      if key in in_img^ {
        index |= 1 << 7
      }
      key = V2{ x+1, y-1 }
      if key in in_img^ {
        index |= 1 << 6
      }
      key = V2{ x-1, y }
      if key in in_img^ {
        index |= 1 << 5
      }
      key = V2{ x, y }
      if key in in_img^ {
        index |= 1 << 4
      }
      key = V2{ x+1, y }
      if key in in_img^ {
        index |= 1 << 3
      }
      key = V2{ x-1, y+1 }
      if key in in_img^ {
        index |= 1 << 2
      }
      key = V2{ x, y+1 }
      if key in in_img^ {
        index |= 1 << 1
      }
      key = V2{ x+1, y+1 }
      if key in in_img^ {
        index |= 1 << 0
      }
      if lookup[index] == '#' {
        out_img[{ x, y }] = 1
      }
    }
  }

  img_in := &img_0
  img_out := &img_1

  for i in 1..50
  {
    clear(img_out)
    enhance(img_in, img_out, &img_min, &img_max, lookup)
    img_min.x += 3
    img_min.y += 3
    img_max.x -= 3
    img_max.y -= 3
    img_in, img_out = img_out, img_in
  }

  return len(img_in^)
}
