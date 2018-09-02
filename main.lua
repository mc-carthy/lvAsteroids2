function love.load()
    screenWidth, screenHeight = love.graphics.getWidth(), love.graphics.getHeight()
    shipSpeed = 100
    shipRotSpeed = 10
    shipRad = 30
    
    bulletSpeed = 500
    bulletLifetime = 4
    bulletRad = 5
    asteroidStages = {
        {
            speed = 120,
            radius = 15
        },
        {
            speed = 70,
            radius = 30
        },
        {
            speed = 50,
            radius = 50
        },
        {
            speed = 20,
            radius = 80
        }
    }

    reset()
end

function reset()
    shipX, shipY = screenWidth / 2, screenHeight / 2
    shipRot = 0
    shipSpeedX, shipSpeedY = 0, 0
    
    bullets = {}
    bulletTimer = 0
    
    asteroids = {
        {
            x = 100,
            y = 100,
        },
        {
            x = screenWidth - 100,
            y = 100,
        },
        {
            x = screenWidth / 2,
            y = screenHeight - 100,
        }
    }
    for _, asteroid in ipairs(asteroids) do
        asteroid.rot = love.math.random() * (2 * math.pi)
        asteroid.stage = #asteroidStages
    end
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

    shipX = (shipX + shipSpeedX * dt) % screenWidth
    shipY = (shipY + shipSpeedY * dt) % screenHeight

    for bulletIndex = #bullets, 1, -1 do
        local bullet = bullets[bulletIndex]

        bullet.timeLeft = bullet.timeLeft - dt

        if bullet.timeLeft <= 0 then
            table.remove(bullets, bulletIndex)
        else
            bullet.x = (bullet.x + math.cos(bullet.rot) * bulletSpeed * dt) % screenWidth
            bullet.y = (bullet.y + math.sin(bullet.rot) * bulletSpeed * dt) % screenHeight
        end

        for asteroidIndex = #asteroids, 1, -1 do
            local asteroid = asteroids[asteroidIndex]
            if circleCollision(
                { x = bullet.x, y = bullet.y, rad = bulletRad }, 
                { x = asteroid.x, y = asteroid.y, rad = asteroidStages[asteroid.stage].radius }
            ) then
                table.remove(bullets, bulletIndex)

                if asteroid.stage > 1 then
                    local angle1 = love.math.random() * (2 * math.pi)
                    local angle2 = (angle1 - math.pi) % (2 * math.pi)

                    table.insert(asteroids, {
                        x = asteroid.x,
                        y = asteroid.y,
                        rot = angle1,
                        stage = asteroid.stage - 1
                    })
                    table.insert(asteroids, {
                        x = asteroid.x,
                        y = asteroid.y,
                        rot = angle2,
                        stage = asteroid.stage - 1
                    })
                end

                table.remove(asteroids, asteroidIndex)
                break
            end
        end
    end

    bulletTimer = bulletTimer + dt
    if love.keyboard.isDown('s') then
        if bulletTimer >= 0.5 then
            bulletTimer = 0
            table.insert(bullets, {
                x = shipX + math.cos(shipRot) * shipRad,
                y = shipY + math.sin(shipRot) * shipRad,
                rot = shipRot,
                timeLeft = bulletLifetime
            })
        end
    end

    for asteroidIndex = #asteroids, 1, -1 do
        local asteroid = asteroids[asteroidIndex]
        asteroid.x = (asteroid.x + math.cos(asteroid.rot) * asteroidStages[asteroid.stage].speed * dt) % screenWidth
        asteroid.y = (asteroid.y + math.sin(asteroid.rot) * asteroidStages[asteroid.stage].speed * dt) % screenHeight

        if circleCollision(
            { x = asteroid.x, y = asteroid.y, rad = asteroidStages[asteroid.stage].radius }, 
            { x = shipX, y = shipY, rad = shipRad }
        ) then
            reset()
            break
        end
    end

    if #asteroids <= 0 then
        reset()
    end
end

function love.draw()
    for y = -1, 1 do
        for x = -1, 1 do
            love.graphics.origin()
            love.graphics.translate(x * screenWidth, y * screenHeight)
            love.graphics.setColor(0, 0, 1)
            love.graphics.circle('fill', shipX, shipY, shipRad)
            love.graphics.setColor(0, 1, 1)
            local shipCircleDistance = 20
            love.graphics.circle(
                'fill',
                shipX + math.cos(shipRot) * shipCircleDistance,
                shipY + math.sin(shipRot) * shipCircleDistance,
                5
            )

            for _, bullet in ipairs(bullets) do
                love.graphics.setColor(0, 1, 0)
                love.graphics.circle('fill', bullet.x, bullet.y, bulletRad)
            end

            for _, asteroid in ipairs(asteroids) do
                love.graphics.setColor(1, 1, 0)
                love.graphics.circle('fill', asteroid.x, asteroid.y, asteroidStages[asteroid.stage].radius)
            end
        end
    end
end

function love.keypressed(key)
    if key == 'escape' then
        love.event.quit()
    end
end

function circleCollision(a, b)
    return (a.x - b.x)^2 + (a.y - b.y)^2 <= (a.rad + b.rad)^2
end