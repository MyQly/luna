# luna

A blog engine written in [Lua](https://www.lua.org/) and powered by [Lapis](https://leafo.net/lapis/), [Fomantic-UI](https://fomantic-ui.com) & [Trumbowyg](https://alex-d.github.io/Trumbowyg/). 

## Installation

Lapis, OpenResty and PostgreSQL are assumed to be installed.

### Create Database

1. Login as postgres. (su postgres)
2. Run psql.
3. Create user (luna_user).
   * CREATE USER luna_user WITH PASSWORD 'luna_user';
4. Create database (luna_blog).
   * CREATE DATABASE luna_blog OWNER luna_user;


### Application Setup
1. Review migrations.lua and update the username/password combination.
2. Run lapis migrate.
3. Install md5.
   * sudo luarocks install md5
4. Start luna_blog.
   * sudo lapis server

