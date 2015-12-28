module bloomfilter;

import std.conv : to;

immutable KEY_SIZE = 12;
immutable ARRAY_SIZE = 1 << KEY_SIZE;
immutable KEY_MASK = (1 << KEY_SIZE) - 1;
immutable KEY_SHIFT = 16;

class BloomFilter
{
  ubyte[ARRAY_SIZE] counters;

  ubyte* firstSlot(uint hash)
  {
    return &(counters[hash1(hash)]);
  }

  ubyte* secondSlot(uint hash)
  {
    return &(counters[hash2(hash)]);
  }

  void clear()
  {
    counters = (ubyte[ARRAY_SIZE]).init;
  }

  void insertHash(uint hash)
  {
    ubyte* slot1 = firstSlot(hash);
    if (!full(slot1)) ++*slot1;
    ubyte* slot2 = secondSlot(hash);
    if (!full(slot2)) ++*slot2;
  }

  void insert(T)(T elem) if ( __traits(isIntegral, T) )
  {
    insertHash(bloomHash!T(elem));
  }

  void removeHash(uint hash)
  {
    ubyte* slot1 = firstSlot(hash);
    if (!full(slot1)) --*slot1;
    ubyte* slot2 = secondSlot(hash);
    if (!full(slot2)) --*slot2;
  }

  void remove(T)(T elem) if ( __traits(isIntegral, T) )
  {
    removeHash(bloomHash!T(elem));
  }

  bool mightContainHash(uint hash)
  {
    return *firstSlot(hash) != 0 && *secondSlot(hash) != 0;
  }

  bool mightContain(T)(T elem)
  {
    return mightContainHash(bloomHash!T(elem));
  }
}

uint bloomHash(T)(T elem)
{
  return ((elem >> 32) ^ elem).to!uint;
}

bool full(ubyte* slot)
{
  return *slot == 0xff;
}

uint hash1(uint hash)
{
  return hash & KEY_MASK;
}

uint hash2(uint hash)
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

  foreach(i; 100UL..1000) assert(bf.mightContain(i));

  falsePositiove = 0UL.iota(100).filter!(a => bf.mightContain(a)).count;
  assert(falsePositiove < 2);  // 2%.

  bf.clear;

  foreach (i; 0UL..2000)
    assert(!bf.mightContain(i));
}
