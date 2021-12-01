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

PART_1_TEST_A_EXPECT : aoc.Result = 5;
PART_1_TEST_B_EXPECT : aoc.Result = nil;
PART_1_TEST_C_EXPECT : aoc.Result = nil;

// SOLUTION ////////////////////////////////////////////////////////////////////////////////////////

part_1 :: proc($MODE : aoc.LogicMode) -> aoc.Result
{
  using aoc, fmt;

  DEBUG  :: false && MODE != .SOLUTION;
  TIMING :: false;

  input := get_input(MODE);

  Allergen :: enum
  {
    nuts,
    wheat,
    fish,
    shellfish,
    dairy,
    sesame,
    soy,
    eggs,
  };

  Allergens :: bit_set[Allergen];

  data : map[string]Allergens;
  counts : map[string]int;

  allLines := lines(input);

  allAllergens : Allergens;

  for line in allLines
  {
    bits := strings.split(line, " (contains ");
    defer delete(bits);
    for allergen in strings.split(bits[1][:len(bits[1])-1], ", ")
    {
      bit, ok := reflect.enum_from_name(Allergen, allergen);
      if !ok
      {
        no(allergen);
      }
      allAllergens |= {bit};
    }
  }

  for line in allLines
  {
    bits := strings.split(line, " (");
    defer delete(bits);
    for ingredient in strings.split(bits[0], " ")
    {
      if ingredient not_in data
      {
        data[ingredient] = allAllergens;
        counts[ingredient] = 1;
      }
      else
      {
        counts[ingredient] += 1;
      }
    }
  }

  slice_contains :: proc(strs : []string, str : string) -> bool
  {
    for s in strs
    {
      if s == str
      {
        return true;
      }
    }
    return false;
  }

  for line in allLines
  {
    bits := strings.split(line, " (contains ");
    defer delete(bits);
    ingredients := strings.split(bits[0], " ");
    for allergen in strings.split(bits[1][:len(bits[1])-1], ", ")
    {
      bit, ok := reflect.enum_from_name(Allergen, allergen);
      if !ok
      {
        no(allergen);
      }
      for ingredient in data
      {
        if !slice_contains(ingredients, ingredient)
        {
          data[ingredient] &= ~{bit};
        }
      }
    }
  }

  total := 0;

  for ingredient, count in counts
  {
    if data[ingredient] == {}
    {
      total += count;
    }
  }

  return total;
}
