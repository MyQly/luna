local blog = require("apps/blog/blog")
local auth = require("apps/auth/auth")
local admin = require("apps/admin/admin")

local lapis = require("lapis")

local app = lapis.Application()
app:enable("etlua")
app.layout = require "views.layout"

-- Init Blog routes
blog(app)
-- Init Admin routes
admin(app)
-- Init Auth Routes
auth(app)



return app