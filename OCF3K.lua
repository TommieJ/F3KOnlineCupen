-- ************ Användarinställningar ************
local launchSwitch = "sf"
local announcements = { 150, 120, 90, 60, 30, 15, 10, 5, 3, 2, 1, 0 }
local delimeter = ";"
-- ************ SLUT Användarinställningar ************


local column1 = 120
local column2 = 200
local row1 = 1
local row2 = 11
local row3 = 21
local row4 = 31
local row5 = 41
local row6 = 51

local startTime

local taskList = {
        "Flygning 60s",
        "Flygning 90s",
        "Flygning 120s",
        "Flygning 150s",
        "Flygning 180s",
    }
local currentTask = 1

local scores = { 0, 0 } --, 0, 0, 0 }

local landings = { false, false, false, false, false }

local targetTimes = { 5, 90, 120, 150, 180 }

local editField = { false, false, false, false, false }
local editLanding = { false, false, false, false, false }

local currentScreen

local F_STATE_ON_THE_GROUND = 0
local F_STATE_LAUNCH_INITIATED = 1
local F_STATE_IN_THE_AIR = 2
local F_STATE_FLIGHT_ENDED = 3
local currentFlightState = 0

local yesHiglighted = true

local scoresRootPath = "/LOGS/"

-- ********** Drawing functions ************
local function getTotalScore()
    local totalScore = 0
    for row, score in ipairs(scores) do
        totalScore = totalScore + score
    end

    for row, landing in ipairs(landings) do
        if landing then
            totalScore = totalScore + 10
        end
    end
    return totalScore
end

local function drawTotalRow()
    lcd.drawNumber(column2, row6, getTotalScore(), MIDSIZE)
end

local function drawScoreRow(row, score, flag)
    if score ~= 0 then
        lcd.drawNumber(column2, row, score, flag)
    end
end

local function drawLandingsRow(row, landing)
    local columnOffset = 32
    local rowOffset = 1
    lcd.drawRectangle(column1 + columnOffset, row + rowOffset, 6, 6, SOLID)
    if landing then
        lcd.drawRectangle(column1 + columnOffset + 1, row + rowOffset + 1, 5, 5, SOLID)
        lcd.drawRectangle(column1 + columnOffset + 2, row + rowOffset + 2, 4, 4, SOLID)
        lcd.drawRectangle(column1 + columnOffset + 3, row + rowOffset + 3, 3, 3, SOLID)
        lcd.drawRectangle(column1 + columnOffset + 4, row + rowOffset + 4, 2, 2, SOLID)
    end
end

local function drawTitleRows()
    lcd.drawText(column1, row1, "60s")
    lcd.drawText(column1,row2, "90s")
    lcd.drawText(column1, row3, "120s")
    lcd.drawText(column1, row4, "150s")
    lcd.drawText(column1, row5, "180s")
end

local function drawScores()
    for row, score in ipairs(scores) do
        local flag = 0
        if editField[row] then
            flag = BLINK
        end
        drawScoreRow(1 + (10 * (row - 1)), score, flag)
    end

    for row, landing in ipairs(landings) do
        drawLandingsRow(1 + (10 * (row - 1)), landing)
    end

    drawTotalRow()
end

local function drawTask(currentTask)
    lcd.drawText(1, row1, currentTask, MIDSIZE)
end

local function drawCurrentTime(currentTime)
    if currentTime ~= nil then
        lcd.drawNumber(100, row3, currentTime, XXLSIZE)
    end
end

-- ********** END Drawing functions ************

local function startTimer()
    print('start timer')
    startTime = getTime()
    currentTime = targetTimes[currentTask]
end

local function endFlight()
    currentFlightState = F_STATE_ON_THE_GROUND
    scores[currentTask] = targetTimes[currentTask] - currentTime
    yesHiglighted = true
    currentScreen = askForLandingPoints
end
local function persistScores()
    local dateNow = getDateTime()
    local formatedDate = string.format("%04d-%02d-%02d %02d:%02d:%02d", dateNow.year, dateNow.mon, dateNow.day, dateNow.hour, dateNow.min, dateNow.sec)
    local fileName = "OCF3K.csv"
    local file = io.open(string.format("%s%s", scoresRootPath, fileName), "a")
    if file  then
        io.write(file, formatedDate)
        for row, score in ipairs(scores) do
            local landingScore = 0
            if landings[row] then landingScore = 10 end
            io.write(file, delimeter, score, delimeter, landingScore)
        end
        io.write(file, delimeter, getTotalScore(), "\n")
        io.close(file)
    end
end
local function advanceToNextTask()
    if currentTask == #scores then
        currentFlightState = F_STATE_FLIGHT_ENDED
    else
        currentTask = currentTask + 1
    end
end
function announce(secondsLeft)
    for _, announcement in pairs(announcements) do
        if announcement == secondsLeft then
            playNumber(secondsLeft, 0)
        end
    end
end

-- ********** Screens ************
timerScreen = function(e)

    lcd.clear()
    drawTitleRows()
    drawTask(taskList[currentTask])
    drawCurrentTime(currentTime)    
    drawScores()

    if e == EVT_MENU_BREAK then
        yesHiglighted = false
        currentScreen = gotoNextTask
    end
    local val = getValue(launchSwitch)
    if val > 0 and currentFlightState == F_STATE_ON_THE_GROUND then
        currentFlightState = F_STATE_LAUNCH_INITIATED
    end
    if (val < 0) and (currentFlightState == F_STATE_LAUNCH_INITIATED) then
        startTimer()
        currentFlightState = F_STATE_IN_THE_AIR
    end
    if val > 0 and currentFlightState == F_STATE_IN_THE_AIR then
        endFlight()
    end
end

askForLandingPoints = function(e)
    lcd.clear()
    lcd.drawText(20,20,"Landningspoang?")
    local flag = 0
    if yesHiglighted then
        flag = INVERS
    end
    lcd.drawText(20,40,"Ja",flag)
    flag = 0
    if not yesHiglighted then
        flag = INVERS
    end
    lcd.drawText(40,40,"Nej", flag)
    if e == EVT_PLUS_BREAK or e == EVT_MINUS_BREAK then
        yesHiglighted = not yesHiglighted
    end
    if e == EVT_ENTER_BREAK then
        landings[currentTask] = yesHiglighted
        if currentTask == #scores then
            currentFlightState = F_STATE_FLIGHT_ENDED
            persistScores()
        else
            advanceToNextTask()
            currentTime = targetTimes[currentTask]
        end

        currentScreen = timerScreen
    end
end

gotoNextTask = function(e)
    lcd.clear()
    local title = ""
    if currentFlightState == F_STATE_FLIGHT_ENDED then
        title = "Starta nasta omgang?"
    else
        title = "Starta nasta flygning?"
    end
    lcd.drawText(20,20,title)
    local flag = 0
    if yesHiglighted then
        flag = INVERS
    end
    lcd.drawText(20,40,"Ja",flag)
    flag = 0
    if not yesHiglighted then
        flag = INVERS
    end
    lcd.drawText(40,40,"Nej", flag)
    if e == EVT_PLUS_BREAK or e == EVT_MINUS_BREAK then
        yesHiglighted = not yesHiglighted
    end
    if e == EVT_ENTER_BREAK then
        if yesHiglighted then
            if currentFlightState == F_STATE_FLIGHT_ENDED then
                currentTask = 1
                scores = {0, 0, 0, 0, 0}
                landings = { false, false, false, false, false }
                currentFlightState = F_STATE_ON_THE_GROUND
                currentTime = targetTimes[currentTask]
            else
                advanceToNextTask()
            end
        end

        currentScreen = timerScreen
    end
end
-- ********** END Screens ************


local function init()
    currentTime = targetTimes[currentTask]
    currentScreen = timerScreen
    currentFlightState = F_STATE_ON_THE_GROUND
end

local function background()
    if currentFlightState == F_STATE_IN_THE_AIR then
        local now = getTime()
        local elapsed = math.floor((now - startTime) / 100 )
        local tempCurrent = targetTimes[currentTask] - elapsed
        if tempCurrent ~= currentTime then
            currentTime = tempCurrent
            screenDirty = true
            announce(currentTime)
            if currentTime == 0 then
                endFlight()
            end
        end
    end
end

local function run(e)
    currentScreen(e)
end

return {run=run, background=background, init=init }