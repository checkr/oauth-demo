require 'sinatra'
require 'tilt/erb'

get '/' do
  erb :index
end
