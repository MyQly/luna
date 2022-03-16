local Model = require("lapis.db.model").Model

return Model:extend("tags", {
  relations = {
    { "article", has_many = "ArticleTags" }
  }
})
