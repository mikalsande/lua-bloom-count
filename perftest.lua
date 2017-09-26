local bloom = require("bloom")
local socket = require("socket")


local dataset = {}
for line in io.lines('./list') do
  table.insert(dataset, line)
end

-- initialize the filter
local timer1 = socket.gettime()*1000
local filter = bloom.new(10000, 0.0001)
local timer2 = socket.gettime()*1000
print('Initialized the filter in ' .. timer2 - timer1 .. ' msec')

-- reset of the filter
timer1 = socket.gettime()*1000
filter.reset()
timer2 = socket.gettime()*1000
print('Reinitialized the filter in ' .. timer2 - timer1 .. ' msec')
print()

-- add items to the file
local i = 0
timer1 = socket.gettime()*1000
for _, line in ipairs(dataset) do
  filter.add(line)
  i = i + 1
end
timer2 = socket.gettime()*1000
print('Added ' .. i .. ' items to the filter in ' .. timer2 - timer1 .. ' msec')
print(i / ((timer2 - timer1)) .. ' inserts per msec')
print()

-- check that the items are in the list
i = 0
timer1 = socket.gettime()*1000
for _, line in ipairs(dataset) do
  filter.check(line)
  i = i + 1
end
timer2 = socket.gettime()*1000
print('Checked ' .. i .. ' items in the filter in ' .. timer2 - timer1 .. ' msec')
print(i / ((timer2 - timer1)) .. ' inserts per msec')
