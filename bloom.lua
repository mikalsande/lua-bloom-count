local bit = require("bit")
local math = require("math")
local xxhash = require("xxhash")
local hash = xxhash.xxh32

math.randomseed(os.time())

local new = function(numberOfItems, failureRate)
  assert(type(numberOfItems) == "number", "numberOfItems must be a number")
  assert(numberOfItems >= 100, "numberOfItems must be >= 100")
  assert(numberOfItems == math.floor(numberOfItems), "numberOfItems must be an integer")
  assert(type(failureRate) == "number", "failureRate must be a number")
  assert(failureRate <= 0.1, "failureRate must be <= 0.1")

  -- Bloom filter variables
  local n = numberOfItems -- unique items to store
  local p = failureRate -- approximated allowed false positive rate
  local m = math.ceil(-n * math.log(p) / (math.log(2)^2)) -- number of bits
  local k = math.floor((m / n * math.log(2)) + 0.5) -- number of hashes

  -- array variables
  local bpi = 32 -- bits per index, the bit module uses signed 32 bit outputs
  local ni = math.ceil(m / bpi) -- number of Lua numbers needed to store the bits

  -- main datastructures
  local array = {} -- main array for numbers we pack bits into

  -- hash variables
  local seed1
  local seed2

  -- counter
  local addedItems = 0

  -- check if input exists, update it if update == true
  local query = function(input, update)
    assert(type(input) == "string", 'input must be a string')
    assert(type(update) == "boolean", 'update must be a boolean')

    -- make two different hashvalues from the input with different seeds
    -- Kirsh & Mitzenmacher optimization will be used to generate the rest of
    -- the needed hashes
    local a = hash(input, seed1)
    local b = hash(input, seed2)

    -- track whehter or not we have added a new value,  0 if added 1 if not added
    local existed = 1

    -- create hashes and compute array index and bit index for them to get
    -- the individual bits
    for i = 1, k do
      -- use enhanced double hashing (Kirsh & Mitzenmacher) to crete the hash value used for the array index
      local x = (a + (i * b) + i^2) % m

      -- index in the array and bit position in the number in the array.
      local array_index = math.floor(x / bpi)
      local bit_index = x - (array_index * bpi)
      array_index = array_index + 1 -- to account for 1 indexed arrays

      -- get value from the array, find the bit value
      local array_value = array[array_index]
      local bit_index_mask = bit.lshift(1, bit_index)
      local thisbit = bit.band(array_value, bit_index_mask)

      -- if the bit is zero we know did not exist already
      if thisbit == 0 then
        -- set existed = 0 to indicate that we have added a new unique item
        existed = 0

        if update then
          -- set the bit
          array[array_index] = bit.bor(array_value, bit_index_mask)
        end
      end
    end

    -- update the item counter if we added a new item
    if update and existed == 0 then
      addedItems = addedItems + 1
    end

    return existed
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

    -- zero the array
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
  local getNumIndexes  = function()
    return ni
  end

  -- reset the arrays to initialize this instance
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
  }
end

-- methods we expose for this module
return { new = new }
