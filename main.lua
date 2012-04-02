display.setStatusBar(display.HiddenStatusBar)

--require classes
local Seedbox = require 'lib/seedbox'
local Seed = require 'lib/seed'
local Tree =    require 'lib/tree'
local Welcome = require 'lib/welcome'
local Meteor = require 'lib/meteor'

--set up groups - make these all globals (not locals) so our other classes can get at them
fullScreen = display.newGroup()

playArea = display.newGroup()
fullScreen:insert(playArea)
background = display.newImage(playArea, 'graphics/background.png')

trees = display.newGroup()
playArea:insert(trees)

burningTrees = display.newGroup()
playArea:insert(burningTrees)

meteors = display.newGroup()
playArea:insert(meteors)

burningMeteors = display.newGroup()
playArea:insert(burningMeteors)

meteorExplosions = display.newGroup()
playArea:insert(meteorExplosions)

seedboxes = display.newGroup()
fullScreen:insert(seedboxes)
seedboxes:toFront()

seeds = display.newGroup()
playArea:insert(seeds)
seeds:toFront()

--more globals for sound effects
sfxGameOver = audio.loadStream("sounds/game_over.wav")
sfxStart = audio.loadStream("sounds/start.wav")
sfxTreeCreated = audio.loadStream("sounds/tree_create_v2.wav")
sfxTreeDamaged = audio.loadStream("sounds/tree_damaged_v2.wav")
sfxTreeDestroyed = audio.loadStream("sounds/tree_destroyed_v2.wav")
sfxMeteorExplosion = audio.loadStream("sounds/game_over_short.wav")
sfxAirRaid = audio.loadStream("sounds/air_raid.mp3")
sfxBgm = audio.loadStream("sounds/gameplay_mastered.mp3")
sfxTitleBgm = audio.loadStream("sounds/title_mastered.mp3")
sfxGameStart = audio.loadStream("sounds/start.wav")

--even more globals for some misc stuff
groundY = 435
gameEvent = ""
bgmChannel = ""
airRaidChannel = ""
startTime = os.time()

local gameOverScreen

function setupGame()
  Runtime:removeEventListener('touch', setupGame) 
  for i = meteors.numChildren, 1, -1 do
    meteors[i]:removeSelf()
  end
  for i = trees.numChildren, 1, -1 do
    trees[i]:removeSelf()
  end  
  for i = seeds.numChildren, 1, -1 do
    seeds[i]:removeSelf()
  end  
  for i = burningMeteors.numChildren, 1, -1 do
    burningMeteors[i]:removeSelf()
  end  
  for i = burningTrees.numChildren, 1, -1 do
    burningTrees[i]:removeSelf()
  end    
  for i = meteorExplosions.numChildren, 1, -1 do
    meteorExplosions[i]:removeSelf()
  end   
  Meteor:setup() 
  startGame()
end 

function startGame()
  print("startGame")
  Welcome:removeWelcome()
  Seedbox:makeSeedBoxes()
  Tree:makeStartTrees()
  Runtime:addEventListener('enterFrame', update)
  Meteor:setup()
  gameStartChannel = audio.play(gameStart) 
  audio.stop(airRaidChannel)   
  audio.stop(bgmChannel)
  bgmChannel = audio.play(sfxBgm, {loops = -1})
  audio.play(sfxGameStart)  
  startTime = os.time()    
end

--stuff we want to happen automatically on every frame
function update(e)
  Tree:growAll()
  Tree:removeBurningTrees()
  Meteor:removeBurningMeteors()
  Meteor:removeMeteorExplosions()  
  Seed:fallAll()
  Meteor:fallAll()
  --make a new tree spontaneously occasionally
  --Tree:chanceOfSpontaneousTree()
end

function drag(event)
  seed = event.target
  seed:drag(event)
end

function generateMeteor()
  Meteor:generate()
end

--this isn't being used currently because the objects don't have physics
function onCollision(e)
  target = e.target
  other = e.other
	
  --set up the different types of collision we care about here
  if(target.name == "meteor" and other.name == "tree") then
    target:hitTree(other)
  elseif(target.name == "meteor" and other.name == "ground") then
    target:hitGround()
	end
end

function alert(text)
  print("alert")
  titleTF = display.newText(text, 0, 0, native.systemFontBold, 30)
  titleTF:setTextColor(254,50,50)
  titleTF:setReferencePoint(display.CenterReferencePoint)
  titleTF.x = display.contentCenterX
  titleTF.y = display.contentCenterY - 15
  if(gameEvent == "lose") then
      gameOverChannel = audio.play(sfxGameOver)  
  end
end

function showGameOverScreen()
  print("showGameOverScreen()")
  gameOverScreen = display.newGroup()
  display.newImage(gameOverScreen, "graphics/game_over.png", 0, 0)
  local survivalTime = math.abs(os.difftime(os.time(), startTime))
  local score1 = display.newText("You protected the earth for", 50, 420, "Impact", 20)
  local score2 = display.newText(survivalTime .. " seconds" , 90, 440, "Impact", 30)
  
  gameOverScreen:insert(score1)
  gameOverScreen:insert(score2)
  Runtime:addEventListener('touch', hideGameOverScreen)  
end

function hideGameOverScreen()
  print("hideGameOverScreen()")
  gameOverScreen:removeSelf()
  Runtime:removeEventListener('touch', hideGameOverScreen)
  Welcome:displayWelcome()
end

local function Main()
--wait for tap before starting
  print("Main")
  Welcome:displayWelcome()
end  

Main()        
