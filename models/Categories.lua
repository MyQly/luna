local Model = require("lapis.db.model").Model

return Model:extend("categories", {
  relations = {
    { "articles", has_many = "Articles" }
  }
})
