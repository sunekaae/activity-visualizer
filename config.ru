require './web.rb'
require 'resque/server'

run Rack::URLMap.new \
  "/"       => Sinatra::Application,
  # TODO: this is likely unnecessary in production.
  # or, at the least, should be protected behind some auth
  "/resque" => Resque::Server.new
