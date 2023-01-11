# README

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version
Ruby 3.1.3

* System dependencies

* Configuration
Edit `config/application.rb`, and add server ip to `config.hosts`
Set env :
```
setenv RAILS_ENV production
setenv EDITOR "mate --wait"
```

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions
If internet avalible :
```
bundle config set --local path 'vendor/bundle'
bin/bundle install
bin/rails credentials:edit
bin/rails sasami:init
bin/rails server -b server_ip -p server_port
```
Else, you can run command below to package required file from a deploied environment :
```
tar -czvf dep_pack.tar.gz ./vendor/cache/ public/assets/
```
And then, release the package in the offline environment :
```
tar -xzvf package.tar.gz
bundle config set --local path 'vendor/bundle'
bin/bundle -l install
bin/rails credentials:edit
bin/rails sasami:init_local
bin/rails server -b server_ip -p server_port
```

* ...
