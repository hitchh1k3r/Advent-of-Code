package aoc;

import "core:fmt"
import "core:strconv"
import "core:unicode/utf8"

@(deferred_in=delete_string)
temp_str :: proc(str: string, allocator := context.allocator, loc := #caller_location) -> string
{
  return str;
}

cat :: proc(args: ..any) -> string
{
  return fmt.aprint(args=args, sep="");
}

int_val :: proc(str : string) -> int
{
  val, _ := strconv.parse_int(str);
  return val;
}

int_arr :: proc(set : []string) -> []int
{
  result := make([]int, len(set));
  for v, i in set
  {
    result[i] = int_val(v);
  }
  return result;
}

// TODO (hitch) 2020-12-10 Make this work!
/*
_parse_list_full :: proc(input : []string, callback : proc(string, int, ^[]$E) -> (E, bool)) -> []E
{
  result := make_slice([]E, 0, len(input));
  for str, i in input
  {
    if el, ok = callback(str, i, &result); ok
    {
      append(&result, el);
    }
  }
  return result;
}
*/

_parse_list_simple :: proc(input : []string, callback : proc(string) -> $E) -> []E
{
  result := make([]E, len(input));
  for str, i in input
  {
    result[i] = callback(str);
  }
  return result;
}

parse_list :: proc { _parse_list_simple }; // _parse_list_full
