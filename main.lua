function love.load()
    screenWidth, screenHeight = love.graphics.getWidth(), love.graphics.getHeight()
    shipX, shipY = screenWidth / 2, screenHeight / 2
    shipRot = 0
    shipSpeedX, shipSpeedY = 0, 0
    shipSpeed = 100
    shipRotSpeed = 10
    shipRad = 30

    bullets = {}
    bulletSpeed = 500
    bulletLifetime = 4
    bulletTimer = 0
    bulletRad = 5

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
    asteroidSpeed = 20
    asteroidRad = 80
    for _, asteroid in ipairs(asteroids) do
        asteroid.rot = love.math.random() * (2 * math.pi)
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
                { x = asteroid.x, y = asteroid.y, rad = asteroidRad }
            ) then
                table.remove(bullets, bulletIndex)
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
        asteroid.x = (asteroid.x + math.cos(asteroid.rot) * asteroidSpeed * dt) % screenWidth
        asteroid.y = (asteroid.y + math.sin(asteroid.rot) * asteroidSpeed * dt) % screenHeight

        if circleCollision(
            { x = asteroid.x, y = asteroid.y, rad = asteroidRad }, 
            { x = shipX, y = shipY, rad = shipRad }
        ) then
            love.load()
            break
        end
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
                love.graphics.circle('fill', asteroid.x, asteroid.y, asteroidRad)
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