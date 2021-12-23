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

PART_2_TEST_A_EXPECT : aoc.Result = 44169;
PART_2_TEST_B_EXPECT : aoc.Result = nil;
PART_2_TEST_C_EXPECT : aoc.Result = nil;

// SOLUTION ////////////////////////////////////////////////////////////////////////////////////////

part_2 :: proc($MODE : aoc.LogicMode) -> aoc.Result
{
  using aoc, fmt;

  State :: struct {
    stacks : [4][4]u8,
    hall : [11]u8,
    energy_used : int,
  }

  when MODE != .SOLUTION
  { // TESTS MODE
    DEBUG  :: true;
    TIMING :: false;
    START_STATE :: State{ { {'B','D','D','A'}, {'C','C','B','D'}, {'B','B','A','C'}, {'D','A','C','A'} }, {}, 0 }
  }
  else
  { // SOLVE MODE
    DEBUG  :: false;
    TIMING :: false;
    START_STATE :: State{ { {'C','D','D','B'}, {'D','C','B','A'}, {'D','B','A','B'}, {'A','A','C','C'} }, {}, 0 }
  }

  moves := cast(^PriorityQueue(State, 200000000))mem.alloc(size_of(PriorityQueue(State, 200000000)))

  moves.priority = proc(using state : State) -> int
  {
    return 1000000-energy_used;
  }
  priority_queue_push(moves, START_STATE);

  move_costs := [?]int{ 1, 10, 100, 1000 }

  is_empty :: proc(s : []u8) -> bool {
    for c in s {
      if c != 0 do return false
    }
    return true
  }

  memo : map[State]int

  idx := 0
  for {
    using state := priority_queue_pop(moves);

    idx += 1
    if (idx % 5000) == 1 {
      println("#############")

      print("#")
      for h in 0..10 {
        if hall[h] == 0 {
          print(".")
        } else {
          print(rune(hall[h]))
        }
      }
      print("#\n")

      print("###")
      for s in 0..3 {
        if stacks[s][0] == 0 {
          print(".")
        } else {
          print(rune(stacks[s][0]))
        }
        print("#")
      }
      print("##\n")

      print("  #")
      for s in 0..3 {
        if stacks[s][1] == 0 {
          print(".")
        } else {
          print(rune(stacks[s][1]))
        }
        print("#")
      }
      print("\n")

      print("  #")
      for s in 0..3 {
        if stacks[s][2] == 0 {
          print(".")
        } else {
          print(rune(stacks[s][2]))
        }
        print("#")
      }
      print("\n")

      print("  #")
      for s in 0..3 {
        if stacks[s][3] == 0 {
          print(".")
        } else {
          print(rune(stacks[s][3]))
        }
        print("#")
      }
      print("\n")

      println("  #########\n", energy_used, "\n")
    }

    if stacks[0][0] == 'A' && stacks[0][1] == 'A' && stacks[0][2] == 'A' && stacks[0][3] == 'A' &&
       stacks[1][0] == 'B' && stacks[1][1] == 'B' && stacks[1][2] == 'B' && stacks[1][3] == 'B' &&
       stacks[2][0] == 'C' && stacks[2][1] == 'C' && stacks[2][2] == 'C' && stacks[2][3] == 'C' &&
       stacks[3][0] == 'D' && stacks[3][1] == 'D' && stacks[3][2] == 'D' && stacks[3][3] == 'D'
    {
      return energy_used
    }

    // Move into hall:
    for h in 0..10 {
      if h == 2 || h == 4 || h == 6 || h == 8 do continue

      for s in 0..3 {
        hmin := min(h, 2*s+2)
        hmax := max(h, 2*s+2)
        if ((stacks[s][0] != 0 && stacks[s][0] != u8(s)+'A') || (stacks[s][1] != 0 && stacks[s][1] != u8(s)+'A') || (stacks[s][2] != 0 && stacks[s][2] != u8(s)+'A') || (stacks[s][3] != 0 && stacks[s][3] != u8(s)+'A')) && is_empty(hall[hmin:hmax+1]) {
          new_state := state
          dist := hmax-hmin
          if stacks[s][0] != 0 {
            new_state.hall[h] = stacks[s][0]
            new_state.stacks[s][0] = 0
            dist += 1
          } else if stacks[s][1] != 0 {
            new_state.hall[h] = stacks[s][1]
            new_state.stacks[s][1] = 0
            dist += 2
          } else if stacks[s][2] != 0 {
            new_state.hall[h] = stacks[s][2]
            new_state.stacks[s][2] = 0
            dist += 3
          } else {
            new_state.hall[h] = stacks[s][3]
            new_state.stacks[s][3] = 0
            dist += 4
          }
          new_state.energy_used += move_costs[new_state.hall[h] - 'A'] * dist
          if new_state.energy_used < 100000 {
            energy := new_state.energy_used
            new_state.energy_used = 0
            if new_state not_in memo || memo[new_state] > energy {
              memo[new_state] = energy
              new_state.energy_used = energy
              priority_queue_push(moves, new_state)
            }
          }
        }
      }
    }

    // Move into stack:
    for h in 0..10 {
      if h == 2 || h == 4 || h == 6 || h == 8 do continue

      if hall[h] != 0 {
        s := hall[h]-'A'
        hs := int(2*s+2)
        hmin := min(h+1, hs)
        hmax := max(h-1, hs)
        if (stacks[s][3] == 0 || (stacks[s][2] == 0 && stacks[s][3] == s+'A') || (stacks[s][1] == 0 && stacks[s][2] == s+'A' && stacks[s][3] == s+'A') || (stacks[s][0] == 0 && stacks[s][1] == s+'A' && stacks[s][2] == s+'A' && stacks[s][3] == s+'A')) && is_empty(hall[hmin:hmax+1]) {
          new_state := state
          dist := hmax-hmin+1
          if stacks[s][3] == 0 {
            new_state.hall[h] = 0
            new_state.stacks[s][3] = s+'A'
            dist += 4
          } else if stacks[s][2] == 0 {
            new_state.hall[h] = 0
            new_state.stacks[s][2] = s+'A'
            dist += 3
          } else if stacks[s][1] == 0 {
            new_state.hall[h] = 0
            new_state.stacks[s][1] = s+'A'
            dist += 2
          } else {
            new_state.hall[h] = 0
            new_state.stacks[s][0] = s+'A'
            dist += 1
          }
          new_state.energy_used += move_costs[s] * dist
          if new_state.energy_used < 100000 {
            energy := new_state.energy_used
            new_state.energy_used = 0
            if new_state not_in memo || memo[new_state] > energy {
              memo[new_state] = energy
              new_state.energy_used = energy
              priority_queue_push(moves, new_state)
            }
          }
        }
      }
    }
  }

  return nil;
}
