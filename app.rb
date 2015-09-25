require 'sinatra'
require 'tilt/erb'

CHECKR_CLIENT_ID     = 'XX'
CHECKR_CLIENT_SECRET = 'XX'
CHECKR_REDIRECT_URL  = 'http://localhost:9292/oauth/callback'
CHECKR_AUTHORIZE_URL = 'https://dashboard.checkr.com/oauth/authorize'

get '/' do
  erb :index, layout: :layout
end

get '/oauth_callback' do
  erb :oauth_callback, layout: :layout
end
