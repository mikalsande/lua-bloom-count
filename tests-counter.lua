luaunit = require('luaunit')
counter = require('bloomcount')


-- default config
n = 10000
p = 0.0001
bpc = 8
stringtest = 'testingtesting'
dataset = {}
for line in io.lines('./list') do
  table.insert(dataset, line)
end


-- initialization tests that should pass
TestInitOk = {}
  local function initializeEmpty(bits)
    filter = counter.new(n, p, bits)
    luaunit.assertEquals(filter.getNumItems(), 0)
    luaunit.assertIsTable(filter)
  end
  function TestInitOk:test2bitCounters()
    initializeEmpty(2)
  end
  function TestInitOk:test3bitCounters()
    initializeEmpty(3)
  end

  function TestInitOk:test4bitCounters()
    initializeEmpty(4)
  end

  function TestInitOk:test5bitCounters()
    initializeEmpty(5)
  end

  function TestInitOk:test6bitCounters()
    initializeEmpty(6)
  end

  function TestInitOk:test7bitCounters()
    initializeEmpty(7)
  end

  function TestInitOk:test8bitCounters()
    initializeEmpty(8)
  end

  function TestInitOk:test9bitCounters()
    initializeEmpty(9)
  end

  function TestInitOk:test10bitCounters()
    initializeEmpty(10)
  end

  function TestInitOk:test11bitCounters()
    initializeEmpty(11)
  end

  function TestInitOk:test12bitCounters()
    initializeEmpty(12)
  end

  function TestInitOk:test13bitCounters()
    initializeEmpty(13)
  end

  function TestInitOk:test14bitCounters()
    initializeEmpty(14)
  end

  function TestInitOk:test15bitCounters()
    initializeEmpty(15)
  end

  function TestInitOk:test16bitCounters()
    initializeEmpty(16)
  end


-- initialization tests that should fail
TestInitNotOk = {}
  function TestInitNotOk:testTooSmallCapacity()
    luaunit.assertFalse(pcall(counter.new, 99, p, bpc))
  end
  function TestInitNotOk:testTooBigFailureRate()
    luaunit.assertFalse(pcall(counter.new, n, 0.21, bpc))
  end

  function TestInitNotOk:testNumberOfItemsMustBeNumber()
    luaunit.assertFalse(pcall(counter.new, "10000", p, bpc))
    luaunit.assertFalse(pcall(counter.new, {}, p, bpc))
    luaunit.assertFalse(pcall(counter.new, false, p, bpc))
    luaunit.assertFalse(pcall(counter.new, nil, p, bpc))
  end

  function TestInitNotOk:testFailureRateMustBeNumber()
    luaunit.assertFalse(pcall(counter.new, n, '0.0001', bpc))
    luaunit.assertFalse(pcall(counter.new, n, {}, bpc))
    luaunit.assertFalse(pcall(counter.new, n, false, bpc))
    luaunit.assertFalse(pcall(counter.new, n, nil, bpc))
  end

  function TestInitNotOk:testBitsPerCounterMustBeNumber()
    luaunit.assertFalse(pcall(counter.new, n, p, '8'))
    luaunit.assertFalse(pcall(counter.new, n, p, {}))
    luaunit.assertFalse(pcall(counter.new, n, p, false))
    luaunit.assertFalse(pcall(counter.new, n, p, nil))
  end

  function TestInitNotOk:testBitsPerCounterMustBeInteger()
    luaunit.assertFalse(pcall(counter.new, n, p, 8.1))
    luaunit.assertFalse(pcall(counter.new, n, p, 7.9))
  end

  function TestInitNotOk:testBitsPerCounterMustBeInteger()
    luaunit.assertFalse(pcall(counter.new, n, 10000.99, bpc))
    luaunit.assertFalse(pcall(counter.new, n, 10000.01, bpc))
  end


-- verify that the error rate does not go above what we specified
TestErrorRate = {}
  local function doVerifyErrorRate(bits)
    filter = counter.new(n, p, bits)
    luaunit.assertIsTable(filter)
    i = 0
		for _, line in ipairs(dataset) do
			filter.add(line)
			i = i + 1
		end

    luaunit.assertAlmostEquals(filter.getNumItems(), i, math.ceil(p * filter.getNumItems()))
  end

  function TestErrorRate:testVerifyErrorRate2bit()
    doVerifyErrorRate(2)
  end

  function TestErrorRate:testVerifyErrorRate3bit()
    doVerifyErrorRate(3)
  end

  function TestErrorRate:testVerifyErrorRate4bit()
    doVerifyErrorRate(4)
  end

  function TestErrorRate:testVerifyErrorRate5bit()
    doVerifyErrorRate(5)
  end

  function TestErrorRate:testVerifyErrorRate6bit()
    doVerifyErrorRate(6)
  end

  function TestErrorRate:testVerifyErrorRate7bit()
    doVerifyErrorRate(7)
  end

  function TestErrorRate:testVerifyErrorRate8bit()
    doVerifyErrorRate(8)
  end

  function TestErrorRate:testVerifyErrorRate9bit()
    doVerifyErrorRate(9)
  end

  function TestErrorRate:testVerifyErrorRate10bit()
    doVerifyErrorRate(10)
  end

  function TestErrorRate:testVerifyErrorRate11bit()
    doVerifyErrorRate(11)
  end

  function TestErrorRate:testVerifyErrorRate12bit()
    doVerifyErrorRate(12)
  end

  function TestErrorRate:testVerifyErrorRate13bit()
    doVerifyErrorRate(13)
  end

  function TestErrorRate:testVerifyErrorRate14bit()
    doVerifyErrorRate(14)
  end

  function TestErrorRate:testVerifyErrorRate15bit()
    doVerifyErrorRate(15)
  end

  function TestErrorRate:testVerifyErrorRate16bit()
    doVerifyErrorRate(16)
  end


-- verify that counters report the correct counts and can count to the maximum
-- values for each of the supported number of bits
TestCounters = {}
  local function doAddCheckTest(bits)
    filter = counter.new(n, p, bits)
    luaunit.assertIsTable(filter)
    for x = 1, 2^bits - 1 do
      luaunit.assertEquals(filter.add(stringtest), x)
      luaunit.assertEquals(filter.check(stringtest), x)
    end
    luaunit.assertEquals(filter.check(stringtest), 2^bits-1)
  end

  function TestCounters:testAddCheck2bits()
    doAddCheckTest(2)
  end

  function TestCounters:testAddCheck3bits()
    doAddCheckTest(3)
  end

  function TestCounters:testAddCheck4bits()
    doAddCheckTest(4)
  end

  function TestCounters:testAddCheck5bits()
    doAddCheckTest(5)
  end

  function TestCounters:testAddCheck6bits()
    doAddCheckTest(6)
  end

  function TestCounters:testAddCheck7bits()
    doAddCheckTest(7)
  end

  function TestCounters:testAddCheck8bits()
    doAddCheckTest(8)
  end

  function TestCounters:testAddCheck9bits()
    doAddCheckTest(9)
  end

  function TestCounters:testAddCheck10bits()
    doAddCheckTest(10)
  end

  function TestCounters:testAddCheck11bits()
    doAddCheckTest(11)
  end

  function TestCounters:testAddCheck12bits()
    doAddCheckTest(12)
  end

  function TestCounters:testAddCheck13bits()
    doAddCheckTest(13)
  end

  function TestCounters:testAddCheck14bits()
    doAddCheckTest(14)
  end

  function TestCounters:testAddCheck15bits()
    doAddCheckTest(15)
  end

  function TestCounters:testAddCheck16bits()
    doAddCheckTest(16)
  end

function TestReset()
  filter = counter.new(n, p, bpc)
  luaunit.assertIsTable(filter)
  luaunit.assertEquals(filter.getNumItems(), 0)

  for x = 1, 2^bpc-1 do
    luaunit.assertEquals(filter.add(stringtest), x)
    luaunit.assertEquals(filter.getNumItems(), 1)
  end

  filter.reset()
  luaunit.assertEquals(filter.getNumItems(), 0)
end


os.exit(luaunit.LuaUnit.run())
