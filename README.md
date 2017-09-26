# lua-bloom-count
Contains two different Bloom filters. It has the following properties.
* use Kirsh & Mitzenmacher enhanced double hashing to simplify hashing
* put 32 bits used as booleans into every array index to save space (luabitop operates on 32 bits)
* configurable capacity and accepted error rate.
* pseudorandomized hash seeds every time the filters are reset

## Getting Started

### Using the filter
New filters are created with the new() method. Give it the desired capacity and an acceptable error rate. In this case 10000 is the capacity and 0.001 (0.1%) is the acceptederror rate.
```
local bloom = require("bloom")

filter = bloom.new(10000, 0.001)

a = filter.add('string')
b = filter.check('string')

print(a .. ' ' .. b)
```
Should print out '0 1'.


### Dependencies
Runtime dependencies are [LuaBitOP](http://bitop.luajit.org/) and [lua-xxhash](https://github.com/mah0x211/lua-xxhash). Both can be instlled with LuaRocks.
```
luarocks install luabitop
luarocks install xxhash
```

The unit tests depend on [luaunit](https://github.com/bluebird75/luaunit)
```
luarocks install luaunit
```

The unit tests depend on [luasocket](https://github.com/diegonehab/luasocket)
```
luarocks install luasocket
```


### Installing

Install the depencencies then copy the bloom.lua files into your Lua path.

## Tests
Simple unit tests and performanc test are included. FYI, some of the tests depend on the ./list file being available, the tests should be run in the repository directory.

### Unit tests
Unit tests for the boolean Bloom filter.
```
$ lua tests.lua -v
Started on Tue Sep 26 19:36:02 2017
    TestInit ... Ok
    TestInitNotOk.testFailureRateMustBeNumber ... Ok
    TestInitNotOk.testNumberOfItemsMustBeInteger ... Ok
    TestInitNotOk.testNumberOfItemsMustBeNumber ... Ok
    TestInitNotOk.testTooBigFailureRate ... Ok
    TestReset ... Ok
    TestVerifyErrorRate ... Ok
=========================================================
Ran 7 tests in 0.081 seconds
```

### Simple performance tests
For the boolean Bloom filter
```
$ lua perftest.lua 
Initialized the filter in 0.19189453125 msec
Reinitialized the filter in 0.104736328125 msec

Added 10000 items to the filter in 40.78515625 msec
245.18724260128 inserts per msec

Checked 10000 items in the filter in 32.51708984375 msec
307.53059539004 inserts per msec
```

## Contributing
Send a pull request if you feel like it.

## Authors
See the list of [contributors](https://github.com/mikalsande/lua-simple-bloom/graphs/contributors) who participated in this project.

## License
Unless another license is specified in the beginning of a file this project is licesed under the Unlicense - see the [LICENSE](LICENSE) file for details

