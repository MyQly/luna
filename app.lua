local blog = require("apps/blog/blog")
local auth = require("apps/auth/auth")
local admin = require("apps/admin/admin")
local depot = require("apps/depot/depot")

local lapis = require("lapis")

local app = lapis.Application()
app:enable("etlua")
app.layout = require "views.layout"

-- Init Blog Routes
blog(app)
-- Init Admin Routes
admin(app)
-- Init Auth Routes
auth(app)
-- Init Depot Routes
depot(app)

return app