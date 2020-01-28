-- Carlo Mehegam
-- Jan. 27, 2020
-- This program is a calculator used to approximate the area under a line using rectangles.
-- Is LOVE2D the best medium for this? No, but it works.

local suit = require 'suit'
local utf8 = require 'utf8'

function love.load()
  love.window.setMode(400, 400, {resizable = true})
  love.graphics.setDefaultFilter('nearest', 'nearest') -- makes images not blurry
  love.window.setTitle("Area under curve estimation") -- window title
  -- final answers
  rightanswer = 0
  leftanswer = 0
  midanswer = 0
  -- SUIT UI elements
  inputa = {text = ""}
  inputb = {text = ""}
  inputN = {text = ""}
  slider = {value = 10, min = 2, max = 1000}
  -- variables for manipulating f(x)
  -- coefficeients for x^0, x^1, x^2, etc
  x0 = {text = "0"}
  x1 = {text = "0"}
  x2 = {text = "0"}
  x3 = {text = "0"}
  x4 = {text = "0"}
end

function love.update(dt)
  -- text inputs for the expression coefficients
  -- the x positions were found with just trial and error to find a place where they look nice
  suit.Input(x4,60,17,16,20)
  validate(x4)
  suit.Input(x3,124,17,16,20)
  validate(x3)
  suit.Input(x2,187,17,16,20)
  validate(x2)
  suit.Input(x1,250,17,16,20)
  validate(x1)
  suit.Input(x0,295,17,16,20)
  validate(x0)
  
  -- buffer to move everything down so f(x) expression can be at the top
  buffer = 40
  -- place textboxes
  suit.Input(inputa, 20,40+buffer,200,30)
  validate(inputa)
  suit.Input(inputb, 20,100+buffer,200,30)
  validate(inputb)
  suit.Input(inputN, 20,190+buffer,200,30)
  validate(inputN)
  -- place slider and update inputN with slider
  -- compare to last slider value to check if it is changing before setting it
  suit.Slider(slider, 20,160+buffer, 200,20)
  if lastSliderValue ~= slider.value then
    inputN = {text = "" .. math.ceil(slider.value)}
  end
  lastSliderValue = slider.value
  -- finally, letting the user press the button once all fields are valid.
  local newa, newb, newN = tonumber(inputa.text), tonumber(inputb.text), tonumber(inputN.text)
  if newa and newb and newN then
    if newN <= 10000000 then
      if suit.Button("Do the math", 20,250+buffer,200,30).hit then doTheMath(newa,newb,newN) end
    end
  end
end

function love.draw()
  love.graphics.print("f(x) =      x^4 +      x^3 +      x^2 +      x +", 20, 20)
  love.graphics.print("interval start (a)", 20, 20+buffer)
  love.graphics.print("interval end (b)", 20, 80+buffer)
  love.graphics.print("# of squares (N)", 20, 140+buffer)
  love.graphics.print("right: " .. rightanswer .. "\nleft: " .. leftanswer .. "\nmiddle: " .. midanswer, 20, 300+buffer)
  --warning message if N is greater then 10mil. just because it slows down after this point.
  if tonumber(inputN.text) then 
      if tonumber(inputN.text) > 10000000 then 
      love.graphics.print("too big! N must be less than 10 million.", 20,250+buffer) 
    end 
  end
  suit.draw()
end


-- validate used to make sure that keys entered into inputs are numbers
function validate(input)
  local len = utf8.len(input.text)
  input.text = input.text:gsub("[^0-9]", "") --only 0-9
  input.cursor = input.cursor - (len - utf8.len(input.text)) --keep cursor from moving
end

function love.keypressed(key, scancode, isrepeat)
  if key == "escape" then
    love.event.quit()
  end
  suit.keypressed(key) --passes pressed key into SUIT, for typing
end

function love.textinput(t) --not sure what this does. some SUIT thing
  suit.textinput(t)
end


--the math!!!

-- the function the calculation is based off of
-- this is the line whose area we're finding
-- area referring to the area between the line and the x axis
-- the user changes the coefficients to get the expression they need
-- this is the smartest way i know to do this, but it is still very limited.
function f(x)
  return tonumber(x4.text)*x*x*x*x + tonumber(x3.text)*x*x*x + tonumber(x2.text)*x*x + tonumber(x1.text)*x + tonumber(x0.text)
end

-- calculating the approximate are with three different methods
-- right-endpoint approximation
-- left-endpoint approximation
-- midpoint approximation
function doTheMath(inputa,inputb,inputn)
  --interval
  a = inputa
  b = inputb
  --num of squares
  n = inputn

  --change in x
  dx = (b-a)/n

  --MIDDLE ENDPOINT ==================
      --adding together y's
      sum = 0
      for i=1,n do
        local temp = a + (i - .5)* dx
        sum = sum + f(temp)
      end
      --y's * x = rectangles
      midanswer = (b-a)/n * (sum)
  --RIGHT ENDPOINT ==================
      sum = 0
      for i=1,n do
        local temp = a + i * dx
        sum = sum + f(temp)
      end
      rightanswer = (b-a)/n * (sum)
  --LEFT ENDPOINT ==================
      sum = 0
      for i=1,n do
        local temp = a + (i - 1)* dx
        sum = sum + f(temp)
      end
      leftanswer = (b-a)/n * (sum)
end