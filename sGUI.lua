local term = require("term")
local component = require("component")
local text = require("text")
local gpu = component.gpu

sgui = {}

sgui.colors = {}

sgui.colors.blue = 0x006DC0
sgui.colors.white = 0xFFFFFF
sgui.colors.black = 0x000000
sgui.colors.darkGray = 0x5A5A5A
sgui.colors.gray = 0xE1E1E1
sgui.colors.lightGray = 0xF0F0F0
sgui.colors.green = 0x00B640

function sgui.lwrite(x, y, maxLineLength, str, lineOffset, lineLimit)
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

function sgui.middleCoords(x, y, w, h, length, line)
    length = length or 0
    line = line or 0
    local rx = math.floor(x + x + w - (length/2))
    local ry = math.floor(y + y + h - (line/2))
    return x, y
end

function sgui.addButton(x, y, w, h, txt, func, fcolor, bcolor)
    fcolor = fcolor or sgui.colors.black
    bcolor = bcolor or sgui.colors.white
    
    button = {properties={x, y, w, h, txt, func, fcolor, bcolor}}
    
    function button.draw()
        gpu.setBackground(button.properties[8])
        gpu.setForeground(button.properties[7])
        gpu.fill(button.properties[1], button.properties[2], button.properties[3], button.properties[4], " ")
        local x, y = sgui.middleCoords(button.properties[1], button.properties[2], button.properties[3], button.properties[4], button.properties[5]:len())
        gpu.set(x, y, button.properties[5])
    end
    
    function button.update()
        while true do
            local evs = {term.pull("touch")}
            if evs[3] >= button.properties[1] and evs[3] <= button.properties[1] + button.properties[3] and evs[4] >= button.properties[2] and evs[3] <= button.properties[2] + button.properties[3] then
                button.properties[6]()
                break
            end
        end
    end
    
    return button
end

function updateButtons(bList)
    while true do
        local evs = {term.pull("touch")}
        for k, button in pairs(bList) do
            if evs[3] >= button.properties[1] and evs[3] <= button.properties[1] + button.properties[3] and evs[4] >= button.properties[2] and evs[3] <= button.properties[2] + button.properties[3] then
                button.properties[6]()
                break
            end
        end
    end
end

function sgui.drawProgressBar(x, y, w, value, maxValue, color)
    local nb = math.ceil((value/maxValue) * w)
    
    gpu.setBackground(sgui.colors.white)
    gpu.setForeground(sgui.colors.black)
    gpu.set(x + math.floor(w/2) - 2, y - 1, math.ceil((value/maxValue) * 100).."%")
    
    gpu.setBackground(gray)
    gpu.fill(x, y, w, 1, " ")
    gpu.setBackground(color)
    gpu.fill(x, y, nb, 1, " ")
end

function sgui.drawWindow(w, h, title, fcolor, bcolor, bbcolor, barSize)
    
    cw, ch = gpu.getResolution()
    local x = 1
    local y = 1
    
    if cw > w then
        x = math.floor((cw - w)/2)
    end
    
    if ch > h then
        y = math.floor((ch - h)/2)
    end
    
    fcolor = fcolor or sgui.colors.white
    bcolor = bcolor or sgui.colors.white
    bbcolor = fcolor or sgui.colors.blue
    
    barSize = barSize or 1
    
    gpu.setBackground(bbcolor)
    gpu.setForeground(fcolor)
    gpu.fill(x, y, w, h, " ")
    
    setBackground(bbcolor)
    gpu.fill(x, y, w, barSize)
    gpu.set(middleCoords(x, y, w, barSize, title:len()), title)
end

return sgui