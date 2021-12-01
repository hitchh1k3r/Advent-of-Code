package aoc;

import "core:math";
import "core:intrinsics";

pow_int :: proc(base, exponent : int) -> int
{
  result := 1;
  if exponent > 0
  {
    for _ in 1..exponent
    {
      result *= base;
    }
  }
  else
  {
    for _ in 1..exponent
    {
      result /= base;
    }
  }
  return result;
}

pow :: proc{ pow_int, math.pow_f32, math.pow_f64 };

// Set Summing:

_sum_slice :: proc(x: $T/[]$E) -> E
where intrinsics.type_is_numeric(E)
{
  result : E = 0;
  for i in x
  {
    result += i;
  }
  return result;
}

_sum_array :: proc(x: $T/[$N]$E) -> E
where intrinsics.type_is_numeric(E)
{
  result : E = 0;
  for i in x
  {
    result += i;
  }
  return result;
}

sum :: proc{ _sum_slice, _sum_array };

// Set Multiplication:

_prod_slice :: proc(x: $T/[]$E) -> E
where intrinsics.type_is_numeric(E)
{
  result : E = 1;
  for i in x
  {
    result *= i;
  }
  return result;
}

_prod_array :: proc(x: $T/[$N]$E) -> E
where intrinsics.type_is_numeric(E)
{
  result : E = 1;
  for i in x
  {
    result *= i;
  }
  return result;
}

prod :: proc{ _prod_slice, _prod_array };

fact :: proc(n: int) -> int
{
  when size_of(int) == size_of(i64)
  {
    @static table := [21]int{
      1,
      1,
      2,
      6,
      24,
      120,
      720,
      5_040,
      40_320,
      362_880,
      3_628_800,
      39_916_800,
      479_001_600,
      6_227_020_800,
      87_178_291_200,
      1_307_674_368_000,
      20_922_789_888_000,
      355_687_428_096_000,
      6_402_373_705_728_000,
      121_645_100_408_832_000,
      2_432_902_008_176_640_000,
    };
  }
  else
  {
    @static table := [13]int{
      1,
      1,
      2,
      6,
      24,
      120,
      720,
      5_040,
      40_320,
      362_880,
      3_628_800,
      39_916_800,
      479_001_600,
    };
  }

  assert(n >= 0, "parameter must not be negative");
  assert(n < len(table), "parameter is too large to lookup in the table");
  return table[n];
}

