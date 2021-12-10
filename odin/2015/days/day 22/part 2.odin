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

  Spell :: struct
  {
    name : string,
    cost, damage, heal, shield, poison, recharge : int,
  }

  spells :: []Spell{
    Spell{ "Magic Missile", 53, 4, 0, 0, 0, 0 },
    Spell{ "Drain",         73, 2, 2, 0, 0, 0 },
    Spell{ "Shield",       113, 0, 0, 6, 0, 0 },
    Spell{ "Poison",       173, 0, 0, 0, 6, 0 },
    Spell{ "Recharge",     229, 0, 0, 0, 0, 5 },
  };

  State :: struct
  {
    mana_spent : int,
    boss_hp : int,
    boss_damage : int,
    player_hp : int,
    player_mana : int,
    shield_timer : int,
    poison_timer : int,
    recharge_timer : int,
  }

  all_states := cast(^PriorityQueue(State, 1000000))mem.alloc(size_of(PriorityQueue(State, 1000000)));
  all_states.priority = proc (state : State) -> int { return max(int) - state.mana_spent; };
  push(all_states, State{ 0, 55, 8, 50, 500, 0, 0, 0 });

  memo : map[State]u8;
  try_num : u128;
  for
  {
    parent_state := pop(all_states);
    for spell in spells
    {
      using state := parent_state;

      player_hp -= 1;

      if (spell.shield > 0 && shield_timer > 1) ||
         (spell.poison > 0 && poison_timer > 1) ||
         (spell.recharge > 0 && recharge_timer > 1) ||
         (player_hp <= 0) ||
         (spell.cost > player_mana)
      {
        continue;
      }

      // Player Turn
      player_mana -= spell.cost;
      mana_spent += spell.cost;

      try_num += 1;
      if try_num % 1000 == 1
      {
        println(try_num, "\t | Player HP:", player_hp, "\t | Mana Spent:", mana_spent, "\t | Spell:", spell.name, "\t | Boss HP:", boss_hp);
      }

      boss_hp -= spell.damage;
      player_hp += spell.heal;

      if recharge_timer > 0
      {
        player_mana += 101;
      }
      if poison_timer > 0
      {
        boss_hp -= 3;
      }

      if boss_hp < 0
      {
        return mana_spent;
      }

      shield_timer = max(0, shield_timer-1);
      poison_timer = max(0, poison_timer-1);
      recharge_timer = max(0, recharge_timer-1);

      shield_timer += spell.shield;
      poison_timer += spell.poison;
      recharge_timer += spell.recharge;

      // Boss Turn
      effective_boss_damage := max(1, boss_damage-(shield_timer > 0 ? 7 : 0));
      player_hp -= effective_boss_damage;

      if recharge_timer > 0
      {
        player_mana += 101;
      }
      if poison_timer > 0
      {
        boss_hp -= 3;
      }

      shield_timer = max(0, shield_timer-1);
      poison_timer = max(0, poison_timer-1);
      recharge_timer = max(0, recharge_timer-1);

      // Next Turns
      if state not_in memo
      {
        memo[state] = 1;
        push(all_states, state);
      }
    }
  }

  return nil;
}
