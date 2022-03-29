local lfs = require("lfs")
local respond_to = require("lapis.application").respond_to

return function(app)

  app:match("upload", "/admin/depot/upload", respond_to({
    before = function(self)
      if not self.session.current_author then
        self.errors = self.params.error == "true"
        self:write({ redirect_to = self:url_for("login") })
      else
        self.current_author = self.session.current_author
      end        
    end,
    GET = function(self)
      for file in lfs.dir ("/var/luna") do
        return lfs.attributes("/var/luna/"..file).mode
      end
    end,
    POST = function(self)
    end
  }))

end