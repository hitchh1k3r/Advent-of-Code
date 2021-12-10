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

  Augment :: struct
  {
    cost, damage, armor : int,
  }

  weapons :: []Augment{ // [1..1]
    Augment{  8, 4, 0 },
    Augment{ 10, 5, 0 },
    Augment{ 25, 6, 0 },
    Augment{ 40, 7, 0 },
    Augment{ 70, 8, 0 },
  };

  armor :: []Augment{ // [0..1]
    Augment{   0, 0, 0 },
    Augment{  13, 0, 1 },
    Augment{  31, 0, 2 },
    Augment{  53, 0, 3 },
    Augment{  75, 0, 4 },
    Augment{ 102, 0, 5 },
  };

  rings :: []Augment{ // [0..2]
    Augment{   0, 0, 0 },
    Augment{   0, 0, 0 },
    Augment{  25, 1, 0 },
    Augment{  50, 2, 0 },
    Augment{ 100, 3, 0 },
    Augment{  20, 0, 1 },
    Augment{  40, 0, 2 },
    Augment{  80, 0, 3 },
  };

  boss_hp := 103;
  boss_damage := 9;
  boss_armor := 2;

  max_gold := min(int);

  simulate :: proc(boss_hp, boss_damage, boss_armor, player_hp, player_damage, player_armor : int) -> bool
  {
    boss_hp := boss_hp;
    player_hp := player_hp;
    boss_damage := max(1, boss_damage-player_armor);
    player_damage := max(1, player_damage-boss_armor);
    for player_hp > 0
    {
      boss_hp -= player_damage;
      if boss_hp <= 0
      {
        return true;
      }
      player_hp -= boss_damage;
    }
    return false;
  }

  for weapon, wi in weapons
  {
    for armor, ai in armor
    {
      for ring_1, r1i in rings
      {
        for ring_2, r2i in rings
        {
          if r1i != r2i
          {
            gold := weapon.cost + armor.cost + ring_1.cost + ring_2.cost;
            if !simulate(boss_hp, boss_damage, boss_armor, 100, weapon.damage + armor.damage + ring_1.damage + ring_2.damage, weapon.armor + armor.armor + ring_1.armor + ring_2.armor)
            {
              max_gold = max(max_gold, gold);
            }
          }
        }
      }
    }
  }

  return max_gold;
}
