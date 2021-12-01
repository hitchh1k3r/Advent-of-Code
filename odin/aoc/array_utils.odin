package aoc;

import "core:strings";

// Spliting Strings:

groups :: proc(str : string) -> []string
{
  return strings.split(str, "\n\n");
}

lines :: proc(str : string) -> []string
{
  return strings.split(str, "\n");
}

words :: proc(str : string) -> []string
{
  return strings.split(str, " ");
}

csv :: proc(str : string, delimiter : string = ",") -> []string
{
  return strings.split(str, delimiter);
}

// Array Manipulation:

_shift_left_slice :: proc(x: ^$T/[]$E, amount : int)
{
  if (amount < 0)
  {
    offset := -amount;
    for i := len(x)-1; i >= offset; i -= 1
    {
      x[i] = x[i-offset];
    }
    for i in 0..<offset
    {
      x[i] = {};
    }
  }
  else
  {
    offset := amount;
    for i in 0..<len(x)-offset
    {
      x[i] = x[i+offset];
    }
    for i in len(x)-offset..<len(x)
    {
      x[i] = {};
    }
  }
}

_shift_left_array :: proc(x: ^$T/[$N]$E, amount : int)
{
  if (amount < 0)
  {
    offset := -amount;
    for i := len(x)-1; i >= offset; i -= 1
    {
      x[i] = x[i-offset];
    }
    for i in 0..<offset
    {
      x[i] = 0;
    }
  }
  else
  {
    offset := amount;
    for i in 0..<len(x)-offset
    {
      x[i] = x[i+offset];
    }
    for i in len(x)-offset..<len(x)
    {
      x[i] = 0;
    }
  }
}

shift_left :: proc{ _shift_left_slice, _shift_left_array };

// 2D Map:

map2d_set :: proc(m : ^$M/map[$A]$S/map[$B]$C, keyA : A, keyB : B, val : C)
{
  sub, ok := m[keyA];
  if !ok
  {
    sub = make(S);
  }
  sub[keyB] = val;
  m[keyA] = sub;
}

// Range Of Ints:

range_fixed :: proc($start, $end : int) -> [end-start]int
{
  result : [end-start+1]int;
  for _, i in result
  {
    result[i] = start+i;
  }
  return result;
}

range_slice :: proc(start, end : int) -> []int
{
  result := make([]int, end-start+1);
  for _, i in result
  {
    result[i] = start+i;
  }
  return result;
}
