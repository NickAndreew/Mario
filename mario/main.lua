--[[
    Super Mario Bros. Demo
    Author: Colton Ogden
    Original Credit: Nintendo

    Demonstrates rendering a screen of tiles.
]]

Class = require 'class'
push = require 'push'

require 'Animation'
require 'Map'
require 'Player'

-- close resolution to NES but 16:9
VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

-- actual window resolution
WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

LEVEL = 1

-- seed RNG
math.randomseed(os.time())

-- makes upscaling look pixel-y instead of blurry
love.graphics.setDefaultFilter('nearest', 'nearest')

-- an object to contain our map data
map = Map()

-- performs initialization of all objects and data needed by program
function love.load()

    -- sets up a different, better-looking retro font as our default
    love.graphics.setFont(love.graphics.newFont('fonts/font.ttf', 8))

    -- sets up virtual screen resolution for an authentic retro feel
    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        resizable = true
    })

    love.window.setTitle('Super Mario 50')

    love.keyboard.keysPressed = {}
    love.keyboard.keysReleased = {}
end

-- called whenever window is resized
function love.resize(w, h)
    push:resize(w, h)
end

-- global key pressed function
function love.keyboard.wasPressed(key)
    if (love.keyboard.keysPressed[key]) then
        return true
    else
        return false
    end
end

-- global key released function
function love.keyboard.wasReleased(key)
    if (love.keyboard.keysReleased[key]) then
        return true
    else
        return false
    end
end

-- called whenever a key is pressed
function love.keypressed(key)
    if key == 'escape' then
        love.event.quit()
    end

    if key == 'enter' or key == 'return' then
        if map.gameState == 'victory' then
            map = Map()
            LEVEL = LEVEL + 1
        elseif map.gameState == 'game_over' then
            map:resetLevel()
        end
    end

    love.keyboard.keysPressed[key] = true
end

-- called whenever a key is released
function love.keyreleased(key)
    love.keyboard.keysReleased[key] = true
end

-- called every frame, with dt passed in as delta in time since last frame
function love.update(dt)
    map:update(dt)

    -- reset all keys pressed and released this frame
    love.keyboard.keysPressed = {}
    love.keyboard.keysReleased = {}
end

-- called each frame, used to render to the screen
function love.draw()
    -- begin virtual resolution drawing
    push:apply('start')

    -- clear screen using Mario background blue
    love.graphics.clear(108/255, 140/255, 255/255, 255/255)

    -- renders our map object onto the screen
    love.graphics.translate(math.floor(-map.camX + 0.5), math.floor(-map.camY + 0.5))
    map:render()

    if map.gameState == 'victory' then
        love.graphics.setFont(love.graphics.newFont('fonts/font.ttf', 30))
        love.graphics.printf('VICTORY', 0, 40, map.mapWidthPixels - map.tileWidth * 10, 'right')        
        love.graphics.setFont(love.graphics.newFont('fonts/font.ttf', 20))
        love.graphics.printf("Press 'ENTER' to start level " .. tostring(LEVEL + 1) .. "!", 0, 70, map.mapWidthPixels - map.tileWidth * 4, 'right')                
    elseif map.gameState == 'game' then    
        love.graphics.setFont(love.graphics.newFont('fonts/font.ttf', 12))
        love.graphics.print("Level: " .. tostring(LEVEL), map.camX + map.tileWidth, map.camY + map.tileWidth, 0, 1, 1, 3, 3)
        love.graphics.print("Scored: " .. tostring(map.scores), map.camX + map.tileWidth, map.camY + (map.tileWidth * 2), 0, 1, 1, 3, 3)
    elseif map.gameState == 'game_over' then
        love.graphics.setFont(love.graphics.newFont('fonts/font.ttf', 50))
        love.graphics.print("GAME OVER!", map.camX + (map.tileWidth * 5), map.camY + (map.tileWidth * 5), 0, 1, 1, 3, 3)
        love.graphics.setFont(love.graphics.newFont('fonts/font.ttf', 20))
        love.graphics.print("You scored: " .. tostring(map.scores), map.camX + (map.tileWidth * 9), map.camY + (map.tileWidth * 8), 0, 1, 1, 3, 3)
        love.graphics.setFont(love.graphics.newFont('fonts/font.ttf', 11))
        love.graphics.print("Press 'Enter' to start Level : " .. tostring(LEVEL) .. " again.", map.camX + (map.tileWidth * 7), map.camY + (map.tileWidth * 10), 0, 1, 1, 3, 3)
    end

    -- end virtual resolution
    push:apply('end')
end
