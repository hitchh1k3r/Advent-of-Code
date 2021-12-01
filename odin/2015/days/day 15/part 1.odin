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

PART_1_TEST_A_EXPECT : aoc.Result = 62842880;
PART_1_TEST_B_EXPECT : aoc.Result = nil;
PART_1_TEST_C_EXPECT : aoc.Result = nil;

// SOLUTION ////////////////////////////////////////////////////////////////////////////////////////

part_1 :: proc($MODE : aoc.LogicMode) -> aoc.Result
{
  using aoc, fmt;

  DEBUG  :: false && MODE != .SOLUTION;
  TIMING :: false;

  input := get_input(MODE);
  all_lines := lines(input);

  Ingredient :: struct
  {
    capacity, durability, flavor, texture, calories : int,
  };
  all_ingredients := make([]Ingredient, len(all_lines));
  for line, i in all_lines
  {
    all_words := words(line);
    all_ingredients[i].capacity = int_val(all_words[2]);
    all_ingredients[i].durability = int_val(all_words[4]);
    all_ingredients[i].flavor = int_val(all_words[6]);
    all_ingredients[i].texture = int_val(all_words[8]);
    all_ingredients[i].calories = int_val(all_words[10]);
  }

  amounts := make([]int, len(all_ingredients));
  best_score := 0;
  iterate :: proc(amounts : []int, all_ingredients : []Ingredient, best_score : ^int, remainder : int, index : int, callback : proc(amounts : []int, all_ingredients : []Ingredient, best_score : ^int))
  {
    if index+1 == len(amounts)
    {
      amounts[index] = remainder;
      callback(amounts, all_ingredients, best_score);
    }
    else
    {
      for i in 0..remainder
      {
        amounts[index] = i;
        iterate(amounts, all_ingredients, best_score, remainder-i, index+1, callback);
      }
    }
  };
  iterate(amounts, all_ingredients, &best_score, 100, 0, proc(amounts : []int, all_ingredients : []Ingredient, best_score : ^int) {
      capacity := 0;
      durability := 0;
      flavor := 0;
      texture := 0;
      calories := 0;
      for i in 0..<len(amounts)
      {
        capacity += amounts[i]*all_ingredients[i].capacity;
        durability += amounts[i]*all_ingredients[i].durability;
        flavor += amounts[i]*all_ingredients[i].flavor;
        texture += amounts[i]*all_ingredients[i].texture;
        calories += amounts[i]*all_ingredients[i].calories;
      }

      capacity = max(0, capacity);
      durability = max(0, durability);
      flavor = max(0, flavor);
      texture = max(0, texture);
      calories = max(0, calories);

      value := capacity * durability * flavor * texture;
      if value > best_score^
      {
        best_score^ = value;
      }
    });

  return best_score;
}
