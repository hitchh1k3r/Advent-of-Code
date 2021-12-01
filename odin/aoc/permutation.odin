package aoc;

import "core:fmt";
import "core:slice";
import "core:sys/windows";

_combos :: proc(input : $T/[]$E, $C : int, $doTiming : bool) -> [][C]E
{
  // {0,1,2,3}4C3 = [ {0,1,2},{0,1,3},{0,2,3},{1,2,3} ]
  // {0,1,2,3,4}5C3 = [ {0,1,2},{0,1,3},{0,1,4},
  //                            {0,2,3},{0,2,4},
  //                                    {0,3,4},

  //                            {1,2,3},{1,2,4},
  //                                    {1,3,4},

  //                                    {2,3,4} ]
  when doTiming
  {
    start, end, frq : windows.LARGE_INTEGER;
    windows.QueryPerformanceFrequency(&frq);
    windows.QueryPerformanceCounter(&start);
  }

  inputSize := len(input);
  // I THINK THIS IS ACTUALLY THE FORMULA FOR perm_unordered_REPEAT
  /*
  prodRange := range_slice(inputSize, inputSize+C-1);
  outSize := prod(prodRange) / fact(C);
  delete(prodRange);
  result := make([][C]E, outSize);
  */
  prodRange := range_slice(inputSize-C+1, inputSize);
  outSize := prod(prodRange) / fact(C);
  delete(prodRange);
  result := make([][C]E, outSize);
  el : [C]E;
  index := range_slice(0, C-1);
  defer delete(index);
  writeIndex := 0;

  for index[0] < inputSize-C+1
  {
    for i in 0..<C
    {
      el[i] = input[index[i]];
    }
    result[writeIndex] = el;
    writeIndex += 1;

    index[C-1] += 1;
    for i := C-1; i > 0; i -= 1
    {
      carry := 1;
      for index[i] > inputSize-(C-i) && i-carry >= 0
      {
        v := index[i-carry] + 1;
        for q in i-carry..C-1
        {
          index[q] = v;
          v += 1;
        }
        carry += 1;
      }
      if carry == 1
      {
        break;
      }
    }
  }

  when doTiming
  {
    windows.QueryPerformanceCounter(&end);
    println("Time :: " , f64(end-start)/f64(frq)*1000.0*1000.0, "us ", (end-start), " cycles");
  }

  return result;
}

_combos_default :: proc(input : $T/[]$E, $C : int) -> [][C]E
{
  return _combos(input, C, false);
}

combos :: proc{ _combos_default, _perms };

_recursive_perms :: proc(input : $T/[]$E, result : ^[][$C]E, parent : [$D]int, startIndex : int, inputSize : int, writeIndex : ^int)
{
  index : [D+1]int;
  when (D+1) == C
  {
    el : [C]E;
  }
  for newIndex in startIndex..inputSize-(C-D)
  {
    for i in 0..D
    {
      readIndex := 0;
      for q in 0..D
      {
        if i == q
        {
          index[q] = newIndex;
        }
        else
        {
          index[q] = parent[readIndex];
          readIndex += 1;
        }
      }
      when (D+1) == C
      {
        for q in 0..<C
        {
          el[q] = input[index[q]];
        }
        result[writeIndex^] = el;
        writeIndex^ += 1;
      }
      when (D+1) < C
      {
        _recursive_perms(input, result, index, newIndex+1, inputSize, writeIndex);
      }
    }
  }
}

_perms :: proc(input : $T/[]$E, $C : int, $doTiming : bool) -> [][C]E
{
  // {0,1,2}3C3 =   [ {0,1,2}, {0,2,1}, {1,0,2}, {1,2,0}, {2,0,1}, {2,1,0} ]
  // {0,1,2,3}4C3 = [ {0,1,2}, {0,1,3}, {0,3,2}, {0,2,1}, {0,2,3}, {0,3,1},
  //                  {1,0,2}, {1,0,3}, {1,3,2}, {1,2,0}, {1,2,3}, {1,3,0},
  //                  {2,0,1}, {2,0,3}, {2,3,1}, {2,1,0}, {2,1,3}, {2,3,0},
  //                  {3,0,1}, {3,0,2}, {3,2,1}, {3,1,0}, {3,1,2}, {3,2,0} ]
  when doTiming
  {
    start, end, frq : windows.LARGE_INTEGER;
    windows.QueryPerformanceFrequency(&frq);
    windows.QueryPerformanceCounter(&start);
  }

  inputSize := len(input);
  prodRange := range_slice(inputSize-C+1, inputSize);
  outSize := prod(prodRange);
  delete(prodRange);
  result := make([][C]E, outSize);

  index : [0]int;
  writeIndex := 0;

  _recursive_perms(input, &result, index, 0, inputSize, &writeIndex);

  when doTiming
  {
    windows.QueryPerformanceCounter(&end);
    fmt.println("Time :: " , f64(end-start)/f64(frq)*1000.0*1000.0, "us ", (end-start), " cycles");
  }

  return result;
}

_perms_default :: proc(input : $T/[]$E, $C : int) -> [][C]E
{
  return _perms(input, C, false);
}

perms :: proc{ _perms_default, _perms };

MultiDimensionIterator :: struct(DIMENSIONS : int, ELEMENT_TYPE : typeid)
{
  index : int,
  current : [DIMENSIONS]ELEMENT_TYPE,
  min : [DIMENSIONS]ELEMENT_TYPE,
  max : [DIMENSIONS]ELEMENT_TYPE,
};

make_multi_d_iterator :: proc(min, max : [$DIMENSIONS]$ELEMENT_TYPE) -> MultiDimensionIterator(DIMENSIONS, ELEMENT_TYPE)
{
  return MultiDimensionIterator(DIMENSIONS, ELEMENT_TYPE){ 0, min, min, max };
}

multi_d_iterate :: proc(using it : ^MultiDimensionIterator($DIMENSIONS, $ELEMENT_TYPE)) -> (val : [DIMENSIONS]ELEMENT_TYPE, idx : int, cond : bool)
{
  val = current;
  idx = index;
  cond = true;

  if index < 0
  {
    cond = false;
    return;
  }
  else if val == max
  {
    index = -1;
    return;
  }

  index += 1;
  for i in 0..<DIMENSIONS
  {
    current[i] += 1;
    if current[i] <= max[i]
    {
      return;
    }
    else
    {
      current[i] = min[i];
    }
  }
  return;
}
