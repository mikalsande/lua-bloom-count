# lua-bloom-count
Counting Bloom and boolean Bloom filter written in Lua.

Contains two different Bloom filters.
* bloombool - standard Bloom filter that give a boolean output
* bloomcount - counting Bloom filters, gives a count as output

Properties of the two filters
* use Kirsh & Mitzenmacher enhanced double hashing to simplify hashing
* pseudorandomized hash seeds every time the filters are reset
* put many bit values in every array index to save space
* configurable number of bits for counters in the counting filter. 2 - 16 bits supported.
* configurable capacity and accepted error rate.

## Getting Started

### Dependencies
The filters are dependent on [LuaBitOP](http://bitop.luajit.org/) and [lua-xxhash](https://github.com/mah0x211/lua-xxhash). Both can be instlled with LuaRocks.

```
luarocks install luabitop
luarocks install xxhash

```

### Installing

Install the depencencies, then copy the bloombool.lua and bloomcount.lua files into your Lua path.

## Tests
Simple unit tests and performanc test are included. FYI, some of the tests depend on the ./list file being available, the tests should be run in the repository directory.

### Unit tests
Unit tests for the boolean Bloom filter.
```
$ lua tests-bool.lua
.......
Ran 7 tests in 0.081 seconds, 7 successes, 0 failures
OK
```

Unit tests for the boolean Bloom filter.
```
$ lua tests-counter.lua
....................................................
Ran 52 tests in 2.297 seconds, 52 successes, 0 failures
OK
```

### Simple performance tests
For the boolean Bloom filter
```
$ lua perf-bool.lua
Added 10000 items to the filter in 54.970947265625 msec
181.91427467457 inserts per msec

Checked 10000 items in the filter in 31.715087890625 msec
315.30733997922 inserts per msec
```

For the counting Bloom filter
```
$ lua perf-count.lua
Added 10000 items to the filter in 71.264892578125 msec
140.32154737394 inserts per msec

Checked 10000 items in the filter in 38.10595703125 msec
262.42616060789 inserts per msec
```


## Contributing
Send a pull request if you feel like it.

## Authors
See the list of [contributors](https://github.com/mikalsande/lua-bloom-count/graphs/contributors) who participated in this project.

## License
Unless another license is specified in the beginning of a file this project is licesed under the Unlicense - see the [LICENSE.md](LICENSE.md) file for details

