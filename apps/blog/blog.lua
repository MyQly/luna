local Articles = require("models.Articles")
local Settings = require("models.Settings")

return function(app)
  app:get("home", "/", function(self)
    self.github = Settings:find( "github" ).value
    self.itchio = Settings:find( "itchio" ).value
    self.twitter = Settings:find( "twitter" ).value
    self.title = Settings:find("title").value
    self.articles = Articles:select("WHERE published = 'true' ORDER BY date desc LIMIT 10") 
    return { render = "index" }
  end)
  
  app:get("/article/:article_id", function(self)
    local article = Articles:find(self.params.article_id)
    if article == nil then
      return { render = "notfound" }
    else
      self.article = article
      self.title = Settings:find("title").value.." - "..article.title
      return { render = "article" }
    end
  end)
end
