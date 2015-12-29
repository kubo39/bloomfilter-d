module bloomfilter;

import std.conv : to;

immutable KEY_SIZE = 12;
immutable ARRAY_SIZE = 1 << KEY_SIZE;
immutable KEY_MASK = (1 << KEY_SIZE) - 1;
immutable KEY_SHIFT = 16;


class BloomFilter
{
private:
  ubyte[ARRAY_SIZE] counters;

  ubyte* firstSlot(uint hash) @nogc nothrow
  {
    return &(counters[hash1(hash)]);
  }

  ubyte* secondSlot(uint hash) @nogc nothrow
  {
    return &(counters[hash2(hash)]);
  }

public:

  void clear()
  {
    counters = (ubyte[ARRAY_SIZE]).init;
  }

  void insert(T)(T elem) if ( __traits(isIntegral, T) )
  {
    ubyte* slot1 = firstSlot(bloomHash!T(elem));
    if (!full(slot1)) ++*slot1;
    ubyte* slot2 = secondSlot(bloomHash!T(elem));
    if (!full(slot2)) ++*slot2;

  }

  void remove(T)(T elem) if ( __traits(isIntegral, T) )
  {
    ubyte* slot1 = firstSlot(bloomHash!T(elem));
    if (!full(slot1)) --*slot1;
    ubyte* slot2 = secondSlot(bloomHash!T(elem));
    if (!full(slot2)) --*slot2;
  }

  bool mightContain(T)(T elem) if ( __traits(isIntegral, T) )
  {
    return *firstSlot(bloomHash!T(elem)) != 0 && *secondSlot(bloomHash!T(elem)) != 0;
  }
}


uint bloomHash(T)(T elem) if ( __traits(isIntegral, T) )
{
  return ((elem >> 32) ^ elem).to!uint;
}


bool full(ubyte* slot) @nogc nothrow
{
  return *slot == 0xff;
}


uint hash1(uint hash) @nogc nothrow
{
  return hash & KEY_MASK;
}


uint hash2(uint hash) @nogc nothrow
{
  return (hash >> KEY_SHIFT) & KEY_MASK;
}


unittest
{
  import std.algorithm : filter, count;
  import std.range : iota;

  auto bf = new BloomFilter;

  foreach (i; 0UL..1000)
    bf.insert(i);

  foreach (i; 0UL..1000)
    assert(bf.mightContain(i));

  auto falsePositiove = 1001UL.iota(2000).filter!(a => bf.mightContain(a)).count;
  assert(falsePositiove < 10);  // 1%.

  foreach (i; 0UL..100)
    bf.remove(i);

  foreach(i; 100UL..1000)
    assert(bf.mightContain(i));

  falsePositiove = 0UL.iota(100).filter!(a => bf.mightContain(a)).count;
  assert(falsePositiove < 2);  // 2%.

  bf.clear;

  foreach (i; 0UL..2000)
    assert(!bf.mightContain(i));
}
