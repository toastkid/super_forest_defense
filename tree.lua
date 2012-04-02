--this class expects a global "trees" displayGroup to exist
--so sue me
Tree = {}

local treeBurnTimeSeconds = 2

--constructor
function Tree:new(midx)
  print("Tree:new, midx = " .. (midx or "nil"))
	local tree = display.newImage("tree_100.png")
  --x is the centre of the tree (the midx var), so we need to work out where the left hand side is for the x coord
  tree.midx = midx
  tree.scaleFactor = math.random(2, 10)/10  --vary between 0.2 and 1
  if(trees.numChildren > 2) then
    tree.xScale = tree.scaleFactor
  end
  --tree.yScale = tree.scaleFactor  
  tree.x = midx - tree.contentBounds.xMin/2
  tree.y = groundY + (tree.contentBounds.yMax - tree.contentBounds.yMin)/2 --+ tree.contentBounds.yMax/2
  print("tree.y = " .. tree.y .. ", height = " .. tree.contentBounds.yMax - tree.contentBounds.yMin .. ", tree.contentBounds.yMin = " ..  tree.contentBounds.yMin .. ", tree.contentBounds.yMax = " .. tree.contentBounds.yMax) 
  tree.name = 'tree'    
  tree.growHeight = 1
  local growthScaleFactor = (90 + math.random(20))/100 --vary between 0.9 and 1.1
  tree.growthSpeed = 0.4 * growthScaleFactor
  tree.dropSeed1height = 150
  tree.dropSeed2height = 300
  tree.droppedSeed1 = false
  tree.droppedSeed2 = false
  tree.droppedSeed3 = false
  tree.growing = true
  tree.stuntage = 0
  tree.hitPoints = 10
  tree.maxGrowHeight = 350 + (math.random(20) - 10)
  print("tree.growthSpeed = " .. tree.growthSpeed)
  treeCreatedChannel = audio.play(sfxTreeCreated)  
  
  function tree:grow()
    if(tree.growing) then 
      tree.stuntage = tree:calculateStuntage()
      if(self.growHeight < self.maxGrowHeight) then
        local growThisTurn = self.growthSpeed - ((self.growthSpeed * 0.8) * tree.stuntage) 
        if(growThisTurn < 0) then
          print("tree.stuntage = " .. tree.stuntage .. ", growThisTurn = " .. growThisTurn)
        end
        self.growHeight = self.growHeight + growThisTurn 
        self.y = self.y - growThisTurn
        --decide whether to drop a seed and/or stop growing
        if(self.growHeight >= self.maxGrowHeight and self.droppedSeed3 == false) then
          self.growing = false
          self:dropSeed()
          self.droppedSeed3 = true
          print("tree dropped seed 3")
        elseif(self.growHeight > self.dropSeed2height and self.droppedSeed2 == false) then
          self:dropSeed()
          self.droppedSeed2 = true
          print("tree dropped seed 2")        
        elseif(self.growHeight > self.dropSeed1height and self.droppedSeed1 == false) then
          self:dropSeed()
          self.droppedSeed1 = true
          print("tree dropped seed 1")            
        end
      end
    end
  end
  
  function tree:dropSeed()
    --seed x pos will be tree top height - 20
    seed = Seed:new(self.x + (math.random(20)-10), self.contentBounds.yMin + 20)
    seeds:insert(seed)
    seed:toFront()
    return seed
  end
  
  function tree:calculateStuntage()
    --stuntage varies between 0 and 1 depending on how many close neighbours the tree has
    local neighbourCount = self:neighbourCount()
    --lets say we want maximum stuntage of 1 to occur when we have five close neighbours
    local result = neighbourCount / 5 
    if(result >= 1) then
      return 1
    else
      return result
    end
  end
  
  function tree:neighbourCount()
    local count = 0
    for i = 1, trees.numChildren do
      otherTree = trees[i]
      if(otherTree ~= self and math.abs(otherTree.x - self.x) < 20) then
        count = count + 1
      end
    end    
    return count  
  end
  
  function tree:loseHitPoints(points)
    print("tree loses " .. points .. "points")
    self.hitPoints = self.hitPoints - points
    if(self.hitPoints <= 0) then
      self:destroy()
    else
      print("tree took damage but survived")
      treeDamagedChannel = audio.play(sfxTreeDamaged)      
    end
  end  
  
  function tree:destroy()
    --put the burning tree there with a timer to destroy it too after a second then remove our object and then destroy the tree
    local burningTree = display.newImage("tree_destroyed.png")
    burningTree.xScale = self.xScale
    burningTree.yScale = self.yScale
    burningTree.x = self.x
    burningTree.y = self.y - 20
    burningTree.startedBurningAt = os.time()
    burningTrees:insert(burningTree) 
  
    audio.play(sfxTreeDestroyed) 
    self:removeSelf()
    print("tree was destroyed")     
  end

	return tree
end

function Tree:makeStartTrees()
  --shove a random tree in at the start
  trees:insert(Tree:new(160))
end

function Tree:removeBurningTrees()
  local timeNow  = os.time()
  for i = burningTrees.numChildren, 1, -1 do
    burningTree = burningTrees[i]
    if(math.abs(os.difftime(timeNow, burningTree.startedBurningAt )) > treeBurnTimeSeconds ) then
      burningTree:removeSelf()
    end
  end
end

function Tree:speak()
  print("I am the tree class")
end

function Tree:growAll()
	for i = trees.numChildren, 1, -1 do
    tree = trees[i]
    tree:grow()
  end
end

function Tree:chanceOfSpontaneousTree()
  if(math.random(500) == 1) then
    trees:insert(Tree:new( math.random(display.contentWidth)))
  end
end

return Tree
