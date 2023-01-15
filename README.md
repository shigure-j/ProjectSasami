# README
ProjectSasami is a simple rails web application to collect and show metrics in IC backend projects.

### Ruby version
Ruby 3.1.3

### Configuration
Edit `config/application.rb`, and add server ip to `config.hosts`

### Setup
If internet avalible :
```
bin/setup
```
Else, use `--local` option to setup with existed gem cache and compiled asstes:
```
bin/setup --local
```
Prepared `vendor/cache` and `public/assets` are packaged in release files.

### Deploy
```
bin/rails server -e production -b server_ip [-p server_port] [-d]
```
Rails default port is `:3000` if `server_port` not given,
option `-d` will runs server as a Daemon, and the pid will stored in `tmp/pids/server.pid`
