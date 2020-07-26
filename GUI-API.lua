local term = require("term")
local component = require("component")
local text = require("text")
local gpu = component.gpu

local blue = 0x006DC0
local white = 0xFFFFFF
local black = 0x000000
local darkGray = 0x5A5A5A
local gray = 0xE1E1E1
local lightGray = 0xF0F0F0
local green = 0x00B640

local buttonList = {}

function lwrite(x, y, maxLineLength, str, lineOffset, lineLimit)
    lineOffset = lineOffset or 0
    strs = text.tokenize(str)
    local txt = ""
    local dy = 0
    for k, v in pairs(strs) do
        local otxt = txt
        txt = txt..v.." "
        if lineLimit ~= nil then
            if dy >= lineLimit then
                return dy +1
            end
        end
        if txt:len() >= maxLineLength or string.find(txt, "\n") ~= nil then
            txt = string.gsub(txt, "\n", "")
            if lineOffset <= 0 then
                gpu.set(x, y+dy, otxt)
                dy = dy + 1
                txt = v.." "
            else
                lineOffset = lineOffset - 1
                txt = v.." "
            end
        end
    end
    gpu.set(x, y+dy, txt)
    return x+dy+1
end

function middleCoords(x, y, w, h, length, line)
    length = length or 0
    line = line or 0
    local rx = math.floor(x + x + dx - (length/2))
    local ry = math.floor(y + y + dy - (line/2))
    return x, y
end

function resetButtons()
    buttonsListv= {}
end

function addButtons(x, y, w, h, txt, func, fcolor, bcolor)
    fcolor = fcolor or black
    bcolor = bcolor or white
    table.insert(buttonList, {x, y, w, h, txt, func, fcolor, bcolor})
end

function drawButtons()
    for k, button in ipairs(buttonList) do
        gpu.setBackground(button[8])
        gpu.setForeground(button[7])
        gpu.fill(button[1], button[2], button[3], button[4], " ")
        gpu.set(button[1], button[2], button[5])
    end
end

function updateButtons()
    while true do
        local evs = {term.pull("touch")}
        for k, button in pairs(buttonList) do
            if evs[3] >= button[1] and evs[3] <= button[1] + button[3] and evs[4] >= button[2] and evs[3] <= button[2] + button[3] then
                button[6]()
                break
            end
        end
    end
end

function drawProgressBar(x, y, w, value, maxValue, color)
    local nb = math.ceil((value/maxValue) * w)
    
    gpu.setBackground(white)
    gpu.setForeground(black)
    gpu.set(x + math.floor(w/2) - 2, y - 1, math.ceil((value/maxValue) * 100).."%")
    
    gpu.setBackground(gray)
    gpu.fill(x, y, w, 1, " ")
    gpu.setBackground(color)
    gpu.fill(x, y, nb, 1, " ")
end

function drawWindow(w, h, title, fcolor, bcolor, bbcolor, barSize)
    
    cw, ch = gpu.getResolution()
    local x = 1
    local y = 1
    
    if cw > w then
        x = math.floor((cw - w)/2)
    end
    
    if ch > h then
        y = math.floor((ch - h)/2)
    end
    
    fcolor = fcolor or white
    bcolor = bcolor or white
    bbcolor = fcolor or blue
    
    barSize = barSize or 1
    
    gpu.setBackground(bbcolor)
    gpu.setForeground(fcolor)
    gpu.fill(x, y, w, h, " ")
    
    setBackground(bbcolor)
    gpu.fill(x, y, w, barSize)
    gpu.set(middleCoords(x, y, w, barSize, title:len()), title)
end