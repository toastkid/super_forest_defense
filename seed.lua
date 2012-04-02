--this class expects a global "seeds" displayGroup to exist

Seed = {}

--constructor
function Seed:new(x,y,species)
  print("Seed:new, x = " .. (x or nil) .. ", y = " .. (y or nil) )
	local seed = display.newImage("seed_icon.png")
  --seed.midx = x
  --seed.midy = y
  --seed.width = seed.contentBounds.xMax - seed.contentBounds.xMin
  --seed.height = seed.contentBounds.yMax - seed.contentBounds.yMin
  seed.x =    x-- - seed.width/2
  seed.y =    y-- - seed.height/2
  seed.name = 'seed'   
  seed.species = species or "oak"
  seed.falling = true
  
  function seed:fall()
    if(self.falling) then
      self.y = self.y + 1
      if(self.y > 445) then
        print("seed hit the ground: x = " .. self.x .. ", y = " .. self.y) 
        self:turnIntoTree()
      end
    end
  end
  
  function seed:turnIntoTree()
    trees:insert(Tree:new(self.x))
    self:removeSelf()
  end

  function seed:drag(event)
    seed.x = event.x
    seed.y = event.y
    if(event.phase == "ended") then
      print("phase == 'ended', setting seed:falling = true")
      seed.falling = true
    else 
      seed.falling = false
    end
  end
  
  seed:addEventListener("touch", drag)

	return seed
end

function Seed:fallAll()
	for i = seeds.numChildren, 1, -1 do
    seed = seeds[i]
    seed:fall()
  end  
end

return Seed
