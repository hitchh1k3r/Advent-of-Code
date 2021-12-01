package aoc;

Stack :: struct(ELEMENT_TYPE : typeid, CAPACITY := 256)
{
  arr : [CAPACITY]ELEMENT_TYPE,
  index : int,
}

push :: proc(using stack : ^Stack($ELEMENT_TYPE, $CAPACITY), el : ELEMENT_TYPE)
{
  if index < CAPACITY
  {
    arr[index] = el;
    index += 1;
  }
}

pop :: proc(using stack : ^Stack($ELEMENT_TYPE, $CAPACITY)) -> ELEMENT_TYPE
{
  result : ELEMENT_TYPE;
  if index > 0
  {
    index -= 1;
    result = stack.arr[index];
  }
  return result;
}
