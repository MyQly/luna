local Model = require("lapis.db.model").Model

return Model:extend("article_tags", {
  relations = {
    { "article", belongs_to = "Articles" },
    { "tag", belongs_to = "Tags" }
  }
})
