---@class CH.Point
---@field pos string
---@field x number
---@field y number

---@class CH.CustomFontConstructorOptions
---@field parent BackdropTemplate|Frame
---@field text string
---@field point CH.Point


---@class CH.CustomFrameConstructorOptions
---@field frameName string
---@field parent BackdropTemplate|Frame
---@field width number
---@field height number
---@field point CH.Point
---@field titleBuilder? CH.CustomFrameconstructorTitle

---@class CH.CustomFrameconstructorTitle
---@field text string
---@field point CH.Point

---@class CH.CustomButtonConstructorOptions
---@field buttonName string
---@field parent BackdropTemplate|Frame
---@field width number
---@field height number
---@field text string
---@field point CH.Point
---@field onClickScript? function

---@class CH.ItemDetails
---@field itemId number
---@field name string
---@field link string
---@field itemType string
---@field itemEquipLoc string
---@field bindType number


---@class CH.Btn
---@field Hide? function
---@field Show? function