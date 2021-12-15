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

PART_1_TEST_A_EXPECT : aoc.Result = 40;
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

  maze := make([][]u8, len(all_lines));
  cost := make([][]int, len(all_lines));

  for line, c in all_lines
  {
    maze[c] = make([]u8, len(line));
    cost[c] = make([]int, len(line));
    for ch, r in line
    {
      maze[c][r] = u8(ch-'0');
      cost[c][r] = 100000000;
    }
  }

  pretty_print :: proc(maze : [][]$E)
  {
    for c in 0..<len(maze)
    {
      for r in 0..<len(maze[c])
      {
        print(maze[c][r]);
      }
      print("\n");
    }
    print("\n");
  }

  // THIS IS TOO SLOW, BUT SHOULD EVENTUALLY FIND THE SOLUTION
  /*
  State :: struct
  {
    pos : [2]int,
    offset : [2]int,
    cost : int,
  }

  moves : PriorityQueue(State, 10000)
  moves.priority = proc(using state : State) -> int
  {
    return 1000000-cost;
  }
  priority_queue_push(&moves, State{ {0,0}, {1,0}, 0 });
  priority_queue_push(&moves, State{ {0,0}, {0,1}, 0 });

  for
  {
    using move := priority_queue_pop(&moves);

    pos += offset;
    cost += int(maze[pos.y][pos.x]);
    if pos.x == len(maze)-1 && pos.y == len(maze[0])-1
    {
      return cost;
    }

    if pos.x > 0
    {
      priority_queue_push(&moves, State{ pos, {-1, 0}, cost });
    }
    if pos.y > 0
    {
      priority_queue_push(&moves, State{ pos, {0, -1}, cost });
    }
    if pos.x < len(maze)
    {
      priority_queue_push(&moves, State{ pos, {1, 0}, cost });
    }
    if pos.y < len(maze[0])
    {
      priority_queue_push(&moves, State{ pos, {0, 1}, cost });
    }
  }
  */

  cost[0][0] = 0;
  better := true;
  for better
  {
    better = false;
    for c in 0..<len(maze)
    {
      for r in 0..<len(maze[c])
      {
        get_maze :: proc(maze : [][]$E, c, r : int) -> int
        {
          if c < 0 || c >= len(maze[0]) || r < 0 || r >= len(maze)
          {
            return 100000000;
          }
          return int(maze[c][r]);
        }

        current := cost[c][r];
        min_neig := min(get_maze(cost, c-1, r), get_maze(cost, c, r-1), get_maze(cost, c+1, r), get_maze(cost, c, r+1)) + get_maze(maze, c, r);
        if min_neig < current || current < 0
        {
          cost[c][r] = min_neig;
          better = true;
        }
      }
    }
  }

  return cost[len(maze)-1][len(maze[0])-1];
}
