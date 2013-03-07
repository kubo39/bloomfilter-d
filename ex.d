import std.stdio;

import bloomfilter;

void main() {
    uint n = 100;
    auto bf = new Bloomfilter(20*n, 5);

    auto l = cast(ubyte[]) "Love";
    // Add "Love" to bloomfilter
    bf.Add(l);

    // Test "Love"
    auto flag = bf.Test(l);
    writeln(flag); // should be true

    auto sd = cast(ubyte[]) "^^aacsv";
    auto flag2 = bf.Test(sd);     // should be false
    writeln(flag2);

    // Add "^^aacsv" to bloomfilter
    bf.Add(sd);
    writeln(bf.Test(l)); // should be true

    bf.clearAll();
    writeln(bf.Test(l)); // should be false
}
