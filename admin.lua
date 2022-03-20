local Authors = require("models.Authors")
local Articles = require("models.Articles")
local Categories = require("models.Categories")
local ArticleTags = require("models.ArticleTags")
local Tags = require("models.Tags")

local md5 = require("md5")

local util = require("lapis.util")
local slugify = util.slugify
local trim = util.trim

local db = require("lapis.db")

return function(app)

  local home = function(self)
    if not self.session.current_author then
      self.errors = self.params.error == "true"
      return { render = "admin.login", layout = "admin.layout" }
    else
      self.current_author = self.session.current_author

      local tab = self.params.tab or "articles"
      self.tab = tab

      self.Articles = Articles

      if tab == "articles" then
        self.articles = Articles:select()
      elseif tab == "categories" then
        self.categories = Categories:select()
      elseif tab == "tags" then
        self.tags = Tags:select()
      elseif tab == "authors" then
        self.authors = Authors:select()
      end

      return { render = "admin.home", layout = "admin.layout" }
    end
  end

  app:get("dashboard", "/dashboard", home)

  app:get("/admin/:tab", home)

  app:get("login", "/login", function(self)
    return { render = "admin.login", layout = "admin.layout" }
  end)

  app:post("login", "/login", function(self)
    local password = md5.sumhexa(self.params.password)
    local email = self.params.email

    local author = Authors:find({ email = email, password = password})

    if not author then
      return { redirect_to = "/login?error=true" }
    else
      self.session.current_author = { id = author.id, name = author.name, email = author.email }
      return { redirect_to = self:url_for("dashboard") }
    end
  end)

  app:get("/admin", function(self)
    return {redirect_to = "/dashboard"}
  end)

  app:get("logout", "/logout", function(self)
    self.session.current_author = nil
    return { redirect_to = "/" }
  end)

  app:get("/admin/article/:article", function(self)
    if not self.session.current_author then
      return { redirect_to = "/admin" }
    end

    if self.params.article == "new" then
      self.article = {
        id = "new",
        title = "",
        content = ""
      }
    else
      self.article = Articles:find(self.params.article)
      self.article_tags = db.query("SELECT name FROM tags WHERE id IN (SELECT tag_id FROM Article_Tags WHERE Article_Id = ?)", self.article.id)
      self.article_category = db.query("SELECT name FROM categories WHERE id = ?", self.article.category_id)
    end

    self.tags = Tags:select({fields = "name"})
    local allTags = ''
    for k,tag in pairs(self.tags) do
      allTags = allTags..'"'..tag.name..'", '
    end
    allTags = string.sub(allTags, 1, -2)
    self.allTagList = allTags

    self.categories = Categories:select({ "name" })
    local allCategories = ''
    for k,category in pairs(self.categories) do
      allCategories = allCategories..'"'..category.name..'", '
    end
    allCategories = string.sub(allCategories, 1, -2)
    self.allCategoryList = allCategories

    return { render = "admin.article", layout = "admin.layout" }
  end)

  app:post("/admin/article/:article", function(self)
    if not self.session.current_author then
      return { status = 401 }
    end

    local article
    local extractedCategory = ''
    local category = ''

    if self.params.category == nil then
      extractedCategory = 'Uncategorized'
    else
      extractedCategory = string.sub(self.params.category,12,-4)
    end

    category = Categories:find({name = extractedCategory})

    if category == nil then
      local newCategory = db.insert("categories", {name = extractedCategory, slug = slugify(extractedCategory)})
      category = Categories:find({name = extractedCategory})
    end

    if self.params.article == "new" then
      article = Articles:create({
        title = self.params.title;
        content = self.params.content;
        date = db.format_date();
        author_id = self.session.current_author.id;
        slug = slugify(self.params.title);
        published = self.params.publish;
        category_id = category.id;
      })
    else
      article = Articles:find(self.params.article)
      article:update({
        title = self.params.title;
        content = self.params.content;
        category_id = category.id;
        published = self.params.publish;
        slug = slugify(self.params.title);
      })
    end
    return { redirect_to = "/admin/article/" .. article.id }
  end)

end
