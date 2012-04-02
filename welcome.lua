Welcome = {}

local welcomeGroup

function Welcome:displayWelcome()
  welcomeGroup = display.newGroup()
  local welcomeGraphic = display.newImage(welcomeGroup, "title.png",0,0)
  Runtime:addEventListener('touch', startGame)  
end

function Welcome:removeWelcome()
  Runtime:removeEventListener('touch', startGame) 
  welcomeGroup:removeSelf()
end

return Welcome
