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

PART_2_TEST_A_EXPECT : aoc.Result = 1924;
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
  all_lines := lines(input);

  draws := int_arr(csv(all_lines[0]));
  boards : [dynamic][5][5]int;
  called : [dynamic][5][5]bool;

  for iBoard := 2; iBoard < len(all_lines); iBoard += 6
  {
    y := 0;
    board : [5][5]int;
    for i in iBoard..<iBoard+5
    {
      nums := int_arr(words(all_lines[i]));
      for c in 0..<5
      {
        board[y][c] = nums[c];
      }
      y += 1;
    }
    append(&boards, board);
    append(&called, [5][5]bool{});
  }

  check_win :: proc(board : [5][5]int, called : ^[5][5]bool, call : int) -> bool
  {
    for y in 0..<5
    {
      for x in 0..<5
      {
        if board[x][y] == call
        {
          called[x][y] = true;
          xWin := true;
          yWin := true;
          for q in 0..<5
          {
            if !called[x][q]
            {
              xWin = false;
            }
            if !called[q][y]
            {
              yWin = false;
            }
          }
          if (xWin || yWin)
          {
            when DEBUG do println(xWin, yWin, board);
          }
          return (xWin || yWin);
        }
      }
    }
    return false;
  }

  done_boards := make([]bool, len(boards));
  wins := 0;
  for call in draws
  {
    when DEBUG do println("calling:",call);
    for board, i in boards
    {
      if !done_boards[i] && check_win(board, &called[i], call)
      {
        done_boards[i] = true;
        wins += 1;
        if wins == len(boards)
        {
          sum := 0;
          for y in 0..<5
          {
            for x in 0..<5
            {
              if !called[i][x][y]
              {
                when DEBUG do println("not called:",board[x][y]);
                sum += board[x][y];
              }
            }
          }
          when DEBUG do println("sum:",sum);
          return sum * call;
        }
      }
    }
  }

  return nil;
}
