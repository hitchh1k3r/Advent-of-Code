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

PART_1_TEST_A_EXPECT : aoc.Result = 4512;
PART_1_TEST_B_EXPECT : aoc.Result = nil;
PART_1_TEST_C_EXPECT : aoc.Result = nil;

// SOLUTION ////////////////////////////////////////////////////////////////////////////////////////

part_1 :: proc($MODE : aoc.LogicMode) -> aoc.Result
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
  all_lines := lines(input);

  Cell :: struct {
    num : int,
    called : bool,
  };

  draws := int_arr(csv(all_lines[0]));
  boards : [dynamic][5][5]Cell;

  for iBoard := 2; iBoard < len(all_lines); iBoard += 6
  {
    y := 0;
    board : [5][5]Cell;
    for i in iBoard..<iBoard+5
    {
      nums := int_arr(words(all_lines[i]));
      for c in 0..<5
      {
        board[y][c].num = nums[c];
      }
      y += 1;
    }
    append(&boards, board);
  }

  when DEBUG do println(draws);
  when DEBUG do println(boards);

  return nil;
}
