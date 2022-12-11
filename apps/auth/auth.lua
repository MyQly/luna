local md5 = require("md5")
local db = require("lapis.db")
local app = require("lapis.application")
local Authors = require("models.Authors")

local respond_to = app.respond_to


local validate = require("lapis.validate")

-- Replace with Luna settings option instead of hardcoded check. I'm not sure why one would want to enable open registration for a blog though.
local registrationEnabled = true
local capture_errors, assert_error = app.capture_errors, app.assert_error

return function(app)

  app:match("login", "/login"	, respond_to({
  		
  	GET = function(self)
			  if not self.session.current_author then
			    self.errors = self.params.error == "true"
			    return {render = "auth.login", layout = "auth.layout"}
			  else
			  	self.current_author = self.session.current_author
			  	return { redirect_to = self:url_for("dashboard") }
		  	end
  	end,

  	POST = function(self)
	    local password = md5.sumhexa(self.params.password)
	    local email = self.params.email

	    local author = Authors:find({ email = email, password = password})

	    if not author then
	      return { redirect_to = "/login?error=true" }
	    else
	      self.session.current_author = { id = author.id, name = author.name, email = author.email }
	      return { redirect_to = self:url_for("dashboard") }
	    end
  	end
  }))

  app:match("logout", "/logout",
  	respond_to({
  		GET = function(self)
				self.session.current_author = nil
  			self:write({ redirect_to = self:url_for("home") })
  		end
  	})
  )  

  app:match("register", "/register",
  	respond_to({
	  	before = function(self)
			--[[ Check if registration is allowed and the user is already logged in.
				If either of these are true, redirect the request to the homepage.
			-- ]]
	  		if not registrationEnabled or self.session.current_author then
	  			self:write({ redirect_to = self:url_for("home") })
	  		end
	  	end,

	  	GET = function(self)
	  		return { render = "auth.register", layout = "auth.layout" }
	  	end,

	  	POST = capture_errors({
			  on_error = function(self)
			    return { render = "auth.register", layout = "auth.layout" }
			  end,
			  function(self)
			    validate.assert_valid(self.params, {
					{ "username", exists = true, min_length = 5},
			      	{ "email", exists = true, min_length = 3 },
			      	{ "password", exists = true, min_length = 2 }
			    })

			    local user = assert_error(Authors:find({email = "self.params.email" }) or Authors:find({name = "self.params.username"}), "Invalid username or email address.")

				user = Authors:create({
		        name = self.params.username;
		        email = self.params.email;
		        password = md5.sumhexa(self.params.password);
		      })

				self.session.current_author = { id = user.id, name = user.name, email = user.email }
			    return { redirect_to = "/admin" }
			  end
			})
		}))
end