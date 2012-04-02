--this class expects a global "meteors" displayGroup to exist
Meteor = {}
--some locals
local nextMeteorHitPoints
local maxMeteorHitPoints
local secondsToNextMeteor
local minSecondsToNextMeteor
local maxMeteorCount
local meteorBurnTimeSeconds
local meteorExplosionTimeSeconds
local hadMeteorExplosion
local meteorFallSpeed
local meteorTimer

function Meteor:setup()
  nextMeteorHitPoints = 5
  maxMeteorHitPoints = 100
  secondsToNextMeteor = 15
  minSecondsToNextMeteor = 2
  maxMeteorCount = 40
  meteorBurnTimeSeconds = 2
  meteorExplosionTimeSeconds = 5
  hadMeteorExplosion = false
  meteorFallSpeed = 0.4
  --start meteors off
  if(meteorTimer) then
    timer.cancel(meteorTimer)
  end
  meteorTimer = timer.performWithDelay(secondsToNextMeteor*1000, generateMeteor)    
end

function Meteor:clearAll()
  for i = meteors.numChildren, 1, -1 do
    meteors[i]:removeSelf()
  end
end

--constructor
function Meteor:new(x)
	local meteor = display.newImage("meteor.png")
  --meteor.midx = x
  --meteor.midy = y
  --meteor.width = meteor.contentBounds.xMax - meteor.contentBounds.xMin
  --meteor.height = meteor.contentBounds.yMax - meteor.contentBounds.yMin
  meteor.x =    x
  meteor.y =    -50 
  meteor.hasHitGround = false
  meteor.hitPoints = nextMeteorHitPoints
  --want meteor to reach full size at 20 hitPoints
  meteor.scaleFactor = (meteor.hitPoints / 20)
  meteor.xScale = meteor.scaleFactor
  meteor.yScale = meteor.scaleFactor  
  if(nextMeteorHitPoints < maxMeteorHitPoints) then
    nextMeteorHitPoints = nextMeteorHitPoints + 1
  end
  meteor.name = 'meteor'   
  print("Meteor:new, x = " .. (x or nil) .. ", hitPoints = " .. meteor.hitPoints )  
  
  function meteor:fall()
    self.y = self.y + meteorFallSpeed
    --see if meteor has hit the ground
    if(self.contentBounds.yMax > groundY and self.hasHitGround == false) then
      self:hitGround()
    end    
    --see if we've hit any of the trees    
    for i = trees.numChildren, 1, -1 do
      tree = trees[i]
      if(self:hasHit(tree)) then
        self:hitTree(tree)
      end
    end    
  end
  
  --see if we've hit a particular tree.  We can't listen for collision because haven't put physics on them
  function meteor:hasHit(tree)
    return (meteor.contentBounds.yMax > tree.contentBounds.yMin and 
            meteor.contentBounds.xMax > tree.contentBounds.xMin and
            meteor.contentBounds.xMin < tree.contentBounds.xMax)
  end
  
  function meteor:hitTree(tree)
    print("meteor has hit tree")
    local treeHitPoints = tree.hitPoints
    local meteorHitPoints = self.hitPoints
    tree:loseHitPoints(meteorHitPoints)
    self:loseHitPoints(treeHitPoints)
  end
  
  function meteor:loseHitPoints(points)
    print("meteor loses " .. points .. "points")
    self.hitPoints = self.hitPoints - points
    if(self.hitPoints <= 0) then
      self:destroy()
    end
  end
  
  function meteor:destroy()
    --put the burning tree there with a timer to destroy it too after a second then remove our object and then destroy the tree
    print("self.x = " .. self.x .. ", self.y = " .. self.y .. ", self.contentBounds.xMin = " .. self.contentBounds.xMin .. ", self.contentBounds.yMin = " .. self.contentBounds.yMin)
    local burningMeteor = display.newImage("meteor_destroyed.png")
    burningMeteor.xScale = self.xScale * 3
    burningMeteor.yScale = self.yScale * 3   
    burningMeteor.x = self.x
    burningMeteor.y = self.y
    --, self.contentBounds.xMin, self.contentBounds.yMin    
    print("burningMeteor.x = " .. burningMeteor.x .. ", burningMeteor.y = " .. burningMeteor.y .. ", burningMeteor.contentBounds.xMin = " .. burningMeteor.contentBounds.xMin .. ", burningMeteor.contentBounds.yMin = " .. burningMeteor.contentBounds.yMin)     
    burningMeteor.startedBurningAt = os.time()
    burningMeteors:insert(burningMeteor) 
  
    audio.play(sfxMeteorDestroyed) 

    self:removeSelf()
    print("meteor was destroyed")     
  end  
  
  function meteor:hitGround()
    print("hit ground")
    print("meteor hit the ground: x = " .. self.x .. "y = " .. self.y) 
    self.hasHitGround = true
    local meteorExplosion = display.newImage("meteor_impact.png")
    audio.play(sfxMeteorExplosion)  
    if(hadMeteorExplosion == false) then
      airRaidChannel = audio.play(sfxAirRaid, {loops = -1})
      hadMeteorExplosion = true
      timer.performWithDelay(3, showGameOverScreen)      
    end
    meteorExplosion.xScale = self.xScale
    meteorExplosion.yScale = self.yScale   
    meteorExplosion.x = self.x
    meteorExplosion.y = self.y + 20
    meteorExplosion.startedBurningAt = os.time()
    meteorExplosions:insert(meteorExplosion)
    --alert('!!METEOR STRIKE!!') 
    --gameEvent = 'lose' 	    
  end  
  
  meteor:addEventListener('collision', onCollision)

	return meteor
end

--class methods
function Meteor:fallAll()
	for i = meteors.numChildren, 1, -1 do
    meteor = meteors[i]
    meteor:fall()
  end  
end

function Meteor:generate()
  if(meteors.numChildren <= maxMeteorCount) then
    meteor = Meteor:new(math.random(20,300))
    meteors:insert(meteor)
    meteor:toFront()    
    if(secondsToNextMeteor > minSecondsToNextMeteor) then
      secondsToNextMeteor = secondsToNextMeteor * 0.95
    end
    print("secondsToNextMeteor = " .. secondsToNextMeteor )
  end
  timer.performWithDelay(secondsToNextMeteor*1000, generateMeteor)
end

function Meteor:removeBurningMeteors()
  local timeNow  = os.time()
  for i = burningMeteors.numChildren, 1, -1 do
    burningMeteor = burningMeteors[i]
    if(math.abs(os.difftime(timeNow, burningMeteor.startedBurningAt )) > meteorBurnTimeSeconds ) then
      burningMeteor:removeSelf()
    end
  end
end

function Meteor:removeMeteorExplosions()
  local timeNow  = os.time()
  for i =  meteorExplosions.numChildren, 1, -1 do
    meteorExplosion = meteorExplosions[i]
    if(math.abs(os.difftime(timeNow, meteorExplosion.startedBurningAt )) > meteorExplosionTimeSeconds ) then
      meteorExplosion:removeSelf()
    end
  end
end

return Meteor
