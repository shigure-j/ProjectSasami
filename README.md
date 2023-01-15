# README

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version

Ruby 3.1.3

* System dependencies

* Configuration

Edit `config/application.rb`, and add server ip to `config.hosts`

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

If internet avalible :
```
bin/setup
bin/rails server -e production -b server_ip -p server_port
```
Else, use `--local` option to setup with existed cached gem package and compiled asstes:
```
bin/setup --local
bin/rails server -e production -b server_ip -p server_port
```
Prepared `vendor/cache` and `public/assets` are packaged in release files.
