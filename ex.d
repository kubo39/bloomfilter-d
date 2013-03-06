import std.stdio;

import bloomfilter;

void main() {
    uint n = 100;
    auto bf = new Bloomfilter(20*n, 5);

    auto l = cast(ubyte[]) "Love";
    bf.Add(l);
    auto flag = bf.Test(l);
    writeln(flag);

    auto sd = cast(ubyte[]) "^^aacsv";
    auto flag2 = bf.Test(sd);
    writeln(flag2);
}
