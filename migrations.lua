local schema = require("lapis.db.schema")
local db = require("lapis.db")
local types = schema.types

return {
  [1] = function()
    schema.create_table("articles", {
      { "id", types.serial },
      { "title", types.text },
      { "content", types.text },
      { "date", types.date },

      "PRIMARY KEY (id)"
    })
  end;
  [2] = function()
    schema.create_table("authors", {
      { "id", types.serial },
      { "name", types.text },
      { "email", types.text },
      { "password", types.text },

      "PRIMARY KEY (id)"
    })

    schema.add_column("articles", "author_id", types.foreign_key)
    db.query("ALTER TABLE articles ADD CONSTRAINT author_fk FOREIGN KEY (author_id) REFERENCES authors (id)")
  end;
  [3] = function ()
    db.insert("authors", {name = "luna_user", email = "luna_user@luna_blog", password = "luna"})
  end;
  [4] = function ()
    schema.create_table("categories", {
      { "id", types.serial },
      { "name", types.text },
      { "slug", types.text },
      
      "PRIMARY KEY (id)"
    })
  end;
  [5] = function ()
    schema.create_table("tags", {
      { "id", types.serial },
      { "name", types.text },
      { "slug", types.text },
      
      "PRIMARY KEY (id)"
    })
  end;
  [6] = function ()
    schema.add_column("articles", "slug", types.text)
    schema.add_column("articles", "published", types.boolean)
    schema.add_column("articles", "category_id", types.foreign_key)
    db.query("ALTER TABLE articles ADD CONSTRAINT category_fk FOREIGN KEY (category_id) REFERENCES categories (id)")
  end;
  [7] = function ()
    schema.create_table("article_tags", {
      { "article_id", types.foreign_key },
      { "tag_id", types.foreign_key }
    })
  end
}
