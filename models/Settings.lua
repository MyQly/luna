local Model = require("lapis.db.model").Model

return Model:extend("settings", {
   primary_key = "name"
})