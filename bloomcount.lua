local bit = require("bit")
local math = require("math")
local xxhash = require("xxhash")
local hash = xxhash.xxh32

math.randomseed(os.time())

local new = function(numberOfItems, failureRate, bitsPerCounter)
  assert(type(numberOfItems) == "number", "numberOfItems must be a number")
  assert(numberOfItems >= 100, "numberOfItems must be >= 100")
  assert(numberOfItems == math.floor(numberOfItems), "numberOfItems must be an integer")
  assert(type(failureRate) == "number", "failureRate must be a number")
  assert(failureRate <= 0.1, "failureRate must be <= 0.1")
  assert(type(bitsPerCounter) == "number", "bitsPerCounter must be a number")
  assert(bitsPerCounter >= 2, "bitsPerCounter must be >= 2")
  assert(bitsPerCounter <= 16, "bitsPerCounter must be <= 16")
  assert(bitsPerCounter == math.floor(bitsPerCounter), "bitsPerCounter must be an integer")

  -- Bloom filter variables
  local n = numberOfItems -- unique items to store
  local p = failureRate -- approximated allowed false positive rate
  local m = math.ceil(-n * math.log(p) / (math.log(2)^2)) -- number of bits
  local k = math.floor((m / n * math.log(2)) + 0.5) -- number of hashes

  -- array variables
  local bpi = 32 -- bits per index, the bit module only supports 32bit signed int
  local cpa = math.floor(bpi / bitsPerCounter) -- counters per array index
  local bpc = math.floor(bpi / cpa) -- bits per counter
  local ni = math.ceil(m / cpa) -- number of Lua numbers needed to store the bits
  local maxval = 2^bpc - 1 -- max value a counter can store

  -- main datastructure
  local array = {} -- main array for numbers we pack bits into

  -- hash variables
  local seed1
  local seed2

  -- counter
  local addedItems = 0

  -- create bit masks used to extract individual counters
  local bitmasks = {} -- bitmasks
  local inv_bitmasks = {} -- invedted bitmasks
  for x = 1, cpa do
    bitmasks[x] = bit.lshift(maxval, (x - 1) * bpc)
    inv_bitmasks[x] = bit.bnot(bitmasks[x])
  end

  local query = function(input, update)
    assert(type(input) == "string", 'input must be a string')
    assert(type(update) == "boolean", 'update must be a boolean')

    -- make two different hashvalues from the input with different seeds
    local a = hash(input, seed1)
    local b = hash(input, seed2)

    -- track whehter or not we have added a new value,  0 if added 1 if not added
    local existed = 1

    -- create hashes and compute array index and bit index for them to get
    -- the individual bits
    local min = maxval -- track the minimum seen value
    for i = 1, k do
      -- use enhanced double hashing (Kirsh & Mitzenmacher) to crete the hash value used for the array index
      local x = (a + (i * b) + i^2) % m

      -- index in the array and bit position in the number in the array.
      local array_index = math.floor(x / cpa)
      local bit_index = x - (array_index * cpa)
      array_index = array_index + 1 -- to account for 1 indexed arrays

      -- get value from the array, find the counter value
      local array_value = array[array_index]
      local bit_index_mask = bitmasks[1 + bit_index]
      local thesebits = bit.band(array_value, bit_index_mask)
      local thisvalue = (bit_index == 0) and thesebits or bit.rshift(thesebits, bit_index * bpc)

      -- if the bit is zero we know did not exist already just return if we are not updating it
      if thisvalue == 0 then
        existed = 0
        if not update then
          return 0
        end
      end

      -- update the value and make sure we don't go above the max value
      if update and thisvalue < maxval then
        thisvalue = thisvalue + 1

        -- zero the bits with bitwize-and using the inverse of the index bitmask
        array_value = bit.band(array_value, inv_bitmasks[1 + bit_index])

        -- update the value in the array
        array[array_index] = array_value + bit.lshift(thisvalue, bpc * bit_index)
      end

      -- update the smallest seen value
      if thisvalue < min then
        min = thisvalue
      end
    end

    -- update the item counter if we added a new item
    if update and existed == 0 then
      addedItems = addedItems + 1
    end

    return min
  end

  --[[
  Adds a new entry to the set. returns 1 if the element
  already existed and 0 if it does not exist in the set.
  ]]
  local add = function(input)
    return query(input, true)
  end

  --[[
  checks whether or not an element is in the set.
  returns 1 if the element exists and 0 if it does
  not exist in the set.
  ]]
  local check = function(input)
    return query(input, false)
  end

  --[[ resets the arrays used in the filter ]]
  local reset = function()
    addedItems = 0

    -- since 2*rand and 3*rand is done modulo a prime these number will always
    -- be different and should therefore safe to use as seeds to generate two
    -- different hashes for the same input.
    local rand = math.random(-2147483648, 2147483647)
    seed1 = (2*rand) % 2147483647
    seed2 = (3*rand) % 2147483647

    for x = 1, ni do
      array[x] = 0
    end
  end

  -- [[ get number of unique added items ]]
  local getNumItems = function()
    return addedItems
  end

  -- [[ get number of bits this instance uses ]]
  local getNumBits = function()
    return m
  end

  -- [[ get number of keys this instance uses ]]
  local getNumKeys = function()
    return k
  end

  -- [[ get number of array indexes this instance uses to store its bits ]]
  local getNumIndexes = function()
    return ni
  end

  -- [[ get the maximum value a counter can store ]]
  local getMaxCounterValue = function()
    return maxval
  end

  -- reset the array to initialize this instance
  reset()

  -- methods we expose for this instance
  return  {
    add = add,
    check = check,
    reset = reset,
    getNumItems = getNumItems,
    getNumBits = getNumBits,
    getNumKeys = getNumKeys,
    getNumIndexes = getNumIndexes,
    getMaxCounterValue = getMaxCounterValue,
  }
end

-- methods we expose for this module
return { new = new }
