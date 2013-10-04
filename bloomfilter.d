import std.math;
import std.bitmanip;
import std.digest.crc;

debug import std.stdio;


class Bloomfilter
{
  private uint _m;
  private uint _k;
  private BitArray _b;
  private CRC32 crc;

  this(uint m, uint k) {
    _m = m;
    _k = k;
    _b.init(new bool[m]);
    crc.put(cast(ubyte[]) "");
  }

  uint[] estimateParameters(uint n, real p) {
    _m = cast(uint) (-1 * cast(long)n * log(p) / pow(log(2), 2));
    _k = cast(uint) ceil(log(2) * cast(real) _m / cast(real) n);
    return [_m, _k];
  }

  uint Cap() {
    return _m;
  }

  uint K() {
    return _k;
  }

  uint[] baseHashes(ubyte[] data) {
    crc.start();
    crc.put(data[]);
    ubyte[4] sum = crc.finish();
    debug writeln("sum :", sum);

    auto upper = sum[0 .. 2];
    auto lower = sum[2 .. 4];
    uint a = cast(uint) lower[0];
    uint b = cast(uint) upper[0];
    return [a, b];
  }

  uint[] locations(ubyte[] data) {
    uint[] locs;
    uint[] arr = baseHashes(data);
    uint a = arr[0];
    uint b = arr[1];
    for(int i; i < _k; i++) {
      locs ~= cast(uint) (a + b * i) % _m;
    }
    debug writeln("locs:", locs);

    return locs;
  }

  void Add(ubyte[] data) {
    foreach(loc; locations(data)) {
      _b.opIndexAssign(true, cast(size_t) loc);
    }
  }

  bool Test(ubyte[] data) {
    BitArray b_loc, tmp;
    b_loc.init(new bool[_m]);
    debug writeln("b_locs:", b_loc);

    foreach(loc; locations(data)){
      b_loc.opIndexAssign(true, cast(size_t) loc);
    }

    tmp = b_loc.opOrAssign(_b);
    if (_b != tmp) {
      return false;
    }
    return true;
  }

  void clearAll() {
    _b.init(new bool[_m]);
  }
}