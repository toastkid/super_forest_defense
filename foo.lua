--This is an example of how to set up (pseudo-) classes in Lua. 
--Use like this (note use of semicolon for method calls and full stop for attribute access)
-- -- in main.lua
--Foo = require "foo"
--foo1 = Foo:new(x,y)
--foo1:speak() -- call instance method
--Foo:speak() -- call class method

--make the "class"
Foo = {}

--constructor
function Foo:new(x, y)
  --the new instance
	local foo = display.newImage("foo.png")
  -- set some instance vars
  foo.x = x - foo.contentBounds.xMin -- .contentBounds.xMin (in Corona) will return the x value of the left hand side of the foo image
  foo.y = y
  foo.name = 'foo'    
  
  --an instance method - note we refer to "self" inside the instance method like in ruby
  function foo:speak()
    print("I am an instance and my name is " .. self.name)
  end
  
  --another instance method
  function foo:moveLeft()
    self.x = self.x - 1
  end
  
	return foo
end

--a class method
function Foo:speak()
  print("I am the class Foo")
end

return Foo
