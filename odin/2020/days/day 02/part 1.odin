package main;

import "core:fmt";
import "core:strings";

import "../../aoc";

// TEST ANSWERS ////////////////////////////////////////////////////////////////////////////////////

PART_1_TEST_A_EXPECT : aoc.Result = 2;
PART_1_TEST_B_EXPECT : aoc.Result = nil;
PART_1_TEST_C_EXPECT : aoc.Result = nil;

// SOLUTION ////////////////////////////////////////////////////////////////////////////////////////

part_1 :: proc($mode : aoc.LogicMode) -> aoc.Result
{
  using aoc, fmt;

  input := getInput(mode);

  Password :: struct
  {
    min      : int,
    max      : int,
    char     : string,
    password : string,
  };

  PERF("Parse/Solve");
  validPasswords := parse_list(lines(input), proc(str : string, index: int, list : ^[]Password) -> (Password, bool)
    {
      el : Password;
      bits := strings.split(str, " ");
      nums := strings.split(bits[0], "-");
      el.min = int_val(nums[0]);
      el.max = int_val(nums[1]);
      el.char = bits[1][:1];
      el.password = bits[2];
      count := 0;
      for c in el.password
      {
        if c == auto_cast el.char[0]
        {
          count += 1;
        }
      }
      return el, (count >= el.min && count >= el.max);
    });
  END_PERF();

  println(validPasswords);

  return len(validPasswords);
}
