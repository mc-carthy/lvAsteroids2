function love.load()
    shipX, shipY = love.graphics.getWidth() / 2, love.graphics.getHeight() / 2
    shipRot = 0
    shipSpeedX, shipSpeedY = 0, 0
    shipSpeed = 100
    shipRotSpeed = 10
end

function love.update(dt)
    if love.keyboard.isDown('right') then
        shipRot = (shipRot + shipRotSpeed * dt) % (2 * math.pi)
    end
    if love.keyboard.isDown('left') then
        shipRot = (shipRot - shipRotSpeed * dt) % (2 * math.pi)
    end
    if love.keyboard.isDown('up') then
        shipSpeedX = shipSpeedX + math.cos(shipRot) * shipSpeed * dt
        shipSpeedY = shipSpeedY + math.sin(shipRot) * shipSpeed * dt
    end

    shipX = (shipX + shipSpeedX * dt) % love.graphics.getWidth()
    shipY = (shipY + shipSpeedY * dt) % love.graphics.getHeight()
end

function love.draw()
    for y = -1, 1 do
        for x = -1, 1 do
            love.graphics.origin()
            love.graphics.translate(x * love.graphics.getWidth(), y * love.graphics.getHeight())
            love.graphics.setColor(0, 0, 1)
            love.graphics.circle('fill', shipX, shipY, 30)
            love.graphics.setColor(0, 1, 1)
            local shipCircleDistance = 20
            love.graphics.circle(
                'fill',
                shipX + math.cos(shipRot) * shipCircleDistance,
                shipY + math.sin(shipRot) * shipCircleDistance,
                5
            )
        end
    end
end

function love.keypressed(key)
    if key == 'escape' then
        love.event.quit()
    end
end