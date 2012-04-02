Welcome = {}
local welcomeGraphic
local welcomeGroup

function Welcome:displayWelcome()
  print("Welcome:displayWelcome")
  welcomeGroup = display.newGroup()
  welcomeGraphic = display.newImage("graphics/title.png",0,0)
  welcomeGroup:insert(welcomeGraphic)
  audio.stop(airRaidChannel)
  audio.stop(bgmChannel)  
  bgmChannel = audio.play(sfxTitleBgm, {loops = -1})  
  Runtime:addEventListener('touch', setupGame) 
end

function Welcome:removeWelcome()
  print("Welcome:removeWelcome")
  welcomeGroup:removeSelf()
end

return Welcome
