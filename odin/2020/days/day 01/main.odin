package main;

import "core:fmt";
import "core:sys/windows";

import "../../aoc";

////////////////////////////////////////////////////////////////////////////////////////////////////

main :: proc()
{
  using fmt, aoc;

  init_performance_timing(5);

  p1_test_a :: proc()->aoc.Result{return part_1(.TEST_A);};
  p1_test_b :: proc()->aoc.Result{return part_1(.TEST_B);};
  p1_test_c :: proc()->aoc.Result{return part_1(.TEST_C);};
  p1_solution :: proc()->aoc.Result{return part_1(.SOLUTION);};
  test_runner("PART 1", p1_test_a, p1_test_b, p1_test_c, p1_solution, PART_1_TEST_A_EXPECT, PART_1_TEST_B_EXPECT, PART_1_TEST_C_EXPECT);

  p2_test_a :: proc()->aoc.Result{return part_2(.TEST_A);};
  p2_test_b :: proc()->aoc.Result{return part_2(.TEST_B);};
  p2_test_c :: proc()->aoc.Result{return part_2(.TEST_C);};
  p2_solution :: proc()->aoc.Result{return part_2(.SOLUTION);};
  test_runner("PART 2", p2_test_a, p2_test_b, p2_test_c, p2_solution, PART_2_TEST_A_EXPECT, PART_2_TEST_B_EXPECT, PART_2_TEST_C_EXPECT);

}
