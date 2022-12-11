local config = require("lapis.config")

config("development", {
  port = 8080,
  postgres = {
    host = "127.0.0.1",
    user = "luna_user",
    password = "@luna-Avenger.4",
    database = "luna"
  },
  filestore = "files/"
})

config("production", {
  port = 80,
  num_workers = 4,
  code_cache = "on"
})
