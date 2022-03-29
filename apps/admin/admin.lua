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
local respond_to = require("lapis.application").respond_to

local app_Articles = require("apps.admin.articles")
local app_Categories = require("apps.admin.categories")
local app_Tags = require("apps.admin.tags")

return function(app)

  app:get("get_category", "/admin/category/:category", function(self)
  end)


  app:get("get_tag", "/admin/tag/:tag", function(self)
  end)

  app:get("get_article", "/admin/article/:article", function(self)
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
      self.article_tags = db.query("SELECT * FROM tags WHERE id IN (SELECT tag_id FROM Article_Tags WHERE Article_Id = ?)", self.article.id)
      --self.article_category = db.query("SELECT name FROM categories WHERE id = ?", self.article.category_id)
    end

    self.tags = Tags:select({ "name" })
    self.categories = Categories:select({ "id", "name" })

    return { render = "admin.article", layout = "admin.layout" }
  end)

  app:post("update_article", "/admin/article/:article", function(self)
    if not self.session.current_author then
      return { status = 401 }
    end

    local article
    local category = ''

    category_id = self.params.category or 'Uncategorized'

    category = Categories:find({id = category_id})

    --[[if category == nil then
      local newCategory = db.insert("categories", {name = category_name, slug = slugify(category_name)})
      category = Categories:find({name = category_name})
    end]]--

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

  app:get("/admin/:tab", function(self)
    return {redirect_to = self:url_for("dashboard")}
  end)

  app:match("manage_app", "/admin/manage/:tab", function(self)
      local tab = self.params.tab or "articles"
      self.tab = tab

      self.Articles = Articles
      self.Categories = Categories
      self.Tags = Tags

      if tab == "articles" then
        self.articles = Articles:select()
        return { render = "admin.manage.articles", layout = "admin.layout" }
      elseif tab == "categories" then
        self.categories = Categories:select()
        return { render = "admin.manage.categories", layout = "admin.layout" }
      elseif tab == "tags" then
        self.tags = Tags:select()
        return { render = "admin.manage.tags", layout = "admin.layout" }
      elseif tab == "authors" then
        self.authors = Authors:select()
        return { render = "admin.manage.authors", layout = "admin.layout" }
      elseif tab == "depot" then
        return { render = "admin.manage.depot", layout = "admin.layout" }
      end

      return { render = "notfound", layout = "admin.layout" }
  end)

  app:match("dashboard", "/admin/dashboard", respond_to({
    before = function(self)
      if not self.session.current_author then
        self.errors = self.params.error == "true"
        self:write({ redirect_to = self:url_for("login") })
      else
        self.current_author = self.session.current_author
      end        
    end,
    GET = function(self)
      return { render = "admin.dashboard", layout = "admin.layout" }
    end
  }))

  app:get("/admin", function(self)
    return {redirect_to = self:url_for("dashboard")}
  end)

end