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

PART_2_TEST_A_EXPECT : aoc.Result = nil;
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

  OpCode :: enum { inp, add, mul, div, mod, eql }

  Variable :: enum { x, y, z, w }

  Number :: union #no_nil { Variable, int }

  Instruction :: struct {
    op : OpCode,
    variable : Variable,
    num : Number,
  }

  program : [dynamic]Instruction

  for line, idx in all_lines {
    instruction : Instruction
    n : int
    if _, ok := aoc.parse_input(line, capture_enum(&instruction.op), " ", capture_enum(&instruction.variable), " ", &n); ok {
      instruction.num = n
    } else {
      v : Variable
      if _, ok := aoc.parse_input(line, capture_enum(&instruction.op), " ", capture_enum(&instruction.variable), " ", capture_enum(&v)); ok {
        instruction.num = v
      } else {
        if _, ok := aoc.parse_input(line, capture_enum(&instruction.op), " ", capture_enum(&instruction.variable)); ok {
        } else {
          assert(false)
        }
      }
    }
    append(&program, instruction)
  }

  State :: struct {
    x_reg, y_reg, z_reg, w_reg : int,
    inst_ptr : int,
    inputs : [14]int,
    input_idx : int,
  }

  sim_single_input :: proc(state : State, program : [dynamic]Instruction, input : int) -> int {
    input := input
    using state := state
    inputs[input_idx] = input
    if input_idx < 3 {
      for i in 1..input_idx {
        print("  ")
      }
      println(input)
    }

    input_idx += 1

    for ; inst_ptr < len(program); inst_ptr += 1 {
      ins := program[inst_ptr]

      register : ^int
      switch ins.variable {
        case .x:
          register = &x_reg
        case .y:
          register = &y_reg
        case .z:
          register = &z_reg
        case .w:
          register = &w_reg
      }

      literal := 0
      source : ^int
      if num, ok := ins.num.(Variable); ok {
        switch num {
          case .x:
            source = &x_reg
          case .y:
            source = &y_reg
          case .z:
            source = &z_reg
          case .w:
            source = &w_reg
        }
      } else {
        literal = ins.num.(int)
        source = &literal
      }

      switch ins.op {
        case .inp:
          if input > 0 {
            register^ = input
            input = 0
          } else {
            Mem :: struct {
              z, idx : int,
            }
            @static memo : map[Mem]u8
            mem := Mem{ z_reg, input_idx }
            if mem in memo {
              return 0
            }
            memo[mem] = 1

            for i := 1; i <= 9; i += 1 {
              n := sim_single_input(state, program, i)
              if n > 0 {
                return n
              }
            }
            return 0
          }
        case .add:
          register^ = register^ + source^
        case .mul:
          register^ = register^ * source^
        case .div:
          register^ = register^ / source^
        case .mod:
          register^ = register^ % source^
        case .eql:
          register^ = (register^ == source^) ? 1 : 0
      }
    }

    if z_reg == 0 {
      ans := 0
      for q in 0..<len(inputs) {
        ans *= 10
        ans += inputs[q]
      }

      return ans
    }

    return 0
  }

  for i := 1; i <= 9; i += 1 {
    n := sim_single_input({}, program, i)
    if n > 0 {
      return n
    }
  }

  return nil;
}
