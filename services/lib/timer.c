#include <time.h>

#include "timer.h"

#define rdtsc_64(lower, upper) asm __volatile ("rdtsc" : "=a"(lower), "=d" (upper));

uint64_t gettsc()
{
  unsigned int tsc_l, tsc_u; //uint32_t

  rdtsc_64(tsc_l, tsc_u);

  return (uint64_t)tsc_u << 32 | tsc_l;
}

uint64_t getclock()
{
  struct timespec ts;

  clock_gettime(CLOCK_MONOTONIC, &ts);

  return (uint64_t)(ts.tv_sec*(1000*1000*1000)) + ts.tv_nsec;
}