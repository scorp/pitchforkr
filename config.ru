require 'rubygems'
require 'vendor/sinatra/lib/sinatra'

Sinatra::Application.default_options.merge!(
  :run => false,
  :env => :production
)

require 'web.rb'
run Sinatra.application