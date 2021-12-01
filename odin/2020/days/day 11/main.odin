package main;

import "core:fmt";
import "core:sys/windows";

import "../../aoc";

////////////////////////////////////////////////////////////////////////////////////////////////////

PT_PROCESS_INPUT     :: aoc.PerformanceSampleId{ 5, "Process Input" };
PT_DO_SIMULATION     :: aoc.PerformanceSampleId{ 6, "Do Simulation" };
PT_SIMULATE          :: aoc.PerformanceSampleId{ 7, "simulate" };
PT_GET_CELL          :: aoc.PerformanceSampleId{ 8, "get_cell" };
PT_SET_CELL          :: aoc.PerformanceSampleId{ 9, "set_cell" };
PT_COUNT_NEIGBORS    :: aoc.PerformanceSampleId{ 10, "count_neigbors" };
PT_COUNT_RESULTS     :: aoc.PerformanceSampleId{ 11, "count_results" };
PT_PRINT_DEBUG_STATE :: aoc.PerformanceSampleId{ 12, "Print Debug State" };

////////////////////////////////////////////////////////////////////////////////////////////////////

main :: proc()
{
  using fmt, aoc;

  aoc.init_performance_timing(13);

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
