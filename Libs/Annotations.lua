---@class App.Point
---@field pos string
---@field x number
---@field y number

---@class App.FontBuilder
---@field parent BackdropTemplate|Frame
---@field text string
---@field point App.Point

---@class App.FrameBuilder
---@field frameName string
---@field parent BackdropTemplate|Frame
---@field width number
---@field height number
---@field point App.Point
---@field titleBuilder? App.FrameTitle

---@class App.FrameTitle
---@field text string
---@field point App.Point

---@class App.ButtonBuilder
---@field buttonName string
---@field parent BackdropTemplate|Frame
---@field width number
---@field height number
---@field text string
---@field point App.Point
---@field onClickScript? function


---@class App.ItemDetails
---@field itemId number
---@field name string
---@field link string
---@field itemType string
---@field itemEquipLoc string
---@field bindType number


---@class App.CustomScrollBuilder
---@field parent BackdropTemplate|Frame
---@field width number
---@field height number
---@field point App.Point

---@class App.Btn
---@field Hide? function
---@field Show? function