require 'sinatra'
require 'tilt/erb'

CHECKR_CLIENT_ID      = 'XX'
CHECKR_CLIENT_SECRET  = 'XX'
CHECKR_REDIRECT_URL   = 'http://localhost:9292/oauth/callback'
CHECKR_AUTHORIZE_URL  = 'https://dashboard.checkr.com/oauth/authorize'
CHECKR_TOKENS_URL     = 'https://api.checkr.com/oauth/tokens'
CHECKR_CANDIDATES_URL = 'https://api.checkr.com/v1/candidates'

get '/' do
  erb :index, layout: :layout
end

get '/oauth_callback' do
  code = params[:code]
  response = HTTParty.post(CHECKR_TOKENS_URL, body: {
    code: code,
    client_id: CHECKR_CLIENT_ID,
    client_secret: CHECKR_CLIENT_SECRET
  })

  token = response.body['token']

  candidates = HTTParty.get(
    CHECKR_CANDIDATES_URL,
    basic_auth: { username: token, password: nil }
  )

  erb :candidates, layout: :layout, candidates: candidates.body
end
