# Luna Blog

Stupid simple blog engine written in Lua using the lapis framework

## Installation

Lapis, OpenResty and PostgreSQL are assumed to be installed.

### Create Database

1. Login as postgres. (su postgres)
2. Run psql.
3. Create user (luna_user).
   * CREATE USER luna_user WITH PASSWORD 'luna_user';
4. Create database (luna_blog).
   * CREATE DATABASE luna_blog OWNER luna_user;
5. Review migrations.lua and update the username/password combination.
6. Run lapis migrate.
7. Install luaossl.
   * sudo luarocks install md5
8. Start luna_blog.
   * sudo lapis server

