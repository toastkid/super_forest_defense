--this class expects a global "seedboxes" displayGroup to exist

Seedbox = {}

--constructor
function Seedbox:new(posn)
  print("Seedbox:new, posn = " .. (posn or "nil"))
	local seedbox = display.newRect(seedboxes, (posn*45), 438, 40, 40)
  seedbox.strokeWidth = 2
  seedbox:setStrokeColor(45,40,10)	
	seedbox:setFillColor(0,0,0)	  
  seedbox.seedCount = 1
  seedbox.name = "seedbox"
  
  --instance methods
	return seedbox
end

--class methods
function Seedbox:makeSeedBoxes()
  --for now just stick the background graphic in there
  local seedboxBg = display.newImage(seedboxes, "graphics/ground2.png", 0, display.contentHeight - 45)
  --local seedboxBg = display.newRect(seedboxes, 0, display.contentHeight - 45, 320, 45)
  
  --seedboxBg:setFillColor(50,0,0)	 
  ----seedboxBg:toFront()
  --for i = 0, 5 do
    --box = Seedbox:new(i, seedboxes)
    ----seedboxes:insert(box)
  --end
end


return Seedbox
