num sum(List<num> list) {
  num sum = 0;
  for (num n in list) {
    sum += n;
  }
  return sum;
}

num toReachAverage(List<List<num>> numbers, num target, [int steps = 1]) {
  // Calculate the target weight of the grade, or the weight of the
  // previous grades + the number of steps
  final targetLength = numbers.fold(0, (a, b) => (a! as num) + b[1]) + steps;

  // Use the following formula to find out which number brings our average to x
  // N = ((X * L) - ∑A) / S
  // where X is our target, L is the target length, A is the weighted numbers array
  // and S is the number of steps, ie. how many times to repeat N to get to X
  return ((targetLength * target) -
          sum(numbers.map((a) => a[0] * a[1]).toList())) /
      steps;
}
