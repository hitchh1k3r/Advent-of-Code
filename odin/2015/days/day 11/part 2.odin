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
import "core:encoding/json"

import "../../../aoc";

// SOLUTION ////////////////////////////////////////////////////////////////////////////////////////

part_2 :: proc($MODE : aoc.LogicMode) -> aoc.Result
{
  using aoc, fmt;

  DEBUG  :: false && MODE != .SOLUTION;
  TIMING :: false;

  input := get_input(MODE);
  data, _ := json.parse(data = transmute([]u8) input, parse_integers = true);

  evaluate :: proc(value : json.Value) -> i64
  {
    add : i64 = 0;
    switch val in value.value
    {
      case json.Null:
      case json.Integer:
        add += val;
      case json.Float:
        add += i64(val);
      case json.Boolean:
      case json.String:
      case json.Array:
        for child in val
        {
          add += evaluate(child);
        }
      case json.Object:
        for _, child in val
        {
          if str, ok := child.value.(json.String); ok && str == "red"
          {
            return 0;
          }
          add += evaluate(child);
        }
    }
    return add;
  }

  return int(evaluate(data));
}
