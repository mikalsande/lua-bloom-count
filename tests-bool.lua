luaunit = require('luaunit')
counter = require('bloombool')


-- default config
n = 10000
p = 0.0001
stringtest = 'testingtesting'
dataset = {}
for line in io.lines('./list') do
  table.insert(dataset, line)
end


-- initialization tests that should pass
function TestInit()
  filter = counter.new(n, p)
  luaunit.assertEquals(filter.getNumItems(), 0)
  luaunit.assertIsTable(filter)
end


-- initialization tests that should fail
TestInitNotOk = {}
  function TestInitNotOk:testTooBigFailureRate()
    luaunit.assertFalse(pcall(counter.new, n, 0.21))
  end

  function TestInitNotOk:testNumberOfItemsMustBeNumber()
    luaunit.assertFalse(pcall(counter.new, "10000", p))
    luaunit.assertFalse(pcall(counter.new, {}, p))
    luaunit.assertFalse(pcall(counter.new, false, p))
    luaunit.assertFalse(pcall(counter.new, nil, p))
  end

  function TestInitNotOk:testFailureRateMustBeNumber()
    luaunit.assertFalse(pcall(counter.new, n, '0.0001'))
    luaunit.assertFalse(pcall(counter.new, n, {}))
    luaunit.assertFalse(pcall(counter.new, n, false))
    luaunit.assertFalse(pcall(counter.new, n, nil))
  end

  function TestInitNotOk:testNumberOfItemsMustBeInteger()
    luaunit.assertFalse(pcall(counter.new, 10000.01, p))
    luaunit.assertFalse(pcall(counter.new, 10000.99, p))
  end


-- verify that the error rate does not go above what we specified
function TestVerifyErrorRate()
  filter = counter.new(n, p)
  luaunit.assertIsTable(filter)
  i = 0
  for _, line in ipairs(dataset) do
    filter.add(line)
    luaunit.assertEquals(filter.check(line), 1)
    i = i + 1
  end

  luaunit.assertAlmostEquals(filter.getNumItems(), i, math.ceil(p * filter.getNumItems()))
end

function TestReset()
  filter = counter.new(n, p)
  luaunit.assertIsTable(filter)
  luaunit.assertEquals(filter.getNumItems(), 0)

  luaunit.assertEquals(filter.add(stringtest), 0)
  luaunit.assertEquals(filter.getNumItems(), 1)

  filter.reset()
  luaunit.assertEquals(filter.getNumItems(), 0)
end


os.exit(luaunit.LuaUnit.run())
